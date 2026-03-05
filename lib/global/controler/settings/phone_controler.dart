// lib/global/controller/settings/phone_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../model/settings/phone_model.dart';
import '../../service/settings/phone_service.dart';
import '../../utils/snackbar_utils.dart';

class PhoneController extends GetxController {
  final isLoading = false.obs;
  final phones = <PhoneModel>[].obs;

  final phoneController = TextEditingController();
  final selectedType = 'Student Cell'.obs;

  String? currentPhoneId;

  @override
  void onInit() {
    super.onInit();
    loadPhones();
  }

  // Load all phones
  Future<void> loadPhones() async {
    try {
      isLoading.value = true;
      final data = await PhoneService.getPhones();
      phones.value = data;
    } catch (e) {
      print('Error loading phone numbers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Populate fields for editing
  void populateFields(PhoneModel phone) {
    currentPhoneId = phone.phoneId;
    phoneController.text = phone.phone ?? '';
    selectedType.value = phone.phoneType ?? 'Student Cell';
  }

  // Clear form fields
  void clearFields() {
    currentPhoneId = null;
    phoneController.clear();
    selectedType.value = 'Student Cell';
  }

  // Save or update phone
  Future<void> savePhone(BuildContext context) async {
    if (currentPhoneId == null) {
      if (context.mounted) {
        SnackbarUtils.showError(context, 'Phone ID not found');
      }
      return;
    }

    try {
      isLoading.value = true;

      final phone = PhoneModel(
        phone: phoneController.text,
        phoneType: selectedType.value,
        phoneId: currentPhoneId,
      );

      final success = await PhoneService.updatePhone(currentPhoneId!, phone);

      if (success) {
        await loadPhones();
        if (context.mounted) {
          SnackbarUtils.showSuccess(context, 'Phone number saved successfully');
          context.pop();
        }
      } else {
        if (context.mounted) {
          SnackbarUtils.showError(context, 'Failed to save phone number');
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
    phoneController.dispose();
    super.onClose();
  }
}