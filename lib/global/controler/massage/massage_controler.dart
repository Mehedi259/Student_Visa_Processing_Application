// lib/global/controller/massage/massage_controller.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../model/massage/massage_model.dart';
import '../../service/massage/massage_service.dart';
import '../../storage/message_storage_helper.dart';
import '../../../global/utils/snackbar_utils.dart';

class MessageController extends GetxController {
  // Observable Variables
  final messages = <MessageItem>[].obs;
  final isLoading = false.obs;
  final isSending = false.obs;
  final isLoadingMore = false.obs;

  // Pagination
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final hasNextPage = false.obs;

  // Search
  final searchQuery = ''.obs;
  Worker? _searchDebounce;

  // Selected File
  Rx<File?> selectedFile = Rx<File?>(null);
  Rx<Uint8List?> selectedWebFile = Rx<Uint8List?>(null);
  final selectedFileName = ''.obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadMessages();

    // Debounce search for better performance
    _searchDebounce = debounce(
      searchQuery,
      (_) {}, // Search is handled by filteredMessages getter
      time: const Duration(milliseconds: 300),
    );
  }

  @override
  void onClose() {
    _searchDebounce?.dispose();
    super.onClose();
  }

  /// Load Messages (Initial or Refresh)
  Future<void> loadMessages(
      {bool refresh = false, BuildContext? context}) async {
    if (refresh) {
      currentPage.value = 1;
      messages.clear();
    }

    // Load from cache first for instant display
    if (!refresh && messages.isEmpty) {
      final cachedMessages = await MessageStorageHelper.getCachedMessages();
      if (cachedMessages.isNotEmpty) {
        messages.value = cachedMessages;

        // Check if cache is still valid
        final isCacheValid = await MessageStorageHelper.isCacheValid();
        if (isCacheValid) {
          return; // Use cache, don't fetch from API
        }
      }
    }

    isLoading.value = true;

    try {
      final response = await MessageService.getMessages(
        pageNumber: currentPage.value,
      );

      if (refresh) {
        // Reverse the items so newest messages are at the bottom
        messages.value = response.items.reversed.toList();
      } else {
        // Add reversed items to existing messages
        messages.value = response.items.reversed.toList();
      }

      // Save to local storage
      await MessageStorageHelper.saveMessages(messages);

      totalPages.value = response.totalPages;
      hasNextPage.value = response.hasNextPage;
    } catch (e) {
      if (context != null && context.mounted) {}
    } finally {
      isLoading.value = false;
    }
  }

  /// Load More Messages (Pagination)
  Future<void> loadMoreMessages({BuildContext? context}) async {
    if (!hasNextPage.value || isLoadingMore.value) return;

    isLoadingMore.value = true;
    currentPage.value++;

    try {
      final response = await MessageService.getMessages(
        pageNumber: currentPage.value,
      );

      // Insert older messages at the beginning (reversed order)
      messages.insertAll(0, response.items.reversed.toList());
      hasNextPage.value = response.hasNextPage;
    } catch (e) {
      if (context != null && context.mounted) {
        SnackbarUtils.showError(context, 'Failed to load more messages');
      }
      currentPage.value--;
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Send Message
  Future<void> sendMessage({
    required String subject,
    required String body,
    BuildContext? context,
  }) async {
    if (subject.trim().isEmpty || body.trim().isEmpty) {
      if (context != null && context.mounted) {
        SnackbarUtils.showInfo(context, 'Subject and message cannot be empty');
      }
      return;
    }

    isSending.value = true;

    try {
      final success = await MessageService.sendMessage(
        subject: subject,
        body: body,
        attachmentFile: selectedFile.value,
        webAttachment: selectedWebFile.value,
      );

      if (success) {
        // Clear attachment
        clearAttachment();

        // Refresh messages
        await loadMessages(refresh: true, context: context);
      }
    } catch (e) {
      if (context != null && context.mounted) {
        SnackbarUtils.showError(context, 'Failed to send message');
      }
    } finally {
      isSending.value = false;
    }
  }

  /// Pick Image from Gallery
  Future<void> pickImage({BuildContext? context}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (image != null) {
        if (kIsWeb) {
          selectedWebFile.value = await image.readAsBytes();
          selectedFileName.value = image.name;
        } else {
          selectedFile.value = File(image.path);
          selectedFileName.value = image.name;
        }

        if (context != null && context.mounted) {
          SnackbarUtils.showInfo(
            context,
            'Image selected: ${selectedFileName.value}',
          );
        }
      }
    } catch (e) {
      if (context != null && context.mounted) {
        SnackbarUtils.showError(context, 'Failed to pick image');
      }
    }
  }

  /// Pick File/Document
  Future<void> pickFile({BuildContext? context}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (kIsWeb) {
          selectedWebFile.value = file.bytes;
          selectedFileName.value = file.name;
        } else {
          selectedFile.value = File(file.path!);
          selectedFileName.value = file.name;
        }

        if (context != null && context.mounted) {
          SnackbarUtils.showInfo(
            context,
            'File selected: ${selectedFileName.value}',
          );
        }
      }
    } catch (e) {
      if (context != null && context.mounted) {
        SnackbarUtils.showError(context, 'Failed to pick file');
      }
    }
  }

  /// Clear Selected Attachment
  void clearAttachment() {
    selectedFile.value = null;
    selectedWebFile.value = null;
    selectedFileName.value = '';
  }

  /// Search Messages with context (show surrounding messages)
  void searchMessages(String query) {
    searchQuery.value = query.toLowerCase();
  }

  /// Get Filtered Messages (only exact matches, no context)
  List<MessageItem> get filteredMessages {
    if (searchQuery.value.isEmpty) {
      return messages;
    }

    // Return only messages that contain the search query
    return messages.where((msg) {
      return msg.subject.toLowerCase().contains(searchQuery.value) ||
          msg.body.toLowerCase().contains(searchQuery.value) ||
          msg.posterName.toLowerCase().contains(searchQuery.value);
    }).toList();
  }
}
