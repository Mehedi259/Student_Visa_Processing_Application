// lib/global/controller/settings/technical_support_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../model/settings/tecnical_support_model.dart';
import '../../service/settings/tecnical_support_service.dart';
import '../../utils/snackbar_utils.dart';

class TechnicalSupportController extends GetxController {
  final isLoading = false.obs;

  final subjectController = TextEditingController();
  final bodyController = TextEditingController();

  // Submit support request
  Future<void> submitRequest(BuildContext context) async {
    if (subjectController.text.isEmpty || bodyController.text.isEmpty) {
      if (context.mounted) {
        SnackbarUtils.showError(context, 'Please fill in all fields');
      }
      return;
    }

    try {
      isLoading.value = true;

      final request = TechnicalSupportModel(
        subject: subjectController.text,
        issue: bodyController.text,
      );

      final success = await TechnicalSupportService.submitSupportRequest(request);

      if (success) {
        subjectController.clear();
        bodyController.clear();
        if (context.mounted) {
          SnackbarUtils.showSuccess(context, 'Support request submitted successfully');
          context.pop();
        }
      } else {
        if (context.mounted) {
          SnackbarUtils.showError(context, 'Failed to submit request');
        }
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarUtils.showError(context, 'An error occurred');
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    subjectController.dispose();
    bodyController.dispose();
    super.onClose();
  }
}
