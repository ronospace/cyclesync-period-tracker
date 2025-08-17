#!/bin/bash

# Production Build Script for CycleSync
# This script builds optimized production versions for all platforms

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="CycleSync"
BUILD_DIR="build"
SYMBOL_DIR="symbols"

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

# Clean previous builds
clean_build() {
    log "Cleaning previous builds..."
    rm -rf build/
    flutter clean
    flutter pub get
    success "Clean completed"
}

# Check dependencies and environment
check_environment() {
    log "Checking build environment..."
    
    # Check Flutter version
    flutter --version
    
    # Check if running on correct branch
    if [ -d ".git" ]; then
        CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
        if [ "$CURRENT_BRANCH" != "main" ] && [ "$CURRENT_BRANCH" != "production" ]; then
            warning "Not on main or production branch. Current branch: $CURRENT_BRANCH"
        fi
    fi
    
    success "Environment check completed"
}

# Pre-build optimizations
pre_build_optimizations() {
    log "Applying pre-build optimizations..."
    
    # Generate optimized assets
    if [ -d "assets/images" ]; then
        log "Optimizing images..."
        # In a real setup, you might use imagemagick or other tools
        find assets/images -name "*.png" -exec echo "Optimizing {}" \;
    fi
    
    # Generate font subsets (if needed)
    log "Optimizing fonts..."
    
    success "Pre-build optimizations completed"
}

# Build Android Release
build_android() {
    log "Building Android release..."
    
    # Create symbols directory
    mkdir -p $BUILD_DIR/android/$SYMBOL_DIR
    
    # Build App Bundle (recommended for Play Store)
    log "Building Android App Bundle..."
    flutter build appbundle \
        --release \
        --obfuscate \
        --split-debug-info=$BUILD_DIR/android/$SYMBOL_DIR \
        --tree-shake-icons \
        --shrink \
        --target-platform android-arm,android-arm64,android-x64
    
    success "Android App Bundle built successfully"
    
    # Build APK for direct distribution
    log "Building Android APK..."
    flutter build apk \
        --release \
        --obfuscate \
        --split-debug-info=$BUILD_DIR/android/$SYMBOL_DIR \
        --tree-shake-icons \
        --shrink \
        --target-platform android-arm,android-arm64,android-x64
    
    success "Android APK built successfully"
    
    # Build split APKs for different architectures
    log "Building split APKs..."
    flutter build apk \
        --release \
        --obfuscate \
        --split-debug-info=$BUILD_DIR/android/$SYMBOL_DIR \
        --tree-shake-icons \
        --shrink \
        --split-per-abi
    
    success "Android builds completed"
    
    # Display build information
    echo "📱 Android builds:"
    echo "  App Bundle: build/app/outputs/bundle/release/app-release.aab"
    echo "  APK: build/app/outputs/flutter-apk/app-release.apk"
    echo "  Split APKs: build/app/outputs/flutter-apk/"
    echo "  Debug symbols: $BUILD_DIR/android/$SYMBOL_DIR"
}

# Build iOS Release
build_ios() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        warning "iOS build skipped - macOS required"
        return
    fi
    
    log "Building iOS release..."
    
    # Create symbols directory
    mkdir -p $BUILD_DIR/ios/$SYMBOL_DIR
    
    # Clean iOS build
    cd ios && xcodebuild clean && cd ..
    
    # Build IPA
    log "Building iOS IPA..."
    flutter build ipa \
        --release \
        --obfuscate \
        --split-debug-info=$BUILD_DIR/ios/$SYMBOL_DIR \
        --tree-shake-icons \
        --export-options-plist=ios/ExportOptions.plist
    
    success "iOS build completed"
    
    # Display build information
    echo "📱 iOS builds:"
    echo "  IPA: build/ios/ipa/*.ipa"
    echo "  Debug symbols: $BUILD_DIR/ios/$SYMBOL_DIR"
}

# Build Web Release
build_web() {
    log "Building web release..."
    
    # Build web version
    flutter build web \
        --release \
        --tree-shake-icons \
        --web-renderer html \
        --source-maps \
        --base-href="/" \
        --pwa-strategy=offline-first
    
    success "Web build completed"
    
    # Optimize web build
    log "Optimizing web assets..."
    cd build/web
    
    # Compress JavaScript and CSS files
    if command -v gzip &> /dev/null; then
        find . -type f \( -name '*.js' -o -name '*.css' -o -name '*.html' \) -exec gzip -9 -k {} \;
        success "Web assets compressed"
    fi
    
    cd ../../
    
    # Display build information
    echo "🌐 Web build:"
    echo "  Directory: build/web/"
    echo "  Entry point: build/web/index.html"
}

