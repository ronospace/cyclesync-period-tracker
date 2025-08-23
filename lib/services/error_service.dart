import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Comprehensive error handling and crash reporting service
class ErrorService {
  static const String _errorLogKey = 'error_log';
  static const int _maxErrorLogs = 50;
  static SharedPreferences? _prefs;
  static final List<ErrorReport> _errorQueue = [];

  /// Initialize error service
  static Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();

      // Set global error handlers
      FlutterError.onError = _handleFlutterError;
      PlatformDispatcher.instance.onError = _handlePlatformError;

      // Load existing error logs
      await _loadErrorLogs();

      debugPrint('✅ ErrorService: Initialized successfully');
    } catch (e) {
      debugPrint('❌ ErrorService: Initialization failed: $e');
    }
  }

  /// Handle Flutter framework errors
  static void _handleFlutterError(FlutterErrorDetails details) {
    final error = ErrorReport(
      type: ErrorType.flutter,
      error: details.exception.toString(),
      stackTrace: details.stack.toString(),
      timestamp: DateTime.now(),
      context: details.context?.toString(),
      fatal: details.silent == false,
    );

    _logError(error);

    // In debug mode, show the red screen
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  }

  /// Handle platform-specific errors
  static bool _handlePlatformError(Object error, StackTrace stackTrace) {
    final errorReport = ErrorReport(
      type: ErrorType.platform,
      error: error.toString(),
      stackTrace: stackTrace.toString(),
      timestamp: DateTime.now(),
      fatal: true,
    );

    _logError(errorReport);
    return true; // Indicates error was handled
  }

  /// Log custom application errors
  static void logError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
    ErrorSeverity severity = ErrorSeverity.error,
    Map<String, dynamic>? metadata,
  }) {
    final errorReport = ErrorReport(
      type: ErrorType.application,
      error: error.toString(),
      stackTrace: stackTrace?.toString(),
      timestamp: DateTime.now(),
      context: context,
      severity: severity,
      metadata: metadata,
      fatal: severity == ErrorSeverity.fatal,
    );

    _logError(errorReport);
  }

  /// Log warning messages
  static void logWarning(
    String message, {
    String? context,
    Map<String, dynamic>? metadata,
  }) {
    logError(
      message,
      context: context,
      severity: ErrorSeverity.warning,
      metadata: metadata,
    );
  }

  /// Log info messages for debugging
  static void logInfo(
    String message, {
    String? context,
    Map<String, dynamic>? metadata,
  }) {
    if (kDebugMode) {
      final errorReport = ErrorReport(
        type: ErrorType.info,
        error: message,
        timestamp: DateTime.now(),
        context: context,
        severity: ErrorSeverity.info,
        metadata: metadata,
        fatal: false,
      );

      debugPrint('ℹ️ $message ${context != null ? '($context)' : ''}');
      _errorQueue.add(errorReport);
    }
  }

  /// Internal error logging
  static void _logError(ErrorReport error) {
    _errorQueue.add(error);
    _persistErrorLog(error);

    // Print to console in debug mode
    if (kDebugMode) {
      final emoji = _getErrorEmoji(error.severity);
      debugPrint('$emoji ${error.type.name.toUpperCase()}: ${error.error}');
      if (error.context != null) {
        debugPrint('   Context: ${error.context}');
      }
      if (error.stackTrace != null && error.severity != ErrorSeverity.info) {
        debugPrint('   Stack: ${error.stackTrace}');
      }
    }

    // Handle critical errors
    if (error.fatal) {
      _handleFatalError(error);
    }
  }

  static String _getErrorEmoji(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.fatal:
        return '💥';
      case ErrorSeverity.error:
        return '❌';
      case ErrorSeverity.warning:
        return '⚠️';
      case ErrorSeverity.info:
        return 'ℹ️';
    }
  }

  /// Handle fatal errors
  static void _handleFatalError(ErrorReport error) {
    debugPrint('💥 FATAL ERROR: ${error.error}');

    // In a real app, you might:
    // 1. Send crash report to analytics service
    // 2. Show user-friendly error dialog
    // 3. Attempt graceful app recovery

    // For now, just ensure it's logged
    _persistErrorLog(error);
  }

  /// Persist error log to storage
  static Future<void> _persistErrorLog(ErrorReport error) async {
    try {
      final existingLogs = await _loadErrorLogs();
      existingLogs.add(error);

      // Keep only the most recent errors
      if (existingLogs.length > _maxErrorLogs) {
        existingLogs.removeRange(0, existingLogs.length - _maxErrorLogs);
      }

      final jsonLogs = existingLogs.map((e) => e.toJson()).toList();
      await _prefs?.setString(_errorLogKey, jsonEncode(jsonLogs));
    } catch (e) {
      debugPrint('Failed to persist error log: $e');
    }
  }

  /// Load error logs from storage
  static Future<List<ErrorReport>> _loadErrorLogs() async {
    try {
      final logsJson = _prefs?.getString(_errorLogKey);
      if (logsJson == null) return [];

      final logsList = jsonDecode(logsJson) as List;
      return logsList.map((json) => ErrorReport.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Failed to load error logs: $e');
      return [];
    }
  }

  /// Get recent error reports
  static Future<List<ErrorReport>> getRecentErrors({int limit = 20}) async {
    final logs = await _loadErrorLogs();
    return logs.reversed.take(limit).toList();
  }

  /// Get error statistics
  static Future<ErrorStatistics> getErrorStatistics() async {
    final logs = await _loadErrorLogs();
    final now = DateTime.now();
    final last24Hours = logs
        .where((e) => now.difference(e.timestamp) < const Duration(hours: 24))
        .toList();

    return ErrorStatistics(
      totalErrors: logs.length,
      errorsLast24Hours: last24Hours.length,
      fatalErrors: logs.where((e) => e.fatal).length,
      mostCommonError: _getMostCommonError(logs),
      errorsByType: _getErrorsByType(logs),
      errorsBySeverity: _getErrorsBySeverity(logs),
    );
  }

  static String? _getMostCommonError(List<ErrorReport> logs) {
    if (logs.isEmpty) return null;

    final errorCounts = <String, int>{};
    for (final log in logs) {
      final error = log.error.length > 100
          ? '${log.error.substring(0, 100)}...'
          : log.error;
      errorCounts[error] = (errorCounts[error] ?? 0) + 1;
    }

    return errorCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  static Map<ErrorType, int> _getErrorsByType(List<ErrorReport> logs) {
    final counts = <ErrorType, int>{};
    for (final log in logs) {
      counts[log.type] = (counts[log.type] ?? 0) + 1;
    }
    return counts;
  }

  static Map<ErrorSeverity, int> _getErrorsBySeverity(List<ErrorReport> logs) {
    final counts = <ErrorSeverity, int>{};
    for (final log in logs) {
      counts[log.severity] = (counts[log.severity] ?? 0) + 1;
    }
    return counts;
  }

  /// Clear all error logs
  static Future<void> clearErrorLogs() async {
    try {
      await _prefs?.remove(_errorLogKey);
      _errorQueue.clear();
      debugPrint('✅ ErrorService: Error logs cleared');
    } catch (e) {
      debugPrint('❌ ErrorService: Failed to clear error logs: $e');
    }
  }

  /// Export error logs for support
  static Future<String> exportErrorLogs() async {
    try {
      final logs = await _loadErrorLogs();
      final export = {
        'exported_at': DateTime.now().toIso8601String(),
        'app_version': '1.0.0', // You'd get this from package info
        'total_errors': logs.length,
        'errors': logs.map((e) => e.toJson()).toList(),
      };

      return jsonEncode(export);
    } catch (e) {
      debugPrint('❌ ErrorService: Failed to export error logs: $e');
      return '{"error": "Failed to export logs"}';
    }
  }

  /// Show user-friendly error dialog
  static void showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    VoidCallback? onRetry,
    VoidCallback? onReport,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Retry'),
            ),
          if (onReport != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onReport();
              },
              child: const Text('Report'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Error report data class
class ErrorReport {
  final ErrorType type;
  final String error;
  final String? stackTrace;
  final DateTime timestamp;
  final String? context;
  final ErrorSeverity severity;
  final Map<String, dynamic>? metadata;
  final bool fatal;

  ErrorReport({
    required this.type,
    required this.error,
    this.stackTrace,
    required this.timestamp,
    this.context,
    this.severity = ErrorSeverity.error,
    this.metadata,
    this.fatal = false,
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'error': error,
    'stackTrace': stackTrace,
    'timestamp': timestamp.toIso8601String(),
    'context': context,
    'severity': severity.name,
    'metadata': metadata,
    'fatal': fatal,
  };

  factory ErrorReport.fromJson(Map<String, dynamic> json) => ErrorReport(
    type: ErrorType.values.firstWhere((e) => e.name == json['type']),
    error: json['error'],
    stackTrace: json['stackTrace'],
    timestamp: DateTime.parse(json['timestamp']),
    context: json['context'],
    severity: ErrorSeverity.values.firstWhere(
      (e) => e.name == json['severity'],
    ),
    metadata: json['metadata'],
    fatal: json['fatal'] ?? false,
  );
}

/// Error statistics data class
class ErrorStatistics {
  final int totalErrors;
  final int errorsLast24Hours;
  final int fatalErrors;
  final String? mostCommonError;
  final Map<ErrorType, int> errorsByType;
  final Map<ErrorSeverity, int> errorsBySeverity;

  ErrorStatistics({
    required this.totalErrors,
    required this.errorsLast24Hours,
    required this.fatalErrors,
    this.mostCommonError,
    required this.errorsByType,
    required this.errorsBySeverity,
  });
}

/// Error types
enum ErrorType {
  flutter,
  platform,
  application,
  network,
  firebase,
  health,
  info,
}

/// Error severity levels
enum ErrorSeverity { fatal, error, warning, info }
