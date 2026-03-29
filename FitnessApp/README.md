# AI Bag Design App

A full-functional Flutter mobile application for designing custom bags using AI technology.

## Features

### Authentication
- Login with email/password
- Sign up with form validation
- Forgot password functionality
- Animated transitions

### Design Creation
- **Upload Image/Logo**: Pick images from gallery or camera
- **AI Text-to-Design**: Generate designs using AI with text prompts
- **Bag Selection**: Choose from multiple bag types (Quad Seal, Gusset, Stand Up Pouch, Flat Bottom)
- **Design Preview**: View and edit your designs with pinch-to-zoom
- **Mockup Preview**: View designs from multiple angles (Front, Side, Back, 3D)

### Collections & Designs
- Browse design collections
- Save and manage your designs
- View design history

### Profile Management
- Edit profile information
- Settings (Language, Dark Mode, Notifications, Auto-Save)
- Security (Change Password, Biometric Login, Two-Factor Auth)
- Account management

## Tech Stack

- **Framework**: Flutter 3.0+
- **State Management**: flutter_bloc + equatable
- **Navigation**: go_router with custom transitions
- **Animations**: animate_do
- **Image Handling**: image_picker
- **HTTP**: dio
- **Local Storage**: shared_preferences

## Project Structure

```
lib/
├── core/
│   ├── router/
│   │   └── app_router.dart          # Navigation configuration
│   └── theme/
│       └── app_theme.dart           # App theme and styling
├── features/
│   ├── auth/
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── auth_bloc.dart   # Authentication state management
│   │       └── pages/
│   │           ├── login_screen.dart
│   │           ├── signup_screen.dart
│   │           └── forgot_password_screen.dart
│   ├── splash/
│   │   └── presentation/pages/
│   │       └── splash_screen.dart
│   ├── onboarding/
│   │   └── presentation/pages/
│   │       └── onboarding_screen.dart
│   ├── home/
│   │   └── presentation/pages/
│   │       └── home_screen.dart     # Main screen with bottom navigation
│   ├── design/
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── design_bloc.dart # Design state management
│   │       └── pages/
│   │           ├── create_design_screen.dart
│   │           ├── bag_selection_screen.dart
│   │           ├── text_to_design_screen.dart
│   │           ├── upload_image_screen.dart
│   │           ├── design_preview_screen.dart
│   │           └── mockup_screen.dart
│   ├── collections/
│   │   └── presentation/pages/
│   │       └── collections_screen.dart
│   ├── saved_designs/
│   │   └── presentation/pages/
│   │       └── saved_designs_screen.dart
│   └── profile/
│       └── presentation/pages/
│           ├── profile_screen.dart
│           ├── edit_profile_screen.dart
│           ├── settings_screen.dart
│           └── security_screen.dart
└── main.dart                        # App entry point
```

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Android SDK / Xcode (for iOS)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd ai_bag_design_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Navigation Flow

```
Splash Screen
    ↓
Onboarding Screen (3 pages)
    ↓
Login Screen ←→ Sign Up Screen
    ↓           ↓
    └─→ Forgot Password
    ↓
Home Screen (Bottom Navigation)
    ├── Create Tab
    │   ├── Upload Image → Bag Selection → Design Preview → Mockup
    │   └── AI Text-to-Design → Bag Selection → Design Preview → Mockup
    ├── Collections Tab
    ├── Your Designs Tab
    └── Profile Tab
        ├── Edit Profile
        ├── Settings
        └── Security
```

## Key Features Implementation

### High-Quality Animations
- Fade transitions for smooth screen changes
- Slide transitions for modal-like screens
- Scale transitions for emphasis
- Pulse animations for loading states
- Custom page transitions using GoRouter

### State Management
- BLoC pattern for predictable state management
- Separate events and states for each feature
- Clean separation of business logic and UI

### Routing
- Declarative routing with go_router
- Custom transition animations
- Deep linking support
- Type-safe navigation

### Image Handling
- Camera and gallery support
- Image quality optimization
- Preview before upload
- Pinch-to-zoom functionality

### Form Validation
- Real-time validation
- Error messages
- Required field checks
- Email format validation

## Customization

### Theme
Edit `lib/core/theme/app_theme.dart` to customize:
- Primary color
- Button styles
- Input decoration
- Text styles

### Routes
Add new routes in `lib/core/router/app_router.dart`

### Animations
Modify animation durations and curves in individual screen files

## Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Future Enhancements

- [ ] Backend API integration
- [ ] Real AI design generation
- [ ] Social sharing
- [ ] Payment integration
- [ ] Push notifications
- [ ] Offline mode
- [ ] Multi-language support
- [ ] Dark mode implementation

## License

This project is licensed under the MIT License.

## Support

For issues and questions, please create an issue in the repository.
