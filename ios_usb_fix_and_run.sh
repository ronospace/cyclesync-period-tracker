#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

need() { command -v "$1" >/dev/null 2>&1 || { echo "❌ $1 not found"; exit 1; }; }
need /usr/libexec/PlistBuddy
need flutter
need xcodebuild

INFO_PLIST_IOS="ios/Runner/Info.plist"
INFO_PLIST_MAC="macos/Runner/Info.plist"
GSI_PLIST="ios/Runner/GoogleService-Info.plist"
IOS_DEBUG_ENT="ios/Runner/DebugProfile.entitlements"
IOS_RELEASE_ENT="ios/Runner/Release.entitlements"
MAC_DEBUG_ENT="macos/Runner/DebugProfile.entitlements"
MAC_RELEASE_ENT="macos/Runner/Release.entitlements"

if [[ ! -f "$INFO_PLIST_IOS" ]]; then
  echo "❌ $INFO_PLIST_IOS not found. Are you in the Flutter project root?"
  exit 1
fi

# --- Function: Add Local Network + Bonjour + ATS rules ---
setup_plist() {
  local PLIST="$1"
  /usr/libexec/PlistBuddy -c "Add :NSLocalNetworkUsageDescription string This app uses the local network to connect to the Dart VM Service for debugging." "$PLIST" 2>/dev/null || \
  /usr/libexec/PlistBuddy -c "Set :NSLocalNetworkUsageDescription 'This app uses the local network to connect to the Dart VM Service for debugging.'" "$PLIST"
  /usr/libexec/PlistBuddy -c "Add :NSBonjourServices array" "$PLIST" 2>/dev/null || true
  /usr/libexec/PlistBuddy -c "Add :NSBonjourServices:0 string _dartVmService._tcp" "$PLIST" 2>/dev/null || true
  /usr/libexec/PlistBuddy -c "Add :NSBonjourServices:1 string _flutterObservatory._tcp" "$PLIST" 2>/dev/null || true
  /usr/libexec/PlistBuddy -c "Delete :NSAppTransportSecurity" "$PLIST" 2>/dev/null || true
  /usr/libexec/PlistBuddy -c "Add :NSAppTransportSecurity dict" "$PLIST" 2>/dev/null || true
  /usr/libexec/PlistBuddy -c "Add :NSAppTransportSecurity:NSAllowsArbitraryLoads bool YES" "$PLIST" 2>/dev/null || \
  /usr/libexec/PlistBuddy -c "Set :NSAppTransportSecurity:NSAllowsArbitraryLoads YES" "$PLIST"
  /usr/libexec/PlistBuddy -c "Add :NSAppTransportSecurity:NSExceptionDomains dict" "$PLIST" 2>/dev/null || true
  for DOMAIN in firebaseio.com googleapis.com gstatic.com googleusercontent.com; do
    /usr/libexec/PlistBuddy -c "Add :NSAppTransportSecurity:NSExceptionDomains:${DOMAIN} dict" "$PLIST" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Add :NSAppTransportSecurity:NSExceptionDomains:${DOMAIN}:NSIncludesSubdomains bool YES" "$PLIST" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Add :NSAppTransportSecurity:NSExceptionDomains:${DOMAIN}:NSTemporaryExceptionAllowsInsecureHTTPLoads bool NO" "$PLIST" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Add :NSAppTransportSecurity:NSExceptionDomains:${DOMAIN}:NSTemporaryExceptionMinimumTLSVersion string TLSv1.2" "$PLIST" 2>/dev/null || true
  done
}

# --- Function: Add Keychain Sharing ---
add_keychain_group() {
  local ENT="$1"
  [[ -f "$ENT" ]] || return 0
  /usr/libexec/PlistBuddy -c "Add :keychain-access-groups array" "$ENT" 2>/dev/null || true
  local BUNDLE_ID
  BUNDLE_ID="$(xcodebuild -showBuildSettings -workspace ios/Runner.xcworkspace -scheme Runner 2>/dev/null | awk -F' = ' '/PRODUCT_BUNDLE_IDENTIFIER/ {print $2; exit}')"
  [[ -n "${BUNDLE_ID:-}" ]] || return 0
  local GROUP="\$(AppIdentifierPrefix)${BUNDLE_ID}"
  if ! /usr/libexec/PlistBuddy -c "Print :keychain-access-groups" "$ENT" 2>/dev/null | grep -q "$BUNDLE_ID"; then
    /usr/libexec/PlistBuddy -c "Add :keychain-access-groups:0 string $GROUP" "$ENT" 2>/dev/null || true
  fi
}

# --- Apply to iOS and macOS ---
setup_plist "$INFO_PLIST_IOS"
setup_plist "$INFO_PLIST_MAC"
add_keychain_group "$IOS_DEBUG_ENT"
add_keychain_group "$IOS_RELEASE_ENT"
add_keychain_group "$MAC_DEBUG_ENT"
add_keychain_group "$MAC_RELEASE_ENT"

# --- Bundle ID check for iOS ---
if [[ -f "$GSI_PLIST" ]]; then
  IOS_INFO_BUNDLE="$(
    /usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$INFO_PLIST_IOS" 2>/dev/null || true
  )"
  GSI_BUNDLE="$(
    /usr/libexec/PlistBuddy -c 'Print :BUNDLE_ID' "$GSI_PLIST" 2>/dev/null || true
  )"
  if [[ "$IOS_INFO_BUNDLE" == *"$(PRODUCT_BUNDLE_IDENTIFIER)"* ]]; then
    IOS_INFO_BUNDLE="$(xcodebuild -showBuildSettings -workspace ios/Runner.xcworkspace -scheme Runner 2>/dev/null | awk -F' = ' '/PRODUCT_BUNDLE_IDENTIFIER/ {print $2; exit}')"
  fi
  if [[ -n "${IOS_INFO_BUNDLE:-}" && -n "${GSI_BUNDLE:-}" && "$IOS_INFO_BUNDLE" != "$GSI_BUNDLE" ]]; then
    echo "⚠️  Bundle ID mismatch:"
    echo "    Xcode/Info: $IOS_INFO_BUNDLE"
    echo "    Firebase  : $GSI_BUNDLE"
  else
    echo "✅ Bundle ID matches Firebase config."
  fi
else
  echo "⚠️  $GSI_PLIST not found."
fi

# --- Build & run to iPhone ---
echo "ℹ️  Uninstall app from iPhone to re-trigger Local Network prompt."
flutter clean
flutter pub get
flutter run -d 00008130-001E49111AB8001C --device-timeout 180
