// lib/global/service/api_services.dart

import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constant/api_constant.dart';
import '../storage/storage_helper.dart';

class ApiService {
  static bool _isRefreshing = false;

  /// POST Request with auto token refresh
  static Future<dynamic> postRequest(String endpoint,
      {Map<String, dynamic>? body}) async {
    try {
      final token = await StorageHelper.getToken();
      final uri = Uri.parse("${ApiConstants.baseUrl}$endpoint");

      developer.log('📤 POST Request to: $uri', name: 'ApiService');
      developer.log('📦 Body: $body', name: 'ApiService');

      final response = await http.post(
        uri,
        headers: _headers(token),
        body: jsonEncode(body),
      );

      developer.log('📥 Response Status: ${response.statusCode}',
          name: 'ApiService');
      developer.log('📥 Response Body: ${response.body}', name: 'ApiService');

      // Handle 401 Unauthorized - Token expired
      if (response.statusCode == 401 && endpoint != ApiConstants.refresh) {
        developer.log('🔄 Token expired, attempting refresh...',
            name: 'ApiService');
        final refreshed = await _refreshToken();

        if (refreshed) {
          // Retry the request with new token
          return postRequest(endpoint, body: body);
        } else {
          throw Exception("Session expired. Please login again.");
        }
      }

      return processResponse(response);
    } catch (e) {
      developer.log('❌ POST Error: $e', name: 'ApiService');
      throw Exception("POST request error: $e");
    }
  }

  /// GET Request with auto token refresh
  static Future<dynamic> getRequest(String endpoint,
      {Map<String, String>? queryParams}) async {
    try {
      final token = await StorageHelper.getToken();
      final uri = Uri.parse("${ApiConstants.baseUrl}$endpoint")
          .replace(queryParameters: queryParams);

      developer.log('📤 GET Request to: $uri', name: 'ApiService');

      final response = await http.get(uri, headers: _headers(token));

      developer.log('📥 Response Status: ${response.statusCode}',
          name: 'ApiService');
      developer.log('📥 Response Body: ${response.body}', name: 'ApiService');

      // Handle 401 Unauthorized - Token expired
      if (response.statusCode == 401) {
        developer.log('🔄 Token expired, attempting refresh...',
            name: 'ApiService');
        final refreshed = await _refreshToken();

        if (refreshed) {
          // Retry the request with new token
          return getRequest(endpoint, queryParams: queryParams);
        } else {
          throw Exception("Session expired. Please login again.");
        }
      }

      return processResponse(response);
    } catch (e) {
      developer.log('❌ GET Error: $e', name: 'ApiService');
      throw Exception("GET request error: $e");
    }
  }

  /// PATCH Request with auto token refresh
  static Future<dynamic> patchRequest(String endpoint,
      {Map<String, dynamic>? body}) async {
    try {
      final token = await StorageHelper.getToken();
      final uri = Uri.parse("${ApiConstants.baseUrl}$endpoint");

      developer.log('📤 PATCH Request to: $uri', name: 'ApiService');
      developer.log('📦 Body: $body', name: 'ApiService');

      final response = await http.patch(
        uri,
        headers: _headers(token),
        body: jsonEncode(body),
      );

      developer.log('📥 Response Status: ${response.statusCode}',
          name: 'ApiService');
      developer.log('📥 Response Body: ${response.body}', name: 'ApiService');

      // Handle 401 Unauthorized - Token expired
      if (response.statusCode == 401) {
        developer.log('🔄 Token expired, attempting refresh...',
            name: 'ApiService');
        final refreshed = await _refreshToken();

        if (refreshed) {
          // Retry the request with new token
          return patchRequest(endpoint, body: body);
        } else {
          throw Exception("Session expired. Please login again.");
        }
      }

      return processResponse(response);
    } catch (e) {
      developer.log('❌ PATCH Error: $e', name: 'ApiService');
      throw Exception("PATCH request error: $e");
    }
  }

