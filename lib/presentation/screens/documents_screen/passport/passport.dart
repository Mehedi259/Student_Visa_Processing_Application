// lib/features/screens/documents/passport/passport_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:iywt/core/routes/routes.dart';
import '../../../../core/custom_assets/assets.gen.dart';
import '../../../../core/routes/route_path.dart';
import '../../../../global/controler/documents/documents_controler.dart';
import '../../../widgets/custom_navigation/custom_navbar.dart';
import 'passport_widgets/details.dart';
import 'passport_widgets/requirements.dart';
import 'passport_widgets/status.dart';
import 'passport_widgets/uploads.dart';

class PassportScreen extends StatefulWidget {
  const PassportScreen({super.key});

  @override
  State<PassportScreen> createState() => _PassportScreenState();
}

class _PassportScreenState extends State<PassportScreen> {
  final DocumentsController _controller = Get.find<DocumentsController>();
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double horizontalPadding = size.width * 0.05;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              _controller.clearCurrentDocument();
              context.pop();
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE8F3FF),
                borderRadius: BorderRadius.circular(25),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.asset(
                  Assets.images.backIcon.path,
                  width: 157,
                  height: 118,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        title: Obx(() {
          final detail = _controller.currentDocumentDetail.value;
          return Text(
            detail?.title ?? 'Document',
            style: const TextStyle(
              fontSize: 18,
              fontFamily: 'Nunito Sans',
              fontWeight: FontWeight.w500,
              color: Color(0xFF1D1B20),
            ),
          );
        }),
        backgroundColor: const Color(0xFFFDFDFD),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildTabBar(horizontalPadding),
          Expanded(
            child: _buildTabContent(horizontalPadding),
          ),
        ],
      ),
      floatingActionButton: _selectedTabIndex == 3
          ? _buildFloatingButtons()
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const CustomNavBar(currentIndex: 2),
    );
  }

  Widget _buildTabBar(double hPadding) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: hPadding, vertical: 10),
      height: 45,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF0F8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildTab('Details', 0),
          _buildTab('Requirements', 1),
          _buildTab('Status', 2),
          _buildTab('Uploads', 3),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF375BA4) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? const Color(0xFFF5F5F7)
                    : const Color(0xFF1D1B20),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(double hPadding) {
    switch (_selectedTabIndex) {
      case 0:
        return DetailsTab(horizontalPadding: hPadding);
      case 1:
        return RequirementsTab(horizontalPadding: hPadding);
      case 2:
        return StatusTab(horizontalPadding: hPadding);
      case 3:
        return UploadsTab(horizontalPadding: hPadding);
      default:
        return const SizedBox();
    }
  }

  Widget _buildFloatingButtons() {
    return Obx(() {
      final isUploading = _controller.isUploading.value;
      final isScanningDisabled = _controller.currentDocumentMobileScanningDisabled.value;

      return Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Opacity(
              opacity: isScanningDisabled ? 0.4 : 1.0,
              child: FloatingActionButton(
                heroTag: 'document',
                backgroundColor: const Color(0xFF375BA4),
                onPressed: (isUploading || isScanningDisabled) ? null : _pickAndUploadDocument,
                child: isUploading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Image.asset(
                  Assets.images.uploadAttachmentIcon.path,
                  color: Colors.white,
                  width: 28,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Opacity(
              opacity: isScanningDisabled ? 0.4 : 1.0,
              child: FloatingActionButton(
                heroTag: 'scan',
                backgroundColor: const Color(0xFF375BA4),
                onPressed: isScanningDisabled ? null : () => context.push(RoutePath.passportScanner.addBasePath),
                child: Image.asset(
                  Assets.images.scanner.path,
                  color: Colors.white,
                  width: 28,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _pickAndUploadDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Show description dialog
        final description = await _showDescriptionDialog();
        if (description == null || description.isEmpty) return;

        final documentId = _controller.currentDocumentId.value;
        if (documentId.isEmpty) {
          Get.snackbar(
            'Error',
            'No document selected',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        // Upload the document
        final success = await _controller.uploadDocument(
          documentId: documentId,
          description: description,
          documentFile: file.path != null ? File(file.path!) : null,
          webFile: file.bytes,
        );

        if (success && mounted) {
          Get.snackbar(
            'Success',
            'Document uploaded successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick file: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<String?> _showDescriptionDialog() async {
    final TextEditingController controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Document Description'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter document description',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF375BA4),
              ),
              child: const Text('Upload'),
            ),
          ],
        );
      },
    );
  }
}