// lib/features/screens/documents/passport/passport_widgets/requirements.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/custom_assets/assets.gen.dart';
import '../../../../../global/controler/documents/documents_controler.dart';

class RequirementsTab extends StatelessWidget {
  final double horizontalPadding;

  const RequirementsTab({
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
      if (detail == null || detail.requirements.isEmpty) {
        return const Center(
          child: Text(
            'No requirements available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        );
      }

      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFDFDFD),
                border: Border.all(
                  color: const Color(0xFFC7C7C7),
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Container(
                    height: 40,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F7),
                      border: Border.all(
                        color: const Color(0xFFC7C7C7),
                        width: 0.5,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          Assets.images.requirements.path,
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Requirements',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1D1B20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFC7C7C7),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        children:
                            detail.requirements.asMap().entries.map((entry) {
                          final requirement = entry.value;
                          return _buildRequirementItem(requirement);
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      );
    });
  }

  Widget _buildRequirementItem(String text, {bool isLast = false}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFC7C7C7),
          width: 1,
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            height: 1.30,
            color: Color(0xFF1D1B20),
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