  /// Multipart PATCH Request (for file uploads with PATCH)
  static Future<dynamic> patchMultipartRequest(
    String endpoint, {
    Map<String, String>? fields,
    Map<String, File>? files,
    Map<String, Uint8List>? webFiles,
  }) async {
    try {
      final token = await StorageHelper.getToken();
      final uri = Uri.parse("${ApiConstants.baseUrl}$endpoint");

      developer.log('📤 PATCH Multipart Request to: $uri', name: 'ApiService');

      var request = http.MultipartRequest('PATCH', uri);

      final cleaned = token?.trim() ?? "";
      if (cleaned.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $cleaned';
        developer.log('🔑 Authorization header added', name: 'ApiService');
      }

      if (fields != null && fields.isNotEmpty) {
        request.fields.addAll(fields);
        developer.log('📦 Fields: $fields', name: 'ApiService');
      }

      if (!kIsWeb && files != null && files.isNotEmpty) {
        for (var entry in files.entries) {
          try {
            // Generate unique filename with timestamp
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final extension = entry.value.path.split('.').last;
            final uniqueFilename = 'profile_$timestamp.$extension';
            
            final file = await http.MultipartFile.fromPath(
              entry.key,
              entry.value.path,
              filename: uniqueFilename,
            );
            request.files.add(file);
            developer.log('📎 File attached: ${entry.key} = $uniqueFilename (${file.length} bytes)', 
                name: 'ApiService');
          } catch (e) {
            developer.log('❌ Error attaching file ${entry.key}: $e', 
                name: 'ApiService');
            throw Exception('Failed to attach file: $e');
          }
        }
      }

      if (kIsWeb && webFiles != null && webFiles.isNotEmpty) {
        for (var entry in webFiles.entries) {
          // Generate unique filename with timestamp
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final file = http.MultipartFile.fromBytes(
            entry.key,
            entry.value,
            filename: 'profile_$timestamp.jpg',
          );
          request.files.add(file);
          developer.log('📎 Web file attached: ${entry.key} (${entry.value.length} bytes)', 
              name: 'ApiService');
        }
      }

      developer.log('🚀 Sending multipart request...', name: 'ApiService');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      developer.log('📥 Response Status: ${response.statusCode}',
          name: 'ApiService');
      developer.log('📥 Response Body: ${response.body}', name: 'ApiService');

      return processResponse(response);
    } catch (e) {
      developer.log('❌ Multipart PATCH Error: $e', name: 'ApiService');
      throw Exception("Multipart PATCH request error: $e");
    }
  }

  /// Multipart PUT Request (legacy support)
  static Future<dynamic> putMultipartRequest(
    String endpoint, {
    Map<String, String>? fields,
    Map<String, File>? files,
    Map<String, Uint8List>? webFiles,
  }) async {
    // Use PATCH instead of PUT for consistency
    return patchMultipartRequest(
      endpoint,
      fields: fields,
      files: files,
      webFiles: webFiles,
    );
  }

  /// Headers with Token
  static Map<String, String> _headers(String? token) {
    final cleaned = token?.trim() ?? "";
    final headers = <String, String>{
      "Content-Type": "application/json",
    };

    if (cleaned.isNotEmpty) {
      headers["Authorization"] = "Bearer $cleaned";
    }

    return headers;
  }

  /// Refresh Token Logic
  static Future<bool> _refreshToken() async {
    if (_isRefreshing) {
      developer.log('⏳ Token refresh already in progress', name: 'ApiService');
      return false;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await StorageHelper.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        developer.log('❌ No refresh token available', name: 'ApiService');
        _isRefreshing = false;
        return false;
      }

      developer.log('🔄 Refreshing access token...', name: 'ApiService');

      final uri = Uri.parse("${ApiConstants.baseUrl}${ApiConstants.refresh}");
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Save new tokens
        if (data['accessToken'] != null) {
          await StorageHelper.saveToken(data['accessToken']);
          developer.log('✅ New access token saved', name: 'ApiService');
        }

        if (data['refreshToken'] != null) {
          await StorageHelper.saveRefreshToken(data['refreshToken']);
          developer.log('✅ New refresh token saved', name: 'ApiService');
        }

        _isRefreshing = false;
        return true;
      } else {
        developer.log('❌ Token refresh failed: ${response.statusCode}',
            name: 'ApiService');
        _isRefreshing = false;

        // Clear tokens on refresh failure
        await StorageHelper.clearToken();
        await StorageHelper.clearRefreshToken();

        return false;
      }
    } catch (e) {
      developer.log('❌ Token refresh error: $e', name: 'ApiService');
      _isRefreshing = false;
      return false;
    }
  }

  /// Response Handler
  static dynamic processResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 305) {
      if (response.body.isNotEmpty) {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          developer.log('⚠️ JSON decode error: $e', name: 'ApiService');
          return {"message": response.body};
        }
      } else {
        return {};
      }
    } else {
      developer.log('❌ HTTP Error ${response.statusCode}: ${response.body}',
          name: 'ApiService');
      throw Exception("Error ${response.statusCode}: ${response.body}");
    }
  }
}
