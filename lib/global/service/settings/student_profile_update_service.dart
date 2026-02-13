// lib/global/service/settings/student_profile_update_service.dart

import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

import '../../constant/api_constant.dart';
import '../../service/api_services.dart';
import '../../model/settings/student_profile_update_model.dart';

class StudentProfileUpdateService {
  static Future<StudentProfileUpdateModel> getStudentInformation() async {
    try {
      developer.log('📥 Fetching student profile info...', name: 'StudentProfileUpdateService');

      final response = await ApiService.getRequest(
        ApiConstants.studentInformation,
      );

      developer.log('✅ Student profile fetched: $response', name: 'StudentProfileUpdateService');

      return StudentProfileUpdateModel.fromJson(
        Map<String, dynamic>.from(response),
      );
    } catch (e) {
      developer.log('❌ Error fetching student profile: $e', name: 'StudentProfileUpdateService');
      throw Exception('Failed to fetch student profile: $e');
    }
  }

  static Future<bool> updateStudentInformation({
    required StudentProfileUpdateModel model,
    File? profileImageFile,         // Mobile/Desktop
    Uint8List? profileImageBytes,   // Web
  }) async {
    try {
      final fields = model.toFormFields();

      developer.log('📤 Updating student profile...', name: 'StudentProfileUpdateService');
      developer.log('📦 Fields: $fields', name: 'StudentProfileUpdateService');

      Map<String, File>? files;
      Map<String, Uint8List>? webFiles;


      if (!kIsWeb && profileImageFile != null) {
        files = {'profilePhotoUrl': profileImageFile};
        developer.log('📎 Mobile image attached: ${profileImageFile.path}',
            name: 'StudentProfileUpdateService');
      }


      if (kIsWeb && profileImageBytes != null) {
        webFiles = {'profilePhotoUrl': profileImageBytes};
        developer.log('📎 Web image attached: ${profileImageBytes.length} bytes',
            name: 'StudentProfileUpdateService');
      }

      await ApiService.patchMultipartRequest(
        ApiConstants.studentInformation,
        fields: fields,
        files: files,
        webFiles: webFiles,
      );

      developer.log('✅ Student profile updated successfully', name: 'StudentProfileUpdateService');
      return true;
    } catch (e) {
      developer.log('❌ Error updating student profile: $e', name: 'StudentProfileUpdateService');
      throw Exception('Failed to update student profile: $e');
    }
  }
}
