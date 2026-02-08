// lib/global/controler/settings/student_information_controler.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../model/settings/student_information_model.dart';
import '../../service/settings/student_information_service.dart';
import '../../../global/utils/snackbar_utils.dart';

class StudentInformationController extends GetxController {
  final isLoading = false.obs;
  final studentInfo = Rxn<StudentInformationModel>();

  final preferredNameController = TextEditingController();
  final dobController = TextEditingController();
  final guardian1Controller = TextEditingController();
  final guardian2Controller = TextEditingController();

  final selectedGender = 'Male'.obs;
  final selectedPronoun = 'He / Him'.obs;

  // Image handling
  final Rx<File?> profilePhotoFile = Rx<File?>(null);
  final Rx<Uint8List?> webProfilePhoto = Rx<Uint8List?>(null);
  final profilePhotoUrl = ''.obs;
  final hasNewPhoto = false.obs; // Track if user picked a new photo

  @override
  void onInit() {
    super.onInit();
    loadStudentInformation();
  }

  // Load student information
  Future<void> loadStudentInformation() async {
    try {
      isLoading.value = true;
      final data = await StudentInformationService.getStudentInformation();
      if (data != null) {
        studentInfo.value = data;
        _populateFields(data);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load student information');
    } finally {
      isLoading.value = false;
    }
  }

  // Populate form fields
  void _populateFields(StudentInformationModel data) {
    preferredNameController.text = data.preferredName ?? '';
    dobController.text = data.dateOfBirth ?? '';
    guardian1Controller.text = data.parentLegalGuardianOneName ?? '';
    guardian2Controller.text = data.parentLegalGuardianTwoName ?? '';
    selectedGender.value = data.gender ?? 'Male';
    selectedPronoun.value = data.pronouns ?? 'He / Him';
    profilePhotoUrl.value = data.profilePhotoUrl ?? '';
    hasNewPhoto.value = false; // Reset when loading data
  }

  // Pick profile photo
  Future<void> pickProfilePhoto() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          // For web platform
          final bytes = await pickedFile.readAsBytes();
          webProfilePhoto.value = bytes;
          profilePhotoFile.value = null;
        } else {
          // For mobile platform
          profilePhotoFile.value = File(pickedFile.path);
          webProfilePhoto.value = null;
        }

        // Update the preview URL
        profilePhotoUrl.value = pickedFile.path;
        hasNewPhoto.value = true;

        debugPrint('📸 Photo picked successfully: ${pickedFile.path}');
      }
    } catch (e) {
      debugPrint('❌ Error picking photo: $e');
      Get.snackbar(
        'Error',
        'Failed to pick photo',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Select Date of Birth
  Future<void> selectDateOfBirth(BuildContext context) async {
    // Parse current date if exists
    DateTime initialDate = DateTime(2000);
    if (dobController.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(dobController.text);
      } catch (e) {
        // If parsing fails, use default
        initialDate = DateTime(2000);
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5B7FBF),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Format: YYYY-MM-DD
      dobController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  // Update student information
  Future<void> updateProfile() async {
    try {
      isLoading.value = true;

      // Only include fields that have values
      final fields = <String, String>{};

      if (preferredNameController.text.isNotEmpty) {
        fields['preferredName'] = preferredNameController.text.trim();
      }
      if (dobController.text.isNotEmpty) {
        fields['dateOfBirth'] = dobController.text.trim();
      }
      if (selectedGender.value.isNotEmpty) {
        fields['gender'] = selectedGender.value;
      }
      if (guardian1Controller.text.isNotEmpty) {
        fields['parentLegalGuardianOneName'] = guardian1Controller.text.trim();
      }
      if (guardian2Controller.text.isNotEmpty) {
        fields['parentLegalGuardianTwoName'] = guardian2Controller.text.trim();
      }
      if (selectedPronoun.value.isNotEmpty) {
        fields['pronouns'] = selectedPronoun.value;
      }

      // Check if there's anything to update
      final hasFieldChanges = fields.isNotEmpty;
      final hasPhotoChange = hasNewPhoto.value &&
          (profilePhotoFile.value != null || webProfilePhoto.value != null);

      if (!hasFieldChanges && !hasPhotoChange) {
        if (Get.context != null) {
          Get.snackbar(
            'Info',
            'No changes to update',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
        return;
      }

      final success = await StudentInformationService.updateStudentInformation(
        fields: fields,
        profilePhoto: hasNewPhoto.value ? profilePhotoFile.value : null,
        webProfilePhoto: hasNewPhoto.value ? webProfilePhoto.value : null,
      );

      if (success) {
        hasNewPhoto.value = false; // Reset after successful update

        if (Get.context != null) {
          Get.snackbar(
            'Success',
            'Profile updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        }

        // Reload data to get updated profile photo URL
        await loadStudentInformation();
      } else {
        if (Get.context != null) {
          Get.snackbar(
            'Error',
            'Failed to update profile',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error updating profile: $e');
      if (Get.context != null) {
        Get.snackbar(
          'Error',
          'An error occurred while updating profile',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    preferredNameController.dispose();
    dobController.dispose();
    guardian1Controller.dispose();
    guardian2Controller.dispose();
    super.onClose();
  }
}
