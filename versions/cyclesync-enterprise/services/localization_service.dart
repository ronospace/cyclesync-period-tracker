import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends ChangeNotifier {
  static const String _localeKey = 'selected_locale';
  
  Locale _currentLocale = const Locale('en', 'US');
  bool _isInitialized = false;

  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English
    Locale('es', 'ES'), // Spanish
    Locale('fr', 'FR'), // French
    Locale('de', 'DE'), // German
    Locale('it', 'IT'), // Italian
    Locale('pt', 'BR'), // Portuguese (Brazil)
    Locale('zh', 'CN'), // Chinese (Simplified)
    Locale('ja', 'JP'), // Japanese
    Locale('ko', 'KR'), // Korean
    Locale('ar', 'SA'), // Arabic
    Locale('hi', 'IN'), // Hindi
    Locale('ru', 'RU'), // Russian
  ];

  // Language display names
  static const Map<String, Map<String, String>> _languageNames = {
    'en_US': {'name': 'English', 'nativeName': 'English'},
    'es_ES': {'name': 'Spanish', 'nativeName': 'Español'},
    'fr_FR': {'name': 'French', 'nativeName': 'Français'},
    'de_DE': {'name': 'German', 'nativeName': 'Deutsch'},
    'it_IT': {'name': 'Italian', 'nativeName': 'Italiano'},
    'pt_BR': {'name': 'Portuguese', 'nativeName': 'Português'},
    'zh_CN': {'name': 'Chinese', 'nativeName': '中文'},
    'ja_JP': {'name': 'Japanese', 'nativeName': '日本語'},
    'ko_KR': {'name': 'Korean', 'nativeName': '한국어'},
    'ar_SA': {'name': 'Arabic', 'nativeName': 'العربية'},
    'hi_IN': {'name': 'Hindi', 'nativeName': 'हिन्दी'},
    'ru_RU': {'name': 'Russian', 'nativeName': 'Русский'},
  };

  Locale get currentLocale => _currentLocale;
  bool get isInitialized => _isInitialized;
  String get languageCode => _currentLocale.languageCode;
  String get countryCode => _currentLocale.countryCode ?? '';

  /// Initialize localization service
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocaleString = prefs.getString(_localeKey);
      
      if (savedLocaleString != null) {
        final parts = savedLocaleString.split('_');
        if (parts.length == 2) {
          final locale = Locale(parts[0], parts[1]);
          if (supportedLocales.contains(locale)) {
            _currentLocale = locale;
          }
        }
      } else {
        // Use system locale if supported
        final systemLocale = _getSystemLocale();
        if (supportedLocales.contains(systemLocale)) {
          _currentLocale = systemLocale;
        }
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing localization: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Set current locale
  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) {
      debugPrint('Unsupported locale: $locale');
      return;
    }

    if (_currentLocale == locale) return;

    _currentLocale = locale;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, '${locale.languageCode}_${locale.countryCode}');
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }

    notifyListeners();
  }

  /// Get system locale
  Locale _getSystemLocale() {
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    
    // Try to match with supported locales
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == systemLocale.languageCode) {
        if (supportedLocale.countryCode == systemLocale.countryCode) {
          return supportedLocale; // Exact match
        }
      }
    }
    
    // Fall back to language-only match
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == systemLocale.languageCode) {
        return supportedLocale;
      }
    }
    
    // Default to English
    return const Locale('en', 'US');
  }

  /// Get language display name
  String getLanguageName(Locale locale, {bool useNativeName = false}) {
    final key = '${locale.languageCode}_${locale.countryCode}';
    final languageData = _languageNames[key];
    
    if (languageData == null) {
      return '${locale.languageCode}_${locale.countryCode}';
    }
    
    return useNativeName ? languageData['nativeName']! : languageData['name']!;
  }

  /// Get current language display name
  String get currentLanguageName => getLanguageName(_currentLocale);
  String get currentLanguageNativeName => getLanguageName(_currentLocale, useNativeName: true);

  /// Check if current locale is RTL
  bool get isRTL => _currentLocale.languageCode == 'ar';

  /// Get text direction
  TextDirection get textDirection => isRTL ? TextDirection.rtl : TextDirection.ltr;

  /// Get all available languages for selection
  List<Map<String, dynamic>> get availableLanguages {
    return supportedLocales.map((locale) {
      final key = '${locale.languageCode}_${locale.countryCode}';
      final languageData = _languageNames[key]!;
      
      return {
        'locale': locale,
        'name': languageData['name'],
        'nativeName': languageData['nativeName'],
        'isSelected': locale == _currentLocale,
        'flag': _getFlagEmoji(locale),
      };
    }).toList();
  }

  /// Get flag emoji for locale
  String _getFlagEmoji(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return locale.countryCode == 'GB' ? '🇬🇧' : '🇺🇸';
      case 'es':
        return '🇪🇸';
      case 'fr':
        return '🇫🇷';
      case 'de':
        return '🇩🇪';
      case 'it':
        return '🇮🇹';
      case 'pt':
        return '🇧🇷';
      case 'zh':
        return '🇨🇳';
      case 'ja':
        return '🇯🇵';
      case 'ko':
        return '🇰🇷';
      case 'ar':
        return '🇸🇦';
      case 'hi':
        return '🇮🇳';
      case 'ru':
        return '🇷🇺';
      default:
        return '🌐';
    }
  }

  /// Reset to system locale
  Future<void> resetToSystemLocale() async {
    final systemLocale = _getSystemLocale();
    await setLocale(systemLocale);
  }

  /// Format date according to current locale
  String formatDate(DateTime date) {
    // This is a simplified formatter - in a real app, use intl package
    switch (_currentLocale.languageCode) {
      case 'en':
        return '${date.month}/${date.day}/${date.year}';
      case 'de':
      case 'fr':
      case 'it':
      case 'es':
        return '${date.day}/${date.month}/${date.year}';
      case 'zh':
      case 'ja':
      case 'ko':
        return '${date.year}/${date.month}/${date.day}';
      default:
        return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Format time according to current locale
  String formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    
    switch (_currentLocale.languageCode) {
      case 'en':
        // 12-hour format
        final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        final period = hour < 12 ? 'AM' : 'PM';
        return '$hour12:$minute $period';
      default:
        // 24-hour format
        return '${hour.toString().padLeft(2, '0')}:$minute';
    }
  }

  /// Get localized strings (this would be replaced with actual localization)
  Map<String, String> get localizedStrings {
    // This is a placeholder - in a real app, use proper localization files
    switch (_currentLocale.languageCode) {
      case 'es':
        return {
          'app_name': 'CycleSync',
          'home': 'Inicio',
          'cycle': 'Ciclo',
          'settings': 'Configuración',
          'profile': 'Perfil',
          // Add more translations
        };
      case 'fr':
        return {
          'app_name': 'CycleSync',
          'home': 'Accueil',
          'cycle': 'Cycle',
          'settings': 'Paramètres',
          'profile': 'Profil',
          // Add more translations
        };
      // Add other languages
      default:
        return {
          'app_name': 'CycleSync',
          'home': 'Home',
          'cycle': 'Cycle',
          'settings': 'Settings',
          'profile': 'Profile',
          // Default English strings
        };
    }
  }

  /// Get localized string by key
  String getString(String key) {
    return localizedStrings[key] ?? key;
  }
}
