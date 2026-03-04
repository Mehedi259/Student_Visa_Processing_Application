// lib/features/auth/screens/forgot_password_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/custom_assets/assets.gen.dart';
import '../../../core/routes/route_path.dart';
import '../../../core/routes/routes.dart';
import '../../../global/controler/auth/forget_password_controler.dart';
import '../../../global/utils/snackbar_utils.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late ForgotPasswordController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ForgotPasswordController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _controller.dispose();
    super.dispose();
  }

  bool get _isButtonEnabled => _emailController.text.isNotEmpty;

  void _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();

      final success = await _controller.sendResetPasswordEmail(email);

      if (!mounted) return;

      if (success) {
        // Show success message
        SnackbarUtils.showSuccess(
          context,
          _controller.successMessage ??
              'Password reset link sent to your email!',
        );

        // Navigate to OTP screen after delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.push(RoutePath.forgetPasswordOtp.addBasePath);
          }
        });
      } else {
        // Show error message
        SnackbarUtils.showError(
          context,
          _controller.errorMessage ?? 'Failed to send reset email',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDFD),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    'Forgot password',
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
                    'Please enter your email to reset the password',
                    style: TextStyle(
                      color: Color(0xFFC7C7C7),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                      letterSpacing: -0.50,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Email Label
                  const Text(
                    'Your Email',
                    style: TextStyle(
                      color: Color(0xFF1D1B20),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Email Input Field
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        color: Color(0xFF1D1B20),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.50,
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                      decoration: const InputDecoration(
                        hintText: 'Enter your email',
                        hintStyle: TextStyle(
                          color: Color(0xFFC7C7C7),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.50,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFFC7C7C7),
                            width: 0.50,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF375BA4),
                            width: 1.0,
                          ),
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 0.50,
                          ),
                        ),
                        focusedErrorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 1.0,
                          ),
                        ),
                        contentPadding: EdgeInsets.only(bottom: 12, right: 8),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 57),

                  // Reset Password Button
                  Consumer<ForgotPasswordController>(
                    builder: (context, controller, child) {
                      return SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: controller.isLoading
                              ? null
                              : (_isButtonEnabled
                                  ? _handleResetPassword
                                  : null),
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
                          child: controller.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFFFDFDFD),
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Reset Password',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.50,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
