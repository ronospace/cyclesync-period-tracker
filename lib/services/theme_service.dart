import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _useSystemThemeKey = 'use_system_theme';
  
  ThemeMode _themeMode = ThemeMode.system;
  bool _useSystemTheme = true;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get useSystemTheme => _useSystemTheme;
  bool get isInitialized => _isInitialized;

  bool get isDarkMode {
    switch (_themeMode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
  }

  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  // Initialize theme from saved preferences
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final savedTheme = prefs.getString(_themeKey);
      final savedUseSystemTheme = prefs.getBool(_useSystemThemeKey) ?? true;
      
      _useSystemTheme = savedUseSystemTheme;
      
      if (savedTheme != null && !_useSystemTheme) {
        switch (savedTheme) {
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          case 'system':
          default:
            _themeMode = ThemeMode.system;
            break;
        }
      } else {
        _themeMode = ThemeMode.system;
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing theme: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    _useSystemTheme = mode == ThemeMode.system;
    
    await _saveThemePreferences();
    notifyListeners();
  }

  // Toggle between light and dark (system mode excluded)
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }

  // Set to use system theme
  Future<void> setUseSystemTheme(bool useSystem) async {
    if (_useSystemTheme == useSystem) return;
    
    _useSystemTheme = useSystem;
    
    if (useSystem) {
      _themeMode = ThemeMode.system;
    }
    
    await _saveThemePreferences();
    notifyListeners();
  }

  // Save theme preferences to storage
  Future<void> _saveThemePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      String themeString;
      switch (_themeMode) {
        case ThemeMode.light:
          themeString = 'light';
          break;
        case ThemeMode.dark:
          themeString = 'dark';
          break;
        case ThemeMode.system:
        default:
          themeString = 'system';
          break;
      }
      
      await prefs.setString(_themeKey, themeString);
      await prefs.setBool(_useSystemThemeKey, _useSystemTheme);
    } catch (e) {
      debugPrint('Error saving theme preferences: $e');
    }
  }

  // Get current brightness based on context
  Brightness getBrightness(BuildContext context) {
    switch (_themeMode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness;
    }
  }

  // Check if current theme is dark
  bool isDarkModeEnabled(BuildContext context) {
    return getBrightness(context) == Brightness.dark;
  }

  // Get theme-appropriate colors
  Color getPrimaryColor(BuildContext context) {
    return isDarkModeEnabled(context) 
        ? AppTheme.primaryPink.withOpacity(0.8)
        : AppTheme.primaryPink;
  }

  Color getBackgroundColor(BuildContext context) {
    return isDarkModeEnabled(context) 
        ? const Color(0xFF121212)
        : const Color(0xFFFAFAFA);
  }

  Color getSurfaceColor(BuildContext context) {
    return isDarkModeEnabled(context) 
        ? const Color(0xFF1E1E1E)
        : Colors.white;
  }

  Color getTextColor(BuildContext context) {
    return isDarkModeEnabled(context) 
        ? Colors.white
        : Colors.black87;
  }

  // Use our advanced themes
  static ThemeData get lightTheme => AppTheme.lightTheme;
  static ThemeData get darkTheme => AppTheme.darkTheme;

  // Theme transition animation duration
  static const Duration transitionDuration = Duration(milliseconds: 300);

  // Get chart colors based on current theme
  Map<String, Color> getChartColors(BuildContext context) {
    return isDarkModeEnabled(context) 
        ? AppTheme.darkChartColors
        : AppTheme.lightChartColors;
  }

  // Get calendar colors based on current theme
  Map<String, Color> getCalendarColors(BuildContext context) {
    return isDarkModeEnabled(context) 
        ? AppTheme.calendarDarkColors
        : AppTheme.calendarLightColors;
  }

  // Get health colors (theme independent)
  Map<String, Color> getHealthColors() {
    return AppTheme.healthColors;
  }

  // Get theme-appropriate gradient
  LinearGradient getPrimaryGradient(BuildContext context) {
    return isDarkModeEnabled(context) 
        ? AppTheme.darkGradient
        : AppTheme.primaryGradient;
  }

  // Reset to default settings
  Future<void> resetToDefault() async {
    _themeMode = ThemeMode.system;
    _useSystemTheme = true;
    
    await _saveThemePreferences();
    notifyListeners();
  }
}
