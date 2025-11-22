# manunitedapk

A Flutter starter app with guidance to run and build the APK for Android.

**Repository contents**
- `lib/`: main app source (pages: `dashboard_page.dart`, `login_page.dart`, `register_page.dart`, `splashscreen.dart`, `welcome.dart`)
- `android/`, `ios/`, `linux/`, `macos/`, `web/`, `windows/`: platform folders
- `assets/images/`: project assets

**This README** explains how to set up the project locally, run it on a device/emulator, and produce signed and unsigned Android APKs suitable for distribution.

**Prerequisites**
- **Flutter SDK**: install from https://docs.flutter.dev/get-started/install (required `flutter` on PATH).
- **Android SDK / Android Studio**: to run emulators and build Android APKs.
- **Java JDK (keytool)**: required to generate a signing key (usually bundled with Android Studio).
- **ADB**: for installing APKs on devices (comes with Android SDK Platform Tools).

Getting the code

```bash
git clone <your-repo-url>
cd manunitedapk
```

Install dependencies (fetch packages):

```bash
flutter pub get
```

Run the app (debug) on a connected device or emulator:

```bash
flutter run
```

If you want to select a device/emulator explicitly:

```bash
flutter devices
flutter run -d <device-id>
```

Build APKs

- Debug APK (unsigned, for quick testing):

```bash
flutter build apk --debug
```

- Release APK (optimized, unsigned):

```bash
flutter build apk --release
```

- Release App Bundle (AAB) for Play Store:

```bash
flutter build appbundle --release
```

Signed APK (recommended for publishing)

1. Generate a keystore (run in PowerShell or Command Prompt). Replace values as needed:

```powershell
keytool -genkey -v -keystore release-key.jks -alias your_key_alias -keyalg RSA -keysize 2048 -validity 10000
```

2. Create a `key.properties` file in the project root (next to `pubspec.yaml`) with these contents:

```
storePassword=<your-keystore-password>
keyPassword=<your-key-password>
keyAlias=your_key_alias
storeFile=release-key.jks
```

3. Configure signing in `android/app/build.gradle` or `android/app/build.gradle.kts`.
	- If your project uses `build.gradle.kts`, follow the Kotlin DSL equivalent to load `key.properties` and set signingConfigs for `release`.
	- Flutter's template usually already supports a signing config — adjust paths/passwords accordingly.

4. Build the signed release APK:

```bash
flutter build apk --release
```

The output APK will be at `build/app/outputs/flutter-apk/app-release.apk` (or similar).

Install APK on a device (via ADB):

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Common notes and troubleshooting
- If `flutter doctor` reports missing tooling, follow the prompts: `flutter doctor -v`.
- If you modify `android/` Gradle scripts, run a clean build: `flutter clean` then `flutter pub get` then `flutter build apk`.
- On Windows PowerShell, run commands shown above directly; if you face permission issues when generating keystore, run an elevated PowerShell.

Useful commands
- `flutter doctor` : check environment health.
- `flutter pub get` : fetch packages.
- `flutter run --release` : run a release-mode app on a connected device.
- `flutter build apk --split-per-abi` : produce multiple APKs per CPU ABI.

Next steps
- Add a `CHANGELOG.md` and a GitHub release process.
- Add continuous integration (e.g., GitHub Actions) to build and upload APKs/artifacts automatically.

If you want, I can add an example `key.properties` loader snippet for `android/app/build.gradle.kts`, a sample GitHub Actions workflow, or commit the `release-key.jks` to `.gitignore`. Tell me which you'd like next.