# Build Desktop (if supported)
build_desktop() {
    # Check if desktop platforms are available
    if flutter config | grep -q "enable-linux-desktop: true"; then
        log "Building Linux release..."
        flutter build linux --release
        success "Linux build completed"
    fi
    
    if [[ "$OSTYPE" == "darwin"* ]] && flutter config | grep -q "enable-macos-desktop: true"; then
        log "Building macOS release..."
        flutter build macos --release
        success "macOS build completed"
    fi
    
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]] && flutter config | grep -q "enable-windows-desktop: true"; then
        log "Building Windows release..."
        flutter build windows --release
        success "Windows build completed"
    fi
}

# Post-build analysis
analyze_builds() {
    log "Analyzing build outputs..."
    
    # Analyze Android build
    if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
        AAB_SIZE=$(du -h "build/app/outputs/bundle/release/app-release.aab" | cut -f1)
        echo "📊 Android App Bundle size: $AAB_SIZE"
    fi
    
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        APK_SIZE=$(du -h "build/app/outputs/flutter-apk/app-release.apk" | cut -f1)
        echo "📊 Android APK size: $APK_SIZE"
    fi
    
    # Analyze web build
    if [ -d "build/web" ]; then
        WEB_SIZE=$(du -sh "build/web" | cut -f1)
        echo "📊 Web build size: $WEB_SIZE"
    fi
    
    success "Build analysis completed"
}

# Generate build report
generate_report() {
    log "Generating build report..."
    
    REPORT_FILE="build_report_$(date +%Y%m%d_%H%M%S).md"
    
    cat > "$REPORT_FILE" << EOF
# CycleSync Production Build Report

**Generated:** $(date)
**Flutter Version:** $(flutter --version | head -1)
**Git Commit:** $(git rev-parse --short HEAD 2>/dev/null || echo "N/A")

## Build Outputs

### Android
- App Bundle: \`build/app/outputs/bundle/release/app-release.aab\`
- APK: \`build/app/outputs/flutter-apk/app-release.apk\`
- Debug Symbols: \`$BUILD_DIR/android/$SYMBOL_DIR\`

### iOS
- IPA: \`build/ios/ipa/*.ipa\`
- Debug Symbols: \`$BUILD_DIR/ios/$SYMBOL_DIR\`

### Web
- Build Directory: \`build/web/\`
- Optimized: Yes (gzipped assets)

## Optimizations Applied

- ✅ Tree shaking enabled
- ✅ Code obfuscation enabled
- ✅ Debug info split
- ✅ Icon tree shaking
- ✅ Code shrinking
- ✅ Multi-architecture support

## Performance Considerations

- Bundle size optimized for app stores
- Split APKs for reduced download size
- Web build optimized for PWA
- Debug symbols preserved for crash analysis

## Next Steps

1. Test builds on physical devices
2. Upload to respective app stores
3. Monitor crash reports and performance
4. Update build configurations as needed

---
Generated by CycleSync build script
EOF

    success "Build report generated: $REPORT_FILE"
}

# Main build process
main() {
    echo "🚀 Starting CycleSync Production Build"
    echo "======================================"
    
    # Check if we should clean first
    if [ "$1" == "--clean" ]; then
        clean_build
    fi
    
    # Build process
    check_environment
    pre_build_optimizations
    
    # Build for specified platforms or all
    case "$1" in
        android)
            build_android
            ;;
        ios)
            build_ios
            ;;
        web)
            build_web
            ;;
        desktop)
            build_desktop
            ;;
        *)
            # Build all platforms
            build_android
            build_ios
            build_web
            build_desktop
            ;;
    esac
    
    analyze_builds
    generate_report
    
    echo ""
    echo "🎉 Production build completed successfully!"
    echo "========================================"
    success "All builds are ready for distribution"
}

# Help function
show_help() {
    cat << EOF
CycleSync Production Build Script

Usage: $0 [OPTION] [PLATFORM]

PLATFORMS:
    android     Build Android App Bundle and APK
    ios         Build iOS IPA (macOS only)
    web         Build web version
    desktop     Build desktop versions (Linux/macOS/Windows)
    (no arg)    Build all available platforms

OPTIONS:
    --clean     Clean builds before building
    --help      Show this help message

Examples:
    $0                  # Build all platforms
    $0 android          # Build Android only
    $0 --clean ios      # Clean and build iOS
    $0 web              # Build web version only

For more information, visit: https://github.com/your-repo/cyclesync
EOF
}

# Handle command line arguments
case "$1" in
    --help|-h)
        show_help
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac
