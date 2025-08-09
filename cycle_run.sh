#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

FIREBASE_DEPLOY_WEB=false
FIREBASE_DEPLOY_RULES=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --web-deploy) FIREBASE_DEPLOY_WEB=true ;;
        --deploy-firestore-rules) FIREBASE_DEPLOY_RULES=true ;;
    esac
done

echo "🚀 Starting CocoaPods repair + Flutter build..."

# 1. Remove old Pods
cd ios
rm -rf Pods Podfile.lock || true

# 2. Reinstall CocoaPods cleanly
if gem list cocoapods -i >/dev/null; then
    echo "🧹 Removing old CocoaPods (gem)..."
    sudo gem uninstall cocoapods -a -x || true
fi
if brew list cocoapods >/dev/null 2>&1; then
    echo "🧹 Removing old CocoaPods (brew)..."
    brew uninstall cocoapods --force || true
fi

echo "📦 Installing CocoaPods (brew)..."
brew install cocoapods

# 3. Reinstall iOS Pods
echo "🔄 Updating pod repo..."
pod repo update
echo "📥 Installing pods..."
pod install

# 4. Go back to project root
cd "$PROJECT_ROOT"

# 5. Clean & get packages
flutter clean
flutter pub get

# 6. Detect best device
REAL_IPHONE_ID=$(flutter devices | awk '/\(mobile\).*ios/ && !/simulator/{print $2; exit}')
SIMULATOR_ID=$(flutter devices | awk '/iPhone 16 Plus/ {print $2; exit}')

if [[ -n "$REAL_IPHONE_ID" ]]; then
    echo "📱 Real iPhone detected: $REAL_IPHONE_ID"
    flutter run -d "$REAL_IPHONE_ID" --device-timeout 180
elif [[ -n "$SIMULATOR_ID" ]]; then
    echo "📱 iPhone 16 Plus simulator detected: $SIMULATOR_ID"
    flutter run -d "$SIMULATOR_ID" --device-timeout 180
elif flutter devices | grep -q macos; then
    echo "💻 Running on macOS desktop"
    flutter run -d macos
else
    echo "🌐 Running on Chrome (web)"
    flutter run -d chrome
fi

# 7. Deploy web app if requested
if [[ "$FIREBASE_DEPLOY_WEB" == true ]]; then
    echo "🌍 Deploying web version to Firebase Hosting..."
    flutter build web --release
    firebase deploy --only hosting
fi

# 8. Deploy Firestore rules if requested
if [[ "$FIREBASE_DEPLOY_RULES" == true ]]; then
    echo "📜 Deploying Firestore rules..."
    firebase deploy --only firestore:rules
fi

say "✅ Done. App is running."
