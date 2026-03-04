import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iywt/core/routes/routes.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../core/custom_assets/assets.gen.dart';
import '../../../core/routes/route_path.dart';
import '../../../global/utils/snackbar_utils.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _secondsRemaining = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _canResend = false;
    _secondsRemaining = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        _timer?.cancel();
      }
    });
  }

  void _resendOTP() {
    if (_canResend) {
      // Handle resend OTP logic here
      _startTimer();
      SnackbarUtils.showSuccess(context, 'OTP resent successfully');
    }
  }

  String get _timerText {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }


  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Back Button
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    child: Assets.images.backIcon.image(
                      width: 44,
                      height: 44,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                const Text(
                  'OTP Verification',
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
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      color: Color(0xFFC7C7C7),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                      letterSpacing: -0.50,
                    ),
                    children: [
                      TextSpan(
                        text: 'Enter the verification code we just sent on your email address ',
                      ),
                      TextSpan(
                        style: TextStyle(
                          color: Color(0xFF1D1B20),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // OTP Input Field using pin_code_fields
                Form(
                  key: _formKey,
                  child: PinCodeTextField(
                    appContext: context,
                    length: 4,
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    animationType: AnimationType.fade,
                    animationDuration: const Duration(milliseconds: 300),
                    enableActiveFill: true,
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D1B20),
                    ),
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(12),
                      fieldHeight: 70,
                      fieldWidth: 70,
                      activeFillColor: const Color(0xFFF5F5F5),
                      selectedFillColor: const Color(0xFFF5F5F5),
                      inactiveFillColor: const Color(0xFFF5F5F5),
                      activeColor: const Color(0xFF375BA4),
                      selectedColor: const Color(0xFF375BA4),
                      inactiveColor: const Color(0xFFE0E0E0),
                      borderWidth: 2,
                    ),
                    onChanged: (value) {
                      setState(() {
                      });
                    },
                    onCompleted: (value) {
                      print('OTP Completed: $value');
                    },
                    beforeTextPaste: (text) {
                      // Allow pasting
                      return true;
                    },
                  ),
                ),

                const SizedBox(height: 40),

                // Timer and Resend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_canResend) ...[
                      const Icon(
                        Icons.access_time,
                        color: Color(0xFFC7C7C7),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _timerText,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFFC7C7C7),
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.50,
                        ),
                      ),
                    ] else ...[
                      const Text(
                        "Didn't receive code? ",
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFFC7C7C7),
                          letterSpacing: -0.50,
                        ),
                      ),
                      GestureDetector(
                        onTap: _resendOTP,
                        child: const Text(
                          'Resend',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF375BA4),
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFF375BA4),
                            letterSpacing: -0.50,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 40),

                // Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                      onPressed: () => context.push(RoutePath.resetPassword.addBasePath),
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
                      'Verify',
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
      ),
    );
  }
}