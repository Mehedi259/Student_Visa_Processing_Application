# IYWT - Exchange Mobile Application

A comprehensive Flutter-based mobile application designed for international student exchange programs, providing seamless document management, communication, and administrative features.

## Overview

IYWT is a production-ready mobile application built with Flutter, offering a robust platform for managing student exchange programs. The application features a clean architecture, comprehensive authentication system, document scanning capabilities, and real-time messaging functionality.

## Key Features

- **Authentication & Security**
  - Email/Password authentication with OTP verification
  - Social login (Google Sign-In, Apple Sign-In)
  - Biometric authentication support
  - Secure password reset flow

- **Document Management**
  - Intelligent document scanning with OCR
  - Multi-format document support (PDF, images)
  - Document categorization (passport, certificates, transcripts)
  - Cloud-based document storage and retrieval
  - QR code generation for documents

- **Student Portal**
  - Comprehensive student profile management
  - Legal entry and destination tracking
  - Country-specific information and requirements
  - Academic records management

- **Communication**
  - Real-time messaging system
  - Push notifications
  - Technical support integration

- **Settings & Preferences**
  - Multi-language support
  - Profile customization
  - Address, email, and phone management
  - Privacy policy and terms of service

## Technical Stack

### Core Technologies
- **Framework**: Flutter 3.6.0+
- **Language**: Dart
- **State Management**: GetX
- **Routing**: GoRouter
- **Dependency Injection**: GetIt

### Key Dependencies
- **UI/UX**: flutter_screenutil, google_fonts, shimmer, auto_size_text
- **Networking**: http, cached_network_image
- **Authentication**: google_sign_in, sign_in_with_apple, local_auth
- **Document Processing**: cunning_document_scanner, pdf, file_picker
- **Media**: image_picker, camera
- **Storage**: shared_preferences, path_provider
- **Utilities**: logger, url_launcher, intl, qr_flutter

## Architecture

The project follows a clean, modular architecture with clear separation of concerns:

```
lib/
├── core/                    # Core functionality and infrastructure
│   ├── custom_assets/       # Generated asset classes
│   ├── network/             # Network connectivity management
│   └── routes/              # Application routing configuration
│
├── global/                  # Shared application logic
│   ├── constant/            # API constants and configuration
│   ├── service/             # Business logic and API services
│   │   ├── auth/            # Authentication services
│   │   ├── documents/       # Document management services
│   │   ├── home/            # Home screen services
│   │   ├── massage/         # Messaging services
│   │   ├── notification/    # Notification services
│   │   └── settings/        # Settings and profile services
│   ├── controler/           # State management controllers
│   ├── model/               # Data models and entities
│   ├── storage/             # Local storage management
│   └── utils/               # Utility functions and helpers
│
└── presentation/            # UI layer
    ├── screens/             # Application screens
    │   ├── authentication/  # Login, registration, password reset
    │   ├── documents_screen/# Document management UI
    │   ├── home/            # Home dashboard
    │   ├── legal_entry_basic/# Legal entry forms
    │   ├── massage_screen/  # Messaging interface
    │   ├── notification/    # Notification center
    │   ├── onbording/       # Onboarding flow
    │   └── settings/        # Settings and profile screens
    └── widgets/             # Reusable UI components
```

## Getting Started

### Prerequisites

- Flutter SDK 3.6.0 or higher
- Dart SDK 3.6.0 or higher
- Android Studio / Xcode for platform-specific builds
- CocoaPods (for iOS)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd iywt
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate required files:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Generate app icons:
```bash
flutter pub run flutter_launcher_icons
```

5. Run the application:
```bash
flutter run
```

## Build & Deployment

### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Configuration

### Environment Setup
Configure API endpoints and environment variables in:
- `lib/global/constant/api_constant.dart`

### Assets
Place your assets in the following directories:
- Icons: `assets/icons/`
- Images: `assets/images/`

## Development Guidelines

### Code Style
- Follow Dart's official style guide
- Use meaningful variable and function names
- Add comments for complex logic
- Maintain consistent formatting (use `flutter format`)

### State Management
- Controllers handle business logic and state
- Services manage API calls and data operations
- Models define data structures

### Testing
```bash
flutter test
```

## Version History

- **v1.0.3+4** - Current stable release

## Platform Support

- ✅ Android (API 21+)
- ✅ iOS (iOS 12.0+)

## License

This project is proprietary software. All rights reserved.

## Contact & Support

For technical support or inquiries, please use the in-app technical support feature.

---

**Built with Flutter** 💙



