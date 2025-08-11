# 🚀 CycleSync Enterprise Deployment Guide

## Overview
Complete deployment guide for the CycleSync Enterprise Healthcare Platform. This guide covers production deployment to App Store, Google Play, and web platforms.

---

## 📋 Pre-Deployment Checklist

### ✅ Development Environment
- [ ] Flutter SDK 3.16+ installed
- [ ] Xcode 15+ (for iOS deployment)
- [ ] Android Studio with latest SDK (for Android deployment)
- [ ] Firebase project configured
- [ ] Apple Developer Account (for iOS)
- [ ] Google Play Console Account (for Android)

### ✅ Production Configuration
- [ ] Firebase production project created
- [ ] Environment variables configured
- [ ] SSL certificates installed
- [ ] Domain names configured (for web)
- [ ] Analytics tracking setup

---

## 🍎 iOS App Store Deployment

### 1. **Xcode Project Configuration**

```bash
# Navigate to iOS directory
cd ios

# Update iOS deployment target (minimum iOS 12.0)
# Edit ios/Podfile:
platform :ios, '12.0'

# Clean and install pods
rm -rf Pods Podfile.lock
pod install
```

### 2. **Bundle ID & Certificates**

```bash
# Update Bundle ID in ios/Runner.xcodeproj
# Recommended format: com.yourcompany.cyclesync.enterprise

# Configure signing certificates in Xcode:
# - Open ios/Runner.xcworkspace
# - Select Runner target → Signing & Capabilities
# - Enable "Automatically manage signing"
# - Select your Apple Developer Team
```

### 3. **HealthKit Entitlements**

```xml
<!-- ios/Runner/Runner.entitlements -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.healthkit</key>
    <true/>
    <key>com.apple.developer.healthkit.access</key>
    <array>
        <string>health-records</string>
    </array>
</dict>
</plist>
```

### 4. **Info.plist Configuration**

```xml
<!-- ios/Runner/Info.plist -->
<key>NSHealthShareUsageDescription</key>
<string>CycleSync needs access to your health data to provide personalized cycle tracking and health insights.</string>
<key>NSHealthUpdateUsageDescription</key>
<string>CycleSync needs to save your health data to provide comprehensive cycle tracking.</string>
```

### 5. **Build & Archive**

```bash
# Clean build
flutter clean
flutter pub get

# Build iOS release
flutter build ios --release

# Open Xcode for archiving
open ios/Runner.xcworkspace

# In Xcode:
# 1. Product → Archive
# 2. Distribute App → App Store Connect
# 3. Upload to TestFlight first for testing
```

---

## 🤖 Android Play Store Deployment

### 1. **Android Configuration**

```bash
# Update android/app/build.gradle
android {
    compileSdkVersion 34
    ndkVersion flutter.ndkVersion
    
    defaultConfig {
        applicationId "com.yourcompany.cyclesync.enterprise"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }
}
```

### 2. **Signing Configuration**

```bash
# Generate keystore
keytool -genkey -v -keystore ~/cyclesync-enterprise-key.jks \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -alias cyclesync-enterprise

# Create android/key.properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=cyclesync-enterprise
storeFile=/Users/ronos/cyclesync-enterprise-key.jks
```

### 3. **Permissions & Manifest**

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />

<!-- Health Connect permissions -->
<uses-permission android:name="android.permission.health.READ_HEALTH_DATA_HISTORY" />
<uses-permission android:name="android.permission.health.WRITE_HEALTH_DATA" />
```

### 4. **Build & Release**

```bash
# Build Android App Bundle (recommended)
flutter build appbundle --release

# Build APK (alternative)
flutter build apk --release

# Files generated:
# - build/app/outputs/bundle/release/app-release.aab
# - build/app/outputs/flutter-apk/app-release.apk
```

---

## 🌐 Web Platform Deployment

### 1. **Web Build Configuration**

```bash
# Build for web
flutter build web --release --web-renderer html

# Output directory: build/web/
```

### 2. **Firebase Hosting Setup**

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize hosting
firebase init hosting

# Select build/web as public directory
# Configure as single-page app: Yes
# Set up automatic builds: Yes (optional)
```

### 3. **Deploy to Firebase Hosting**

```bash
# Deploy to production
firebase deploy --only hosting

# Deploy to staging
firebase hosting:channel:deploy preview
```

### 4. **Custom Domain Setup**

```bash
# Add custom domain in Firebase Console
# Configure DNS records:
# - A record: 151.101.1.195, 151.101.65.195
# - AAAA record: 2a04:4e42::175, 2a04:4e42:400::175
```

