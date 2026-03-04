// lib/features/screens/documents/documents_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:iywt/core/routes/routes.dart';
import '../../../core/routes/route_path.dart';
import '../../../global/controler/documents/documents_controler.dart';
import '../../widgets/custom_navigation/custom_navbar.dart';
import '../../../core/custom_assets/assets.gen.dart';

enum DocumentStatus { complete, incomplete, warning }

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final DocumentsController _controller = Get.put(DocumentsController());

  @override
  void initState() {
    super.initState();
    // Fetch dashboard data on init
    _controller.fetchDocumentsDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        title: const Text(
          'Documents',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Nunito Sans',
            fontWeight: FontWeight.w600,
            color: Color(0xFF1D1B20),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        if (_controller.isLoadingDashboard.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF375BA4),
            ),
          );
        }

        final dashboard = _controller.dashboard.value;
        if (dashboard == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No data available',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _controller.fetchDocumentsDashboard(),
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
            await _controller.fetchDocumentsDashboard();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 0),
              child: Column(
                children: [
                  _buildDocumentCard(
                    context: context,
                    title: 'Preliminary',
                    onTap: () {
                      _controller.fetchPreliminaryDocuments();
                      context.push(RoutePath.preliminary.addBasePath);
                    },
                    iconImage: Assets.images.preliminary.provider(),
                    progress: dashboard.preliminaryDocuments.completed,
                    total: dashboard.preliminaryDocuments.total,
                    status: _getStatus(dashboard.preliminaryDocuments.status),
                  ),
                  const SizedBox(height: 12.91),
                  _buildDocumentCard(
                    context: context,
                    title: 'Student',
                    onTap: () {
                      _controller.fetchStudentDocuments();
                      context.push(RoutePath.student.addBasePath);
                    },
                    iconImage: Assets.images.student.provider(),
                    progress: dashboard.studentDocuments.completed,
                    total: dashboard.studentDocuments.total,
                    status: _getStatus(dashboard.studentDocuments.status),
                  ),
                  const SizedBox(height: 12.91),
                  _buildDocumentCard(
                    context: context,
                    title: 'Country',
                    onTap: () {
                      _controller.fetchCountryDocuments();
                      context.push(RoutePath.country.addBasePath);
                    },
                    iconImage: Assets.images.country.provider(),
                    progress: dashboard.countryDocuments.completed,
                    total: dashboard.countryDocuments.total,
                    status: _getStatus(dashboard.countryDocuments.status),
                    isCountryFlag: true,
                    countryFlagUrl: dashboard.countryFlagUrl,
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        );
      }),
      bottomNavigationBar: const CustomNavBar(currentIndex: 2),
    );
  }

  DocumentStatus _getStatus(String status) {
    switch (status.toLowerCase()) {
      case 'complete':
      case 'scanapproved':
        return DocumentStatus.complete;
      case 'incomplete':
      case 'partiallycomplete':
        return DocumentStatus.incomplete;
      case 'pending':
      case 'initial':
      default:
        return DocumentStatus.warning;
    }
  }

  Widget _buildDocumentCard({
    required BuildContext context,
    required String title,
    required ImageProvider iconImage,
    required int progress,
    required int total,
    required DocumentStatus status,
    required VoidCallback onTap,
    bool isCountryFlag = false,
    String? countryFlagUrl,
  }) {
    ImageProvider? statusImage;
    double statusIconSize = 20;

    if (status == DocumentStatus.complete) {
      statusImage = Assets.images.correct.provider();
    } else if (status == DocumentStatus.warning) {
      statusImage = Assets.images.alert.provider();
      statusIconSize = 16;
    } else if (status == DocumentStatus.incomplete) {
      statusImage = Assets.images.cross.provider();
      statusIconSize = 16;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 353,
          minHeight: 119.09,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16.62),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 38.16,
              height: 38.16,
              decoration: BoxDecoration(
                color: isCountryFlag
                    ? const Color(0xFFF5F5F7)
                    : const Color(0xFF375BA4),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isCountryFlag &&
                        countryFlagUrl != null &&
                        countryFlagUrl.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          countryFlagUrl,
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return SizedBox(
                              width: 24,
                              height: 24,
                              child: Image(
                                image: iconImage,
                                fit: BoxFit.contain,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const SizedBox(
                              width: 24,
                              height: 24,
                              child: Center(
                                child: SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF375BA4),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : SizedBox(
                        width: 24,
                        height: 24,
                        child: Image(
                          image: iconImage,
                          fit: BoxFit.contain,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 14),
            // Title and Progress Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1D1B20),
                  ),
                ),
                // Status, Progress, and Chevron
                Row(
                  children: [
                    if (statusImage != null) ...[
                      SizedBox(
                        width: statusIconSize,
                        height: statusIconSize,
                        child: Image(
                          image: statusImage,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      '$progress/$total',
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFC7C7C7),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFFC7C7C7),
                      size: 24,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
