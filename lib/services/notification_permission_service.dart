import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'error_service.dart';

/// Service for managing notification permissions across platforms
class NotificationPermissionService {
  static NotificationPermissionService? _instance;
  static NotificationPermissionService get instance => 
      _instance ??= NotificationPermissionService._();
  
  NotificationPermissionService._();

  /// Check if notification permissions are granted
  Future<bool> hasNotificationPermission() async {
    try {
      if (Platform.isIOS) {
        return await _checkIOSNotificationPermission();
      } else if (Platform.isAndroid) {
        return await _checkAndroidNotificationPermission();
      }
      return false;
    } catch (e) {
      ErrorService.logError(
        e,
        context: 'Check notification permission',
        severity: ErrorSeverity.error,
      );
      return false;
    }
  }

  /// Request notification permissions with proper flow
  Future<NotificationPermissionResult> requestNotificationPermission({
    bool showRationale = true,
  }) async {
    try {
      if (Platform.isIOS) {
        return await _requestIOSNotificationPermission();
      } else if (Platform.isAndroid) {
        return await _requestAndroidNotificationPermission(
          showRationale: showRationale,
        );
      }
      return NotificationPermissionResult.unsupported;
    } catch (e) {
      ErrorService.logError(
        e,
        context: 'Request notification permission',
        severity: ErrorSeverity.error,
      );
      return NotificationPermissionResult.error;
    }
  }

  /// Show permission rationale dialog
  Future<bool> showPermissionRationale(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.notifications_active,
          size: 48,
          color: Colors.pink,
        ),
        title: const Text('Stay Informed'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'CycleSync needs notification permission to:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            _RationaleItem(
              icon: Icons.event,
              text: 'Remind you when your period is about to start',
            ),
            _RationaleItem(
              icon: Icons.favorite,
              text: 'Alert you during your fertility window',
            ),
            _RationaleItem(
              icon: Icons.medication,
              text: 'Send medication and appointment reminders',
            ),
            _RationaleItem(
              icon: Icons.insights,
              text: 'Provide personalized cycle insights',
            ),
            SizedBox(height: 16),
            Text(
              'You can manage these permissions in Settings anytime.',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
            ),
            child: const Text('Allow Notifications'),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Open app notification settings
  Future<bool> openNotificationSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      ErrorService.logError(
        e,
        context: 'Open notification settings',
        severity: ErrorSeverity.error,
      );
      return false;
    }
  }

  /// Show settings redirect dialog
  Future<bool> showSettingsDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.settings,
          size: 48,
          color: Colors.orange,
        ),
        title: const Text('Enable Notifications'),
        content: const Text(
          'To receive cycle reminders and alerts, please enable notifications '
          'for CycleSync in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context, true);
              await openNotificationSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Get detailed permission status
  Future<NotificationPermissionStatus> getDetailedPermissionStatus() async {
    try {
      final hasPermission = await hasNotificationPermission();
      
      if (hasPermission) {
        return NotificationPermissionStatus.granted;
      }

      // Check if permission was permanently denied
      if (Platform.isAndroid) {
        final status = await Permission.notification.status;
        if (status.isPermanentlyDenied) {
          return NotificationPermissionStatus.permanentlyDenied;
        }
        return NotificationPermissionStatus.denied;
      } else if (Platform.isIOS) {
        // iOS doesn't have permanently denied concept for notifications
        return NotificationPermissionStatus.denied;
      }

      return NotificationPermissionStatus.unknown;
    } catch (e) {
      ErrorService.logError(
        e,
        context: 'Get detailed permission status',
        severity: ErrorSeverity.error,
      );
      return NotificationPermissionStatus.unknown;
    }
  }

  /// Handle permission request with complete flow
  Future<NotificationPermissionResult> handlePermissionFlow(
    BuildContext context, {
    bool showRationale = true,
  }) async {
    try {
      // Check current status
      final status = await getDetailedPermissionStatus();
      
      switch (status) {
        case NotificationPermissionStatus.granted:
          return NotificationPermissionResult.granted;
          
        case NotificationPermissionStatus.permanentlyDenied:
          final shouldOpenSettings = await showSettingsDialog(context);
          return shouldOpenSettings
              ? NotificationPermissionResult.redirectedToSettings
              : NotificationPermissionResult.permanentlyDenied;
          
        case NotificationPermissionStatus.denied:
        case NotificationPermissionStatus.unknown:
          // Show rationale if requested
          if (showRationale) {
            final shouldRequest = await showPermissionRationale(context);
            if (!shouldRequest) {
              return NotificationPermissionResult.deniedByUser;
            }
          }
          
          // Request permission
          return await requestNotificationPermission(showRationale: false);
      }
    } catch (e) {
      ErrorService.logError(
        e,
        context: 'Handle permission flow',
        severity: ErrorSeverity.error,
      );
      return NotificationPermissionResult.error;
    }
  }

  /// iOS-specific permission check
  Future<bool> _checkIOSNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      // Fallback for iOS
      return false;
    }
  }

  /// Android-specific permission check
  Future<bool> _checkAndroidNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      // For older Android versions, notifications are granted by default
      return true;
    }
  }

  /// iOS-specific permission request
  Future<NotificationPermissionResult> _requestIOSNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      
      switch (status) {
        case PermissionStatus.granted:
        case PermissionStatus.limited:
          return NotificationPermissionResult.granted;
        case PermissionStatus.denied:
          return NotificationPermissionResult.denied;
        case PermissionStatus.permanentlyDenied:
          return NotificationPermissionResult.permanentlyDenied;
        default:
          return NotificationPermissionResult.denied;
      }
    } catch (e) {
      ErrorService.logError(
        e,
        context: 'iOS notification permission request',
        severity: ErrorSeverity.error,
      );
      return NotificationPermissionResult.error;
    }
  }

  /// Android-specific permission request
  Future<NotificationPermissionResult> _requestAndroidNotificationPermission({
    bool showRationale = true,
  }) async {
    try {
      final status = await Permission.notification.request();
      
      switch (status) {
        case PermissionStatus.granted:
          return NotificationPermissionResult.granted;
        case PermissionStatus.denied:
          return NotificationPermissionResult.denied;
        case PermissionStatus.permanentlyDenied:
          return NotificationPermissionResult.permanentlyDenied;
        default:
          return NotificationPermissionResult.denied;
      }
    } catch (e) {
      // For older Android versions that don't support runtime notification permissions
      if (e is PlatformException && e.code == 'REQUEST_PERMISSION_ERROR') {
        return NotificationPermissionResult.granted;
      }
      
      ErrorService.logError(
        e,
        context: 'Android notification permission request',
        severity: ErrorSeverity.error,
      );
      return NotificationPermissionResult.error;
    }
  }

  /// Check if should show permission prompt based on user behavior
  Future<bool> shouldShowPermissionPrompt() async {
    try {
      // Check if permission was already requested
      final status = await getDetailedPermissionStatus();
      
      // Don't show if already granted or permanently denied
      if (status == NotificationPermissionStatus.granted ||
          status == NotificationPermissionStatus.permanentlyDenied) {
        return false;
      }
      
      // You could add logic here to check user preferences or frequency
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Initialize permission service
  Future<void> initialize() async {
    try {
      // Pre-check permission status for faster subsequent calls
      await hasNotificationPermission();
      debugPrint('NotificationPermissionService initialized');
    } catch (e) {
      ErrorService.logError(
        e,
        context: 'Initialize notification permission service',
        severity: ErrorSeverity.error,
      );
    }
  }
}

/// Widget for permission rationale items
class _RationaleItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _RationaleItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.pink.withOpacity(0.7),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

/// Enum for notification permission results
enum NotificationPermissionResult {
  granted,
  denied,
  permanentlyDenied,
  deniedByUser,
  redirectedToSettings,
  unsupported,
  error,
}

/// Enum for detailed permission status
enum NotificationPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  unknown,
}

