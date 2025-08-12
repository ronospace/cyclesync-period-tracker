#!/bin/bash
# Switch to CycleSync Enterprise

echo "🏥 Switching to CycleSync Enterprise..."

# Backup current work first
echo "📦 Creating backup of current work..."
mkdir -p versions/current-backup-$(date +%Y%m%d-%H%M%S)
cp -r lib/ versions/current-backup-$(date +%Y%m%d-%H%M%S)/

# Restore CycleSync Enterprise
echo "🔄 Restoring CycleSync Enterprise..."
cp -r versions/cyclesync-enterprise/lib/* lib/
cp versions/cyclesync-enterprise/main_enterprise.dart lib/main.dart

echo "⚠️  Switched to CycleSync Enterprise!"
echo "🚨 WARNING: This version has compilation errors that need fixing"
echo "🔧 Run: flutter analyze to see issues"
echo "📱 Current app: CycleSync Enterprise - Healthcare-grade cycle tracking"
