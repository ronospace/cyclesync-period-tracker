import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;

import 'cache_service.dart';
import 'retry_service.dart';

/// Supported languages in the app
enum SupportedLanguage {
  english('en', 'English', '🇺🇸'),
  spanish('es', 'Español', '🇪🇸'),
  french('fr', 'Français', '🇫🇷'),
  german('de', 'Deutsch', '🇩🇪'),
  italian('it', 'Italiano', '🇮🇹'),
  portuguese('pt', 'Português', '🇵🇹'),
  russian('ru', 'Русский', '🇷🇺'),
  chinese('zh', '中文', '🇨🇳'),
  japanese('ja', '日本語', '🇯🇵'),
  korean('ko', '한국어', '🇰🇷'),
  arabic('ar', 'العربية', '🇸🇦'),
  hindi('hi', 'हिंदी', '🇮🇳'),
  dutch('nl', 'Nederlands', '🇳🇱'),
  swedish('sv', 'Svenska', '🇸🇪'),
  polish('pl', 'Polski', '🇵🇱'),
  turkish('tr', 'Türkçe', '🇹🇷'),
  hebrew('he', 'עברית', '🇮🇱'),
  thai('th', 'ไทย', '🇹🇭'),
  vietnamese('vi', 'Tiếng Việt', '🇻🇳'),
  indonesian('id', 'Bahasa Indonesia', '🇮🇩');

  const SupportedLanguage(this.code, this.name, this.flag);

  final String code;
  final String name;
  final String flag;

  static SupportedLanguage fromCode(String code) {
    return SupportedLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => SupportedLanguage.english,
    );
  }
}

/// Translation context for better accuracy
enum TranslationContext {
  medical,      // Medical/health terminology
  ui,          // User interface elements
  symptoms,    // Symptom descriptions
  emotions,    // Mood and emotional states
  general,     // General app content
  notifications, // Push notifications
  errors,      // Error messages
  onboarding,  // Onboarding flow
  cycle,       // Menstrual cycle specific
  fertility,   // Fertility tracking
}

/// Translation request for batch processing
class TranslationRequest {
  final String key;
  final String text;
  final TranslationContext context;
  final SupportedLanguage targetLanguage;
  final Map<String, String>? variables;

  const TranslationRequest({
    required this.key,
    required this.text,
    required this.context,
    required this.targetLanguage,
    this.variables,
  });

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'text': text,
      'context': context.name,
      'targetLanguage': targetLanguage.code,
      'variables': variables,
    };
  }
}

/// Localization delegate for Flutter
class CycleSyncLocalizationsDelegate extends LocalizationsDelegate<CycleSyncLocalizations> {
  const CycleSyncLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return SupportedLanguage.values.any((lang) => lang.code == locale.languageCode);
  }

  @override
  Future<CycleSyncLocalizations> load(Locale locale) async {
    final localizations = CycleSyncLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(CycleSyncLocalizationsDelegate old) => false;
}

/// Main localization class
class CycleSyncLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  CycleSyncLocalizations(this.locale);

  static CycleSyncLocalizations? of(BuildContext context) {
    return Localizations.of<CycleSyncLocalizations>(context, CycleSyncLocalizations);
  }

  Future<void> load() async {
    final language = SupportedLanguage.fromCode(locale.languageCode);
    _localizedStrings = await I18nService().getTranslations(language);
  }

  String translate(String key, {Map<String, String>? variables}) {
    String text = _localizedStrings[key] ?? key;
    
    if (variables != null) {
      variables.forEach((key, value) {
        text = text.replaceAll('{$key}', value);
      });
    }
    
    return text;
  }

  // Helper method for common translations
  String get appName => translate('app_name');
  String get welcomeMessage => translate('welcome_message');
  String get cycleTracker => translate('cycle_tracker');
  String get symptoms => translate('symptoms');
  String get mood => translate('mood');
  String get predictions => translate('predictions');
  String get insights => translate('insights');
  String get settings => translate('settings');
  String get profile => translate('profile');
  String get calendar => translate('calendar');
  String get notifications => translate('notifications');
  String get privacy => translate('privacy');
  String get help => translate('help');
  String get logout => translate('logout');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get add => translate('add');
  String get remove => translate('remove');
  String get confirm => translate('confirm');
  String get error => translate('error');
  String get success => translate('success');
  String get loading => translate('loading');
}

