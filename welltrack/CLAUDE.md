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
├── services/        # External service integrations
├── utils/          # Utility functions
├── viewmodels/     # ViewModels for MVVM pattern
└── widgets/        # Small reusable widgets
```

### Key Architectural Patterns

1. **Dependency Injection**: Using GetIt (simpler approach than Injectable)
   - Services are registered in `lib/core/injection.dart`
   - Use `getIt.registerLazySingleton<T>()` for services
   - Access via `locate<T>()` helper function
   - No code generation required

2. **State Management**: Provider pattern
   - `UserProvider` manages user authentication state
   - `ProximityProvider` handles location-based features
   - `MentalStateViewModel` manages mental state tracking
   - Providers use ChangeNotifier for reactive updates
   - Registered in `MultiProvider` in main.dart

3. **Navigation Architecture**:
   - `MainPageWrapper`: Pages with bottom navigation (Home, Calendar, Stats, Profile)
   - `NonMainPageWrapper`: Standalone pages without bottom nav
   - `NavigationService` handles programmatic navigation
   - Navigation key registered in GetIt for global access

4. **Data Persistence**:
   - Local SQLite database via `sqflite` for offline support
   - `DatabaseHelper` singleton manages database operations
   - Tables: `mental_states`, `journal_entries`
   - Schema migrations handled in `_onUpgrade`

### External Services

1. **Supabase Integration**:
   - Authentication service (`authenticators.dart`)
   - Database operations for mental states
   - Image storage for profile avatars
   - Configured in `main.dart` with project credentials
   - Global access via `supabase` variable

2. **Google Sign-In**:
   - Integrated alongside email/password auth
   - Configured for iOS, Android, and web platforms
   - Requires OAuth2 client configuration

3. **Location Services**:
   - Used for proximity features
   - Google Maps integration for location selection
   - Requires API key configuration in platform files

4. **Audio & Speech Services**:
   - Audio recording via `record` package
   - Audio playback via `audioplayers` package
   - Speech-to-text via `speech_to_text` package
   - Transcription service in `lib/services/transcription_service.dart`

### Platform Configuration

#### Android
- Minimum SDK: 23 (required for audio recording)
- Target SDK: 35
- Permissions in AndroidManifest.xml:
  - Internet, Camera, Storage, Audio Recording
  - Location (Fine, Coarse, Background)
  - Activity Recognition, Bluetooth

#### iOS
- Deployment target: 12.0
- Info.plist permissions:
  - Camera, Photo Library, Microphone
  - Speech Recognition, Location
  - Google Maps API key

#### Web
- PWA support configured
- Google Sign-In web client ID required

### Database Schema
```sql
-- Local SQLite tables
mental_states:
  - id INTEGER PRIMARY KEY
  - state REAL (mood value)
  - date TEXT
  - emotions TEXT (JSON)
  - factors TEXT (JSON)

journal_entries:
  - id INTEGER PRIMARY KEY
  - user_id INTEGER
  - date TEXT
  - type TEXT (text/photo/audio)
  - text_content TEXT
  - photo_path TEXT
  - audio_path TEXT
  - caption TEXT
  - transcription TEXT
  - created_at TEXT
  - updated_at TEXT
```

### Current Development Branch
- Working on `feature/journalupdate` branch
- Adding audio transcription capabilities
- Enhanced journal entry models
- Modified services: database_helper, journal entries

### Environment Configuration
- Google Maps API keys in platform-specific files
- Supabase credentials hardcoded in main.dart
- Consider using environment variables for production

### Known Issues & Solutions

1. **Supabase Connection**: Hardcoded credentials in `main.dart` - consider environment variables for production
2. **No Test Infrastructure**: Tests need to be implemented
3. **Image Assets**: Located in both `assets/Images/` and `lib/images/` - consider consolidating
4. **API Keys**: Google Maps API key exposed in iOS Info.plist - use build-time injection for production