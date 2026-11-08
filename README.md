# Delivery Management System

A Flutter web application for managing delivery orders.

## Requirements

- Flutter SDK compatible with the Dart constraint in `pubspec.yaml`
- A Firebase project configured for the app

## Run locally

```shell
flutter pub get
flutter run -d chrome
```

## Verify and build

```shell
flutter analyze
flutter test
flutter build web
```

## Firebase configuration

`lib/firebase_options.dart` contains FlutterFire client configuration for the currently selected Firebase project. If you use a different project, configure the app with FlutterFire CLI and review the project's Authentication and Firestore settings before running or deploying it.

Firebase client configuration is not a service-account credential. Never commit service-account JSON files, private keys, or signing credentials. Restrict Firebase API keys and configure Firestore security rules for your project.

## Code generation

After changing Riverpod-annotated providers, regenerate the provider code:

```shell
dart run build_runner build --delete-conflicting-outputs
```
