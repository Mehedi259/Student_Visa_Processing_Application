// lib/features/screens/documents/passport/passport_widgets/uploads.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../global/controler/documents/documents_controler.dart';



class UploadsTab extends StatelessWidget {
  final double horizontalPadding;

  const UploadsTab({
    super.key,
    required this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    final DocumentsController controller = Get.find<DocumentsController>();

    return Obx(() {
      if (controller.isLoadingDetail.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF375BA4),
          ),
        );
      }

      final detail = controller.currentDocumentDetail.value;
      if (detail == null || detail.documentUploads.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.upload_file_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'No uploads yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Use the scan or upload button to add documents',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Scan Uploads',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...detail.documentUploads.asMap().entries.map((entry) {
                    final index = entry.key;
                    final upload = entry.value;
                    final isLast = index == detail.documentUploads.length - 1;

                    return Column(
                      children: [
                        _buildUploadCard(
                          context: context,
                          date: _formatDate(upload.createdOn),
                          uploadedBy: upload.createdBy,
                          description: upload.description,
                          documentUrl: upload.url,
                          documentUploadId: upload.documentUploadId,
                          deleteEnabled: upload.deleteEnabled,
                          controller: controller,
                        ),
                        if (!isLast) const SizedBox(height: 12),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      );
    });
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildUploadCard({
    required BuildContext context,
    required String date,
    required String uploadedBy,
    required String description,
    required String documentUrl,
    required String documentUploadId,
    required bool deleteEnabled,
    required DocumentsController controller,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFD),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFC7C7C7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Uploaded by',
                      style: TextStyle(
                        fontSize: 8,
                        color: Color(0xFFC7C7C7),
                      ),
                    ),
                    Text(
                      uploadedBy,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1D1B20),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 8,
                        color: Color(0xFFC7C7C7),
                      ),
                    ),
                    Text(
                      description.isNotEmpty ? description : 'No description',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1D1B20),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _openDocument(documentUrl),
                child: const Text(
                  'View scan',
                  style: TextStyle(color: Color(0xFF375BA4)),
                ),
              ),
            ],
          ),
          if (deleteEnabled) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFE0E0E0)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showDeleteConfirmation(
                  context,
                  documentUploadId,
                  controller,
                ),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Delete Upload'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red.shade700,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    String documentUploadId,
    DocumentsController controller,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Upload'),
          content: const Text(
            'Are you sure you want to delete this upload? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF375BA4)),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      try {
        await controller.deleteDocumentUpload(documentUploadId);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Document deleted successfully'),
              backgroundColor: Color(0xFF375BA4),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete document: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _openDocument(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Could not open document',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open document: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}