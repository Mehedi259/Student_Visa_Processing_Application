// lib/presentation/screens/authentication/login.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/custom_assets/assets.gen.dart';
import '../../../global/controler/auth/login_controler.dart';
import '../../../global/utils/snackbar_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginController controller;
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(LoginController());

    // Listen to focus changes
    _emailFocusNode.addListener(() {
      setState(() {
        _isEmailFocused = _emailFocusNode.hasFocus;
      });
    });

    _passwordFocusNode.addListener(() {
      setState(() {
        _isPasswordFocused = _passwordFocusNode.hasFocus;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setContext(context);
    });
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  /// Launch Register URL in external browser
  Future<void> _launchRegisterUrl() async {
    final url = Uri.parse('https://world.iywt.com/portal');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          SnackbarUtils.showError(context, 'Could not open registration page');
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF1D1B20),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Top Background Image
            Positioned(
              left: -7,
              top: -28,
              child: Container(
                width: 408,
                height: 408,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(Assets.images.globeHand.path),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Logo
            Positioned(
              left: 0,
              right: 0,
              top: 120,
              child: Column(
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(Assets.images.splashScreenLogo.path),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Login Section
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              left: 0,
              right: 0,
              top: viewInsets > 0 ? 0 : 347,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF375BA4),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
                ),
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Color(0xFFFDFDFD),
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: controller.emailController,
                        focusNode: _emailFocusNode,
                        hint: 'Email',
                        isFocused: _isEmailFocused,
                      ),
                      const SizedBox(height: 8),
                      Obx(() => _buildTextField(
                            controller: controller.passwordController,
                            focusNode: _passwordFocusNode,
                            hint: 'Password',
                            isFocused: _isPasswordFocused,
                            obscureText: controller.obscurePassword.value,
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.obscurePassword.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color(0xFFE7E7E7),
                                size: 16,
                              ),
                              onPressed: controller.togglePasswordVisibility,
                            ),
                          )),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => _launchRegisterUrl(),
                            child: const Text(
                              'Register?',
                              style: TextStyle(
                                color: Color(0xFFFDFDFD),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push('/forgetPassword'),
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                color: Color(0xFFFDFDFD),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildRememberMeCheckbox(controller),
                      const SizedBox(height: 8),
                      _buildLoginButtonRow(controller),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required bool isFocused,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 52.63,
      decoration: BoxDecoration(
        border: Border.all(
          color: isFocused ? const Color(0xFFFDFDFD) : const Color(0xFFC7C7C7),
          width: isFocused ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(10),
        color: isFocused ? const Color(0xFF2E4A7F) : Colors.transparent,
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: const Color(0xFFFDFDFD).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        style: const TextStyle(
          color: Color(0xFFE7E7E7),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: isFocused
                ? const Color(0xFFE7E7E7).withOpacity(0.7)
                : const Color(0xFFE7E7E7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _buildRememberMeCheckbox(LoginController controller) {
    return Obx(() => Row(
          children: [
            GestureDetector(
              onTap: controller.toggleRememberMe,
              child: Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  color: controller.rememberMe.value
                      ? const Color(0xFFF5F5F7)
                      : Colors.transparent,
                  border: Border.all(color: const Color(0xFFF5F5F7), width: 1),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: controller.rememberMe.value
                    ? const Icon(Icons.check,
                        size: 12, color: Color(0xFF375BA4))
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: controller.toggleRememberMe,
              child: const Text(
                'Remember me',
                style: TextStyle(
                  color: Color(0xFFE7E7E7),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildLoginButtonRow(LoginController controller) {
    return Row(
      children: [
        Expanded(
          child: Obx(() => GestureDetector(
                onTap:
                    controller.isLoading.value ? null : controller.handleLogin,
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDFDFD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF375BA4),
                            ),
                          ),
                        )
                      : const Text(
                          'Log in',
                          style: TextStyle(
                            color: Color(0xFF375BA4),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              )),
        ),
        const SizedBox(width: 8),
        Obx(() => GestureDetector(
              onTap: controller.canUseBiometric.value
                  ? controller.handleBiometricLogin
                  : null,
              child: Opacity(
                opacity: controller.canUseBiometric.value ? 1.0 : 0.5,
                child: Image.asset(
                  Assets.images.loginScreenFaceIcon.path,
                  width: 60,
                  height: 60,
                ),
              ),
            )),
      ],
    );
  }
}
