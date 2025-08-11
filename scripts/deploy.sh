#!/bin/bash

# ===========================================
# CycleSync Enterprise Deployment Script
# ===========================================
# 
# Automated deployment script for CycleSync Enterprise Healthcare Platform
# Supports iOS, Android, and Web deployments with comprehensive validation

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/build"
VERSION="2.0.0-enterprise"

# Functions
log_header() {
    echo -e "\n${PURPLE}===========================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}===========================================${NC}\n"
}

log_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Validate environment
validate_environment() {
    log_header "🔍 Validating Development Environment"
    
    local errors=0
    
    # Check Flutter
    if command_exists flutter; then
        local flutter_version=$(flutter --version | head -n1)
        log_success "Flutter found: $flutter_version"
    else
        log_error "Flutter not found. Please install Flutter SDK"
        ((errors++))
    fi
    
    # Check Dart
    if command_exists dart; then
        local dart_version=$(dart --version)
        log_success "Dart found: $dart_version"
    else
        log_error "Dart not found"
        ((errors++))
    fi
    
    # Check Git
    if command_exists git; then
        log_success "Git found"
    else
        log_error "Git not found"
        ((errors++))
    fi
    
    # Check Firebase CLI (optional)
    if command_exists firebase; then
        log_success "Firebase CLI found"
    else
        log_warning "Firebase CLI not found - web deployment will be skipped"
    fi
    
    # Check for iOS tools (macOS only)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command_exists xcodebuild; then
            log_success "Xcode found"
        else
            log_warning "Xcode not found - iOS deployment will be skipped"
        fi
        
        if command_exists pod; then
            log_success "CocoaPods found"
        else
            log_warning "CocoaPods not found - iOS dependencies may fail"
        fi
    fi
    
    if [ $errors -gt 0 ]; then
        log_error "Environment validation failed with $errors errors"
        exit 1
    fi
    
    log_success "Environment validation passed!"
}

# Clean previous builds
clean_build() {
    log_header "🧹 Cleaning Previous Builds"
    
    cd "$PROJECT_ROOT"
    
    log_info "Cleaning Flutter build cache..."
    flutter clean
    
    log_info "Removing build directory..."
    rm -rf build/
    
    # Clean iOS builds
    if [[ "$OSTYPE" == "darwin"* ]] && [ -d "ios" ]; then
        log_info "Cleaning iOS builds..."
        cd ios
        rm -rf build/
        rm -rf Pods/
        rm -f Podfile.lock
        cd ..
    fi
    
    # Clean Android builds
    if [ -d "android" ]; then
        log_info "Cleaning Android builds..."
        cd android
        ./gradlew clean || true
        cd ..
    fi
    
    log_success "Clean completed!"
}

# Install dependencies
install_dependencies() {
    log_header "📦 Installing Dependencies"
    
    cd "$PROJECT_ROOT"
    
    log_info "Getting Flutter packages..."
    flutter pub get
    
    # Install iOS dependencies (macOS only)
    if [[ "$OSTYPE" == "darwin"* ]] && [ -d "ios" ] && command_exists pod; then
        log_info "Installing iOS dependencies..."
        cd ios
        pod install
        cd ..
    fi
    
    log_success "Dependencies installed!"
}

# Run tests and analysis
run_tests() {
    log_header "🧪 Running Tests and Analysis"
    
    cd "$PROJECT_ROOT"
    
    log_info "Running Flutter analyze..."
    flutter analyze || {
        log_error "Flutter analyze failed"
        exit 1
    }
    
    log_info "Running Flutter tests..."
    flutter test || {
        log_error "Flutter tests failed"
        exit 1
    }
    
    log_success "All tests passed!"
}

# Build iOS
build_ios() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_warning "Skipping iOS build - not running on macOS"
        return
    fi
    
    if ! command_exists xcodebuild; then
        log_warning "Skipping iOS build - Xcode not found"
        return
    fi
    
    log_header "📱 Building iOS Release"
    
    cd "$PROJECT_ROOT"
    
    log_info "Building iOS release..."
    flutter build ios --release --no-codesign
    
    log_success "iOS build completed!"
    log_info "📁 iOS build location: build/ios/iphoneos/Runner.app"
    
    log_info "🔧 Next steps for iOS deployment:"
    echo "1. Open ios/Runner.xcworkspace in Xcode"
    echo "2. Select 'Any iOS Device' as target"
    echo "3. Product → Archive"
    echo "4. Distribute App → App Store Connect"
}

# Build Android
build_android() {
    log_header "🤖 Building Android Release"
    
    cd "$PROJECT_ROOT"
    
    # Check for keystore configuration
    if [ ! -f "android/key.properties" ]; then
        log_warning "No signing configuration found. Building unsigned APK."
        log_info "For production deployment, configure signing in android/key.properties"
    fi
    
    log_info "Building Android App Bundle (AAB)..."
    flutter build appbundle --release
    
    log_info "Building Android APK..."
    flutter build apk --release
    
    log_success "Android builds completed!"
    log_info "📁 AAB location: build/app/outputs/bundle/release/app-release.aab"
    log_info "📁 APK location: build/app/outputs/flutter-apk/app-release.apk"
    
    log_info "🔧 Next steps for Android deployment:"
    echo "1. Upload app-release.aab to Google Play Console"
    echo "2. Create a release in Play Console"
    echo "3. Test on internal track first"
}

