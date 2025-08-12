#!/bin/bash
# Check which app version is currently active

echo "📱 Current App Status Check"
echo "=========================="

# Check main.dart content to determine current app
if grep -q "FlowSense" lib/main.dart; then
    echo "✅ Currently active: FlowSense v1"
    echo "📝 Description: Simple & polished cycle tracking"
    echo "🎯 Target: General users"
    echo "🏗️ Architecture: Clean & minimal"
elif grep -q "MyApp.*themeService\|ErrorService\|PerformanceService" lib/main.dart; then
    echo "✅ Currently active: CycleSync Enterprise"
    echo "📝 Description: Healthcare-grade cycle tracking"
    echo "🎯 Target: Healthcare professionals"
    echo "🏗️ Architecture: Enterprise-grade"
    echo "⚠️ WARNING: May have compilation issues"
else
    echo "❓ Unknown app version active"
fi

echo ""
echo "📊 Available Commands:"
echo "🌸 ./switch_to_flowsense.sh  - Switch to FlowSense v1"
echo "🏥 ./switch_to_cyclesync.sh  - Switch to CycleSync Enterprise"
echo "📋 cat MASTER_PLAN.md        - View master plan"
echo "🚀 flutter run               - Run current app"
echo "🔍 flutter analyze           - Check for issues"
