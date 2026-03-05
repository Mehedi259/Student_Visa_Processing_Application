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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final horizontalPadding = screenWidth > 600 ? 40.0 : 20.0;
              
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    MediaQuery.of(context).size.height * 0.06,
                    horizontalPadding,
                    0,
                  ),
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
                      SizedBox(height: MediaQuery.of(context).size.height * 0.016),
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
                      SizedBox(height: MediaQuery.of(context).size.height * 0.016),
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
                      SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                    ],
                  ),
                ),
              );
            },
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

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive sizing
    final cardHorizontalPadding = screenWidth * 0.065;
    final cardVerticalPadding = screenHeight * 0.02;
    final iconSize = screenWidth * 0.095;
    final iconImageSize = screenWidth * 0.06;
    final titleFontSize = screenWidth * 0.055;
    final progressFontSize = screenWidth * 0.045;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: screenWidth > 600 ? 500 : double.infinity,
          minHeight: screenHeight * 0.14,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: cardHorizontalPadding,
          vertical: cardVerticalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: iconSize,
              height: iconSize,
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
                          width: iconImageSize,
                          height: iconImageSize,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return SizedBox(
                              width: iconImageSize,
                              height: iconImageSize,
                              child: Image(
                                image: iconImage,
                                fit: BoxFit.contain,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              width: iconImageSize,
                              height: iconImageSize,
                              child: Center(
                                child: SizedBox(
                                  width: iconImageSize * 0.5,
                                  height: iconImageSize * 0.5,
                                  child: const CircularProgressIndicator(
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
                        width: iconImageSize,
                        height: iconImageSize,
                        child: Image(
                          image: iconImage,
                          fit: BoxFit.contain,
                        ),
                      ),
              ),
            ),
            SizedBox(height: screenHeight * 0.017),
            // Title and Progress Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: titleFontSize.clamp(18.0, 22.0),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1D1B20),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // Status, Progress, and Chevron
                Row(
                  mainAxisSize: MainAxisSize.min,
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
                      const SizedBox(width: 8),
                    ],
                    Text(
                      '$progress/$total',
                      style: TextStyle(
                        fontSize: progressFontSize.clamp(16.0, 18.0),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFC7C7C7),
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
