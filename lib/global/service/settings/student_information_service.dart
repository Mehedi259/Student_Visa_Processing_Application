// lib/global/service/settings/student_information_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../constant/api_constant.dart';
import '../../model/settings/student_information_model.dart';
import '../api_services.dart';

class StudentInformationService {
  // Get Student Information
  static Future<StudentInformationModel?> getStudentInformation() async {
    try {
      final response =
          await ApiService.getRequest(ApiConstants.studentInformation);
      if (response != null) {
        return StudentInformationModel.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching student information: $e');
      rethrow;
    }
  }

  // Update Student Information (with photo upload) using PATCH
  static Future<bool> updateStudentInformation({
    required Map<String, String> fields,
    File? profilePhoto,
    Uint8List? webProfilePhoto,
  }) async {
    try {
      // Check if there's anything to update
      final hasFields = fields.isNotEmpty;
      final hasPhoto = (!kIsWeb && profilePhoto != null) ||
          (kIsWeb && webProfilePhoto != null);

      if (!hasFields && !hasPhoto) {
        debugPrint('⚠️ No data to update');
        return false;
      }

      Map<String, File>? files;
      Map<String, Uint8List>? webFiles;

      if (!kIsWeb && profilePhoto != null) {
        files = {'profilePhotoUrl': profilePhoto};
        debugPrint('📤 Uploading profile photo (mobile): ${profilePhoto.path}');
      }

      if (kIsWeb && webProfilePhoto != null) {
        webFiles = {'profilePhotoUrl': webProfilePhoto};
        debugPrint(
            '📤 Uploading profile photo (web): ${webProfilePhoto.length} bytes');
      }

      debugPrint('📤 Updating fields: ${fields.keys.join(", ")}');

      await ApiService.patchMultipartRequest(
        ApiConstants.studentInformation,
        fields: fields,
        files: files,
        webFiles: webFiles,
      );

      debugPrint('✅ Student information updated successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating student information: $e');
      return false;
    }
  }
}
