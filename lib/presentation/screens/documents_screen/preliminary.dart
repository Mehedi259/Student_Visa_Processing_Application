// lib/features/screens/documents/preliminary_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:iywt/core/routes/routes.dart';
import '../../../core/routes/route_path.dart';
import '../../../core/custom_assets/assets.gen.dart';
import '../../../global/controler/documents/documents_controler.dart';

class PreliminaryScreen extends StatefulWidget {
  const PreliminaryScreen({super.key});

  @override
  State<PreliminaryScreen> createState() => _PreliminaryScreenState();
}

class _PreliminaryScreenState extends State<PreliminaryScreen> {
  final DocumentsController _controller = Get.find<DocumentsController>();

  @override
  void initState() {
    super.initState();
    // Fetch preliminary documents if not already loaded
    if (_controller.preliminaryDocs.value == null) {
      _controller.fetchPreliminaryDocuments();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image(
            image: Assets.images.backIcon.provider(),
            height: 40,
            width: 40,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Preliminary",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          Obx(() {
            final docs = _controller.preliminaryDocs.value;
            if (docs == null) {
              return const SizedBox(width: 80);
            }

            final completed = docs.completed;
            final total = docs.total;
            final isComplete = completed == total;

            return Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Image(
                      image: isComplete
                          ? Assets.images.correct.provider()
                          : Assets.images.cross.provider(),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "$completed/$total",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          })
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

        final docs = _controller.preliminaryDocs.value;
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
                  'No documents available',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _controller.fetchPreliminaryDocuments(),
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
            await _controller.fetchPreliminaryDocuments();
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
                    'You will upload documentation for ${doc.title.toLowerCase()}.',
                onPressed: () {
                  _controller.currentDocumentMobileScanningDisabled.value = doc.mobileScanningDisabled;
                  _controller.fetchDocumentDetail(doc.studentDocumentId);
                  context.push(RoutePath.passport.addBasePath);
                },
                status: doc.status,
                width: width,
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
    required VoidCallback onPressed,
    required double width,
  }) {
    // Determine status icon based on status value
    ImageProvider statusIcon;
    
    switch (status.toLowerCase()) {
      case 'complete':
      case 'scanapproved':
        statusIcon = Assets.images.correct.provider(); // Green checkmark
        break;
      case 'incomplete':
        statusIcon = Assets.images.cross.provider(); // Red cross
        break;
      case 'partiallycomplete':
        statusIcon = Assets.images.alert.provider(); // Yellow triangle
        break;
      case 'pending':
      case 'initial':
      default:
        statusIcon = Assets.images.cross.provider(); // Red cross for pending/initial
        break;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onPressed,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(10),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D1B20),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9E9E9E),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 26,
              height: 26,
              child: Image(
                image: statusIcon,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right,
              size: 26,
              color: Colors.grey.shade400,
            )
          ],
        ),
      ),
    );
  }
}