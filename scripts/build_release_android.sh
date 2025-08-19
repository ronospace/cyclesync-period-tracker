#!/usr/bin/env bash
# Build Android release APKs with size optimizations
set -euo pipefail

# Create a symbols directory for split debug info if it doesn't exist
mkdir -p build/symbols

# Clean old builds
flutter clean

# Get dependencies
flutter pub get

# Build split-per-ABI, tree-shake icons, obfuscate, and split debug info
flutter build apk \
  --release \
  --split-per-abi \
  --tree-shake-icons \
  --obfuscate \
  --split-debug-info=build/symbols

# Print resulting APK sizes
echo "Built APKs (per ABI):"
ls -lh build/app/outputs/flutter-apk/*.apk