/// Comprehensive internationalization service
class I18nService {
  static final I18nService _instance = I18nService._internal();
  factory I18nService() => _instance;
  I18nService._internal();

  static const String _languagePrefsKey = 'selected_language';
  static const String _translationsVersionKey = 'translations_version';
  static const String _autoTranslateKey = 'auto_translate_enabled';

  SupportedLanguage _currentLanguage = SupportedLanguage.english;
  final Map<SupportedLanguage, Map<String, String>> _translations = {};
  final Map<String, Timer> _translationTimers = {};
  final Set<String> _pendingTranslations = {};
  
  SharedPreferences? _prefs;
  bool _autoTranslateEnabled = true;
  bool _initialized = false;

  // Translation API configuration (would use real service in production)
  static const String _translationApiUrl = 'https://api.translate.service.com/v1/translate';
  static const String _translationApiKey = 'your_api_key_here';

  SupportedLanguage get currentLanguage => _currentLanguage;
  List<SupportedLanguage> get supportedLanguages => SupportedLanguage.values;
  bool get autoTranslateEnabled => _autoTranslateEnabled;

  /// Initialize the i18n service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      
      // Load saved language preference
      final languageCode = _prefs?.getString(_languagePrefsKey);
      if (languageCode != null) {
        _currentLanguage = SupportedLanguage.fromCode(languageCode);
      } else {
        // Detect system language
        _currentLanguage = _detectSystemLanguage();
      }

      // Load auto-translate preference
      _autoTranslateEnabled = _prefs?.getBool(_autoTranslateKey) ?? true;

      // Initialize date formatting
      await initializeDateFormatting(_currentLanguage.code);

      // Load base translations
      await _loadBaseTranslations();

      // Pre-load current language translations
      await _loadLanguageTranslations(_currentLanguage);

