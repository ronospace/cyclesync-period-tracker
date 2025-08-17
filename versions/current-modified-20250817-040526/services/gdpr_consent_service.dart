import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

/// A service to handle GDPR and data privacy consent
class GDPRConsentService extends ChangeNotifier {
  static const String _consentKey = 'gdpr_consent_status';
  static const String _personalizedAdsKey = 'personalized_ads_consent';
  static const String _analyticsKey = 'analytics_consent';
  static const String _aiProcessingKey = 'ai_processing_consent';
  static const String _consentVersionKey = 'consent_version';
  static const String _consentShownTimestampKey = 'consent_timestamp';
  
  // Current consent version - increment when privacy policy changes require re-consent
  static const int currentConsentVersion = 1;

  late SharedPreferences _prefs;
  bool _isInitialized = false;
  bool _hasConsent = false;
  bool _hasPersonalizedAdsConsent = false;
  bool _hasAnalyticsConsent = false;
  bool _hasAIProcessingConsent = false;
  int _consentVersion = 0;
  DateTime? _consentTimestamp;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get hasConsent => _hasConsent;
  bool get hasPersonalizedAdsConsent => _hasPersonalizedAdsConsent;
  bool get hasAnalyticsConsent => _hasAnalyticsConsent;
  bool get hasAIProcessingConsent => _hasAIProcessingConsent;
  bool get needsReConsent => _consentVersion < currentConsentVersion && _hasConsent;
  int get consentVersion => _consentVersion;
  DateTime? get consentTimestamp => _consentTimestamp;
  
  // Private constructor for singleton pattern
  GDPRConsentService._();
  
  // Singleton instance
  static final GDPRConsentService _instance = GDPRConsentService._();
  
  // Factory constructor to return the same instance
  factory GDPRConsentService() => _instance;

  /// Initialize the service by loading stored preferences
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _prefs = await SharedPreferences.getInstance();
    
    // Load stored consent values
    _hasConsent = _prefs.getBool(_consentKey) ?? false;
    _hasPersonalizedAdsConsent = _prefs.getBool(_personalizedAdsKey) ?? false;
    _hasAnalyticsConsent = _prefs.getBool(_analyticsKey) ?? false;
    _hasAIProcessingConsent = _prefs.getBool(_aiProcessingKey) ?? false;
    _consentVersion = _prefs.getInt(_consentVersionKey) ?? 0;
    
    final timestamp = _prefs.getInt(_consentShownTimestampKey);
    if (timestamp != null) {
      _consentTimestamp = DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    
    _isInitialized = true;
    notifyListeners();
    
    debugPrint('GDPR Consent Service initialized');
    debugPrint('Consent status: ${_hasConsent ? "Granted" : "Not granted"}');
    debugPrint('Consent version: $_consentVersion (Current: $currentConsentVersion)');
    
    // Check if we need to request consent again due to version change
    if (needsReConsent) {
      debugPrint('Re-consent needed: User consented to version $_consentVersion but current is $currentConsentVersion');
    }
  }

  /// Update all consent settings at once
  Future<void> updateAllConsent({
    required bool generalConsent,
    required bool personalizedAdsConsent,
    required bool analyticsConsent,
    required bool aiProcessingConsent,
  }) async {
    if (!_isInitialized) await initialize();
    
    _hasConsent = generalConsent;
    _hasPersonalizedAdsConsent = personalizedAdsConsent;
    _hasAnalyticsConsent = analyticsConsent;
    _hasAIProcessingConsent = aiProcessingConsent;
    _consentVersion = currentConsentVersion;
    _consentTimestamp = DateTime.now();
    
    await _prefs.setBool(_consentKey, generalConsent);
    await _prefs.setBool(_personalizedAdsKey, personalizedAdsConsent);
    await _prefs.setBool(_analyticsKey, analyticsConsent);
    await _prefs.setBool(_aiProcessingKey, aiProcessingConsent);
    await _prefs.setInt(_consentVersionKey, currentConsentVersion);
    await _prefs.setInt(_consentShownTimestampKey, DateTime.now().millisecondsSinceEpoch);
    
    notifyListeners();
    
    debugPrint('Updated all consent settings:');
    debugPrint('General consent: $generalConsent');
    debugPrint('Personalized ads: $personalizedAdsConsent');
    debugPrint('Analytics: $analyticsConsent');
    debugPrint('AI processing: $aiProcessingConsent');
  }

