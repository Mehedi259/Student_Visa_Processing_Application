// lib/presentation/screens/settings/settings.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:iywt/core/routes/routes.dart';
import '../../../core/custom_assets/assets.gen.dart';
import '../../../core/routes/route_path.dart';
import '../../../global/controler/home/home_controler.dart';
import '../../../global/controler/settings/student_information_controler.dart';
import '../../../global/storage/storage_helper.dart';
import '../../widgets/custom_navigation/custom_navbar.dart';
import '../../../global/utils/snackbar_utils.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentController = Get.put(StudentInformationController());

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1D1B20),
            fontFamily: 'Nunito Sans',
          ),
        ),
        backgroundColor: const Color(0xFFFDFDFD),
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() => RefreshIndicator(
            onRefresh: () async {
              await studentController.loadStudentInformation();
            },
            color: const Color(0xFF375BA4),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      kToolbarHeight -
                      kBottomNavigationBarHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

                      // Profile Section
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 13, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: studentController
                                      .profilePhotoUrl.value.isEmpty
                                  ? Assets.images.abdullahAlJunaid.image(
                                      width: 60, height: 60, fit: BoxFit.cover)
                                  : Image.network(
                                      studentController.profilePhotoUrl.value,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return SizedBox(
                                          width: 60,
                                          height: 60,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                      loadingProgress.expectedTotalBytes!
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) =>
                                          Assets.images.abdullahAlJunaid.image(
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover),
                                    ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              studentController
                                      .preferredNameController.text.isEmpty
                                  ? 'Student Name'
                                  : studentController
                                      .preferredNameController.text,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1D1B20),
                                fontFamily: 'Nunito Sans',
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        height: 0.5,
                        color: const Color(0xFFC7C7C7),
                      ),

                      const SizedBox(height: 18),

                      _buildSettingOption(
                        context: context,
                        icon: Assets.images.myInformation,
                        title: 'My Information',
                        onTap: () =>
                            context.go(RoutePath.myInformation.addBasePath),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        height: 0.5,
                        color: const Color(0xFFC7C7C7),
                      ),

                      const SizedBox(height: 18),

                      _buildSettingOption(
                        context: context,
                        icon: Assets.images.tecnicalSupport,
                        title: 'Technical Support',
                        onTap: () =>
                            context.go(RoutePath.technicalSupport.addBasePath),
                      ),

                      _buildSettingOption(
                        context: context,
                        icon: Assets.images.privacyPolicy,
                        title: 'Privacy Policy',
                        onTap: () =>
                            context.go(RoutePath.privacyPolicy.addBasePath),
                      ),

                      const Spacer(),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: OutlinedButton(
                          onPressed: () => _showLogoutDialog(context),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 44),
                            side: const BorderSide(
                                color: Color(0xFF375BA4), width: 1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF375BA4),
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          )),
      bottomNavigationBar: const CustomNavBar(currentIndex: 4),
    );
  }

  Widget _buildSettingOption({
    required BuildContext context,
    required AssetGenImage icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              icon.image(width: 24, height: 24),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1D1B20),
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Close dialog first
                Navigator.of(context).pop();

                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF375BA4),
                    ),
                  ),
                );

                // Clear all stored data
                await StorageHelper.clearToken();
                await StorageHelper.clearRefreshToken();
                await StorageHelper.clearRememberMe();

                // Delete all GetX controllers to clear cached data
                Get.delete<StudentInformationController>(force: true);
                Get.delete<HomeController>(force: true);
                try {
                  Get.delete(force: true); // Delete all controllers
                } catch (e) {
                  print("⚠️ Error deleting controllers: $e");
                }

                // Close loading dialog
                if (context.mounted) {
                  Navigator.of(context).pop();
                }

                // Navigate to login screen
                if (context.mounted) {
                  context.go(RoutePath.login.addBasePath);
                }

                // Show success message
                if (context.mounted) {
                  SnackbarUtils.showSuccess(context, 'Logged out successfully');
                }

                print("✅ Logout successful - Token cleared and controllers deleted");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF375BA4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