      _initialized = true;
      debugPrint('✅ I18nService initialized with language: ${_currentLanguage.name}');
    } catch (e) {
      debugPrint('❌ Failed to initialize I18nService: $e');
      rethrow;
    }
  }

  /// Change the app language
  Future<void> changeLanguage(SupportedLanguage language) async {
    if (_currentLanguage == language) return;

    _currentLanguage = language;
    await _prefs?.setString(_languagePrefsKey, language.code);

    // Initialize date formatting for new language
    await initializeDateFormatting(language.code);

    // Load translations for new language
    await _loadLanguageTranslations(language);

    debugPrint('🌐 Language changed to: ${language.name}');
  }

  /// Get translations for a specific language
  Future<Map<String, String>> getTranslations(SupportedLanguage language) async {
    if (!_translations.containsKey(language)) {
      await _loadLanguageTranslations(language);
    }
    return _translations[language] ?? {};
  }

  /// Translate a single text
  Future<String> translate(
    String key,
    String text, {
    SupportedLanguage? targetLanguage,
    TranslationContext context = TranslationContext.general,
    Map<String, String>? variables,
    bool forceRefresh = false,
  }) async {
    final target = targetLanguage ?? _currentLanguage;
    
    // Return immediately if target is English and we have the base text
    if (target == SupportedLanguage.english) {
      return _interpolateVariables(text, variables);
    }

    final cacheKey = '${target.code}:$key';
    
    // Check cache first
    if (!forceRefresh) {
      final cached = await CacheService().get<String>(cacheKey);
      if (cached != null) {
        return _interpolateVariables(cached, variables);
      }
    }

    // Get from loaded translations
    final translations = _translations[target];
    if (translations != null && translations.containsKey(key)) {
      return _interpolateVariables(translations[key]!, variables);
    }

    // Auto-translate if enabled
    if (_autoTranslateEnabled && !_pendingTranslations.contains(cacheKey)) {
      _scheduleTranslation(TranslationRequest(
        key: key,
        text: text,
        context: context,
        targetLanguage: target,
        variables: variables,
      ));
    }

    // Return original text as fallback
    return _interpolateVariables(text, variables);
  }

  /// Batch translate multiple texts
  Future<Map<String, String>> batchTranslate(
    List<TranslationRequest> requests,
  ) async {
    if (!_autoTranslateEnabled) return {};

    final results = <String, String>{};
    final toTranslate = <TranslationRequest>[];

    // Check cache first
    for (final request in requests) {
      final cacheKey = '${request.targetLanguage.code}:${request.key}';
      final cached = await CacheService().get<String>(cacheKey);
      
      if (cached != null) {
        results[request.key] = _interpolateVariables(cached, request.variables);
      } else {
        toTranslate.add(request);
      }
    }

    // Translate remaining requests
    if (toTranslate.isNotEmpty) {
      try {
        final translated = await _performBatchTranslation(toTranslate);
        results.addAll(translated);
      } catch (e) {
        debugPrint('❌ Batch translation failed: $e');
      }
    }

    return results;
  }

  /// Get formatted date according to current language
  String formatDate(DateTime date, [String? pattern]) {
    final formatter = DateFormat(pattern ?? 'yMMMd', _currentLanguage.code);
    return formatter.format(date);
  }

  /// Get formatted time according to current language
  String formatTime(DateTime time, [bool use24Hour = false]) {
    final pattern = use24Hour ? 'HH:mm' : 'h:mm a';
    final formatter = DateFormat(pattern, _currentLanguage.code);
    return formatter.format(time);
  }

  /// Get formatted number according to current language
  String formatNumber(num number, [int? decimalDigits]) {
    final formatter = NumberFormat.decimalPattern(_currentLanguage.code);
    if (decimalDigits != null) {
      formatter.minimumFractionDigits = decimalDigits;
      formatter.maximumFractionDigits = decimalDigits;
    }
    return formatter.format(number);
  }

  /// Get currency formatted according to current language
  String formatCurrency(num amount, String currencyCode) {
    final formatter = NumberFormat.currency(
      locale: _currentLanguage.code,
      symbol: currencyCode,
    );
    return formatter.format(amount);
  }

  /// Export all translations for a language
  Future<Map<String, dynamic>> exportTranslations(SupportedLanguage language) async {
    final translations = await getTranslations(language);
    return {
      'language': language.code,
      'languageName': language.name,
      'version': await _getTranslationsVersion(),
      'translations': translations,
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  /// Import translations from external source
  Future<bool> importTranslations(
    SupportedLanguage language,
    Map<String, String> translations,
  ) async {
    try {
      _translations[language] = translations;
      
      // Cache translations
      for (final entry in translations.entries) {
        final cacheKey = '${language.code}:${entry.key}';
        await CacheService().set(
          cacheKey,
          entry.value,
          policy: CacheExpiryPolicy.weekly,
        );
      }

      await _saveTranslationsToDevice(language, translations);
      debugPrint('✅ Imported ${translations.length} translations for ${language.name}');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to import translations: $e');
      return false;
    }
  }

  /// Enable/disable automatic translation
  Future<void> setAutoTranslateEnabled(bool enabled) async {
    _autoTranslateEnabled = enabled;
    await _prefs?.setBool(_autoTranslateKey, enabled);
    debugPrint('🤖 Auto-translate ${enabled ? "enabled" : "disabled"}');
  }

  /// Get translation statistics
  Map<String, dynamic> getTranslationStats() {
    final stats = <String, dynamic>{
      'currentLanguage': _currentLanguage.name,
      'supportedLanguages': SupportedLanguage.values.length,
      'autoTranslateEnabled': _autoTranslateEnabled,
      'languageStats': <String, int>{},
    };

    for (final entry in _translations.entries) {
      stats['languageStats'][entry.key.name] = entry.value.length;
    }

    return stats;
  }

  /// Clear translation cache
  Future<void> clearTranslationCache([SupportedLanguage? language]) async {
    if (language != null) {
      final pattern = '${language.code}:.*';
      await CacheService().removePattern(pattern);
      _translations.remove(language);
    } else {
      await CacheService().removePattern('.*:.*'); // All translations
      _translations.clear();
    }
  }

  // Private helper methods

  SupportedLanguage _detectSystemLanguage() {
    final systemLocale = PlatformDispatcher.instance.locale.languageCode;
    return SupportedLanguage.fromCode(systemLocale);
  }

  Future<void> _loadBaseTranslations() async {
    try {
      // Load English as base language
      final englishTranslations = await _loadTranslationsFromAssets(SupportedLanguage.english);
      _translations[SupportedLanguage.english] = englishTranslations;
    } catch (e) {
      debugPrint('❌ Failed to load base translations: $e');
      // Fallback to hardcoded translations
      _translations[SupportedLanguage.english] = _getFallbackTranslations();
    }
  }

  Future<void> _loadLanguageTranslations(SupportedLanguage language) async {
    if (_translations.containsKey(language)) return;

    try {
      // Try to load from device storage first
      var translations = await _loadTranslationsFromDevice(language);
      
      if (translations.isEmpty) {
        // Load from assets
        translations = await _loadTranslationsFromAssets(language);
      }

      if (translations.isEmpty && language != SupportedLanguage.english) {
        // Auto-translate from English
        if (_autoTranslateEnabled) {
          translations = await _autoTranslateFromEnglish(language);
        }
      }

      _translations[language] = translations;
    } catch (e) {
      debugPrint('❌ Failed to load translations for ${language.name}: $e');
    }
  }

  Future<Map<String, String>> _loadTranslationsFromAssets(SupportedLanguage language) async {
    try {
      final String jsonString = await rootBundle.loadString('assets/i18n/${language.code}.json');
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return jsonMap.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      debugPrint('Could not load translations from assets for ${language.code}: $e');
      return {};
    }
  }

  Future<Map<String, String>> _loadTranslationsFromDevice(SupportedLanguage language) async {
    try {
      final key = 'translations_${language.code}';
      final jsonString = _prefs?.getString(key);
      if (jsonString != null) {
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        return jsonMap.map((key, value) => MapEntry(key, value.toString()));
      }
    } catch (e) {
      debugPrint('Could not load translations from device for ${language.code}: $e');
    }
    return {};
  }

  Future<void> _saveTranslationsToDevice(SupportedLanguage language, Map<String, String> translations) async {
    try {
      final key = 'translations_${language.code}';
      final jsonString = jsonEncode(translations);
      await _prefs?.setString(key, jsonString);
    } catch (e) {
      debugPrint('Could not save translations to device for ${language.code}: $e');
    }
  }

  Future<Map<String, String>> _autoTranslateFromEnglish(SupportedLanguage targetLanguage) async {
    final englishTranslations = _translations[SupportedLanguage.english] ?? {};
    if (englishTranslations.isEmpty) return {};

    final requests = englishTranslations.entries.map((entry) => TranslationRequest(
      key: entry.key,
      text: entry.value,
      context: _inferContext(entry.key),
      targetLanguage: targetLanguage,
    )).toList();

    try {
      return await _performBatchTranslation(requests);
    } catch (e) {
      debugPrint('❌ Auto-translation failed for ${targetLanguage.name}: $e');
      return {};
    }
  }

  void _scheduleTranslation(TranslationRequest request) {
    final cacheKey = '${request.targetLanguage.code}:${request.key}';
    _pendingTranslations.add(cacheKey);

    // Cancel existing timer for this key
    _translationTimers[cacheKey]?.cancel();

    // Schedule translation with debouncing
    _translationTimers[cacheKey] = Timer(const Duration(milliseconds: 500), () async {
      try {
        final result = await _performSingleTranslation(request);
        if (result.isNotEmpty) {
          await CacheService().set(
            cacheKey,
            result,
            policy: CacheExpiryPolicy.weekly,
          );
          
          // Update in-memory cache
          _translations[request.targetLanguage] ??= {};
          _translations[request.targetLanguage]![request.key] = result;
        }
      } catch (e) {
        debugPrint('❌ Scheduled translation failed: $e');
      } finally {
        _pendingTranslations.remove(cacheKey);
        _translationTimers.remove(cacheKey);
      }
    });
  }

  Future<String> _performSingleTranslation(TranslationRequest request) async {
    return await RetryService().execute(
      'translate_single',
      () => _callTranslationApi(request.text, request.targetLanguage, request.context),
      config: RetryConfig.network,
    );
  }

  Future<Map<String, String>> _performBatchTranslation(List<TranslationRequest> requests) async {
    return await RetryService().execute(
      'translate_batch',
      () => _callBatchTranslationApi(requests),
      config: RetryConfig.network,
    );
  }

  Future<String> _callTranslationApi(
    String text,
    SupportedLanguage targetLanguage,
    TranslationContext context,
  ) async {
    // This would integrate with a real translation service like Google Translate, DeepL, etc.
    // For demo purposes, return a mock translation
    if (kDebugMode) {
      await Future.delayed(const Duration(milliseconds: 100));
      return '[${targetLanguage.code.toUpperCase()}] $text';
    }

    final response = await http.post(
      Uri.parse(_translationApiUrl),
      headers: {
        'Authorization': 'Bearer $_translationApiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'text': text,
        'target_language': targetLanguage.code,
        'context': context.name,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['translated_text'] ?? text;
    } else {
      throw Exception('Translation API error: ${response.statusCode}');
    }
  }

  Future<Map<String, String>> _callBatchTranslationApi(List<TranslationRequest> requests) async {
    // Mock batch translation for demo
    if (kDebugMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      final results = <String, String>{};
      for (final request in requests) {
        results[request.key] = '[${request.targetLanguage.code.toUpperCase()}] ${request.text}';
      }
      return results;
    }

    final response = await http.post(
      Uri.parse('$_translationApiUrl/batch'),
      headers: {
        'Authorization': 'Bearer $_translationApiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'requests': requests.map((r) => r.toMap()).toList(),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> translations = data['translations'] ?? [];
      final results = <String, String>{};
      
      for (int i = 0; i < requests.length && i < translations.length; i++) {
        results[requests[i].key] = translations[i]['translated_text'] ?? requests[i].text;
      }
      
      return results;
    } else {
      throw Exception('Batch translation API error: ${response.statusCode}');
    }
  }

  String _interpolateVariables(String text, Map<String, String>? variables) {
    if (variables == null) return text;
    
    String result = text;
    variables.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    
    return result;
  }

  TranslationContext _inferContext(String key) {
    if (key.contains('symptom') || key.contains('pain') || key.contains('flow')) {
      return TranslationContext.symptoms;
    } else if (key.contains('mood') || key.contains('emotion')) {
      return TranslationContext.emotions;
    } else if (key.contains('cycle') || key.contains('period')) {
      return TranslationContext.cycle;
    } else if (key.contains('fertile') || key.contains('ovulation')) {
      return TranslationContext.fertility;
    } else if (key.contains('error') || key.contains('warning')) {
      return TranslationContext.errors;
    } else if (key.contains('notification') || key.contains('reminder')) {
      return TranslationContext.notifications;
    } else if (key.contains('medical') || key.contains('health')) {
      return TranslationContext.medical;
    } else if (key.contains('button') || key.contains('menu') || key.contains('title')) {
      return TranslationContext.ui;
    }
    
    return TranslationContext.general;
  }

  Future<String> _getTranslationsVersion() async {
    return _prefs?.getString(_translationsVersionKey) ?? '1.0.0';
  }

  Map<String, String> _getFallbackTranslations() {
    return {
      'app_name': 'CycleSync',
      'welcome_message': 'Welcome to CycleSync',
      'cycle_tracker': 'Cycle Tracker',
      'symptoms': 'Symptoms',
      'mood': 'Mood',
      'predictions': 'Predictions',
      'insights': 'Insights',
      'settings': 'Settings',
      'profile': 'Profile',
      'calendar': 'Calendar',
      'notifications': 'Notifications',
      'privacy': 'Privacy',
      'help': 'Help',
      'logout': 'Logout',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'remove': 'Remove',
      'confirm': 'Confirm',
      'error': 'Error',
      'success': 'Success',
      'loading': 'Loading...',
      'no_data': 'No data available',
      'network_error': 'Network connection error',
      'try_again': 'Try again',
      'period_start': 'Period started',
      'period_end': 'Period ended',
      'ovulation_predicted': 'Ovulation predicted',
      'fertile_window': 'Fertile window',
      'cycle_length': 'Cycle length: {days} days',
      'next_period': 'Next period in {days} days',
    };
  }

  /// Dispose of resources
  void dispose() {
    for (final timer in _translationTimers.values) {
      timer.cancel();
    }
    _translationTimers.clear();
  }
}

/// Helper extension for easy translation access
extension TranslationExtension on String {
  String tr([Map<String, String>? variables]) {
    return I18nService().translate(this, this, variables: variables).then((result) => result) as String;
  }
}