/// Extension for permission result helpers
extension NotificationPermissionResultExtension on NotificationPermissionResult {
  bool get isGranted => this == NotificationPermissionResult.granted;
  bool get isDenied => this == NotificationPermissionResult.denied;
  bool get isPermanentlyDenied => this == NotificationPermissionResult.permanentlyDenied;
  bool get needsSettings => 
      this == NotificationPermissionResult.permanentlyDenied ||
      this == NotificationPermissionResult.redirectedToSettings;
  
  String get displayMessage {
    switch (this) {
      case NotificationPermissionResult.granted:
        return 'Notifications enabled successfully!';
      case NotificationPermissionResult.denied:
        return 'Notifications permission denied. You can enable it later in settings.';
      case NotificationPermissionResult.permanentlyDenied:
        return 'Please enable notifications in Settings to receive reminders.';
      case NotificationPermissionResult.deniedByUser:
        return 'You chose not to enable notifications. You can change this anytime.';
      case NotificationPermissionResult.redirectedToSettings:
        return 'Please enable notifications in Settings and return to the app.';
      case NotificationPermissionResult.unsupported:
        return 'Notifications are not supported on this device.';
      case NotificationPermissionResult.error:
        return 'Unable to request notification permission. Please try again.';
    }
  }
  
  Color get displayColor {
    switch (this) {
      case NotificationPermissionResult.granted:
        return Colors.green;
      case NotificationPermissionResult.denied:
      case NotificationPermissionResult.deniedByUser:
        return Colors.orange;
      case NotificationPermissionResult.permanentlyDenied:
      case NotificationPermissionResult.error:
        return Colors.red;
      case NotificationPermissionResult.redirectedToSettings:
      case NotificationPermissionResult.unsupported:
        return Colors.blue;
    }
  }
}
