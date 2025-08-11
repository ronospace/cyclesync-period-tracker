/// Analytics and monitoring configuration for CycleSync Enterprise
/// 
/// Provides healthcare-compliant analytics setup with privacy protection,
/// performance monitoring, and comprehensive error tracking.

import 'dart:async';
import 'dart:developer' as developer;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'production_config.dart';

class AnalyticsConfig {
  static FirebaseAnalytics? _analytics;
  static FirebaseCrashlytics? _crashlytics;
  static FirebasePerformance? _performance;
  
  static bool _initialized = false;
  
  /// Initialize analytics services with healthcare compliance
  static Future<void> initializeAnalytics() async {
    if (_initialized) return;
    
    try {
      // Initialize Firebase Analytics with privacy settings
      if (ProductionConfig.enableAnalytics) {
        _analytics = FirebaseAnalytics.instance;
        await _configureAnalytics();
      }
      
      // Initialize Crashlytics for error reporting
      if (ProductionConfig.enableCrashlytics) {
        _crashlytics = FirebaseCrashlytics.instance;
        await _configureCrashlytics();
      }
      
      // Initialize Performance Monitoring
      if (ProductionConfig.enablePerformanceMonitoring) {
        _performance = FirebasePerformance.instance;
        await _configurePerformanceMonitoring();
      }
      
      _initialized = true;
      developer.log('✅ Analytics services initialized successfully');
      
    } catch (e, stackTrace) {
      developer.log(
        '❌ Failed to initialize analytics services: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Configure Firebase Analytics with healthcare compliance
  static Future<void> _configureAnalytics() async {
    if (_analytics == null) return;
    
    // Enable analytics collection with privacy compliance
    await _analytics!.setAnalyticsCollectionEnabled(true);
    
    // Set user properties for healthcare compliance (anonymized)
    await _analytics!.setUserProperty(
      name: 'user_type', 
      value: 'healthcare_user'
    );
    
    await _analytics!.setUserProperty(
      name: 'app_version', 
      value: '2.0.0-enterprise'
    );
    
    await _analytics!.setUserProperty(
      name: 'privacy_mode', 
      value: ProductionConfig.enableHIPAAMode ? 'hipaa_compliant' : 'standard'
    );
    
    // Set anonymized user ID based on timestamp (not personally identifiable)
    final anonymizedUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    await _analytics!.setUserId(id: anonymizedUserId);
    
    // Configure sampling rate for privacy
    await _analytics!.setSessionTimeoutDuration(
      const Duration(minutes: 30)
    );
    
    developer.log('📊 Firebase Analytics configured with healthcare compliance');
  }
  
  /// Configure Crashlytics for production error reporting
  static Future<void> _configureCrashlytics() async {
    if (_crashlytics == null) return;
    
    // Enable crashlytics collection
    await _crashlytics!.setCrashlyticsCollectionEnabled(true);
    
    // Set user identifier (anonymized for healthcare compliance)
    await _crashlytics!.setUserIdentifier(
      'user_${DateTime.now().millisecondsSinceEpoch}'
    );
    
    // Set custom keys for better debugging
    await _crashlytics!.setCustomKey('app_version', '2.0.0-enterprise');
    await _crashlytics!.setCustomKey('environment', 'production');
    await _crashlytics!.setCustomKey('hipaa_mode', ProductionConfig.enableHIPAAMode);
    await _crashlytics!.setCustomKey('encryption_enabled', ProductionConfig.enableEncryption);
    
    // Configure Flutter error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      _crashlytics!.recordFlutterFatalError(details);
    };
    
    // Configure platform error handling
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics!.recordError(error, stack, fatal: true);
      return true;
    };
    
    developer.log('🔥 Firebase Crashlytics configured for production');
  }
  
  /// Configure Performance Monitoring
  static Future<void> _configurePerformanceMonitoring() async {
    if (_performance == null) return;
    
    // Enable performance monitoring
    await _performance!.setPerformanceCollectionEnabled(true);
    
    // Set custom attributes for healthcare app monitoring
    final trace = _performance!.newTrace('app_initialization');
    await trace.start();
    
    trace.setMetric('healthcare_features_count', 25);
    trace.setMetric('encryption_enabled', ProductionConfig.enableEncryption ? 1 : 0);
    trace.setMetric('hipaa_mode', ProductionConfig.enableHIPAAMode ? 1 : 0);
    
    await trace.stop();
    
    developer.log('⚡ Firebase Performance Monitoring configured');
  }
  
  // ===================
  // Analytics Event Logging
  // ===================
  
  /// Log custom analytics events with healthcare compliance
  static Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (_analytics == null || !ProductionConfig.enableAnalytics) return;
    
    try {
      // Sanitize parameters for healthcare compliance
      final sanitizedParams = _sanitizeParameters(parameters);
      
      await _analytics!.logEvent(
        name: name,
        parameters: sanitizedParams,
      );
      
      if (kDebugMode) {
        developer.log('📊 Analytics event: $name ${sanitizedParams ?? ''}');
      }
    } catch (e) {
      developer.log('❌ Failed to log analytics event: $e');
    }
  }
  
  /// Log healthcare-specific events
  static Future<void> logHealthcareEvent({
    required String eventType,
    Map<String, Object>? metadata,
  }) async {
    await logEvent(
      name: 'healthcare_$eventType',
      parameters: {
        'event_type': eventType,
        'timestamp': DateTime.now().toIso8601String(),
        'hipaa_compliant': ProductionConfig.enableHIPAAMode,
        ...?_sanitizeParameters(metadata),
      },
    );
  }
  