  /// Update general consent status
  Future<void> updateGeneralConsent(bool value) async {
    if (!_isInitialized) await initialize();
    
    _hasConsent = value;
    await _prefs.setBool(_consentKey, value);
    
    // If general consent is revoked, revoke all specific consents too
    if (!value) {
      await updatePersonalizedAdsConsent(false);
      await updateAnalyticsConsent(false);
      await updateAIProcessingConsent(false);
    }
    
    notifyListeners();
  }

  /// Update personalized ads consent status
  Future<void> updatePersonalizedAdsConsent(bool value) async {
    if (!_isInitialized) await initialize();
    
    _hasPersonalizedAdsConsent = value;
    await _prefs.setBool(_personalizedAdsKey, value);
    notifyListeners();
  }

  /// Update analytics consent status
  Future<void> updateAnalyticsConsent(bool value) async {
    if (!_isInitialized) await initialize();
    
    _hasAnalyticsConsent = value;
    await _prefs.setBool(_analyticsKey, value);
    notifyListeners();
  }

  /// Update AI processing consent status
  Future<void> updateAIProcessingConsent(bool value) async {
    if (!_isInitialized) await initialize();
    
    _hasAIProcessingConsent = value;
    await _prefs.setBool(_aiProcessingKey, value);
    notifyListeners();
  }

  /// Reset all consent settings (for testing or user request)
  Future<void> resetAllConsent() async {
    if (!_isInitialized) await initialize();
    
    _hasConsent = false;
    _hasPersonalizedAdsConsent = false;
    _hasAnalyticsConsent = false;
    _hasAIProcessingConsent = false;
    _consentVersion = 0;
    _consentTimestamp = null;
    
    await _prefs.remove(_consentKey);
    await _prefs.remove(_personalizedAdsKey);
    await _prefs.remove(_analyticsKey);
    await _prefs.remove(_aiProcessingKey);
    await _prefs.remove(_consentVersionKey);
    await _prefs.remove(_consentShownTimestampKey);
    
    notifyListeners();
    
    debugPrint('Reset all consent settings');
  }

  /// Check if app needs to show consent dialog based on region
  /// 
  /// This is a basic implementation. For production, you would need to:
  /// 1. Use a proper IP geolocation API or device locale to determine user region
  /// 2. Keep an updated list of regions requiring explicit consent (EU, UK, Brazil, California, etc.)
  bool needsToShowConsentDialog() {
    if (!_isInitialized) {
      throw Exception('GDPR Consent Service not initialized');
    }
    
    // If user has already consented to the current version, no need to show again
    if (_hasConsent && _consentVersion >= currentConsentVersion) {
      return false;
    }
    
    // For demonstration purposes, assume all users need consent
    // In production, check if user is in a GDPR/CCPA region based on IP or locale
    return true;
  }

  /// Get a map of all consent statuses for logging or debugging
  Map<String, dynamic> getConsentStatus() {
    return {
      'hasGeneralConsent': _hasConsent,
      'hasPersonalizedAdsConsent': _hasPersonalizedAdsConsent,
      'hasAnalyticsConsent': _hasAnalyticsConsent,
      'hasAIProcessingConsent': _hasAIProcessingConsent,
      'consentVersion': _consentVersion,
      'currentVersion': currentConsentVersion,
      'needsReConsent': needsReConsent,
      'consentTimestamp': _consentTimestamp?.toIso8601String(),
    };
  }
}
