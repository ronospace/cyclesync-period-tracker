import 'dart:io';
import 'package:flutter/foundation.dart';

/// Cross-platform configuration for CycleSync
/// Handles platform-specific features and capabilities
class PlatformConfig {
  static bool get isIOS => Platform.isIOS;
  static bool get isAndroid => Platform.isAndroid;
  static bool get isWeb => kIsWeb;
  static bool get isDesktop =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  static bool get isMobile => Platform.isIOS || Platform.isAndroid;

  /// Health Integration Capabilities
  static bool get supportsHealthKit => Platform.isIOS;
  static bool get supportsGoogleFit => Platform.isAndroid;
  static bool get supportsHealthIntegration =>
      supportsHealthKit || supportsGoogleFit;

  /// Native Features
  static bool get supportsNativeNotifications => isMobile;
  static bool get supportsBackgroundSync => isMobile;
  static bool get supportsWearableSync => isMobile;
  static bool get supportsNativeBiometrics => isMobile;

  /// Platform-specific Health Data Types
  static List<String> get supportedHealthDataTypes {
    if (Platform.isIOS) {
      return [
        'heart_rate',
        'steps',
        'sleep_analysis',
        'body_temperature',
        'menstrual_flow',
        'ovulation_test',
        'basal_body_temperature',
        'cervical_mucus_quality',
        'sexual_activity',
        'intermenstrual_bleeding',
        'mood',
        'symptoms',
        'weight',
        'height',
        'body_mass_index',
        'active_energy',
        'resting_energy',
        'workout_data',
      ];
    } else if (Platform.isAndroid) {
      return [
        'heart_rate',
        'steps',
        'sleep_session',
        'body_temperature',
        'weight',
        'height',
        'active_calories',
        'nutrition',
        'hydration',
        'workout_session',
      ];
    }
    return [];
  }

  /// Platform-specific Database Paths
  static String get databasePath {
    if (Platform.isIOS) {
      return 'Documents/cyclesync.db';
    } else if (Platform.isAndroid) {
      return 'databases/cyclesync.db';
    }
    return 'cyclesync.db';
  }

  /// Platform-specific Notification Categories
  static Map<String, dynamic> get notificationCategories {
    if (Platform.isIOS) {
      return {
        'cycle_reminder': {
          'identifier': 'CYCLE_REMINDER',
          'actions': ['LOG_CYCLE', 'POSTPONE'],
        },
        'health_tip': {
          'identifier': 'HEALTH_TIP',
          'actions': ['READ_MORE', 'DISMISS'],
        },
      };
    } else if (Platform.isAndroid) {
      return {
        'cycle_reminder': {
          'channelId': 'cycle_reminders',
          'importance': 'high',
          'actions': ['LOG_CYCLE', 'POSTPONE'],
        },
        'health_tip': {
          'channelId': 'health_tips',
          'importance': 'default',
          'actions': ['READ_MORE', 'DISMISS'],
        },
      };
    }
    return {};
  }

  /// Platform-specific Export Formats
  static List<String> get supportedExportFormats {
    if (Platform.isIOS) {
      return ['pdf', 'csv', 'json', 'healthkit'];
    } else if (Platform.isAndroid) {
      return ['pdf', 'csv', 'json', 'googlefit'];
    }
    return ['pdf', 'csv', 'json'];
  }

  /// Platform-specific Share Options
  static List<String> get shareOptions {
    final baseOptions = ['email', 'copy_link', 'export_file'];

    if (Platform.isIOS) {
      return [...baseOptions, 'airdrop', 'messages', 'notes'];
    } else if (Platform.isAndroid) {
      return [...baseOptions, 'bluetooth', 'nearby_share', 'messaging_apps'];
    }
    return baseOptions;
  }

  /// Platform-specific Biometric Options
  static Map<String, bool> get biometricCapabilities {
    if (Platform.isIOS) {
      return {'face_id': true, 'touch_id': true, 'passcode': true};
    } else if (Platform.isAndroid) {
      return {
        'fingerprint': true,
        'face_unlock': true,
        'pattern': true,
        'pin': true,
      };
    }
    return {};
  }

  /// Platform-specific Theme Preferences
  static Map<String, dynamic> get themeCapabilities {
    return {
      'supports_dark_mode': true,
      'supports_system_theme': true,
      'supports_dynamic_colors': Platform.isAndroid, // Material You
      'supports_accent_colors': Platform.isIOS,
      'adaptive_icons': Platform.isAndroid,
      'sf_symbols': Platform.isIOS,
    };
  }

  /// Platform-specific Storage Options
  static Map<String, String> get storageOptions {
    if (Platform.isIOS) {
      return {
        'documents': 'NSDocumentDirectory',
        'cache': 'NSCachesDirectory',
        'keychain': 'iOS Keychain',
        'cloud': 'iCloud',
      };
    } else if (Platform.isAndroid) {
      return {
        'internal': 'Internal Storage',
        'external': 'External Storage',
        'cache': 'Cache Directory',
        'keystore': 'Android Keystore',
        'cloud': 'Google Drive',
      };
    }
    return {'local': 'Local Storage', 'cache': 'Cache Storage'};
  }

