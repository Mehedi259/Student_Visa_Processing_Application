// lib/core/routes/routes.dart

import 'package:go_router/go_router.dart';

import '../../presentation/screens/authentication/forget_password.dart';
import '../../presentation/screens/authentication/forget_password_otp.dart';
import '../../presentation/screens/authentication/login.dart';
import '../../presentation/screens/authentication/reset_password.dart';
import '../../presentation/screens/authentication/reset_password_success.dart';
import '../../presentation/screens/documents_screen/birth_certificate/birth_certificate.dart';
import '../../presentation/screens/documents_screen/birth_certificate/birth_certificate_scanner.dart';
import '../../presentation/screens/documents_screen/college_certificate/college_certificate.dart';
import '../../presentation/screens/documents_screen/college_certificate/college_certificate_scanner.dart';
import '../../presentation/screens/documents_screen/college_transcript/college_transcript.dart';
import '../../presentation/screens/documents_screen/college_transcript/college_transcript_scanner.dart';
import '../../presentation/screens/documents_screen/country.dart';
import '../../presentation/screens/documents_screen/documents.dart';
import '../../presentation/screens/documents_screen/health_insurance/health_insurance.dart';
import '../../presentation/screens/documents_screen/health_insurance/health_insurance_scanner.dart';
import '../../presentation/screens/documents_screen/passport/passport.dart';
import '../../presentation/screens/documents_screen/passport/passport_scanner.dart';
import '../../presentation/screens/documents_screen/preliminary.dart';
import '../../presentation/screens/documents_screen/school_acceptance/school_acceptance.dart';
import '../../presentation/screens/documents_screen/school_acceptance/school_acceptance_scanner.dart';
import '../../presentation/screens/documents_screen/student.dart';
import '../../presentation/screens/home/home.dart';
import '../../presentation/screens/legal_entry_basic/destination.dart';
import '../../presentation/screens/massage_screen/massage_screen.dart';
import '../../presentation/screens/notification/notification.dart';
import '../../presentation/screens/settings/settings.dart';
import '../../presentation/screens/settings/my_information.dart';
import '../../presentation/screens/settings/student_information.dart';
import '../../presentation/screens/settings/student_profile_update.dart';
import '../../presentation/screens/settings/address.dart';
import '../../presentation/screens/settings/add_address.dart';
import '../../presentation/screens/settings/email.dart';
import '../../presentation/screens/settings/add_email.dart';
import '../../presentation/screens/settings/phone.dart';
import '../../presentation/screens/settings/add_phone.dart';
import '../../presentation/screens/settings/change_password.dart';
import '../../presentation/screens/settings/technical_support.dart';
import '../../presentation/screens/settings/privacy_policy.dart';
import '../../presentation/screens/splash/splash.dart';
import 'route_observer.dart';
import 'route_path.dart';

