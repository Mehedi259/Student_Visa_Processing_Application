// lib/global/controller/settings/email_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../model/settings/email_model.dart';
import '../../service/settings/email_service.dart';
import '../../utils/snackbar_utils.dart';

class EmailController extends GetxController {
  final isLoading = false.obs;
  final emails = <EmailModel>[].obs;

  final emailController = TextEditingController();
  final selectedType = 'Student'.obs;

  String? currentEmailId;

  @override
  void onInit() {
    super.onInit();
    loadEmails();
  }

  // Load all emails
  Future<void> loadEmails() async {
    try {
      isLoading.value = true;
      final data = await EmailService.getEmails();
      emails.value = data;
    } catch (e) {
      print('Error loading emails: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Populate fields for editing
  void populateFields(EmailModel email) {
    currentEmailId = email.emailId;
    emailController.text = email.email ?? '';
    selectedType.value = email.emailType ?? 'Student';
  }

  // Clear form fields
  void clearFields() {
    currentEmailId = null;
    emailController.clear();
    selectedType.value = 'Student';
  }

  // Save or update email
  Future<void> saveEmail(BuildContext context) async {
    if (currentEmailId == null) {
      if (context.mounted) {
        SnackbarUtils.showError(context, 'Email ID not found');
      }
      return;
    }

    try {
      isLoading.value = true;

      final email = EmailModel(
        email: emailController.text,
        emailType: selectedType.value,
        emailId: currentEmailId,
      );

      final success = await EmailService.updateEmail(currentEmailId!, email);

      if (success) {
        await loadEmails();
        if (context.mounted) {
          SnackbarUtils.showSuccess(context, 'Email saved successfully');
          context.pop();
        }
      } else {
        if (context.mounted) {
          SnackbarUtils.showError(context, 'Failed to save email');
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
    emailController.dispose();
    super.onClose();
  }
}