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
        // Check if file exists
        final fileExists = await profilePhoto.exists();
        debugPrint('📂 File exists: $fileExists');
        
        if (fileExists) {
          final fileSize = await profilePhoto.length();
          debugPrint('📏 File size: $fileSize bytes');
          files = {'profilePhotoUrl': profilePhoto};
          debugPrint('📤 Uploading profile photo (mobile): ${profilePhoto.path}');
        } else {
          debugPrint('❌ File does not exist: ${profilePhoto.path}');
          return false;
        }
      }

      if (kIsWeb && webProfilePhoto != null) {
        webFiles = {'profilePhotoUrl': webProfilePhoto};
        debugPrint(
            '📤 Uploading profile photo (web): ${webProfilePhoto.length} bytes');
      }

      debugPrint('📤 Updating fields: ${fields.keys.join(", ")}');

      final response = await ApiService.patchMultipartRequest(
        ApiConstants.studentInformation,
        fields: fields,
        files: files,
        webFiles: webFiles,
      );

      debugPrint('✅ Student information updated successfully');
      debugPrint('📥 Server response: $response');
      return true;
    } on Exception catch (e) {
      final errorMessage = e.toString();
      
      // Check if it's a "no modification" error
      if (errorMessage.contains('No documents were modified')) {
        debugPrint('⚠️ No changes detected by server (same data)');
        // Return true since data is already correct
        return true;
      }
      
      debugPrint('❌ Error updating student information: $e');
      return false;
    } catch (e) {
      debugPrint('❌ Error updating student information: $e');
      return false;
    }
  }
}