  /// Log cycle tracking events
  static Future<void> logCycleEvent({
    required String action,
    String? cyclePhase,
    Map<String, Object>? additionalData,
  }) async {
    await logEvent(
      name: 'cycle_tracking',
      parameters: {
        'action': action,
        'cycle_phase': cyclePhase ?? 'unknown',
        'timestamp': DateTime.now().toIso8601String(),
        ...?_sanitizeParameters(additionalData),
      },
    );
  }
  
  /// Log user engagement events
  static Future<void> logEngagementEvent({
    required String screen,
    required Duration timeSpent,
    Map<String, Object>? additionalData,
  }) async {
    await logEvent(
      name: 'user_engagement',
      parameters: {
        'screen_name': screen,
        'time_spent_seconds': timeSpent.inSeconds,
        'engagement_level': _calculateEngagementLevel(timeSpent),
        ...?_sanitizeParameters(additionalData),
      },
    );
  }
  
  // ===================
  // Error Reporting
  // ===================
  
  /// Report non-fatal errors with context
  static Future<void> reportError({
    required Object error,
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? additionalData,
  }) async {
    if (_crashlytics == null) return;
    
    try {
      // Set context for better debugging
      if (context != null) {
        await _crashlytics!.setCustomKey('error_context', context);
      }
      
      // Add additional data
      if (additionalData != null) {
        for (final entry in additionalData.entries) {
          await _crashlytics!.setCustomKey(entry.key, entry.value.toString());
        }
      }
      
      // Report the error
      await _crashlytics!.recordError(
        error,
        stackTrace,
        fatal: false,
        information: [
          'Context: $context',
          'Healthcare Mode: ${ProductionConfig.enableHIPAAMode}',
          'Encryption: ${ProductionConfig.enableEncryption}',
        ],
      );
      
      if (kDebugMode) {
        developer.log('🔥 Error reported: $error');
      }
    } catch (e) {
      developer.log('❌ Failed to report error: $e');
    }
  }
  
  /// Report healthcare-specific errors
  static Future<void> reportHealthcareError({
    required Object error,
    StackTrace? stackTrace,
    required String healthcareContext,
    Map<String, dynamic>? sensitiveData,
  }) async {
    // Remove sensitive data for healthcare compliance
    final sanitizedData = sensitiveData != null 
        ? _sanitizeSensitiveData(sensitiveData)
        : <String, dynamic>{};
    
    await reportError(
      error: error,
      stackTrace: stackTrace,
      context: 'Healthcare: $healthcareContext',
      additionalData: {
        'healthcare_module': healthcareContext,
        'data_encrypted': ProductionConfig.enableEncryption,
        ...sanitizedData,
      },
    );
  }
  
  // ===================
  // Performance Monitoring
  // ===================
  
  /// Start performance trace for critical operations
  static Trace? startTrace(String traceName) {
    if (_performance == null) return null;
    
    final trace = _performance!.newTrace(traceName);
    trace.start();
    return trace;
  }
  
  /// Create HTTP request trace
  static HttpMetric? createHttpMetric({
    required String url,
    required String httpMethod,
  }) {
    if (_performance == null) return null;
    
    return _performance!.newHttpMetric(url, HttpMethod.values.firstWhere(
      (method) => method.name.toUpperCase() == httpMethod.toUpperCase(),
      orElse: () => HttpMethod.Get,
    ));
  }
  
  // ===================
  // Privacy & Compliance
  // ===================
  
  /// Sanitize parameters to remove sensitive healthcare data
  static Map<String, Object>? _sanitizeParameters(Map<String, Object>? params) {
    if (params == null) return null;
    
    final sanitized = <String, Object>{};
    final sensitiveKeys = [
      'personal_info', 'medical_data', 'health_records',
      'user_id', 'email', 'phone', 'name', 'dob',
      'symptoms', 'medications', 'conditions',
    ];
    
    for (final entry in params.entries) {
      final key = entry.key.toLowerCase();
      final isSensitive = sensitiveKeys.any((sensitive) => key.contains(sensitive));
      
      if (isSensitive) {
        sanitized[entry.key] = '[REDACTED_FOR_PRIVACY]';
      } else {
        sanitized[entry.key] = entry.value;
      }
    }
    
    return sanitized;
  }
  
  /// Remove sensitive data from error reports
  static Map<String, dynamic> _sanitizeSensitiveData(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};
    
    for (final entry in data.entries) {
      final value = entry.value;
      
      if (value is String && (value.contains('@') || value.length > 50)) {
        sanitized[entry.key] = '[SANITIZED]';
      } else if (value is Map || value is List) {
        sanitized[entry.key] = '[COMPLEX_DATA_SANITIZED]';
      } else {
        sanitized[entry.key] = value;
      }
    }
    
    return sanitized;
  }
  
  /// Calculate engagement level based on time spent
  static String _calculateEngagementLevel(Duration timeSpent) {
    if (timeSpent.inSeconds < 10) return 'low';
    if (timeSpent.inSeconds < 60) return 'medium';
    if (timeSpent.inSeconds < 300) return 'high';
    return 'very_high';
  }
  
  // ===================
  // Utility Methods
  // ===================
  
  /// Get analytics instance
  static FirebaseAnalytics? get analytics => _analytics;
  
  /// Get crashlytics instance
  static FirebaseCrashlytics? get crashlytics => _crashlytics;
  
  /// Get performance monitoring instance
  static FirebasePerformance? get performance => _performance;
  
  /// Check if analytics services are initialized
  static bool get isInitialized => _initialized;
  
  /// Disable analytics for testing
  static Future<void> disableForTesting() async {
    await _analytics?.setAnalyticsCollectionEnabled(false);
    await _crashlytics?.setCrashlyticsCollectionEnabled(false);
    await _performance?.setPerformanceCollectionEnabled(false);
    developer.log('🧪 Analytics disabled for testing');
  }
}
