# Android APK build instructions (Flutter)

This project already contains a configured `android/` directory and can generate an APK.

## Prerequisites
- Flutter SDK available on PATH
- Android toolchain installed (Android SDK + build-tools)
- Java (JDK) available (the build uses Gradle; Java 17 is commonly used by modern Flutter/AGP)

## Build a debug APK (recommended for CI/artifacts)
From the project root:

```bash
flutter pub get
flutter build apk --debug
```

Output:
- `build/app/outputs/flutter-apk/app-debug.apk`

## Build a release APK (requires signing)
A release build typically requires a signing key configuration.

```bash
flutter pub get
flutter build apk --release
```

Output:
- `build/app/outputs/flutter-apk/app-release.apk`

### Signing notes
The current Android Gradle configuration uses **debug signing for the release build** (so `flutter run --release` works without extra setup).
For production distribution, configure proper release signing in `android/app/build.gradle.kts` using a keystore.

## Troubleshooting

### Permission / `chmod` failure during APK copy (`Operation not permitted`)
If you see an error similar to:

- `Could not set file mode 777 on '.../app-debug.apk'`
- `chmod ... (errno 1: Operation not permitted)`

it usually means previous build artifacts under `build/` were created by a different user (commonly `root`), and the current build user cannot modify them.

Fix by cleaning Flutter outputs, then rebuilding:

```bash
flutter clean
flutter pub get
flutter build apk --debug
flutter build apk --release
```

Note: This Flutter module does not include an `android/gradlew` wrapper script (it relies on Flutter's embedded Gradle invocation), so `./android/gradlew -p android clean` is not applicable here.

### Other issues
- If you see Gradle download issues, retry (network/transient repository failures can happen during dependency fetch).
- If the Android SDK is missing, run:
  ```bash
  flutter doctor -v
  ```
  and install the missing components indicated by Flutter.
