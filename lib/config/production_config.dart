class ProductionConfig {
  // ===================
  // Firebase Configuration
  // ===================

  /// Firebase API Key - loaded from environment variables for security
  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'FIREBASE_API_KEY_NOT_SET',
  );

  /// Firebase App ID - loaded from environment variables
  static const String firebaseAppId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: 'FIREBASE_APP_ID_NOT_SET',
  );

  /// Firebase Project ID - loaded from environment variables
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'FIREBASE_PROJECT_ID_NOT_SET',
  );

  /// Firebase Storage Bucket
  static const String firebaseStorageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: 'FIREBASE_STORAGE_BUCKET_NOT_SET',
  );

  /// Firebase Messaging Sender ID
  static const String firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: 'FIREBASE_MESSAGING_SENDER_ID_NOT_SET',
  );

  // ===================
  // Healthcare Compliance Settings
  // ===================

  /// Enable AES-256 encryption for all sensitive health data
  static const bool enableEncryption = true;

  /// Enable comprehensive audit logging for healthcare compliance
  static const bool enableAuditLogging = true;

  /// Enable HIPAA-compliant mode with additional privacy protections
  static const bool enableHIPAAMode = true;

  /// Enable data anonymization for analytics
  static const bool enableDataAnonymization = true;

  /// Maximum data retention period (in days) for healthcare compliance
  static const int maxDataRetentionDays = 2555; // 7 years for healthcare

  // ===================
  // Performance Settings
  // ===================

  /// Cache maximum age in seconds (7 days)
  static const int cacheMaxAge = 7 * 24 * 60 * 60;

  /// Background sync interval in seconds (5 minutes)
  static const int syncInterval = 5 * 60;

  /// Maximum concurrent sync operations
  static const int maxConcurrentSyncs = 3;

  /// Network timeout in seconds
  static const int networkTimeout = 30;

  /// Maximum retry attempts for failed operations
  static const int maxRetryAttempts = 3;

  /// Batch size for bulk operations
  static const int batchSize = 100;

  // ===================
  // Security Settings
  // ===================

  /// Enable certificate pinning for network security
  static const bool enableCertificatePinning = true;

  /// Enable biometric authentication requirements
  static const bool requireBiometricAuth = true;

  /// Automatic logout timeout in minutes
  static const int autoLogoutTimeout = 15;

  /// Enable screenshot prevention in app switcher
  static const bool preventScreenshots = true;

  /// Enable app integrity verification
  static const bool enableIntegrityCheck = true;

  // ===================
  // Analytics & Monitoring
  // ===================

  /// Enable Firebase Analytics with privacy compliance
  static const bool enableAnalytics = true;

  /// Enable Crashlytics for error reporting
  static const bool enableCrashlytics = true;

  /// Enable performance monitoring
  static const bool enablePerformanceMonitoring = true;

  /// Analytics sampling rate (0.0 to 1.0)
  static const double analyticsSamplingRate = 0.1; // 10% sampling for privacy

  // ===================
  // Feature Flags
  // ===================

  /// Enable HealthKit integration on iOS
  static const bool enableHealthKit = true;

  /// Enable Health Connect integration on Android
  static const bool enableHealthConnect = true;

  /// Enable AI-powered predictions
  static const bool enableAIPredictions = true;

  /// Enable real-time synchronization
  static const bool enableRealTimeSync = true;

  /// Enable advanced analytics dashboard
  static const bool enableAdvancedAnalytics = true;

  /// Enable push notifications
  static const bool enablePushNotifications = true;

  /// Enable dark mode support
  static const bool enableDarkMode = true;

  // ===================
  // API Endpoints
  // ===================

  /// Base API URL for production environment
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.cyclesync.com/v1',
  );

  /// Health data synchronization endpoint
  static const String syncEndpoint = '$apiBaseUrl/sync';

  /// Analytics reporting endpoint
  static const String analyticsEndpoint = '$apiBaseUrl/analytics';

  /// User authentication endpoint
  static const String authEndpoint = '$apiBaseUrl/auth';

  // ===================
  // HealthKit Configuration
  // ===================

  /// HealthKit data types to read
  static const List<String> healthKitReadTypes = [
    'HKQuantityTypeIdentifierBodyTemperature',
    'HKQuantityTypeIdentifierHeartRate',
    'HKQuantityTypeIdentifierRestingHeartRate',
    'HKQuantityTypeIdentifierHeartRateVariabilitySDNN',
    'HKQuantityTypeIdentifierBodyMass',
    'HKQuantityTypeIdentifierHeight',
    'HKQuantityTypeIdentifierStepCount',
    'HKQuantityTypeIdentifierDistanceWalkingRunning',
    'HKQuantityTypeIdentifierActiveEnergyBurned',
    'HKQuantityTypeIdentifierBasalEnergyBurned',
    'HKCategoryTypeIdentifierSleepAnalysis',
    'HKCategoryTypeIdentifierMenstrualFlow',
    'HKCategoryTypeIdentifierOvulationTestResult',
    'HKCategoryTypeIdentifierCervicalMucusQuality',
    'HKCategoryTypeIdentifierIntermenstrualBleeding',
    'HKCategoryTypeIdentifierSexualActivity',
    'HKQuantityTypeIdentifierBasalBodyTemperature',
  ];

  /// HealthKit data types to write
  static const List<String> healthKitWriteTypes = [
    'HKCategoryTypeIdentifierMenstrualFlow',
    'HKCategoryTypeIdentifierOvulationTestResult',
    'HKCategoryTypeIdentifierCervicalMucusQuality',
    'HKCategoryTypeIdentifierIntermenstrualBleeding',
    'HKCategoryTypeIdentifierSexualActivity',
    'HKQuantityTypeIdentifierBasalBodyTemperature',
  ];

  // ===================
  // Validation Methods
  // ===================

  /// Validate that all required configuration values are set
  static bool validateConfiguration() {
    final requiredConfigs = [
      firebaseApiKey,
      firebaseAppId,
      firebaseProjectId,
      firebaseStorageBucket,
      firebaseMessagingSenderId,
    ];

    for (final config in requiredConfigs) {
      if (config.contains('_NOT_SET')) {
        return false;
      }
    }

    return true;
  }

  /// Get configuration summary for debugging (without sensitive data)
  static Map<String, dynamic> getConfigurationSummary() {
    return {
      'firebase_configured': !firebaseApiKey.contains('_NOT_SET'),
      'encryption_enabled': enableEncryption,
      'hipaa_mode': enableHIPAAMode,
      'analytics_enabled': enableAnalytics,
      'healthkit_enabled': enableHealthKit,
      'cache_max_age_hours': cacheMaxAge / 3600,
      'sync_interval_minutes': syncInterval / 60,
      'environment': 'production',
      'version': '2.0.0-enterprise',
    };
  }

  // ===================
  // Runtime Configuration
  // ===================

  /// Get configuration value based on build mode
  static T getConfigValue<T>(T productionValue, T debugValue) {
    return const bool.fromEnvironment('dart.vm.product')
        ? productionValue
        : debugValue;
  }

  /// Check if app is running in production mode
  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');

  /// Check if app is running in debug mode
  static bool get isDebug => !isProduction;

  /// Get appropriate log level for current environment
  static String get logLevel => isProduction ? 'ERROR' : 'DEBUG';
}
