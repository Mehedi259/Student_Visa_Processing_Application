// lib/presentation/screens/settings/student_profile_update.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../core/custom_assets/assets.gen.dart';
import '../../../global/controler/settings/student_information_controler.dart';

class StudentProfileUpdateScreen extends StatelessWidget {
  const StudentProfileUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StudentInformationController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Assets.images.backIcon.image(width: 44, height: 44),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Profile Photo with tap to change
              GestureDetector(
                onTap: controller.pickProfilePhoto,
                child: Stack(
                  children: [
                    Obx(() {
                      return CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.blue.shade200,
                        child: ClipOval(
                          child: _buildProfileImage(controller),
                        ),
                      );
                    }),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF5B7FBF),
                          shape: BoxShape.circle,
                        ),
                        child: Assets.images.camera.image(width: 20, height: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Tap to change photo',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 30),

              _buildTextField(
                label: 'Preferred Name',
                controller: controller.preferredNameController,
                maxLength: 18,
              ),
              const SizedBox(height: 20),

              _buildTextField(
                label: 'Date of Birth',
                controller: controller.dobController,
                suffixIcon: Assets.images.dateOfBirthIcon,
                readOnly: true,
                onTap: () => controller.selectDateOfBirth(context),
              ),
              const SizedBox(height: 20),

              Obx(() => _buildDropdownField(
                label: 'Gender',
                value: controller.selectedGender.value,
                items: const ['Male', 'Female', 'Non-binary'],
                onChanged: (value) => controller.selectedGender.value = value!,
              )),
              const SizedBox(height: 20),

              _buildTextField(
                label: 'Parent / Legal Guardian 1',
                controller: controller.guardian1Controller,
              ),
              const SizedBox(height: 20),

              _buildTextField(
                label: 'Parent / Legal Guardian 2',
                controller: controller.guardian2Controller,
              ),
              const SizedBox(height: 20),

              Obx(() => _buildDropdownField(
                label: 'Pronouns',
                value: controller.selectedPronoun.value,
                items: const ['She / Her', 'He / Him', 'They / Them', 'Prefer not to say'],
                onChanged: (value) => controller.selectedPronoun.value = value!,
              )),
              const SizedBox(height: 40),

              // Save button with PATCH API
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    await controller.updateProfile();
                    // Go back after successful update
                    if (!controller.isLoading.value && context.mounted) {
                      context.pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B7FBF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // Build profile image widget with proper handling for web and mobile
  Widget _buildProfileImage(StudentInformationController controller) {
    // If user picked a new photo
    if (controller.hasNewPhoto.value) {
      if (kIsWeb && controller.webProfilePhoto.value != null) {
        // Web: Display from memory bytes
        return Image.memory(
          controller.webProfilePhoto.value!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        );
      } else if (!kIsWeb && controller.profilePhotoFile.value != null) {
        // Mobile: Display from file
        return Image.file(
          controller.profilePhotoFile.value!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        );
      }
    }

    // Display existing profile photo from URL
    if (controller.profilePhotoUrl.value.isNotEmpty &&
        controller.profilePhotoUrl.value.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: controller.profilePhotoUrl.value,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) =>
            Assets.images.abdullahAlJunaid.image(width: 120, height: 120, fit: BoxFit.cover),
      );
    }

    // Default placeholder image
    return Assets.images.abdullahAlJunaid.image(width: 120, height: 120, fit: BoxFit.cover);
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    AssetGenImage? suffixIcon,
    bool readOnly = false,
    int? maxLength,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          maxLength: maxLength,
          onTap: onTap,
          inputFormatters: maxLength != null
              ? [
            LengthLimitingTextInputFormatter(maxLength),
          ]
              : null,
          decoration: InputDecoration(
            counterText: '', // Hide the counter text below the field
            suffixIcon: suffixIcon != null
                ? Padding(padding: const EdgeInsets.all(12.0), child: suffixIcon.image(width: 20, height: 20))
                : null,
            border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF5B7FBF))),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF5B7FBF))),
          ),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
