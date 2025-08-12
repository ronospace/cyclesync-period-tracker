#!/bin/bash
# Switch to FlowSense v1

echo "🌸 Switching to FlowSense v1..."

# Backup current work first
echo "📦 Creating backup of current work..."
mkdir -p versions/current-backup-$(date +%Y%m%d-%H%M%S)
cp -r lib/ versions/current-backup-$(date +%Y%m%d-%H%M%S)/

# Restore FlowSense v1
echo "🔄 Restoring FlowSense v1..."
cp -r versions/flowsense-v1/lib/* lib/
cp versions/flowsense-v1/pubspec.yaml .
cp versions/flowsense-v1/firebase.json .

echo "✅ Switched to FlowSense v1!"
echo "🚀 Run: flutter run -d \"iPhone-Simulator-ID\" to test"
echo "📱 Current app: FlowSense - Your intelligent flow tracking companion"
