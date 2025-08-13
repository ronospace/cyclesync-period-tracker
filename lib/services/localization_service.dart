import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends ChangeNotifier {
  static const String _localeKey = 'selected_locale';
  
  Locale _currentLocale = const Locale('en', 'US');
  bool _isInitialized = false;

  // Supported locales - 28 languages for global coverage
  static const List<Locale> supportedLocales = [
    // Major Languages
    Locale('en', 'US'), // English (US)
    Locale('en', 'GB'), // English (UK)
    Locale('es', 'ES'), // Spanish (Spain)
    Locale('es', 'MX'), // Spanish (Mexico)
    Locale('fr', 'FR'), // French
    Locale('de', 'DE'), // German
    Locale('it', 'IT'), // Italian
    Locale('pt', 'BR'), // Portuguese (Brazil)
    Locale('pt', 'PT'), // Portuguese (Portugal)
    
    // Asian Languages
    Locale('zh', 'CN'), // Chinese (Simplified)
    Locale('zh', 'TW'), // Chinese (Traditional)
    Locale('ja', 'JP'), // Japanese
    Locale('ko', 'KR'), // Korean
    Locale('hi', 'IN'), // Hindi
    Locale('th', 'TH'), // Thai
    Locale('vi', 'VN'), // Vietnamese
    Locale('id', 'ID'), // Indonesian
    Locale('ms', 'MY'), // Malay
    
    // European Languages
    Locale('ru', 'RU'), // Russian
    Locale('pl', 'PL'), // Polish
    Locale('nl', 'NL'), // Dutch
    Locale('sv', 'SE'), // Swedish
    Locale('no', 'NO'), // Norwegian
    Locale('da', 'DK'), // Danish
    Locale('fi', 'FI'), // Finnish
    Locale('cs', 'CZ'), // Czech
    Locale('hu', 'HU'), // Hungarian
    Locale('ro', 'RO'), // Romanian
    
    // Middle Eastern & African Languages
    Locale('ar', 'SA'), // Arabic
    Locale('tr', 'TR'), // Turkish
    Locale('he', 'IL'), // Hebrew
    Locale('sw', 'KE'), // Swahili
    
    // Other Important Languages
    Locale('bn', 'BD'), // Bengali
    Locale('ur', 'PK'), // Urdu
    Locale('fa', 'IR'), // Persian/Farsi
    Locale('uk', 'UA'), // Ukrainian
  ];

  // Language display names for all 36 supported languages
  static const Map<String, Map<String, String>> _languageNames = {
    // Major Languages
    'en_US': {'name': 'English (US)', 'nativeName': 'English (US)'},
    'en_GB': {'name': 'English (UK)', 'nativeName': 'English (UK)'},
    'es_ES': {'name': 'Spanish (Spain)', 'nativeName': 'Español (España)'},
    'es_MX': {'name': 'Spanish (Mexico)', 'nativeName': 'Español (México)'},
    'fr_FR': {'name': 'French', 'nativeName': 'Français'},
    'de_DE': {'name': 'German', 'nativeName': 'Deutsch'},
    'it_IT': {'name': 'Italian', 'nativeName': 'Italiano'},
    'pt_BR': {'name': 'Portuguese (Brazil)', 'nativeName': 'Português (Brasil)'},
    'pt_PT': {'name': 'Portuguese (Portugal)', 'nativeName': 'Português (Portugal)'},
    
    // Asian Languages
    'zh_CN': {'name': 'Chinese (Simplified)', 'nativeName': '中文 (简体)'},
    'zh_TW': {'name': 'Chinese (Traditional)', 'nativeName': '中文 (繁體)'},
    'ja_JP': {'name': 'Japanese', 'nativeName': '日本語'},
    'ko_KR': {'name': 'Korean', 'nativeName': '한국어'},
    'hi_IN': {'name': 'Hindi', 'nativeName': 'हिन्दी'},
    'th_TH': {'name': 'Thai', 'nativeName': 'ไทย'},
    'vi_VN': {'name': 'Vietnamese', 'nativeName': 'Tiếng Việt'},
    'id_ID': {'name': 'Indonesian', 'nativeName': 'Bahasa Indonesia'},
    'ms_MY': {'name': 'Malay', 'nativeName': 'Bahasa Melayu'},
    
    // European Languages
    'ru_RU': {'name': 'Russian', 'nativeName': 'Русский'},
    'pl_PL': {'name': 'Polish', 'nativeName': 'Polski'},
    'nl_NL': {'name': 'Dutch', 'nativeName': 'Nederlands'},
    'sv_SE': {'name': 'Swedish', 'nativeName': 'Svenska'},
    'no_NO': {'name': 'Norwegian', 'nativeName': 'Norsk'},
    'da_DK': {'name': 'Danish', 'nativeName': 'Dansk'},
    'fi_FI': {'name': 'Finnish', 'nativeName': 'Suomi'},
    'cs_CZ': {'name': 'Czech', 'nativeName': 'Čeština'},
    'hu_HU': {'name': 'Hungarian', 'nativeName': 'Magyar'},
    'ro_RO': {'name': 'Romanian', 'nativeName': 'Română'},
    
    // Middle Eastern & African Languages
    'ar_SA': {'name': 'Arabic', 'nativeName': 'العربية'},
    'tr_TR': {'name': 'Turkish', 'nativeName': 'Türkçe'},
    'he_IL': {'name': 'Hebrew', 'nativeName': 'עברית'},
    'sw_KE': {'name': 'Swahili', 'nativeName': 'Kiswahili'},
    
    // Other Important Languages
    'bn_BD': {'name': 'Bengali', 'nativeName': 'বাংলা'},
    'ur_PK': {'name': 'Urdu', 'nativeName': 'اردو'},
    'fa_IR': {'name': 'Persian', 'nativeName': 'فارسی'},
    'uk_UA': {'name': 'Ukrainian', 'nativeName': 'Українська'},
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
  bool get isRTL => ['ar', 'he', 'fa', 'ur'].contains(_currentLocale.languageCode);

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
    final key = '${locale.languageCode}_${locale.countryCode}';
    
    switch (key) {
      // Major Languages
      case 'en_US': return '🇺🇸'; // United States
      case 'en_GB': return '🇬🇧'; // United Kingdom
      case 'es_ES': return '🇪🇸'; // Spain
      case 'es_MX': return '🇲🇽'; // Mexico
      case 'fr_FR': return '🇫🇷'; // France
      case 'de_DE': return '🇩🇪'; // Germany
      case 'it_IT': return '🇮🇹'; // Italy
      case 'pt_BR': return '🇧🇷'; // Brazil
      case 'pt_PT': return '🇵🇹'; // Portugal
      
      // Asian Languages
      case 'zh_CN': return '🇨🇳'; // China
      case 'zh_TW': return '🇹🇼'; // Taiwan
      case 'ja_JP': return '🇯🇵'; // Japan
      case 'ko_KR': return '🇰🇷'; // South Korea
      case 'hi_IN': return '🇮🇳'; // India
      case 'th_TH': return '🇹🇭'; // Thailand
      case 'vi_VN': return '🇻🇳'; // Vietnam
      case 'id_ID': return '🇮🇩'; // Indonesia
      case 'ms_MY': return '🇲🇾'; // Malaysia
      
      // European Languages
      case 'ru_RU': return '🇷🇺'; // Russia
      case 'pl_PL': return '🇵🇱'; // Poland
      case 'nl_NL': return '🇳🇱'; // Netherlands
      case 'sv_SE': return '🇸🇪'; // Sweden
      case 'no_NO': return '🇳🇴'; // Norway
      case 'da_DK': return '🇩🇰'; // Denmark
      case 'fi_FI': return '🇫🇮'; // Finland
      case 'cs_CZ': return '🇨🇿'; // Czech Republic
      case 'hu_HU': return '🇭🇺'; // Hungary
      case 'ro_RO': return '🇷🇴'; // Romania
      
      // Middle Eastern & African Languages
      case 'ar_SA': return '🇸🇦'; // Saudi Arabia
      case 'tr_TR': return '🇹🇷'; // Turkey
      case 'he_IL': return '🇮🇱'; // Israel
      case 'sw_KE': return '🇰🇪'; // Kenya
      
      // Other Important Languages
      case 'bn_BD': return '🇧🇩'; // Bangladesh
      case 'ur_PK': return '🇵🇰'; // Pakistan
      case 'fa_IR': return '🇮🇷'; // Iran
      case 'uk_UA': return '🇺🇦'; // Ukraine
      
      default: return '🌐'; // Globe for unsupported
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
