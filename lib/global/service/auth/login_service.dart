// lib/global/service/auth/login_service.dart
import 'dart:developer' as developer;
import '../../constant/api_constant.dart';
import '../../storage/storage_helper.dart';
import '../api_services.dart';

class LoginService {
  /// Login API call
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      developer.log('🔐 Attempting login for: $email', name: 'LoginService');

      final response = await ApiService.postRequest(
        ApiConstants.login,
        body: {
          "email": email,
          "password": password,
        },
      );

      developer.log('✅ Login successful', name: 'LoginService');

      // Extract and save tokens
      if (response != null) {
        // Save access token
        if (response['accessToken'] != null) {
          final token = response['accessToken'];
          if (token != null && token.isNotEmpty) {
            await StorageHelper.saveToken(token);
            developer.log('💾 Access token saved successfully',
                name: 'LoginService');
          }
        }

        // Save refresh token
        if (response['refreshToken'] != null) {
          final refreshToken = response['refreshToken'];
          if (refreshToken != null && refreshToken.isNotEmpty) {
            await StorageHelper.saveRefreshToken(refreshToken);
            developer.log('💾 Refresh token saved successfully',
                name: 'LoginService');
          }
        }
      }

      return {
        'success': true,
        'data': response,
      };
    } catch (e) {
      developer.log('❌ Login failed: $e', name: 'LoginService');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Refresh Access Token using Refresh Token
  static Future<Map<String, dynamic>> refreshAccessToken() async {
    try {
      final refreshToken = await StorageHelper.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        developer.log('❌ No refresh token found', name: 'LoginService');
        return {
          'success': false,
          'error': 'No refresh token available',
        };
      }

      developer.log('🔄 Attempting to refresh access token',
          name: 'LoginService');

      final response = await ApiService.postRequest(
        ApiConstants.refresh,
        body: {
          "refreshToken": refreshToken,
        },
      );

      developer.log('✅ Token refresh successful', name: 'LoginService');

      // Extract and save new tokens
      if (response != null) {
        // Save new access token
        if (response['accessToken'] != null) {
          final token = response['accessToken'];
          if (token != null && token.isNotEmpty) {
            await StorageHelper.saveToken(token);
            developer.log('💾 New access token saved', name: 'LoginService');
          }
        }

        // Save new refresh token
        if (response['refreshToken'] != null) {
          final newRefreshToken = response['refreshToken'];
          if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
            await StorageHelper.saveRefreshToken(newRefreshToken);
            developer.log('💾 New refresh token saved', name: 'LoginService');
          }
        }
      }

      return {
        'success': true,
        'data': response,
      };
    } catch (e) {
      developer.log('❌ Token refresh failed: $e', name: 'LoginService');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Logout
  static Future<void> logout() async {
    await StorageHelper.clearToken();
    await StorageHelper.clearRefreshToken();
    await StorageHelper.clearRememberMe();
    developer.log('👋 User logged out', name: 'LoginService');
  }
}
