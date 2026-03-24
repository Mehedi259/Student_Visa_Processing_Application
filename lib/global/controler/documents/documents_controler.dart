// lib/global/controller/documents/documents_controller.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;

import '../../model/documents/documents_model.dart';
import '../../service/documents/documents_service.dart';

class DocumentsController extends GetxController {
  // Loading states
  final isLoadingDashboard = false.obs;
  final isLoadingDocuments = false.obs;
  final isLoadingDetail = false.obs;
  final isUploading = false.obs;

  // Data
  final Rx<DocumentsDashboard?> dashboard = Rx<DocumentsDashboard?>(null);
  final Rx<DocumentTypeList?> preliminaryDocs = Rx<DocumentTypeList?>(null);
  final Rx<DocumentTypeList?> studentDocs = Rx<DocumentTypeList?>(null);
  final Rx<DocumentTypeList?> countryDocs = Rx<DocumentTypeList?>(null);
  final Rx<DocumentDetail?> currentDocumentDetail = Rx<DocumentDetail?>(null);

  // Current selected document ID
  final currentDocumentId = ''.obs;
  final currentDocumentMobileScanningDisabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDocumentsDashboard();
  }

  /// Fetch Documents Dashboard
  Future<void> fetchDocumentsDashboard() async {
    try {
      isLoadingDashboard.value = true;
      final data = await DocumentsService.getDocumentsDashboard();
      dashboard.value = data;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load dashboard: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingDashboard.value = false;
    }
  }

  /// Fetch Preliminary Documents
  Future<void> fetchPreliminaryDocuments() async {
    try {
      isLoadingDocuments.value = true;
      final data = await DocumentsService.getDocumentTypeList('Preliminary');
      preliminaryDocs.value = data;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load preliminary documents: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingDocuments.value = false;
    }
  }

  /// Fetch Student Documents
  Future<void> fetchStudentDocuments() async {
    try {
      isLoadingDocuments.value = true;
      final data = await DocumentsService.getDocumentTypeList('Student');
      studentDocs.value = data;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load student documents: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingDocuments.value = false;
    }
  }

  /// Fetch Country Documents
  Future<void> fetchCountryDocuments() async {
    try {
      isLoadingDocuments.value = true;
      final data = await DocumentsService.getDocumentTypeList('Country');
      countryDocs.value = data;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load country documents: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingDocuments.value = false;
    }
  }

  /// Fetch Document Detail
  Future<void> fetchDocumentDetail(String documentId) async {
    try {
      isLoadingDetail.value = true;
      currentDocumentId.value = documentId;

      developer.log('📄 Fetching document detail for ID: $documentId',
          name: 'DocumentsController');

      final data = await DocumentsService.getDocumentDetail(documentId);
      currentDocumentDetail.value = data;

      developer.log('✅ Document detail loaded: ${data.title}',
          name: 'DocumentsController');
    } catch (e) {
      developer.log('❌ Error fetching document detail: $e',
          name: 'DocumentsController');
      Get.snackbar(
        'Error',
        'Failed to load document detail: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// Upload Document
  Future<bool> uploadDocument({
    required String documentId,
    required String description,
    File? documentFile,
    Uint8List? webFile,
  }) async {
    try {
      developer.log('🚀 Starting document upload',
          name: 'DocumentsController');
      developer.log('📄 Document ID: $documentId',
          name: 'DocumentsController');
      developer.log('📝 Description: $description',
          name: 'DocumentsController');

      if (documentFile != null) {
        developer.log('📁 File path: ${documentFile.path}',
            name: 'DocumentsController');
        developer.log('📏 File size: ${await documentFile.length()} bytes',
            name: 'DocumentsController');
        developer.log('✅ File exists: ${await documentFile.exists()}',
            name: 'DocumentsController');
      }

      isUploading.value = true;

      await DocumentsService.uploadDocument(
        documentId: documentId,
        description: description,
        documentFile: documentFile,
        webFile: webFile,
      );

      developer.log('✅ Upload successful', name: 'DocumentsController');

      Get.snackbar(
        'Success',
        'Document uploaded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );

      // Refresh document detail after upload
      await fetchDocumentDetail(documentId);

      // Refresh dashboard to update counts
      await fetchDocumentsDashboard();

      return true;
    } catch (e, stackTrace) {
      developer.log('❌ Upload error: $e',
          name: 'DocumentsController', error: e, stackTrace: stackTrace);

      Get.snackbar(
        'Error',
        'Failed to upload document: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    } finally {
      isUploading.value = false;
    }
  }

  /// Delete Document Upload
  Future<bool> deleteDocumentUpload(String documentUploadId) async {
    try {
      developer.log('🗑️ Starting document upload deletion',
          name: 'DocumentsController');
      developer.log('📄 Document Upload ID: $documentUploadId',
          name: 'DocumentsController');

      await DocumentsService.deleteDocumentUpload(documentUploadId);

      developer.log('✅ Delete successful', name: 'DocumentsController');

      // Refresh document detail after deletion
      if (currentDocumentId.value.isNotEmpty) {
        await fetchDocumentDetail(currentDocumentId.value);
      }

      // Refresh dashboard to update counts
      await fetchDocumentsDashboard();

      return true;
    } catch (e, stackTrace) {
      developer.log('❌ Delete error: $e',
          name: 'DocumentsController', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get status enum from string
  String getStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'scanapproved':
      case 'complete':
        return 'Complete';
      case 'incomplete':
      case 'partiallycomplete':
        return 'Incomplete';
      case 'pending':
      case 'initial':
        return 'Pending';
      default:
        return 'Pending';
    }
  }

  /// Clear current document detail
  void clearCurrentDocument() {
    currentDocumentDetail.value = null;
    currentDocumentId.value = '';
  }

  @override
  void onClose() {
    // Clean up if needed
    super.onClose();
  }
}