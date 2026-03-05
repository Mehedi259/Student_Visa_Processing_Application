// lib/features/settings/student_profile_update_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../core/custom_assets/assets.gen.dart';
import '../../../global/controler/settings/student_profile_update_controller.dart';


class StudentProfileUpdateScreen extends StatelessWidget {
  const StudentProfileUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StudentProfileUpdateController());

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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
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
              // Profile photo
              _ProfilePhoto(controller: controller),
              const SizedBox(height: 30),

              // Preferred Name
              _ObxTextField(
                label: 'Preferred Name',
                initialValue: controller.preferredName.value,
                maxLength: 18,
                onChanged: (v) => controller.preferredName.value = v,
              ),
              const SizedBox(height: 20),

              // Date of Birth
              _DateField(controller: controller),
              const SizedBox(height: 20),

              // Gender
              _ObxDropdown(
                label: 'Gender',
                value: controller.gender,
                items: controller.genderOptions,
                onChanged: (v) => controller.gender.value = v!,
              ),
              const SizedBox(height: 20),

              // Parent / Legal Guardian 1
              _ObxTextField(
                label: 'Parent / Legal Guardian 1',
                initialValue: controller.guardian1.value,
                onChanged: (v) => controller.guardian1.value = v,
              ),
              const SizedBox(height: 20),

              // Parent / Legal Guardian 2
              _ObxTextField(
                label: 'Parent / Legal Guardian 2',
                initialValue: controller.guardian2.value,
                onChanged: (v) => controller.guardian2.value = v,
              ),
              const SizedBox(height: 20),

              // Pronouns
              _ObxDropdown(
                label: 'Pronouns',
                value: controller.pronouns,
                items: controller.pronounOptions,
                onChanged: (v) => controller.pronouns.value = v!,
              ),
              const SizedBox(height: 40),

              // Error message
              if (controller.errorMessage.value != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    controller.errorMessage.value!,
                    style:
                    const TextStyle(color: Colors.red, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isSaving.value
                      ? null
                      : () async {
                    await controller.saveChanges();
                    // Show success message if no error
                    if (context.mounted && controller.errorMessage.value == null) {
                      // Import SnackbarUtils at the top
                      // ignore: use_build_context_synchronously
                      context.pop();
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Profile updated successfully',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: const Color(0xFF28A745),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          elevation: 6,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B7FBF),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                    const Color(0xFF5B7FBF).withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isSaving.value
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }
}

// =============================================================================
// Profile Photo
// =============================================================================

class _ProfilePhoto extends StatelessWidget {
  final StudentProfileUpdateController controller;

  const _ProfilePhoto({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showPickerSheet(context),
          child: Stack(
            children: [
              Obx(() {
                final image = _resolveImage();
                return CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade200,
                  // Use a unique key derived from the current image source so
                  // Flutter rebuilds the widget when the image changes.
                  key: ValueKey(_imageKey()),
                  backgroundImage: image,
                  child: image == null
                      ? const Icon(Icons.person,
                      size: 60, color: Colors.grey)
                      : null,
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
                  child: const Icon(
                    Icons.camera_alt,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to change photo',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  // Priority: local file (just picked) > local bytes (web) > direct API URL
  ImageProvider? _resolveImage() {
    if (!kIsWeb && controller.selectedImageFile.value != null) {
      return FileImage(controller.selectedImageFile.value!);
    }
    if (kIsWeb && controller.selectedImageBytes.value != null) {
      return MemoryImage(controller.selectedImageBytes.value!);
    }
    final url = controller.apiProfilePhotoUrl.value;
    if (url != null && url.isNotEmpty) {
      // Direct URL from GET API - no caching, no storage
      return NetworkImage(url);
    }
    return null;
  }

  // Unique string that changes whenever the displayed image changes.
  // Used as a ValueKey on CircleAvatar so Flutter fully rebuilds the widget
  // instead of reusing the old render object with the cached image.
  String _imageKey() {
    if (!kIsWeb && controller.selectedImageFile.value != null) {
      return controller.selectedImageFile.value!.path;
    }
    if (kIsWeb && controller.selectedImageBytes.value != null) {
      return 'web_${controller.selectedImageBytes.value!.length}';
    }
    return controller.apiProfilePhotoUrl.value ?? 'no_image';
  }

  void _showPickerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Change Photo',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                controller.pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                controller.pickImageFromCamera();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Reactive TextField
// =============================================================================

class _ObxTextField extends StatefulWidget {
  final String label;
  final String initialValue;
  final int? maxLength;
  final ValueChanged<String> onChanged;
  final bool readOnly;
  final IconData? suffixIcon;
  final VoidCallback? onTap;

  const _ObxTextField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.maxLength,
    this.readOnly = false,
    this.suffixIcon,
    this.onTap,
  });

  @override
  State<_ObxTextField> createState() => _ObxTextFieldState();
}

class _ObxTextFieldState extends State<_ObxTextField> {
  late TextEditingController _textController;
  bool _initialised = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_ObxTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Populate the field the first time a non-empty value arrives from the API
    if (!_initialised &&
        widget.initialValue.isNotEmpty &&
        _textController.text.isEmpty) {
      _textController.text = widget.initialValue;
      _initialised = true;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
        const SizedBox(height: 8),
        TextField(
          controller: _textController,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          maxLength: widget.maxLength,
          inputFormatters: widget.maxLength != null
              ? [LengthLimitingTextInputFormatter(widget.maxLength!)]
              : null,
          decoration: InputDecoration(
            counterText: '',
            suffixIcon: widget.suffixIcon != null
                ? Icon(widget.suffixIcon, size: 20)
                : null,
            border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF5B7FBF))),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Date Field
// =============================================================================

class _DateField extends StatelessWidget {
  final StudentProfileUpdateController controller;
  const _DateField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => _ObxTextField(
      label: 'Date of Birth',
      initialValue: controller.dateOfBirth.value,
      readOnly: true,
      suffixIcon: Icons.calendar_today,
      onChanged: (_) {},
      onTap: () => _selectDate(context),
    ));
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initial = DateTime(2000);

    try {
      if (controller.dateOfBirth.value.isNotEmpty) {
        initial = DateTime.parse(
          controller.dateOfBirth.value.replaceAllMapped(
            RegExp(r'(\d{2}) ([A-Z]{3}) (\d{4})'),
                (m) => '${m[3]}-${_monthNum(m[2]!)}-${m[1]}',
          ),
        );
      }
    } catch (_) {}

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
          const ColorScheme.light(primary: Color(0xFF5B7FBF)),
        ),
        child: child!,
      ),
    );

    if (picked != null) controller.setDateOfBirth(picked);
  }

  String _monthNum(String m) {
    const map = {
      'JAN': '01', 'FEB': '02', 'MAR': '03', 'APR': '04',
      'MAY': '05', 'JUN': '06', 'JUL': '07', 'AUG': '08',
      'SEP': '09', 'OCT': '10', 'NOV': '11', 'DEC': '12',
    };
    return map[m] ?? '01';
  }
}

// =============================================================================
// Reactive Dropdown
// =============================================================================

class _ObxDropdown extends StatelessWidget {
  final String label;
  final RxString value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _ObxDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
            TextStyle(fontSize: 14, color: Colors.grey.shade500)),
        const SizedBox(height: 8),
        Obx(() => DropdownButtonFormField<String>(
          value: value.value,
          decoration: InputDecoration(
            border: UnderlineInputBorder(
                borderSide:
                BorderSide(color: Colors.grey.shade300)),
            enabledBorder: UnderlineInputBorder(
                borderSide:
                BorderSide(color: Colors.grey.shade300)),
            focusedBorder: const UnderlineInputBorder(
                borderSide:
                BorderSide(color: Color(0xFF5B7FBF))),
          ),
          items: items
              .map((i) =>
              DropdownMenuItem(value: i, child: Text(i)))
              .toList(),
          onChanged: onChanged,
        )),
      ],
    );
  }
}