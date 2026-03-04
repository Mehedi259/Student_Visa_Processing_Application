
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iywt/core/routes/routes.dart';

import '../../../core/custom_assets/assets.gen.dart';
import '../../../core/routes/route_path.dart';
import '../../../global/utils/snackbar_utils.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // Password validation states
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_validatePassword);
  }

  void _validatePassword() {
    final password = _newPasswordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  bool get _isPasswordValid =>
      _hasMinLength &&
          _hasUppercase &&
          _hasLowercase &&
          _hasNumber &&
          _hasSpecialChar;

  bool get _canSubmit =>
      _newPasswordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _isPasswordValid;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Assets.images.backIcon.image(
                      width: 44,
                      height: 44,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Title
                  const Text(
                    'Reset Password',
                    style: TextStyle(
                      color: Color(0xFF1D1B20),
                      fontSize: 18,
                      fontFamily: 'Nunito Sans',
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.50,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Subtitle
                  const Text(
                    'Set the new password for your account so you can login and access all the features',
                    style: TextStyle(
                      color: Color(0xFFC7C7C7),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                      letterSpacing: -0.50,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // New Password Label
                  const Text(
                    'New Password',
                    style: TextStyle(
                      color: Color(0xFF1D1B20),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // New Password Field
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: _obscureNewPassword,
                    style: const TextStyle(
                      color: Color(0xFF1D1B20),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.50,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter new password',
                      hintStyle: const TextStyle(
                        color: Color(0xFFC7C7C7),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.50,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNewPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: const Color(0xFFC7C7C7),
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFC7C7C7),
                          width: 0.50,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF375BA4),
                          width: 1.0,
                        ),
                      ),
                      errorBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 0.50,
                        ),
                      ),
                      focusedErrorBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 1.0,
                        ),
                      ),
                      contentPadding: const EdgeInsets.only(bottom: 12, right: 8),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Password Requirements
                  _buildPasswordRequirement(
                    'At least 8 characters',
                    _hasMinLength,
                  ),
                  const SizedBox(height: 8),
                  _buildPasswordRequirement(
                    'Must contain one uppercase letter',
                    _hasUppercase,
                  ),
                  const SizedBox(height: 8),
                  _buildPasswordRequirement(
                    'Must contain one lowercase letter',
                    _hasLowercase,
                  ),
                  const SizedBox(height: 8),
                  _buildPasswordRequirement(
                    'Must contain one number',
                    _hasNumber,
                  ),
                  const SizedBox(height: 8),
                  _buildPasswordRequirement(
                    'Must contain one special character',
                    _hasSpecialChar,
                  ),

                  const SizedBox(height: 32),

                  // Confirm Password Label
                  const Text(
                    'Confirm Password',
                    style: TextStyle(
                      color: Color(0xFF1D1B20),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: const TextStyle(
                      color: Color(0xFF1D1B20),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.50,
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'Re-enter password',
                      hintStyle: const TextStyle(
                        color: Color(0xFFC7C7C7),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.50,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: const Color(0xFFC7C7C7),
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFC7C7C7),
                          width: 0.50,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF375BA4),
                          width: 1.0,
                        ),
                      ),
                      errorBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 0.50,
                        ),
                      ),
                      focusedErrorBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 1.0,
                        ),
                      ),
                      contentPadding: const EdgeInsets.only(bottom: 12, right: 8),
                    ),
                    validator: (value) {
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 40),

                  // Reset Password Button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _canSubmit
                          ? () {
                        if (_formKey.currentState!.validate()) {
                          // Handle password reset
                          context.push(RoutePath.resetPasswordSuccess.addBasePath);
                          SnackbarUtils.showSuccess(context, 'Password reset successfully!');
                        }
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF375BA4),
                        disabledBackgroundColor: const Color(0x7F375BA4),
                        foregroundColor: const Color(0xFFFDFDFD),
                        disabledForegroundColor: const Color(0xFFFDFDFD),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            width: 1,
                            color: Color(0xFF375BA4),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.50,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRequirement(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.circle_outlined,
          color: isMet ? const Color(0xFF4CAF50) : const Color(0xFFC7C7C7),
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: isMet ? const Color(0xFF4CAF50) : const Color(0xFFC7C7C7),
            fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
            letterSpacing: -0.50,
          ),
        ),
      ],
    );
  }
}