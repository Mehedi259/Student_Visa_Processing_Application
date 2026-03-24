// lib/presentation/screens/legal_entry_basic/destination.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../widgets/custom_navigation/custom_navbar.dart';
import '../../../core/custom_assets/assets.gen.dart';
import '../../../global/controler/legal_entry_basic/legal_entry_basic_controler.dart';

class DestinationScreen extends StatefulWidget {
  const DestinationScreen({super.key});

  @override
  State<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen> {
  late LegalEntryBasicController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(LegalEntryBasicController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Legal Entry Basics',
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
        if (controller.isLoading.value && controller.legalEntryData.value == null) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF375BA4),
            ),
          );
        }

        final data = controller.legalEntryData.value;

        if (data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Failed to load data'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchLegalEntryBasics,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF375BA4),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          color: const Color(0xFF375BA4),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildCountrySummaryCard(data),
                const SizedBox(height: 16),

                _buildExpandableCard(
                  image: Assets.images.importantDates.provider(),
                  title: 'Important Dates',
                  content: data.formattedImportantDates,
                  isExpanded: controller.isImportantDatesExpanded,
                  onToggle: controller.toggleImportantDates,
                  iconSize: 18,
                ),
                const SizedBox(height: 12),

                _buildExpandableCard(
                  image: Assets.images.instructionForDocumentSubmission.provider(),
                  title: 'Application Submission',
                  content: data.instructionsForDocumentSubmission,
                  isExpanded: controller.isInstructionsExpanded,
                  onToggle: controller.toggleInstructions,
                  iconSize: 20,
                ),
                const SizedBox(height: 12),

                _buildExpandableCard(
                  image: Assets.images.consulateOrOtherVisits.provider(),
                  title: 'Consulate or Other Visits',
                  content: data.consulateOrOtherVisits,
                  isExpanded: controller.isConsulateExpanded,
                  onToggle: controller.toggleConsulate,
                ),
                const SizedBox(height: 12),

                _buildExpandableCard(
                  image: Assets.images.importantNotes.provider(),
                  title: 'Important Notes',
                  content: data.importantNotes,
                  isExpanded: controller.isImportantNotesExpanded,
                  onToggle: controller.toggleImportantNotes,
                ),
                const SizedBox(height: 12),

                _buildExpandableCard(
                  image: Assets.images.postArrivalinstructions.provider(),
                  title: 'Post Arrival Instructions',
                  content: data.postArrivalInstructions,
                  isExpanded: controller.isPostArrivalExpanded,
                  onToggle: controller.togglePostArrival,
                ),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: const CustomNavBar(currentIndex: 1),
    );
  }

  // Country Summary Card
  Widget _buildCountrySummaryCard(dynamic data) {
    return Obx(() => Container(
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
      child: Column(
        children: [
          InkWell(
            onTap: controller.toggleCountrySummary,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  // Country Flag from API
                  CachedNetworkImage(
                    imageUrl: data.countryFlagUrl,
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) {
                      // Debug: Print error
                      print('❌ Flag Load Error: $error');
                      print('❌ Failed URL: $url');

                      return Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.grey.shade300,
                        ),
                        child: const Icon(
                          Icons.flag,
                          size: 16,
                          color: Colors.grey,
                        ),
                      );
                    },
                    imageBuilder: (context, imageProvider) => Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${data.countryName} Summary',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Icon(
                    controller.isCountrySummaryExpanded.value
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          // Expandable Body with Markdown
          if (controller.isCountrySummaryExpanded.value)
            Container(
              padding: const EdgeInsets.all(16),
              child: Markdown(
                data: data.countrySummary,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                styleSheet: MarkdownStyleSheet(
                  h1: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  h2: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  h3: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  p: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                  listBullet: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  blockquote: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                  blockquoteDecoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                    border: Border(
                      left: BorderSide(
                        color: Colors.grey.shade400,
                        width: 4,
                      ),
                    ),
                  ),
                  blockquotePadding: const EdgeInsets.all(12),
                ),
              ),
            ),
        ],
      ),
    ));
  }

  // Expandable Card
  Widget _buildExpandableCard({
    required String title,
    required ImageProvider image,
    required String content,
    required RxBool isExpanded,
    required VoidCallback onToggle,
    double iconSize = 24,
  }) {
    return Obx(() => Container(
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
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      image: DecorationImage(
                        image: image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded.value
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 24,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          // Expandable Content with Markdown
          if (isExpanded.value)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Markdown(
                data: content,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                styleSheet: MarkdownStyleSheet(
                  h1: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  h2: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  h3: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  p: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                  listBullet: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  blockquote: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                  blockquoteDecoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                    border: Border(
                      left: BorderSide(
                        color: Colors.grey.shade400,
                        width: 4,
                      ),
                    ),
                  ),
                  blockquotePadding: const EdgeInsets.all(12),
                  code: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: Colors.grey.shade800,
                    backgroundColor: Colors.grey.shade100,
                  ),
                ),
              ),
            ),
        ],
      ),
    ));
  }
}