# Build Web
build_web() {
    log_header "🌐 Building Web Release"
    
    cd "$PROJECT_ROOT"
    
    log_info "Building Flutter web..."
    flutter build web --release --web-renderer html
    
    log_success "Web build completed!"
    log_info "📁 Web build location: build/web/"
    
    # Deploy to Firebase if available
    if command_exists firebase; then
        log_info "Deploying to Firebase Hosting..."
        
        # Check if Firebase is initialized
        if [ -f "firebase.json" ]; then
            firebase deploy --only hosting
            log_success "Web deployed to Firebase Hosting!"
        else
            log_warning "Firebase not initialized. Run 'firebase init hosting' first."
            log_info "🔧 Manual deployment steps:"
            echo "1. Run 'firebase init hosting'"
            echo "2. Set public directory to 'build/web'"
            echo "3. Configure as single-page app: Yes"
            echo "4. Run 'firebase deploy --only hosting'"
        fi
    else
        log_info "🔧 Manual web deployment options:"
        echo "1. Firebase Hosting: Install Firebase CLI and run deployment"
        echo "2. Static hosting: Upload build/web/ contents to your web server"
        echo "3. GitHub Pages: Push build/web/ to gh-pages branch"
    fi
}

# Generate deployment report
generate_report() {
    log_header "📊 Generating Deployment Report"
    
    local report_file="$BUILD_DIR/deployment-report-$(date +%Y%m%d-%H%M%S).md"
    mkdir -p "$BUILD_DIR"
    
    cat > "$report_file" << EOF
# CycleSync Enterprise Deployment Report

**Date:** $(date)
**Version:** $VERSION
**Git Commit:** $(git rev-parse HEAD)
**Git Branch:** $(git branch --show-current)

## Build Summary

### Environment
- **OS:** $(uname -s) $(uname -r)
- **Flutter:** $(flutter --version | head -n1)
- **Dart:** $(dart --version)

### Build Artifacts

EOF
    
    # iOS artifacts
    if [ -d "build/ios" ]; then
        echo "#### iOS" >> "$report_file"
        echo "- ✅ iOS Release Build: \`build/ios/iphoneos/Runner.app\`" >> "$report_file"
        echo "" >> "$report_file"
    fi
    
    # Android artifacts
    if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
        echo "#### Android" >> "$report_file"
        echo "- ✅ Android App Bundle: \`build/app/outputs/bundle/release/app-release.aab\`" >> "$report_file"
    fi
    
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        echo "- ✅ Android APK: \`build/app/outputs/flutter-apk/app-release.apk\`" >> "$report_file"
        echo "" >> "$report_file"
    fi
    
    # Web artifacts
    if [ -d "build/web" ]; then
        echo "#### Web" >> "$report_file"
        echo "- ✅ Web Build: \`build/web/\`" >> "$report_file"
        echo "" >> "$report_file"
    fi
    
    cat >> "$report_file" << EOF
## Next Steps

### iOS Deployment
1. Open \`ios/Runner.xcworkspace\` in Xcode
2. Archive and upload to App Store Connect
3. Submit for review

### Android Deployment
1. Upload AAB to Google Play Console
2. Create production release
3. Roll out to users

### Web Deployment
1. Deploy \`build/web/\` to hosting provider
2. Configure domain and SSL
3. Set up CDN if needed

## Security Checklist
- [ ] Environment variables configured
- [ ] API keys secured
- [ ] HIPAA compliance verified
- [ ] Encryption enabled
- [ ] Analytics configured

---
Generated by CycleSync Enterprise Deployment Script
EOF
    
    log_success "Deployment report generated: $report_file"
}

# Main deployment function
main() {
    log_header "🚀 CycleSync Enterprise Deployment Script"
    log_info "Version: $VERSION"
    log_info "Starting deployment process..."
    
    # Parse command line arguments
    local build_ios=true
    local build_android=true
    local build_web=true
    local skip_tests=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --ios-only)
                build_android=false
                build_web=false
                shift
                ;;
            --android-only)
                build_ios=false
                build_web=false
                shift
                ;;
            --web-only)
                build_ios=false
                build_android=false
                shift
                ;;
            --skip-tests)
                skip_tests=true
                shift
                ;;
            --help)
                echo "Usage: $0 [OPTIONS]"
                echo "Options:"
                echo "  --ios-only     Build iOS only"
                echo "  --android-only Build Android only"
                echo "  --web-only     Build web only"
                echo "  --skip-tests   Skip tests and analysis"
                echo "  --help         Show this help"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Execute deployment steps
    validate_environment
    clean_build
    install_dependencies
    
    if [ "$skip_tests" = false ]; then
        run_tests
    else
        log_warning "Skipping tests as requested"
    fi
    
    # Build platforms
    if [ "$build_ios" = true ]; then
        build_ios
    fi
    
    if [ "$build_android" = true ]; then
        build_android
    fi
    
    if [ "$build_web" = true ]; then
        build_web
    fi
    
    generate_report
    
    log_header "🎉 Deployment Complete!"
    log_success "CycleSync Enterprise has been built successfully!"
    
    echo -e "\n${CYAN}📋 Summary:${NC}"
    [ "$build_ios" = true ] && echo -e "📱 ${GREEN}iOS:${NC} Ready for Xcode archiving"
    [ "$build_android" = true ] && echo -e "🤖 ${GREEN}Android:${NC} Ready for Play Console upload"  
    [ "$build_web" = true ] && echo -e "🌐 ${GREEN}Web:${NC} Ready for hosting deployment"
    
    echo -e "\n${PURPLE}🚀 Your enterprise healthcare platform is ready for production!${NC}"
}

# Run main function with all arguments
main "$@"