---

## 🏗️ CI/CD Pipeline Setup

### GitHub Actions Workflow

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy CycleSync Enterprise

on:
  push:
    branches: [ main ]
    tags: [ 'v*' ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter analyze

  deploy-android:
    needs: test
    runs-on: ubuntu-latest
    if: startsWith(github.ref, 'refs/tags/')
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '11'
      - run: flutter pub get
      - run: flutter build appbundle --release
      - uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.GOOGLE_PLAY_SERVICE_ACCOUNT }}
          packageName: com.yourcompany.cyclesync.enterprise
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: production

  deploy-ios:
    needs: test
    runs-on: macos-latest
    if: startsWith(github.ref, 'refs/tags/')
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build ios --release --no-codesign
      - uses: yukiarrr/ios-build-action@v1.4.0
        with:
          project-path: ios/Runner.xcodeproj
          p12-base64: ${{ secrets.IOS_P12_BASE64 }}
          certificate-password: ${{ secrets.IOS_CERTIFICATE_PASSWORD }}
          mobileprovision-base64: ${{ secrets.IOS_MOBILE_PROVISION_BASE64 }}
          code-signing-identity: 'iPhone Distribution'
          team-id: ${{ secrets.IOS_TEAM_ID }}
          workspace-path: ios/Runner.xcworkspace

  deploy-web:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build web --release
      - uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          projectId: your-firebase-project-id
```

---

## 🔒 Production Security Configuration

### 1. **Environment Variables**

Create `lib/config/production_config.dart`:

```dart
class ProductionConfig {
  static const String firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String firebaseAppId = String.fromEnvironment('FIREBASE_APP_ID');
  static const String firebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  
  // Healthcare compliance settings
  static const bool enableEncryption = true;
  static const bool enableAuditLogging = true;
  static const bool enableHIPAAMode = true;
  
  // Performance settings
  static const int cacheMaxAge = 7 * 24 * 60 * 60; // 7 days
  static const int syncInterval = 5 * 60; // 5 minutes
}
```

### 2. **API Keys Management**

```bash
# Set environment variables for production
export FIREBASE_API_KEY="your_production_api_key"
export FIREBASE_APP_ID="your_production_app_id"
export FIREBASE_PROJECT_ID="your_production_project_id"

# Build with environment variables
flutter build ios --release --dart-define=FIREBASE_API_KEY=$FIREBASE_API_KEY
```

---

## 📊 Production Monitoring

### 1. **Firebase Analytics Setup**

```dart
// lib/config/analytics_config.dart
class AnalyticsConfig {
  static Future<void> initializeAnalytics() async {
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    await FirebaseAnalytics.instance.setUserId('user_${DateTime.now().millisecondsSinceEpoch}');
    
    // Healthcare compliance: anonymize user data
    await FirebaseAnalytics.instance.setUserProperty(
      name: 'user_type', 
      value: 'healthcare_user'
    );
  }
}
```

### 2. **Crashlytics Configuration**

```dart
// lib/main_enterprise.dart - Add to initialization
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  
  runApp(CycleSyncEnterpriseApp());
}
```

---

## 🚀 Deployment Commands Summary

### Quick Deploy Script

Create `scripts/deploy.sh`:

```bash
#!/bin/bash

echo "🚀 CycleSync Enterprise Deployment Script"

# Clean build
flutter clean
flutter pub get

# Run tests
echo "🧪 Running tests..."
flutter test
flutter analyze

# Build platforms
echo "📱 Building iOS..."
flutter build ios --release

echo "🤖 Building Android..."
flutter build appbundle --release

echo "🌐 Building Web..."
flutter build web --release

# Deploy web to Firebase
echo "🚀 Deploying web to Firebase..."
firebase deploy --only hosting

echo "✅ Deployment complete!"
echo "📱 iOS: Archive and submit via Xcode"
echo "🤖 Android: Upload AAB to Play Console"
echo "🌐 Web: Live at your-domain.com"
```

Make it executable:
```bash
chmod +x scripts/deploy.sh
```

---

## 📈 Post-Deployment Monitoring

### Health Checks
- [ ] App Store/Play Store review status
- [ ] Firebase hosting uptime
- [ ] Analytics data flowing
- [ ] Crashlytics reporting
- [ ] User feedback monitoring
- [ ] Performance metrics tracking

### Success Metrics
- [ ] Download/install rates
- [ ] User retention rates
- [ ] Crash-free user percentage
- [ ] App store ratings
- [ ] Healthcare compliance audits

---

**Next Steps**: Run the deployment preparation commands and configure your production environments!
