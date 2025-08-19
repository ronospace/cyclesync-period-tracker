# CycleSync App Assets

This directory contains all the logo and icon assets for the CycleSync period tracking application.

## Design Concept

The CycleSync logo incorporates:
- **Moon phases** representing the natural cycles
- **Pink/purple color scheme** (#E91E63, #9C27B0, #FCE4EC) for feminine health themes
- **Circular arrangement** symbolizing the cyclical nature of periods
- **Clean, modern typography** for the app name

## Directory Structure

```
assets/
├── app_icon.png              # Main app icon (1024x1024)
├── logos/
│   ├── cyclesync_logo.svg    # Original vector logo design
│   ├── cyclesync_logo_512.png
│   ├── cyclesync_logo_1024.png
│   ├── cyclesync_logo_2048.png
│   ├── cyclesync_logo_square.png
│   └── favicon.png
├── icons/
│   ├── app_icon.svg          # Original vector icon design
│   ├── android/
│   │   ├── icon-48.png       # mdpi
│   │   ├── icon-72.png       # hdpi
│   │   ├── icon-96.png       # xhdpi
│   │   ├── icon-144.png      # xxhdpi
│   │   ├── icon-192.png      # xxxhdpi
│   │   └── icon-512.png      # Play Store
│   └── ios/
│       ├── icon-20.png → icon-1024.png   # All iOS sizes
│       └── (various iOS icon sizes)
```

## Platform Implementation

### Android
- Icons automatically generated and placed in `android/app/src/main/res/mipmap-*/`
- AndroidManifest.xml updated with `@mipmap/launcher_icon`
- Uses density-specific icons (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)

### iOS  
- Icons automatically generated and placed in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- Contents.json automatically updated with all required sizes
- Includes all required iOS app icon sizes (20pt to 1024pt)

### Web/Desktop
- Web icons generated automatically by flutter_launcher_icons
- MacOS and Windows icons configured in pubspec.yaml

## File Specifications

### Logo Files
- **cyclesync_logo.svg**: Original vector design (400x120px)
- **cyclesync_logo_*.png**: Marketing versions in various sizes
- **cyclesync_logo_square.png**: Square version for social media (400x400px)

### App Icon Files
- **app_icon.svg**: Original vector design (1024x1024px)
- **app_icon.png**: Main Flutter launcher icon source (1024x1024px)

### Color Palette
- Primary: #E91E63 (Pink 500)
- Secondary: #9C27B0 (Purple 500)
- Light: #FCE4EC (Pink 50)
- Dark: #6A1B9A (Purple 800)
- Background: #F8BBD9 (Pink 200)

## Usage Guidelines

1. **App Store/Play Store**: Use the 1024x1024 icon versions
2. **Marketing Materials**: Use the horizontal logo versions
3. **Social Media**: Use the square logo version
4. **Website Favicon**: Use favicon.png (32x32)
5. **High-DPI Displays**: Use 2048px versions for crisp rendering

## Tools Used

- **Vector Graphics**: SVG format for scalability
- **Conversion**: rsvg-convert (librsvg) for PNG generation
- **Flutter Integration**: flutter_launcher_icons plugin
- **Color Scheme**: Material Design color palette

## Maintenance

When updating icons:
1. Edit the SVG source files
2. Regenerate PNG files using rsvg-convert
3. Run `flutter pub run flutter_launcher_icons` to update platform-specific icons
4. Test on both Android and iOS devices

## Copyright

These assets are proprietary to the CycleSync application. All rights reserved.
