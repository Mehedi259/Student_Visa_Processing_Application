import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iywt/core/routes/routes.dart';

import '../../../core/custom_assets/assets.gen.dart';
import '../../../core/routes/route_path.dart';

class PasswordResetSuccessScreen extends StatelessWidget {
  const PasswordResetSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Back Button
              GestureDetector(
                onTap: () {
                  context.pop();
                },
                child: Assets.images.backIcon.image(
                  width: 44,
                  height: 44,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              const Text(
                'Password reset',
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
                'Your password has been successfully reset. Click below to log in',
                style: TextStyle(
                  color: Color(0xFFC7C7C7),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                  letterSpacing: -0.50,
                ),
              ),

              const SizedBox(height: 40),


              // Return to Login Button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => context.go(RoutePath.login.addBasePath),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF375BA4),
                    foregroundColor: const Color(0xFFFDFDFD),
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
                    'Return to Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.50,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}