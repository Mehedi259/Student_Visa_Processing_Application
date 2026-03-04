// ============================================
// lib/presentation/screens/settings/my_information.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iywt/core/routes/routes.dart';
import '../../../core/custom_assets/assets.gen.dart';
import '../../../core/routes/route_path.dart';

class MyInformationScreen extends StatelessWidget {
  const MyInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          child: IconButton(
            icon: Assets.images.backIcon.image(width: 44, height: 44),
            onPressed: () => context.pop(),
          ),
        ),
        title: const Text(
          'My information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildOptionTile(
              context: context,
              icon: Assets.images.myInformation,
              title: 'Student Information',
              onTap: () =>
                  context.push(RoutePath.studentInformation.addBasePath),
            ),
            const SizedBox(height: 12),
            _buildOptionTile(
              context: context,
              icon: Assets.images.location,
              title: 'Address',
              onTap: () => context.push(RoutePath.address.addBasePath),
            ),
            const SizedBox(height: 12),
            _buildOptionTile(
              context: context,
              icon: Assets.images.email,
              title: 'Email',
              onTap: () => context.push(RoutePath.email.addBasePath),
            ),
            const SizedBox(height: 12),
            _buildOptionTile(
              context: context,
              icon: Assets.images.phone,
              title: 'Phone',
              onTap: () => context.push(RoutePath.phone.addBasePath),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required AssetGenImage icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            icon.image(width: 24, height: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
