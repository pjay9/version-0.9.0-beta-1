# Setup Guide

This guide provides detailed instructions for setting up the Gen-AR Mechanic application on your development environment.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Environment Setup](#environment-setup)
3. [Dependencies Installation](#dependencies-installation)
4. [API Configuration](#api-configuration)
5. [ML Model Setup](#ml-model-setup)
6. [Platform-Specific Configuration](#platform-specific-configuration)
7. [Running the Application](#running-the-application)
8. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Software

- **Flutter SDK**: Version 3.5.3 or higher
  - Download from: https://docs.flutter.dev/get-started/install
  - Verify installation: `flutter doctor`
  
- **Dart SDK**: Included with Flutter installation

- **IDE**: Choose one of the following:
  - Android Studio (recommended for Android development)
  - Visual Studio Code with Flutter extensions
  - IntelliJ IDEA with Flutter plugin

- **Platform-Specific Tools**:
  - **Android**: Android Studio, Android SDK, Android Emulator or physical device
  - **iOS**: Xcode (macOS only), iOS Simulator or physical device

### Required Accounts

- **Google Cloud Account**: For Gemini API access
  - Sign up at: https://cloud.google.com/
  - Enable Gemini API in Google Cloud Console

## Environment Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd version-0.9.0-beta-1
```

### 2. Verify Flutter Installation

```bash
flutter doctor
```

Ensure all required components show as installed. Fix any issues reported.

### 3. Check Flutter Version

```bash
flutter --version
```

Should show Flutter 3.5.3 or higher.

## Dependencies Installation

### 1. Install Flutter Packages

```bash
flutter pub get
```

This will install all dependencies listed in `pubspec.yaml`.

### 2. Verify Dependencies

The following packages should be installed:
- `http`: ^1.2.0 (for API calls)
- `camera`: ^0.11.0+2 (for camera access)
- `path_provider`: ^2.1.2 (for file system access)
- `tflite_flutter`: ^0.10.4 (for TensorFlow Lite - to be added)
- `image`: ^4.1.3 (for image processing - to be added)
- `flutter_dotenv`: ^5.1.0 (for environment variables - to be added)

## API Configuration

### 1. Obtain Gemini API Key

1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the generated API key

### 2. Configure API Key (Current Method)

**Option A: Direct Configuration (Temporary - for development only)**

Edit `lib/config/api_config.dart`:
```dart
class ApiConfig {
  static const String geminiApiKey = "YOUR_API_KEY_HERE";
}
```

**⚠️ Warning**: This method is insecure. Use environment variables for production.

**Option B: Environment Variables (Recommended)**

1. Install `flutter_dotenv` package (add to `pubspec.yaml`):
   ```yaml
   dependencies:
     flutter_dotenv: ^5.1.0
   ```

2. Create `.env` file in project root:
   ```
   GEMINI_API_KEY=your_api_key_here
   ```

3. Add `.env` to `.gitignore`:
   ```
   .env
   ```

4. Update `lib/config/api_config.dart` to load from environment:
   ```dart
   import 'package:flutter_dotenv/flutter_dotenv.dart';
   
   class ApiConfig {
     static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
   }
   ```

5. Load environment in `main.dart`:
   ```dart
   import 'package:flutter_dotenv/flutter_dotenv.dart';
   
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await dotenv.load(fileName: ".env");
     runApp(const MechanicApp());
   }
   ```

### 3. Verify API Configuration

Test the API key by making a simple request or checking the API configuration in the app.

## ML Model Setup

### 1. Prepare Model Files

You need two files:
- **Model file**: `car_parts.tflite` (TensorFlow Lite model)
- **Labels file**: `labels.txt` (text file with class names, one per line)

### 2. Create Assets Directory

```bash
mkdir -p assets
```

### 3. Add Model Files

Place your files in the `assets` directory:
```
assets/
├── car_parts.tflite
└── labels.txt
```

### 4. Update pubspec.yaml

Add assets section:
```yaml
flutter:
  assets:
    - assets/car_parts.tflite
    - assets/labels.txt
    - assets/.env  # If using environment variables
```

### 5. Labels File Format

The `labels.txt` file should contain one class name per line:
```
AC Compressor
Radiator
Battery
Fuse Box
Alternator
...
```

### 6. Model Requirements

- **Input size**: 224x224 pixels (configurable in `ml_service.dart`)
- **Input format**: RGB, normalized to [-1, 1] range
- **Output format**: Single output tensor with class probabilities
- **Quantization**: Float16 or Int8 (Float16 recommended for better accuracy)

## Platform-Specific Configuration

### Android Setup

#### 1. Update AndroidManifest.xml

Add camera permissions in `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Add permissions -->
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
                     android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" 
                     android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    
    <application>
        <!-- existing configuration -->
    </application>
</manifest>
```

#### 2. Configure Minimum SDK

Ensure `android/app/build.gradle` has appropriate minimum SDK:
```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Required for camera and TensorFlow Lite
    }
}
```

#### 3. Test on Android

```bash
flutter run
# Or specify device
flutter devices
flutter run -d <device-id>
```

### iOS Setup

#### 1. Update Info.plist

Add camera usage description in `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to capture vehicle parts for identification.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select images.</string>
```

#### 2. Configure Podfile

Ensure minimum iOS version in `ios/Podfile`:
```ruby
platform :ios, '12.0'
```

#### 3. Install iOS Dependencies

```bash
cd ios
pod install
cd ..
```

#### 4. Test on iOS

```bash
flutter run
# Or open in Xcode
open ios/Runner.xcworkspace
```

## Running the Application

### 1. Check Connected Devices

```bash
flutter devices
```

### 2. Run in Debug Mode

```bash
flutter run
```

### 3. Run in Release Mode

```bash
flutter run --release
```

### 4. Build APK (Android)

```bash
flutter build apk --release
```

### 5. Build IPA (iOS)

```bash
flutter build ios --release
```

## Troubleshooting

### Common Issues

#### Issue: Camera not working

**Solution**:
- Verify camera permissions are granted
- Check AndroidManifest.xml / Info.plist configuration
- Test on physical device (emulators may not support camera)

#### Issue: API key not working

**Solution**:
- Verify API key is correct
- Check API key has Gemini API enabled
- Verify network connectivity
- Check API quota/limits in Google Cloud Console

#### Issue: ML model not loading

**Solution**:
- Verify model file exists in `assets/` directory
- Check `pubspec.yaml` includes assets
- Run `flutter clean` and `flutter pub get`
- Verify model file format is correct (.tflite)
- Check model input/output dimensions match code

#### Issue: Dependencies conflicts

**Solution**:
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

#### Issue: Build errors

**Solution**:
- Check Flutter version compatibility
- Verify all dependencies are compatible
- Check platform-specific requirements
- Review error messages for specific guidance

### Getting Help

If you encounter issues not covered here:

1. Check [Flutter Documentation](https://docs.flutter.dev/)
2. Review [TensorFlow Lite Documentation](https://www.tensorflow.org/lite)
3. Check [Gemini API Documentation](https://ai.google.dev/docs)
4. Contact the development team

## Next Steps

After successful setup:

1. Review [Architecture Documentation](ARCHITECTURE.md)
2. Read [API Documentation](API_DOCUMENTATION.md)
3. Check [Improvements Plan](../improvements.md) for enhancement ideas
4. Start developing!

---

**Last Updated**: 2024  
**Maintained by**: Gen-AR Mechanic Development Team

