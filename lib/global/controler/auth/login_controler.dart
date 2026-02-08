// lib/global/controler/auth/login_controler.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:developer' as developer;
import '../../service/auth/login_service.dart';
import '../../storage/storage_helper.dart';

class LoginController extends GetxController {
  // Observable variables
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final rememberMe = false.obs;
  final canUseBiometric = false.obs;

  // Text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Local Auth
  final LocalAuthentication _localAuth = LocalAuthentication();

  // BuildContext reference
  BuildContext? _context;

  void setContext(BuildContext context) {
    _context = context;
  }

  @override
  void onInit() {
    super.onInit();
    _checkBiometricAvailability();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// Check if biometric login is available
  Future<void> _checkBiometricAvailability() async {
    try {
      final canCheck = await StorageHelper.canUseBiometricLogin();
      canUseBiometric.value = canCheck;

      if (canCheck) {
        // Also load remember me state
        rememberMe.value = await StorageHelper.getRememberMe();
      }

      developer.log('🔐 Biometric available: $canCheck',
          name: 'LoginController');
    } catch (e) {
      developer.log('❌ Error checking biometric: $e', name: 'LoginController');
      canUseBiometric.value = false;
    }
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  /// Toggle remember me
  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  /// Show SnackBar
  void _showSnackBar(String message, {bool isError = false}) {
    if (_context == null || !_context!.mounted) return;

    ScaffoldMessenger.of(_context!).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Validate input
  bool _validateInput() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      _showSnackBar('Please enter your email', isError: true);
      return false;
    }

    if (!GetUtils.isEmail(email)) {
      _showSnackBar('Please enter a valid email', isError: true);
      return false;
    }

    if (password.isEmpty) {
      _showSnackBar('Please enter your password', isError: true);
      return false;
    }

    return true;
  }

  /// Handle biometric authentication
  Future<void> handleBiometricLogin() async {
    if (!canUseBiometric.value) {
      _showSnackBar('Biometric login not available', isError: true);
      return;
    }

    try {
      // Check if device supports biometric
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      if (!canAuthenticate) {
        _showSnackBar('Biometric not supported on this device', isError: true);
        return;
      }

      // Get available biometrics
      final availableBiometrics = await _localAuth.getAvailableBiometrics();

      if (availableBiometrics.isEmpty) {
        _showSnackBar('No biometric enrolled on this device', isError: true);
        return;
      }

      developer.log('🔐 Starting biometric authentication',
          name: 'LoginController');
      developer.log('📱 Available biometrics: $availableBiometrics',
          name: 'LoginController');

      // Authenticate
      final bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to login',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow PIN/Pattern as fallback
        ),
      );

      if (authenticated) {
        developer.log('✅ Biometric authentication successful',
            name: 'LoginController');

        // Check if refresh token exists
        final refreshToken = await StorageHelper.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          _showSnackBar('Session expired. Please login again.', isError: true);
          canUseBiometric.value = false;
          await StorageHelper.clearRememberMe();
          return;
        }

        // Show loading state
        isLoading.value = true;

        developer.log('🔄 Refreshing access token with refresh token',
            name: 'LoginController');

        // Call refresh token API to get new access token
        final result = await LoginService.refreshAccessToken();

        isLoading.value = false;

        if (result['success'] == true) {
          developer.log('✅ Access token refreshed successfully',
              name: 'LoginController');
          _showSnackBar('Login successful!', isError: false);

          await Future.delayed(const Duration(milliseconds: 500));

          if (_context != null && _context!.mounted) {
            _context!.go('/home');
          }
        } else {
          developer.log('❌ Token refresh failed: ${result['error']}',
              name: 'LoginController');
          _showSnackBar(
            result['error'] ?? 'Session expired. Please login again.',
            isError: true,
          );
          canUseBiometric.value = false;
          await StorageHelper.clearRememberMe();
        }
      } else {
        developer.log('❌ Biometric authentication failed',
            name: 'LoginController');
        _showSnackBar('Authentication failed', isError: true);
      }
    } on PlatformException catch (e) {
      developer.log('❌ Biometric error: ${e.code} - ${e.message}',
          name: 'LoginController');

      if (e.code == 'NotAvailable') {
        _showSnackBar('Biometric not available', isError: true);
      } else if (e.code == 'NotEnrolled') {
        _showSnackBar('No biometric enrolled', isError: true);
      } else if (e.code == 'LockedOut') {
        _showSnackBar('Too many attempts. Try again later.', isError: true);
      } else if (e.code == 'PermanentlyLockedOut') {
        _showSnackBar('Biometric is permanently locked', isError: true);
      } else {
        _showSnackBar('Authentication error: ${e.message}', isError: true);
      }
    } catch (e) {
      developer.log('❌ Biometric error: $e', name: 'LoginController');
      _showSnackBar('An error occurred', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  /// Handle regular login
  Future<void> handleLogin() async {
    if (!_validateInput()) return;
    if (_context == null || !_context!.mounted) return;

    try {
      isLoading.value = true;

      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      developer.log('🚀 Login attempt started', name: 'LoginController');

      final result = await LoginService.login(
        email: email,
        password: password,
      );

      if (result['success'] == true) {
        developer.log('✅ Login successful', name: 'LoginController');

        // Save remember me preference
        await StorageHelper.saveRememberMe(rememberMe.value);

        // Update biometric availability
        await _checkBiometricAvailability();

        _showSnackBar('Login successful!', isError: false);

        await Future.delayed(const Duration(milliseconds: 500));

        if (_context != null && _context!.mounted) {
          _context!.go('/home');
        }
      } else {
        developer.log('❌ Login failed: ${result['error']}',
            name: 'LoginController');
        _showSnackBar(
          result['error'] ?? 'Invalid credentials',
          isError: true,
        );
      }
    } catch (e) {
      developer.log('❌ Login error: $e', name: 'LoginController');
      _showSnackBar(
        'An error occurred. Please try again.',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
