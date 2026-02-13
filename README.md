# PocketCoach

A polished, premium AI coaching app built with Flutter.

## Documentation
- [Project Overview](docs/PROJECT_OVERVIEW.md)
- [Technical Documentation](docs/TECHNICAL_DOCUMENTATION.md)

## Features
- **Premium UI**: Minimalist design with smooth animations.
- **Smart Coaching**: Mock AI engine based on coach personalities.
- **Context Awareness**: Remembers user goals and values.
- **Offline First**: Works without internet (except for future AI calls).

## Getting Started

### Prerequisites
- Flutter SDK
- Dart SDK

### Setup
1. Clone the repo
2. Run `flutter pub get`
3. Generate code: `dart run build_runner build --delete-conflicting-outputs`

### Run
```bash
flutter run
```

Use demo mode to get screenshots for the app store.
```bash
flutter run --dart-define=DEMO_MODE=true
```

## Deployment

### iOS (IPA)
To build an IPA for TestFlight or App Store:
```bash
flutter build ipa
```
This will create an archive in `build/ios/archive/Runner.xcarchive` and an IPA in `build/ios/ipa`.

### Android (App Bundle)
To build an App Bundle (.aab) for Play Store:
```bash
flutter build appbundle
```
The bundle will be located at `build/app/outputs/bundle/release/app-release.aab`.

## Architecture
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Persistence**: Hive
