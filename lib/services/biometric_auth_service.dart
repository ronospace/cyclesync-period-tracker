import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'error_service.dart';

/// Service for handling biometric authentication (Face ID, Touch ID, Fingerprint)
class BiometricAuthService {
  static BiometricAuthService? _instance;
  static BiometricAuthService get instance => _instance ??= BiometricAuthService._();
  
  BiometricAuthService._();

  final LocalAuthentication _localAuth = LocalAuthentication();
  
  // SharedPreferences keys
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricFailedAttemptsKey = 'biometric_failed_attempts';
  static const String _lastFailedAttemptKey = 'last_failed_attempt';
  static const String _biometricSetupCompletedKey = 'biometric_setup_completed';

  /// Check if biometric authentication is available on device
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      ErrorService.logError(e, context: 'Check biometric availability');
      return false;
    }
  }

  /// Get available biometric types on device
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      ErrorService.logError(e, context: 'Get available biometrics');
      return [];
    }
  }

  /// Get user-friendly names for available biometrics
  Future<List<String>> getAvailableBiometricNames() async {
    try {
      final biometrics = await getAvailableBiometrics();
      return biometrics.map((biometric) {
        switch (biometric) {
          case BiometricType.face:
            if (Platform.isIOS) return 'Face ID';
            return 'Face Recognition';
          case BiometricType.fingerprint:
            if (Platform.isIOS) return 'Touch ID';
            return 'Fingerprint';
          case BiometricType.iris:
            return 'Iris Scan';
          case BiometricType.strong:
            return 'Strong Biometric';
          case BiometricType.weak:
            return 'Weak Biometric';
        }
      }).toList();
    } catch (e) {
      ErrorService.logError(e, context: 'Get biometric names');
      return [];
    }
  }

  /// Check if biometric authentication is currently enabled by user
  Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_biometricEnabledKey) ?? false;
    } catch (e) {
      ErrorService.logError(e, context: 'Check biometric enabled');
      return false;
    }
  }

  /// Enable biometric authentication
  Future<bool> enableBiometricAuth() async {
    try {
      // First check if biometrics are available
      if (!await isBiometricAvailable()) {
        throw Exception('Biometric authentication not available on this device');
      }

      // Test biometric authentication before enabling
      final isAuthenticated = await authenticateWithBiometric(
        reason: 'Please verify your identity to enable biometric authentication',
      );

      if (isAuthenticated) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_biometricEnabledKey, true);
        await prefs.setBool(_biometricSetupCompletedKey, true);
        
        // Reset failed attempts on successful setup
        await _resetFailedAttempts();
        
        debugPrint('Biometric authentication enabled');
        return true;
      } else {
        debugPrint('Biometric authentication test failed');
        return false;
      }
    } catch (e) {
      ErrorService.logError(e, context: 'Enable biometric auth');
      return false;
    }
  }

  /// Disable biometric authentication
  Future<bool> disableBiometricAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricEnabledKey, false);
      await _resetFailedAttempts();
      
      debugPrint('Biometric authentication disabled');
      return true;
    } catch (e) {
      ErrorService.logError(e, context: 'Disable biometric auth');
      return false;
    }
  }

  /// Authenticate using biometric
  Future<bool> authenticateWithBiometric({
    String? reason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      // Check if biometric is available and enabled
      if (!await isBiometricAvailable()) {
        throw Exception('Biometric authentication not available');
      }

      if (!await isBiometricEnabled()) {
        throw Exception('Biometric authentication not enabled');
      }

      // Check failed attempts rate limiting
      if (await _isRateLimited()) {
        throw Exception('Too many failed attempts. Please try again later.');
      }

      final defaultReason = Platform.isIOS 
          ? 'Please verify your identity to access CycleSync'
          : 'Verify your identity to continue';

      final isAuthenticated = await _localAuth.authenticate(
        localizedFallbackTitle: 'Use Passcode',
        authMessages: _getAuthMessages(),
        options: AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
        ),
      );

      if (isAuthenticated) {
        await _resetFailedAttempts();
        debugPrint('Biometric authentication successful');
        return true;
      } else {
        await _recordFailedAttempt();
        debugPrint('Biometric authentication failed');
        return false;
      }
    } on PlatformException catch (e) {
      await _recordFailedAttempt();
      ErrorService.logError(e, context: 'Biometric authentication');
      
      // Handle specific error codes
      switch (e.code) {
        case 'NotAvailable':
          throw Exception('Biometric authentication not available');
        case 'NotEnrolled':
          throw Exception('No biometric credentials enrolled');
        case 'LockedOut':
          throw Exception('Biometric authentication locked due to too many attempts');
        case 'PermanentlyLockedOut':
          throw Exception('Biometric authentication permanently locked');
        case 'UserCancel':
          return false; // User cancelled, not an error
        case 'UserFallback':
          throw Exception('User requested fallback authentication');
        default:
          throw Exception('Biometric authentication error: ${e.message}');
      }
    } catch (e) {
      await _recordFailedAttempt();
      ErrorService.logError(e, context: 'Biometric authentication');
      return false;
    }
  }

  /// Authenticate with fallback to device credentials (passcode/PIN/pattern)
  Future<bool> authenticateWithFallback({
    String? reason,
  }) async {
    try {
      final defaultReason = Platform.isIOS 
          ? 'Please verify your identity to access CycleSync'
          : 'Verify your identity to continue';

      final isAuthenticated = await _localAuth.authenticate(
        localizedFallbackTitle: 'Use Passcode',
        authMessages: _getAuthMessages(),
        options: const AuthenticationOptions(
          biometricOnly: false,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        await _resetFailedAttempts();
        debugPrint('Fallback authentication successful');
        return true;
      } else {
        await _recordFailedAttempt();
        debugPrint('Fallback authentication failed');
        return false;
      }
    } on PlatformException catch (e) {
      ErrorService.logError(e, context: 'Fallback authentication');
      
      switch (e.code) {
        case 'UserCancel':
          return false;
        default:
          throw Exception('Authentication error: ${e.message}');
      }
    } catch (e) {
      ErrorService.logError(e, context: 'Fallback authentication');
      return false;
    }
  }

  /// Check if app should prompt for biometric setup
  Future<bool> shouldPromptBiometricSetup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final setupCompleted = prefs.getBool(_biometricSetupCompletedKey) ?? false;
      
      // Only prompt if setup not completed and biometrics are available
      return !setupCompleted && await isBiometricAvailable();
    } catch (e) {
      return false;
    }
  }

  /// Mark biometric setup as completed (user chose not to enable)
  Future<void> markBiometricSetupCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricSetupCompletedKey, true);
    } catch (e) {
      ErrorService.logError(e, context: 'Mark biometric setup completed');
    }
  }

  /// Get biometric authentication status
  Future<BiometricAuthStatus> getBiometricAuthStatus() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return BiometricAuthStatus.notAvailable;
      }

      final biometrics = await getAvailableBiometrics();
      if (biometrics.isEmpty) {
        return BiometricAuthStatus.notEnrolled;
      }

      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) {
        return BiometricAuthStatus.disabled;
      }

      if (await _isRateLimited()) {
        return BiometricAuthStatus.rateLimited;
      }

      return BiometricAuthStatus.ready;
    } catch (e) {
      ErrorService.logError(e, context: 'Get biometric auth status');
      return BiometricAuthStatus.error;
    }
  }

  /// Get user-friendly status message
  Future<String> getBiometricStatusMessage() async {
    final status = await getBiometricAuthStatus();
    final biometricNames = await getAvailableBiometricNames();
    final biometricName = biometricNames.isNotEmpty ? biometricNames.first : 'biometric';

    switch (status) {
      case BiometricAuthStatus.notAvailable:
        return 'Biometric authentication is not available on this device';
      case BiometricAuthStatus.notEnrolled:
        return 'No $biometricName enrolled. Please set up $biometricName in device settings';
      case BiometricAuthStatus.disabled:
        return '$biometricName authentication is disabled for CycleSync';
      case BiometricAuthStatus.rateLimited:
        return 'Too many failed attempts. Please try again later';
      case BiometricAuthStatus.ready:
        return '$biometricName authentication is ready';
      case BiometricAuthStatus.error:
        return 'Error checking biometric authentication status';
    }
  }

  /// Private helper methods

  Future<void> _recordFailedAttempt() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentAttempts = prefs.getInt(_biometricFailedAttemptsKey) ?? 0;
      await prefs.setInt(_biometricFailedAttemptsKey, currentAttempts + 1);
      await prefs.setInt(_lastFailedAttemptKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      ErrorService.logError(e, context: 'Record failed attempt');
    }
  }

  Future<void> _resetFailedAttempts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_biometricFailedAttemptsKey);
      await prefs.remove(_lastFailedAttemptKey);
    } catch (e) {
      ErrorService.logError(e, context: 'Reset failed attempts');
    }
  }

  Future<bool> _isRateLimited() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final failedAttempts = prefs.getInt(_biometricFailedAttemptsKey) ?? 0;
      final lastFailedAttempt = prefs.getInt(_lastFailedAttemptKey) ?? 0;
      
      // Rate limit after 5 failed attempts
      if (failedAttempts >= 5) {
        final lastAttemptTime = DateTime.fromMillisecondsSinceEpoch(lastFailedAttempt);
        final now = DateTime.now();
        final timeSinceLastAttempt = now.difference(lastAttemptTime);
        
        // Allow retry after 5 minutes
        if (timeSinceLastAttempt.inMinutes < 5) {
          return true;
        } else {
          // Reset after cooldown period
          await _resetFailedAttempts();
          return false;
        }
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  List<AuthMessages> _getAuthMessages() {
    return [
      const IOSAuthMessages(
        cancelButton: 'Cancel',
        goToSettingsButton: 'Settings',
        goToSettingsDescription: 'Please set up biometric authentication in Settings',
        lockOut: 'Biometric authentication is disabled. Please use your passcode.',
      ),
      const AndroidAuthMessages(
        cancelButton: 'Cancel',
        goToSettingsButton: 'Settings',
        goToSettingsDescription: 'Please set up biometric authentication in Settings',
        biometricHint: 'Verify your identity',
        biometricNotRecognized: 'Biometric not recognized. Try again.',
        biometricSuccess: 'Biometric authentication successful',
        deviceCredentialsRequiredTitle: 'Device credentials required',
        deviceCredentialsSetupDescription: 'Please set up device credentials in Settings',
        signInTitle: 'Biometric Authentication',
      ),
    ];
  }

  /// Get remaining time for rate limit
  Future<Duration?> getRateLimitRemainingTime() async {
    try {
      if (!await _isRateLimited()) return null;
      
      final prefs = await SharedPreferences.getInstance();
      final lastFailedAttempt = prefs.getInt(_lastFailedAttemptKey) ?? 0;
      final lastAttemptTime = DateTime.fromMillisecondsSinceEpoch(lastFailedAttempt);
      final now = DateTime.now();
      final elapsed = now.difference(lastAttemptTime);
      
      const cooldownDuration = Duration(minutes: 5);
      return cooldownDuration - elapsed;
    } catch (e) {
      return null;
    }
  }

  /// Clear all biometric data (for logout/reset)
  Future<void> clearBiometricData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_biometricEnabledKey);
      await prefs.remove(_biometricFailedAttemptsKey);
      await prefs.remove(_lastFailedAttemptKey);
      await prefs.remove(_biometricSetupCompletedKey);
      
      debugPrint('Biometric data cleared');
    } catch (e) {
      ErrorService.logError(e, context: 'Clear biometric data');
    }
  }

  /// Check if device has strong biometric security
  Future<bool> hasStrongBiometricSecurity() async {
    try {
      final biometrics = await getAvailableBiometrics();
      return biometrics.contains(BiometricType.strong) ||
             biometrics.contains(BiometricType.face) ||
             biometrics.contains(BiometricType.fingerprint);
    } catch (e) {
      return false;
    }
  }
}

/// Biometric authentication status
enum BiometricAuthStatus {
  notAvailable,
  notEnrolled,
  disabled,
  rateLimited,
  ready,
  error,
}

/// Extension for user-friendly status messages
extension BiometricAuthStatusExtension on BiometricAuthStatus {
  String get displayName {
    switch (this) {
      case BiometricAuthStatus.notAvailable:
        return 'Not Available';
      case BiometricAuthStatus.notEnrolled:
        return 'Not Set Up';
      case BiometricAuthStatus.disabled:
        return 'Disabled';
      case BiometricAuthStatus.rateLimited:
        return 'Rate Limited';
      case BiometricAuthStatus.ready:
        return 'Ready';
      case BiometricAuthStatus.error:
        return 'Error';
    }
  }

  bool get isUsable => this == BiometricAuthStatus.ready;
  
  bool get needsSetup => 
      this == BiometricAuthStatus.notEnrolled || 
      this == BiometricAuthStatus.disabled;
}
