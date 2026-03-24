// lib/features/screens/documents/school_acceptance/school_acceptance_widget/details.dart

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/custom_assets/assets.gen.dart';
import '../../../../../global/controler/documents/documents_controler.dart';

class DetailsTab extends StatefulWidget {
  final double horizontalPadding;

  const DetailsTab({
    super.key,
    required this.horizontalPadding,
  });

  @override
  State<DetailsTab> createState() => _DetailsTabState();
}

class _DetailsTabState extends State<DetailsTab> {
  final DocumentsController _controller = Get.find<DocumentsController>();
  bool _showFullDescription = false;
  bool _isInstructionExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.isLoadingDetail.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF375BA4),
          ),
        );
      }

      final detail = _controller.currentDocumentDetail.value;
      if (detail == null) {
        return const Center(
          child: Text('No document details available'),
        );
      }

      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFDFDFD),
                border: Border.all(
                  width: 0.5,
                  color: const Color(0xFFC7C7C7),
                ),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F7),
                      border: Border(
                          bottom:
                              BorderSide(color: Color(0xFFB0B0B0), width: 0.5)),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(11)),
                    ),
                    child: Row(
                      children: [
                        Image.asset(Assets.images.descriptionIcon.path,
                            width: 20, height: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Description',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_up),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Render Markdown Description
                        MarkdownBody(
                          data: _showFullDescription
                              ? detail.description
                              : _getTruncatedText(detail.description, 300),
                          styleSheet: MarkdownStyleSheet(
                            h1: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D1B20),
                            ),
                            h2: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1D1B20),
                            ),
                            h3: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1D1B20),
                            ),
                            p: const TextStyle(
                              fontSize: 14,
                              height: 1.43,
                              color: Color(0xFF1D1B20),
                            ),
                            listBullet: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF375BA4),
                            ),
                            strong: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            em: const TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          onTapLink: (text, href, title) {
                            if (href != null) {
                              _launchURL(href);
                            }
                          },
                        ),
                        if (detail.description.length > 300) ...[
                          const SizedBox(height: 14),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _showFullDescription = !_showFullDescription;
                              });
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                            ),
                            child: Text(
                              _showFullDescription ? 'See less' : 'See more',
                              style: const TextStyle(
                                  color: Color(0xFF375BA4),
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Instructions Section
            if (detail.instructions.isNotEmpty)
              _buildExpandableCard(
                iconAsset: Assets.images.instructionIcon,
                title: 'Instruction',
                isExpanded: _isInstructionExpanded,
                onTap: () {
                  setState(() {
                    _isInstructionExpanded = !_isInstructionExpanded;
                  });
                },
                child: MarkdownBody(
                  data: detail.instructions,
                  styleSheet: MarkdownStyleSheet(
                    h1: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D1B20),
                    ),
                    h2: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D1B20),
                    ),
                    h3: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D1B20),
                    ),
                    p: const TextStyle(
                      fontSize: 14,
                      height: 1.43,
                      color: Color(0xFF1D1B20),
                    ),
                    listBullet: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF375BA4),
                    ),
                  ),
                  onTapLink: (text, href, title) {
                    if (href != null) {
                      _launchURL(href);
                    }
                  },
                ),
              ),

            const SizedBox(height: 14),

            // Sample Document Section
            if (detail.sampleUrl != null && detail.sampleUrl!.isNotEmpty)
              _buildSimpleCard(
                iconAsset: Assets.images.sampleDocument,
                title: 'Sample Document',
                trailing: const Text(
                  'View',
                  style: TextStyle(
                      color: Color(0xFF375BA4),
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  _launchURL(detail.sampleUrl!);
                },
              ),

            const SizedBox(height: 14),

            // Blank Form Section
            if (detail.blankFormUrl != null && detail.blankFormUrl!.isNotEmpty)
              _buildSimpleCard(
                iconAsset: Assets.images.sampleDocument,
                title: 'Blank Form',
                trailing: const Text(
                  'Download',
                  style: TextStyle(
                      color: Color(0xFF375BA4),
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  _launchURL(detail.blankFormUrl!);
                },
              ),

            const SizedBox(height: 14),

            // Key Tips Section
            if (detail.keyTips.isNotEmpty)
              _buildExpandableCard(
                iconAsset: Assets.images.keytipsIcon,
                title: 'Key tips',
                isExpanded: true,
                onTap: null,
                child: MarkdownBody(
                  data: detail.keyTips,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(
                      fontSize: 14,
                      height: 1.43,
                      color: Color(0xFF1D1B20),
                    ),
                    listBullet: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF375BA4),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 30),
          ],
        ),
      );
    });
  }

  String _getTruncatedText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Error',
        'Could not open link',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _buildExpandableCard({
    required AssetGenImage iconAsset,
    required String title,
    required bool isExpanded,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        border: Border.all(color: const Color(0xFFB0B0B0), width: 0.5),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                border: const Border(
                    bottom: BorderSide(color: Color(0xFFB0B0B0), width: 0.5)),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Row(
                children: [
                  Image.asset(iconAsset.path, width: 20, height: 20),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500))),
                  Icon(isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(padding: const EdgeInsets.all(12), child: child),
        ],
      ),
    );
  }

  Widget _buildSimpleCard({
    required AssetGenImage iconAsset,
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          border: Border.all(color: const Color(0xFFB0B0B0), width: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Image.asset(iconAsset.path, width: 20, height: 20),
            const SizedBox(width: 8),
            Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500))),
            trailing,
          ],
        ),
      ),
    );
  }
}
