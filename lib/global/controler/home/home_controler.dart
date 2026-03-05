// lib/global/controler/home/home_controler.dart

import 'package:get/get.dart';
import 'dart:developer' as developer;
import '../../model/home/home_model.dart';
import '../../model/settings/student_information_model.dart';
import '../../service/home/home_service.dart';
import '../../service/settings/student_information_service.dart';

class HomeController extends GetxController {
  // Observable variables
  final isLoading = false.obs;
  final Rx<DashboardModel?> dashboardData = Rx<DashboardModel?>(null);
  final Rx<StudentInformationModel?> studentInfo =
      Rx<StudentInformationModel?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  /// Fetch Initial Data (Dashboard + Student Info)
  Future<void> fetchInitialData() async {
    try {
      isLoading.value = true;

      // Fetch both APIs concurrently
      await Future.wait([
        fetchDashboard(),
        fetchStudentInformation(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch Dashboard Data
  Future<void> fetchDashboard() async {
    try {
      developer.log('🔄 Fetching dashboard data', name: 'HomeController');

      final result = await HomeService.getDashboard();

      if (result != null && result['success'] == true) {
        dashboardData.value = result['data'] as DashboardModel?;
        developer.log('✅ Dashboard loaded successfully',
            name: 'HomeController');
      } else {
        developer.log(
            '❌ Dashboard fetch failed: ${result?['error'] ?? 'Unknown error'}',
            name: 'HomeController');
      }
    } catch (e) {
      developer.log('❌ Dashboard error: $e', name: 'HomeController');
    }
  }

  /// Fetch Student Information
  Future<void> fetchStudentInformation() async {
    try {
      developer.log('🔄 Fetching student information', name: 'HomeController');

      final result = await StudentInformationService.getStudentInformation();

      if (result != null) {
        studentInfo.value = result;
        developer.log('✅ Student information loaded successfully',
            name: 'HomeController');
      } else {
        developer.log('❌ Student information fetch failed',
            name: 'HomeController');
      }
    } catch (e) {
      developer.log('❌ Student information error: $e', name: 'HomeController');
    }
  }

  /// Refresh Dashboard
  Future<void> refreshDashboard() async {
    await fetchInitialData();
  }

  /// Get greeting based on time
  String getGreeting() {
    // Get current local time
    final now = DateTime.now();
    final hour = now.hour;

    developer.log('Current hour: $hour', name: 'HomeController');

    if (hour >= 5 && hour < 12) {
      return 'Good Morning!';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon!';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening!';
    } else {
      return 'Good Night!';
    }
  }

  /// Get display name (preferredName from StudentInformation API)
  String get displayName {
    return studentInfo.value?.preferredName ??
        dashboardData.value?.fullName ??
        'User';
  }
}
