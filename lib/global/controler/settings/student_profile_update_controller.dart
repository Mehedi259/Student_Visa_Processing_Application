// lib/global/controller/settings/student_profile_update_controller.dart

import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../model/settings/student_profile_update_model.dart';
import '../../service/settings/student_profile_update_service.dart';

class StudentProfileUpdateController extends GetxController {
  // ---------------------------------------------------------------------------
  // Observable State
  // ---------------------------------------------------------------------------
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();

  // Form fields
  final preferredName = ''.obs;
  final dateOfBirth = ''.obs;
  final gender = 'Male'.obs;
  final guardian1 = ''.obs;
  final guardian2 = ''.obs;
  final pronouns = 'Prefer not to say'.obs;

  // Profile photo state
  final Rx<File?> selectedImageFile = Rx<File?>(null);            // Mobile/Desktop
  final Rx<Uint8List?> selectedImageBytes = Rx<Uint8List?>(null); // Web

  // Direct API profile photo URL (no caching, no storage)
  final apiProfilePhotoUrl = RxnString();

  // ---------------------------------------------------------------------------
  // Dropdown Options
  // ---------------------------------------------------------------------------
  final genderOptions = ['Male', 'Female', 'Non-binary'];
  final pronounOptions = [
    'She / Her',
    'He / Him',
    'They / Them',
    'Prefer not to say',
  ];

  final _picker = ImagePicker();

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------
  @override
  void onInit() {
    super.onInit();
    fetchStudentProfile();
  }

  // ---------------------------------------------------------------------------
  // Fetch Profile
  // ---------------------------------------------------------------------------
  Future<void> fetchStudentProfile() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final model = await StudentProfileUpdateService.getStudentInformation();
      _populateFields(model);
      developer.log('Profile loaded into controller',
          name: 'StudentProfileUpdateController');
    } catch (e) {
      errorMessage.value = 'Failed to load profile. Please try again.';
      developer.log('fetchStudentProfile error: $e',
          name: 'StudentProfileUpdateController');
    } finally {
      isLoading.value = false;
    }
  }

  void _populateFields(StudentProfileUpdateModel model) {
    preferredName.value = model.preferredName ?? '';
    dateOfBirth.value = model.dateOfBirth ?? '';
    gender.value = _validGender(model.gender);
    guardian1.value = model.parentLegalGuardianOneName ?? '';
    guardian2.value = model.parentLegalGuardianTwoName ?? '';
    pronouns.value = _validPronoun(model.pronouns);

    // Store direct API URL without any caching
    apiProfilePhotoUrl.value = model.profilePhotoUrl;
  }

  // ---------------------------------------------------------------------------
  // Image Picker
  // ---------------------------------------------------------------------------
  Future<void> pickImageFromGallery() async => _pickImage(ImageSource.gallery);
  Future<void> pickImageFromCamera() async => _pickImage(ImageSource.camera);

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (picked == null) return;

      if (kIsWeb) {
        selectedImageBytes.value = await picked.readAsBytes();
        selectedImageFile.value = null;
      } else {
        selectedImageFile.value = File(picked.path);
        selectedImageBytes.value = null;
      }

      developer.log('Image selected: ${picked.path}',
          name: 'StudentProfileUpdateController');
    } catch (e) {
      developer.log('Image pick error: $e',
          name: 'StudentProfileUpdateController');
      _showError('Could not select image. Please try again.');
    }
  }

  // ---------------------------------------------------------------------------
  // Date of Birth
  // ---------------------------------------------------------------------------
  void setDateOfBirth(DateTime date) {
    // API expected format: "14 JAN 2002"
    dateOfBirth.value = DateFormat('dd MMM yyyy').format(date).toUpperCase();
  }

  // ---------------------------------------------------------------------------
  // Save Changes
  // ---------------------------------------------------------------------------
  Future<void> saveChanges() async {
    if (isSaving.value) return;

    isSaving.value = true;
    errorMessage.value = null;

    try {
      final hasNewImage = (!kIsWeb && selectedImageFile.value != null) ||
          (kIsWeb && selectedImageBytes.value != null);

      final model = StudentProfileUpdateModel(
        preferredName: preferredName.value.trim(),
        dateOfBirth: dateOfBirth.value.trim(),
        gender: gender.value,
        parentLegalGuardianOneName: guardian1.value.trim(),
        parentLegalGuardianTwoName: guardian2.value.trim(),
        pronouns: pronouns.value,
      );

      await StudentProfileUpdateService.updateStudentInformation(
        model: model,
        profileImageFile: kIsWeb ? null : selectedImageFile.value,
        profileImageBytes: kIsWeb ? selectedImageBytes.value : null,
      );

      // After successful upload, clear local selection and refresh from API
      if (hasNewImage) {
        selectedImageFile.value = null;
        selectedImageBytes.value = null;
        // Re-fetch profile to get updated photo URL from API
        await fetchStudentProfile();
      }

      developer.log('Profile saved successfully',
          name: 'StudentProfileUpdateController');

      _showSuccess('Profile updated successfully!');
    } catch (e) {
      errorMessage.value = 'Failed to save profile. Please try again.';
      developer.log('saveChanges error: $e',
          name: 'StudentProfileUpdateController');
      _showError('Could not update profile. Please try again.');
    } finally {
      isSaving.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  String _validGender(String? value) {
    const options = ['Male', 'Female', 'Non-binary'];
    return options.contains(value) ? value! : 'Male';
  }

  String _validPronoun(String? value) {
    const options = [
      'She / Her',
      'He / Him',
      'They / Them',
      'Prefer not to say',
    ];
    return options.contains(value) ? value! : 'Prefer not to say';
  }

  bool get hasLocalImage =>
      (!kIsWeb && selectedImageFile.value != null) ||
          (kIsWeb && selectedImageBytes.value != null);

  // ---------------------------------------------------------------------------
  // Snackbar helpers — safe wrappers that prevent the null overlay crash
  //
  // Root cause: Get.snackbar internally calls Get.context, which is null
  // during a GoRouter transition (the overlay is momentarily unmounted).
  // We guard with a null check and an isSnackbarOpen guard to be safe.
  // ---------------------------------------------------------------------------
  void _showSuccess(String message) {
    _safeSnackbar(
      title: 'Success',
      message: message,
      backgroundColor: Colors.green.shade600,
    );
  }

  void _showError(String message) {
    _safeSnackbar(
      title: 'Error',
      message: message,
      backgroundColor: Colors.red.shade600,
    );
  }

  void _safeSnackbar({
    required String title,
    required String message,
    required Color backgroundColor,
  }) {
    // Prevent stacking multiple snackbars
    if (Get.isSnackbarOpen) return;

    // Get.context is null when no overlay is active (e.g. mid-GoRouter push).
    // Without this guard, SnackbarController throws:
    //   "Null check operator used on a null value" at snackbar_controller.dart:94
    if (Get.context == null) {
      developer.log('Snackbar skipped — no active context',
          name: 'StudentProfileUpdateController');
      return;
    }

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}