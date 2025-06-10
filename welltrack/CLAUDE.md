# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Development Commands

### Flutter Development
```bash
# Get dependencies
flutter pub get

# Run the app on connected device/emulator
flutter run

# Run with specific device
flutter run -d <device_id>

# List available devices
flutter devices

# Generate code (required after modifying injectable annotations)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch for changes and regenerate code
flutter pub run build_runner watch --delete-conflicting-outputs

# Clean build
flutter clean

# Format code
dart format .

# Analyze code
flutter analyze

# Run tests (when implemented)
flutter test

# Build for platforms
flutter build apk              # Android APK
flutter build appbundle       # Android App Bundle
flutter build ios             # iOS (requires macOS)
flutter build macos           # macOS desktop
flutter build web             # Web
```

## High-Level Architecture

### Project Structure
```
lib/
├── components/       # Reusable UI components
├── controllers/      # Business logic controllers
├── core/            # Core utilities (DI setup)
├── enum/            # Enumerations
├── models/          # Data models
├── pages/           # Screen/page widgets
├── providers/       # State management providers
└── services/        # External service integrations
```

### Key Architectural Patterns

1. **Dependency Injection**: Using GetIt + Injectable
   - Services are registered in `lib/core/injection.dart`
   - Use `@injectable` and `@singleton` annotations
   - Run code generation after adding new injectable classes

2. **State Management**: Provider pattern
   - `UserProvider` manages user authentication state
   - `ProximityProvider` handles location-based features
   - Providers use ChangeNotifier for reactive updates

3. **Navigation Architecture**:
   - `MainPageWrapper`: Pages with bottom navigation (Home, Calendar, Stats, Profile)
   - `NonMainPageWrapper`: Standalone pages without bottom nav
   - `NavigationService` handles programmatic navigation

4. **Repository Pattern**:
   - Abstract interfaces (e.g., `MentalStateRepository`)
   - Concrete implementations (e.g., `MentalStateRepositoryImpl`)
   - Registered as singletons in DI container

### External Services

1. **Supabase Integration**:
   - Authentication service (`authenticators.dart`)
   - Database operations for mental states
   - Image storage for profile avatars
   - Configured in `main.dart` with project credentials

2. **Google Sign-In**:
   - Integrated alongside email/password auth
   - Configured for iOS, Android, and web platforms

3. **Location Services**:
   - Used for proximity features
   - Google Maps integration for location selection

### Database Schema
The app uses Supabase with these main tables:
- `profiles`: User profile information
- `mental_states`: Mood tracking data with timestamps
- Storage buckets for avatar images

### Common Development Tasks

1. **Adding a new injectable service**:
   ```dart
   @injectable
   class MyService {
     // Implementation
   }
   ```
   Then run: `flutter pub run build_runner build --delete-conflicting-outputs`

2. **Creating a new page with navigation**:
   - For main pages: Wrap with `MainPageWrapper`
   - For other pages: Wrap with `NonMainPageWrapper`
   - Update navigation logic in bottom nav if needed

3. **Adding a new provider**:
   - Create provider class extending `ChangeNotifier`
   - Register in `MultiProvider` in `main.dart`
   - Use `context.watch<ProviderName>()` or `context.read<ProviderName>()`

### Platform-Specific Notes

- **Android**: Minimum SDK 21, target SDK 34
- **iOS**: Deployment target 12.0
- **Web**: Configured with PWA support
- **macOS**: Desktop support enabled

### Known Issues & Solutions

1. **Supabase Connection**: Hardcoded credentials in `main.dart` - consider environment variables for production
2. **No Test Infrastructure**: Tests need to be implemented
3. **Image Assets**: Located in both `assets/Images/` and `lib/images/` - consider consolidating