  /// Platform-specific Localization
  static Map<String, dynamic> get localizationCapabilities {
    return {
      'supports_rtl': true,
      'supports_plurals': true,
      'date_formats': _getDateFormats(),
      'number_formats': _getNumberFormats(),
      'currency_formats': _getCurrencyFormats(),
    };
  }

  static Map<String, String> _getDateFormats() {
    if (Platform.isIOS) {
      return {
        'short': 'M/d/yy',
        'medium': 'MMM d, y',
        'long': 'MMMM d, y',
        'full': 'EEEE, MMMM d, y',
      };
    } else if (Platform.isAndroid) {
      return {
        'short': 'd/M/yy',
        'medium': 'd MMM y',
        'long': 'd MMMM y',
        'full': 'EEEE, d MMMM y',
      };
    }
    return {
      'short': 'M/d/yy',
      'medium': 'MMM d, y',
      'long': 'MMMM d, y',
      'full': 'EEEE, MMMM d, y',
    };
  }

  static Map<String, String> _getNumberFormats() {
    return {
      'decimal': '#,##0.##',
      'percent': '#,##0%',
      'currency': '¤#,##0.00',
    };
  }

  static Map<String, String> _getCurrencyFormats() {
    if (Platform.isIOS) {
      return {
        'symbol_position': 'before',
        'decimal_separator': '.',
        'thousands_separator': ',',
      };
    } else if (Platform.isAndroid) {
      return {
        'symbol_position': 'before',
        'decimal_separator': '.',
        'thousands_separator': ',',
      };
    }
    return {
      'symbol_position': 'before',
      'decimal_separator': '.',
      'thousands_separator': ',',
    };
  }

  /// Platform-specific Performance Options
  static Map<String, dynamic> get performanceOptions {
    return {
      'background_app_refresh': Platform.isIOS,
      'doze_optimization': Platform.isAndroid,
      'battery_optimization': isMobile,
      'memory_management': {
        'ios': Platform.isIOS,
        'android_low_ram': Platform.isAndroid,
      },
    };
  }

  /// Platform-specific Security Features
  static Map<String, bool> get securityFeatures {
    return {
      'app_transport_security': Platform.isIOS,
      'network_security_config': Platform.isAndroid,
      'certificate_pinning': isMobile,
      'root_detection': Platform.isAndroid,
      'jailbreak_detection': Platform.isIOS,
      'secure_storage': isMobile,
    };
  }

  /// Platform-specific Wearable Integration
  static Map<String, dynamic> get wearableIntegration {
    if (Platform.isIOS) {
      return {
        'apple_watch': {
          'supported': true,
          'complications': true,
          'haptic_feedback': true,
          'digital_crown': true,
        },
      };
    } else if (Platform.isAndroid) {
      return {
        'wear_os': {
          'supported': true,
          'complications': true,
          'ambient_mode': true,
          'fitness_tracking': true,
        },
        'fitbit': {'supported': true, 'web_api': true},
        'garmin': {'supported': true, 'connect_iq': true},
      };
    }
    return {};
  }

  /// Get platform-specific feature availability
  static bool isFeatureSupported(String feature) {
    switch (feature) {
      case 'health_kit':
        return supportsHealthKit;
      case 'google_fit':
        return supportsGoogleFit;
      case 'native_notifications':
        return supportsNativeNotifications;
      case 'background_sync':
        return supportsBackgroundSync;
      case 'wearable_sync':
        return supportsWearableSync;
      case 'biometric_auth':
        return supportsNativeBiometrics;
      case 'dark_mode':
        return true; // Supported on all platforms
      case 'multi_language':
        return true; // Supported on all platforms
      case 'data_export':
        return true; // Supported on all platforms
      default:
        return false;
    }
  }

  /// Get platform-specific configuration
  static Map<String, dynamic> getPlatformConfiguration() {
    return {
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
      'is_mobile': isMobile,
      'is_desktop': isDesktop,
      'health_integration': supportsHealthIntegration,
      'supported_features': _getSupportedFeatures(),
      'capabilities': _getCapabilities(),
    };
  }

  static List<String> _getSupportedFeatures() {
    final features = <String>[];

    if (supportsHealthIntegration) features.add('health_integration');
    if (supportsNativeNotifications) features.add('notifications');
    if (supportsBackgroundSync) features.add('background_sync');
    if (supportsWearableSync) features.add('wearable_integration');
    if (supportsNativeBiometrics) features.add('biometric_security');

    // Always supported features
    features.addAll([
      'dark_mode',
      'multi_language',
      'data_export',
      'ai_insights',
      'cycle_tracking',
      'analytics',
    ]);

    return features;
  }

  static Map<String, dynamic> _getCapabilities() {
    return {
      'health': supportedHealthDataTypes,
      'notifications': notificationCategories,
      'export': supportedExportFormats,
      'share': shareOptions,
      'biometrics': biometricCapabilities,
      'theme': themeCapabilities,
      'storage': storageOptions,
      'localization': localizationCapabilities,
      'performance': performanceOptions,
      'security': securityFeatures,
      'wearable': wearableIntegration,
    };
  }
}
