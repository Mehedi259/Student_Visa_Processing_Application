// lib/global/storage/message_storage_helper.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/massage/massage_model.dart';

class MessageStorageHelper {
  static const String _messagesKey = "cached_messages";
  static const String _lastFetchKey = "messages_last_fetch";

  /// Save Messages to Local Storage
  static Future<void> saveMessages(List<MessageItem> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = messages.map((msg) => msg.toJson()).toList();
      await prefs.setString(_messagesKey, jsonEncode(jsonList));
      await prefs.setInt(_lastFetchKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error saving messages: $e');
    }
  }

  /// Get Cached Messages from Local Storage
  static Future<List<MessageItem>> getCachedMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_messagesKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((json) => MessageItem.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error loading cached messages: $e');
    }
    return [];
  }

  /// Check if Cache is Valid (less than 5 minutes old)
  static Future<bool> isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastFetch = prefs.getInt(_lastFetchKey);

      if (lastFetch == null) return false;

      final now = DateTime.now().millisecondsSinceEpoch;
      final difference = now - lastFetch;

      // Cache valid for 5 minutes
      return difference < (5 * 60 * 1000);
    } catch (e) {
      return false;
    }
  }

  /// Clear Cached Messages
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_messagesKey);
      await prefs.remove(_lastFetchKey);
    } catch (e) {
      print('Error clearing message cache: $e');
    }
  }
}
