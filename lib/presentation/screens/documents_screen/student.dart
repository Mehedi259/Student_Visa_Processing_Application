// lib/features/screens/documents/student_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:iywt/core/routes/routes.dart';
import '../../../core/routes/route_path.dart';
import '../../../core/custom_assets/assets.gen.dart';
import '../../../global/controler/documents/documents_controler.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final DocumentsController _controller = Get.find<DocumentsController>();

  @override
  void initState() {
    super.initState();
    // Fetch student documents if not already loaded
    if (_controller.studentDocs.value == null) {
      _controller.fetchStudentDocuments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: Image(
            image: Assets.images.backIcon.provider(),
            height: 44,
            width: 44,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Student',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(() {
            final docs = _controller.studentDocs.value;
            if (docs == null) {
              return const SizedBox(width: 80);
            }

            final completed = docs.completed;
            final total = docs.total;
            final isComplete = completed == total;
            final hasWarning = completed > 0 && completed < total;

            return Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Image(
                    image: isComplete
                        ? Assets.images.correct.provider()
                        : hasWarning
                        ? Assets.images.alert.provider()
                        : Assets.images.cross.provider(),
                    height: 16,
                    width: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$completed/$total',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoadingDocuments.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF375BA4),
            ),
          );
        }

        final docs = _controller.studentDocs.value;
        if (docs == null || docs.documents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.description_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No student documents available',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _controller.fetchStudentDocuments(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF375BA4),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await _controller.fetchStudentDocuments();
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.documents.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              // Sort documents by displayOrder
              final sortedDocs = List.from(docs.documents)
                ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
              final doc = sortedDocs[index];
              
              return _buildDocumentItem(
                title: doc.title,
                description: doc.shortDescription ??
                    'Upload required documentation for ${doc.title.toLowerCase()}.',
                status: doc.status,
                onTap: () {
                  _controller.currentDocumentMobileScanningDisabled.value = doc.mobileScanningDisabled;
                  _controller.fetchDocumentDetail(doc.studentDocumentId);
                  context.push(RoutePath.collegeCertificateScannerScreen.addBasePath);
                },
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildDocumentItem({
    required String title,
    required String description,
    required String status,
    required VoidCallback onTap,
  }) {
    // Determine status icon based on status value
    AssetGenImage icon;
    
    switch (status.toLowerCase()) {
      case 'complete':
      case 'scanapproved':
        icon = Assets.images.correct; // Green checkmark
        break;
      case 'incomplete':
        icon = Assets.images.cross; // Red cross
        break;
      case 'partiallycomplete':
        icon = Assets.images.alert; // Yellow triangle
        break;
      case 'pending':
      case 'initial':
        icon = Assets.images.pending; // Pending icon
        break;
      default:
        icon = Assets.images.cross; // Red cross for unknown status
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Image(
              image: icon.provider(),
              height: 20,
              width: 20,
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right,
              size: 26,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}