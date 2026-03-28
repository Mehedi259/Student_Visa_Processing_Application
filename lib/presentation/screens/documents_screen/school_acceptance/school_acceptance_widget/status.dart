// lib/features/screens/documents/school_acceptance/school_acceptance_widget/status.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../core/custom_assets/assets.gen.dart';
import '../../../../../global/controler/documents/documents_controler.dart';

class StatusTab extends StatelessWidget {
  final double horizontalPadding;

  const StatusTab({
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
      if (detail == null || detail.documentUpdates.isEmpty) {
        return const Center(
          child: Text(
            'No status updates available',
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      color: Color(0xFF1D1B20),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...detail.documentUpdates.asMap().entries.map((entry) {
                    final index = entry.key;
                    final update = entry.value;
                    final isLast = index == detail.documentUpdates.length - 1;

                    return Column(
                      children: [
                        _buildStatusCard(
                          context,
                          date: _formatDate(update.createdOn),
                          email: update.createdBy,
                          status: update.status.toLowerCase(),
                          exception: update.exception,
                          solution: update.solution,
                          showDetails: update.exception != null &&
                              update.solution != null,
                        ),
                        if (!isLast) const SizedBox(height: 11),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 30),
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

  Widget _buildStatusCard(
      BuildContext context, {
        required String date,
        required String email,
        required String status,
        String? exception,
        String? solution,
        required bool showDetails,
      }) {
    final Map<String, dynamic> statusInfo = {
      'scanapproved': {'icon': Assets.images.correct},
      'complete': {'icon': Assets.images.correct},
      'incomplete': {'icon': Assets.images.cross},
      'partiallycomplete': {'icon': Assets.images.alert},
      'pending': {'icon': Assets.images.alert},
      'initial': {'icon': Assets.images.incomplete},
    }[status] ??
        {'icon': Assets.images.cross};

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFD),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFDFDFD)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFC7C7C7),
                  ),
                ),
                const SizedBox(height: 8.28),
                const Text(
                  'Created by',
                  style: TextStyle(
                    fontSize: 8,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFC7C7C7),
                  ),
                ),
                const SizedBox(height: 0),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF1D1B20),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          showDetails
              ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                statusInfo['icon'].path,
                width: 18.91,
                height: 18.91,
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => _showDetailsDialog(
                  context,
                  status: status,
                  exception: exception ?? '',
                  solution: solution ?? '',
                ),
                child: const Text(
                  'View details',
                  style: TextStyle(
                    color: Color(0xFF375BA4),
                    fontSize: 10,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.underline,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          )
              : Image.asset(
            statusInfo['icon'].path,
            width: 18.91,
            height: 18.91,
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(
      BuildContext context, {
        required String status,
        required String exception,
        required String solution,
      }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 314,
            padding: const EdgeInsets.all(23),
            decoration: BoxDecoration(
              color: const Color(0xFFFDFDFD),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      _getStatusIcon(status),
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _getStatusTitle(status),
                      style: const TextStyle(
                        color: Color(0xFF1D1B20),
                        fontSize: 20,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 38.75),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: const Color(0xFFC7C7C7),
                ),
                const SizedBox(height: 16.25),
                if (exception.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        Assets.images.issue.path,
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Issue',
                              style: TextStyle(
                                color: Color(0xFF1D1B20),
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              exception,
                              style: const TextStyle(
                                color: Color(0xFF1D1B20),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.43,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                ],
                if (solution.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        Assets.images.correct.path,
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Resolution',
                              style: TextStyle(
                                color: Color(0xFF1D1B20),
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              solution,
                              style: const TextStyle(
                                color: Color(0xFF1D1B20),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.43,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'scanapproved':
      case 'complete':
        return Assets.images.correct.path;
      case 'incomplete':
        return Assets.images.cross.path;
      case 'partiallycomplete':
        return Assets.images.alert.path;
      case 'pending':
        return Assets.images.pending.path;
      default:
        return Assets.images.incomplete.path;
    }
  }

  String _getStatusTitle(String status) {
    switch (status.toLowerCase()) {
      case 'scanapproved':
      case 'complete':
        return 'Complete';
      case 'incomplete':
        return 'Incomplete';
      case 'partiallycomplete':
        return 'Partially Complete';
      case 'pending':
        return 'Pending';
      default:
        return 'Initial';
    }
  }
}