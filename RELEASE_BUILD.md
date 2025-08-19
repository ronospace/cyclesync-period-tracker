# Release build and size optimization

This project is configured to reduce app size for Android releases.

What was enabled
- R8 code shrinking and resource shrinking (release): android/app/build.gradle.kts
- ABI splits (per-ABI APKs): armeabi-v7a, arm64-v8a, x86_64
- ProGuard rules for Flutter/Firebase/Ads: android/app/proguard-rules.pro
- Flutter build flags in script: --split-per-abi, --tree-shake-icons, --obfuscate, --split-debug-info

Build commands
- Android: scripts/build_release_android.sh
  - Outputs per-ABI APKs under build/app/outputs/flutter-apk/

AdMob integration
- Mobile Ads SDK initialized in lib/main.dart
- AdMob App ID placeholders added:
  - Android: AndroidManifest.xml meta-data com.google.android.gms.ads.APPLICATION_ID = {{ADMOB_APP_ID_ANDROID}}
  - iOS: Info.plist GADApplicationIdentifier = {{ADMOB_APP_ID_IOS}}
- Test banner widget: lib/widgets/common/banner_ad_container.dart
  - Replace with your real unit ID when ready or pass via constructor.

Next steps to reduce size further
- Convert large PNG/JPEG assets to WebP or AVIF if possible
- Remove any unused assets from pubspec.yaml
- Avoid bundling large font/icon packs; rely on tree-shaken Material icons
- Audit dependencies and remove unused features

iOS notes
- App Thinning (slicing, bitcode stripping by Xcode) reduces download size automatically
- Ensure “Strip Debug Symbols” and “Dead Code Stripping” are enabled for Release

