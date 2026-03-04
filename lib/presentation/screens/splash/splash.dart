// lib/presentation/screens/authentication/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/custom_assets/assets.gen.dart';
import '../../../global/storage/storage_helper.dart';
import '../../../global/service/auth/login_service.dart';
import 'dart:developer' as developer;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 5000), () {
      if (mounted) {
        _checkAutoLogin();
      }
    });
  }

  /// Check if user should be auto-logged in
  Future<void> _checkAutoLogin() async {
    try {
      developer.log('🔍 Checking auto-login status', name: 'SplashScreen');

      // Check if remember me is enabled and refresh token exists
      final rememberMe = await StorageHelper.getRememberMe();
      final refreshToken = await StorageHelper.getRefreshToken();

      developer.log('Remember Me: $rememberMe', name: 'SplashScreen');
      developer.log('Has Refresh Token: ${refreshToken != null && refreshToken.isNotEmpty}', name: 'SplashScreen');

      // Case 2: Remember Me is enabled → Auto-login to home
      if (rememberMe && refreshToken != null && refreshToken.isNotEmpty) {
        developer.log('✅ Remember Me enabled, attempting auto-login', name: 'SplashScreen');

        // Try to refresh the access token
        final result = await LoginService.refreshAccessToken();

        if (result['success'] == true) {
          developer.log('✅ Auto-login successful, navigating to home', name: 'SplashScreen');
          if (mounted) {
            context.go('/home');
          }
          return;
        } else {
          developer.log('❌ Token refresh failed: ${result['error']}', name: 'SplashScreen');
          // Clear invalid tokens but keep the session for biometric
          await StorageHelper.clearToken();
          await StorageHelper.clearRefreshToken();
          // Don't clear remember me - let user try again
        }
      } else {
        // Case 1: Remember Me not enabled → Go to login screen
        // But biometric will be available if refresh token exists
        developer.log('ℹ️ Remember Me not enabled, navigating to login', name: 'SplashScreen');
      }

      // Navigate to login screen
      // Biometric option will be available if refresh token exists
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      developer.log('❌ Auto-login error: $e', name: 'SplashScreen');
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF1D1B20),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Assets.images.splashScreenBackground.path),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Center content with animation
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Image.asset(
                      Assets.images.splashScreenLogo.path,
                      width: size.width * 0.6,
                      height: size.width * 0.6,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}