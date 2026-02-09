// lib/global/controler/settings/student_information_controler.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../model/settings/student_information_model.dart';
import '../../service/settings/student_information_service.dart';

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
    
    // Only reset hasNewPhoto if we're not in the middle of an update
    // This prevents the flag from being reset after picking a photo
    if (!isLoading.value) {
      hasNewPhoto.value = false;
    }
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
        requestFullMetadata: false, // Avoid metadata issues
      );

      if (pickedFile != null) {
        // Check if user picked the same file from cache
        final isSameFile = profilePhotoFile.value?.path == pickedFile.path;
        
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
        debugPrint('✅ hasNewPhoto flag set to: ${hasNewPhoto.value}');
        
        if (isSameFile) {
          debugPrint('⚠️ Same photo selected from cache');
        }
      } else {
        debugPrint('❌ No photo selected');
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
        // Try parsing "DD MMM YYYY" format first
        final parts = dobController.text.split(' ');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final monthMap = {
            'JAN': 1, 'FEB': 2, 'MAR': 3, 'APR': 4, 'MAY': 5, 'JUN': 6,
            'JUL': 7, 'AUG': 8, 'SEP': 9, 'OCT': 10, 'NOV': 11, 'DEC': 12
          };
          final month = monthMap[parts[1].toUpperCase()] ?? 1;
          final year = int.parse(parts[2]);
          initialDate = DateTime(year, month, day);
        } else {
          // Try standard parsing
          initialDate = DateTime.parse(dobController.text);
        }
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
      // Format: DD MMM YYYY (to match API format)
      const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 
                      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
      dobController.text =
          "${picked.day.toString().padLeft(2, '0')} ${months[picked.month - 1]} ${picked.year}";
    }
  }

  // Update student information
  Future<void> updateProfile() async {
    try {
      isLoading.value = true;

      // Check what has changed
      final hasPhotoChange = hasNewPhoto.value &&
          (profilePhotoFile.value != null || webProfilePhoto.value != null);

      // Only include fields that have actually changed
      final fields = <String, String>{};
      
      // Compare with original data to detect changes
      final originalData = studentInfo.value;
      
      if (originalData != null) {
        if (preferredNameController.text.trim() != (originalData.preferredName ?? '')) {
          fields['preferredName'] = preferredNameController.text.trim();
        }
        if (dobController.text.trim() != (originalData.dateOfBirth ?? '')) {
          fields['dateOfBirth'] = dobController.text.trim();
        }
        if (selectedGender.value != (originalData.gender ?? '')) {
          fields['gender'] = selectedGender.value;
        }
        if (guardian1Controller.text.trim() != (originalData.parentLegalGuardianOneName ?? '')) {
          fields['parentLegalGuardianOneName'] = guardian1Controller.text.trim();
        }
        if (guardian2Controller.text.trim() != (originalData.parentLegalGuardianTwoName ?? '')) {
          fields['parentLegalGuardianTwoName'] = guardian2Controller.text.trim();
        }
        if (selectedPronoun.value != (originalData.pronouns ?? '')) {
          fields['pronouns'] = selectedPronoun.value;
        }
      } else {
        // If no original data, include all non-empty fields
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
      }

      // Check if there's anything to update
      if (fields.isEmpty && !hasPhotoChange) {
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

      debugPrint('📝 Changed fields: ${fields.keys.join(", ")}');
      debugPrint('📸 Photo changed: $hasPhotoChange');

      final success = await StudentInformationService.updateStudentInformation(
        fields: fields,
        profilePhoto: hasNewPhoto.value ? profilePhotoFile.value : null,
        webProfilePhoto: hasNewPhoto.value ? webProfilePhoto.value : null,
      );

      if (success) {
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

        // Reset photo flag before reloading
        hasNewPhoto.value = false;

        // Reload data to get updated profile photo URL
        await loadStudentInformation();
      } else {
        if (Get.context != null) {
          Get.snackbar(
            'Error',
            'Failed to update profile. Please try again.',
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