class AppRouter {
  static final GoRouter initRoute = GoRouter(
    initialLocation: RoutePath.splash.addBasePath,
    debugLogDiagnostics: true,
    routes: [

      // ================== OnBoarding ==================
      GoRoute(
        name: RoutePath.splash,
        path: RoutePath.splash.addBasePath,
        builder: (context, state) => const SplashScreen(),
      ),

      // ================== Authentication ==================
      GoRoute(
        name: RoutePath.login,
        path: RoutePath.login.addBasePath,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: RoutePath.forgetPassword,
        path: RoutePath.forgetPassword.addBasePath,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        name: RoutePath.forgetPasswordOtp,
        path: RoutePath.forgetPasswordOtp.addBasePath,
        builder: (context, state) => const OtpVerificationScreen(),
      ),
      GoRoute(
        name: RoutePath.resetPassword,
        path: RoutePath.resetPassword.addBasePath,
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        name: RoutePath.resetPasswordSuccess,
        path: RoutePath.resetPasswordSuccess.addBasePath,
        builder: (context, state) => const PasswordResetSuccessScreen(),
      ),

      // ================== Home ==================
      GoRoute(
        name: RoutePath.home,
        path: RoutePath.home.addBasePath,
        builder: (context, state) => const HomeScreen(),
      ),

      // ================== Legal Entry Basic ==================
      GoRoute(
        name: RoutePath.destination,
        path: RoutePath.destination.addBasePath,
        builder: (context, state) => const DestinationScreen(),
      ),

      // ================== Documents ==================
      GoRoute(
        name: RoutePath.documents,
        path: RoutePath.documents.addBasePath,
        builder: (context, state) => const DocumentsScreen(),
      ),
      GoRoute(
        name: RoutePath.preliminary,
        path: RoutePath.preliminary.addBasePath,
        builder: (context, state) => const PreliminaryScreen(),
      ),
      GoRoute(
        name: RoutePath.student,
        path: RoutePath.student.addBasePath,
        builder: (context, state) => const StudentScreen(),
      ),
      GoRoute(
        name: RoutePath.country,
        path: RoutePath.country.addBasePath,
        builder: (context, state) => const CountryScreen(),
      ),
      GoRoute(
        name: RoutePath.passport,
        path: RoutePath.passport.addBasePath,
        builder: (context, state) => const PassportScreen(),
      ),
      GoRoute(
        name: RoutePath.passportScanner,
        path: RoutePath.passportScanner.addBasePath,
        builder: (context, state) => const PassportScannerScreen(),
      ),
      GoRoute(
        name: RoutePath.birthCertificateScannerScreen,
        path: RoutePath.birthCertificateScannerScreen.addBasePath,
        builder: (context, state) => const BirthCertificateScannerScreen(),
      ),
      GoRoute(
        name: RoutePath.birthCertificateScanner,
        path: RoutePath.birthCertificateScanner.addBasePath,
        builder: (context, state) => const BirthCertificateScanner(),
      ),
      GoRoute(
        name: RoutePath.collegeCertificateScannerScreen,
        path: RoutePath.collegeCertificateScannerScreen.addBasePath,
        builder: (context, state) => const CollegeCertificateScannerScreen(),
      ),
      GoRoute(
        name: RoutePath.collegeCertificateScanner,
        path: RoutePath.collegeCertificateScanner.addBasePath,
        builder: (context, state) => const CollegeCertificateScanner(),
      ),
      GoRoute(
        name: RoutePath.collegeTranscriptScannerScreen,
        path: RoutePath.collegeTranscriptScannerScreen.addBasePath,
        builder: (context, state) => const CollegeTranscriptScannerScreen(),
      ),
      GoRoute(
        name: RoutePath.collegeTranscriptScanner,
        path: RoutePath.collegeTranscriptScanner.addBasePath,
        builder: (context, state) => const CollegeTranscriptScanner(),
      ),
      GoRoute(
        name: RoutePath.schoolAcceptanceScannerScreen,
        path: RoutePath.schoolAcceptanceScannerScreen.addBasePath,
        builder: (context, state) => const SchoolAcceptanceScannerScreen(),
      ),
      GoRoute(
        name: RoutePath.schoolAcceptanceScanner,
        path: RoutePath.schoolAcceptanceScanner.addBasePath,
        builder: (context, state) => const SchoolAcceptanceScanner(),
      ),
      GoRoute(
        name: RoutePath.healthInsuranceScannerScreen,
        path: RoutePath.healthInsuranceScannerScreen.addBasePath,
        builder: (context, state) => const HealthInsuranceScannerScreen(),
      ),
      GoRoute(
        name: RoutePath.healthInsuranceScanner,
        path: RoutePath.healthInsuranceScanner.addBasePath,
        builder: (context, state) => const HealthInsuranceScanner(),
      ),

      // ================== Massage ==================
      GoRoute(
        name: RoutePath.massageScreen,
        path: RoutePath.massageScreen.addBasePath,
        builder: (context, state) => const MessageScreen(),
      ),

      // ================== Settings ==================
      GoRoute(
        name: RoutePath.settings,
        path: RoutePath.settings.addBasePath,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        name: RoutePath.myInformation,
        path: RoutePath.myInformation.addBasePath,
        builder: (context, state) => const MyInformationScreen(),
      ),
      GoRoute(
        name: RoutePath.studentInformation,
        path: RoutePath.studentInformation.addBasePath,
        builder: (context, state) => const StudentInformationScreen(),
      ),
      GoRoute(
        name: RoutePath.studentProfileUpdate,
        path: RoutePath.studentProfileUpdate.addBasePath,
        builder: (context, state) => const StudentProfileUpdateScreen(),
      ),
      GoRoute(
        name: RoutePath.address,
        path: RoutePath.address.addBasePath,
        builder: (context, state) => const AddressScreen(),
      ),
      GoRoute(
        name: RoutePath.addAddress,
        path: RoutePath.addAddress.addBasePath,
        builder: (context, state) => const AddAddressScreen(),
      ),
      GoRoute(
        name: RoutePath.email,
        path: RoutePath.email.addBasePath,
        builder: (context, state) => const EmailScreen(),
      ),
      GoRoute(
        name: RoutePath.addEmail,
        path: RoutePath.addEmail.addBasePath,
        builder: (context, state) => const AddEmailScreen(),
      ),
      GoRoute(
        name: RoutePath.phone,
        path: RoutePath.phone.addBasePath,
        builder: (context, state) => const PhoneScreen(),
      ),
      GoRoute(
        name: RoutePath.addPhone,
        path: RoutePath.addPhone.addBasePath,
        builder: (context, state) => const AddPhoneScreen(),
      ),
      GoRoute(
        name: RoutePath.changePassword,
        path: RoutePath.changePassword.addBasePath,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        name: RoutePath.technicalSupport,
        path: RoutePath.technicalSupport.addBasePath,
        builder: (context, state) => const TechnicalSupportScreen(),
      ),
      GoRoute(
        name: RoutePath.privacyPolicy,
        path: RoutePath.privacyPolicy.addBasePath,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),

      // ================== Notification ==================
      GoRoute(
        name: RoutePath.notification,
        path: RoutePath.notification.addBasePath,
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
    observers: [routeObserver],
  );

  static GoRouter get route => initRoute;
}

extension BasePathExtension on String {
  String get addBasePath => '/$this';
}