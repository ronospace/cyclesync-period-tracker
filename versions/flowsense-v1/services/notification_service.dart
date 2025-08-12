import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  // Notification IDs
  static const int _cycleReminderID = 1;
  static const int _cycleStartPredictionID = 2;
  static const int _cycleEndReminderID = 3;
  static const int _ovulationPredictionID = 4;

  /// Initialize the notification service
  static Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      // Initialize timezone data
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('America/New_York')); // Default timezone

      // Android initialization settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings  
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // macOS initialization settings
      const DarwinInitializationSettings macOSSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: macOSSettings,
      );

      final bool? result = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      _initialized = result ?? false;
      return _initialized;
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      return false;
    }
  }

  /// Handle notification tap
  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // TODO: Add navigation logic based on payload
  }

  /// Request notification permissions
  static Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      // Android 13+ requires notification permission
      final status = await Permission.notification.request();
      return status.isGranted;
    } else if (Platform.isIOS || Platform.isMacOS) {
      // Request permissions through the plugin for iOS/macOS
      final bool? result = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }
    return true;
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      return await Permission.notification.isGranted;
    } else if (Platform.isIOS || Platform.isMacOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.checkPermissions();
      return result?.isEnabled ?? false;
    }
    return true;
  }

  /// Schedule a notification
  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_initialized) {
      debugPrint('NotificationService not initialized');
      return;
    }

    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'cycle_reminders',
        'Cycle Reminders',
        channelDescription: 'Notifications for cycle tracking and reminders',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        macOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );

      debugPrint('Scheduled notification: $title for ${scheduledDate.toString()}');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  /// Cancel a specific notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Schedule cycle start reminder
  static Future<void> scheduleCycleStartReminder(DateTime predictedStart) async {
    // Schedule reminder 1 day before predicted start
    final reminderDate = predictedStart.subtract(const Duration(days: 1));
    
    if (reminderDate.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: _cycleStartPredictionID,
        title: 'Cycle Starting Soon',
        body: 'Your next cycle is predicted to start tomorrow. Be prepared!',
        scheduledDate: reminderDate,
        payload: 'cycle_start_reminder',
      );
    }
  }

  /// Schedule ovulation prediction
  static Future<void> scheduleOvulationReminder(DateTime predictedOvulation) async {
    // Schedule reminder 1 day before predicted ovulation
    final reminderDate = predictedOvulation.subtract(const Duration(days: 1));
    
    if (reminderDate.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: _ovulationPredictionID,
        title: 'Ovulation Approaching',
        body: 'Your fertile window is starting soon. Track your symptoms!',
        scheduledDate: reminderDate,
        payload: 'ovulation_reminder',
      );
    }
  }

  /// Schedule cycle logging reminder
  static Future<void> scheduleCycleLoggingReminder() async {
    // Schedule daily reminder at 9 AM if no cycle logged recently
    final tomorrow9AM = DateTime.now().add(const Duration(days: 1)).copyWith(
      hour: 9,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );

    await _scheduleNotification(
      id: _cycleReminderID,
      title: 'Track Your Cycle',
      body: 'Don\'t forget to log your cycle data today!',
      scheduledDate: tomorrow9AM,
      payload: 'cycle_logging_reminder',
    );
  }

  /// Schedule cycle end reminder
  static Future<void> scheduleCycleEndReminder(DateTime cycleStart, int averageCycleLength) async {
    final predictedEnd = cycleStart.add(Duration(days: averageCycleLength));
    final reminderDate = predictedEnd.subtract(const Duration(days: 1));
    
    if (reminderDate.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: _cycleEndReminderID,
        title: 'Cycle Ending Soon',
        body: 'Your current cycle is expected to end tomorrow. Don\'t forget to log it!',
        scheduledDate: reminderDate,
        payload: 'cycle_end_reminder',
      );
    }
  }

  /// Get pending notifications (for debugging/info)
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Update notifications based on cycle data
  static Future<void> updateCycleNotifications(List<Map<String, dynamic>> cycles) async {
    if (cycles.isEmpty) return;

    try {
      // Cancel existing cycle-related notifications
      await cancelNotification(_cycleStartPredictionID);
      await cancelNotification(_ovulationPredictionID);
      await cancelNotification(_cycleEndReminderID);

      // Calculate predictions based on recent cycles
      final predictions = _calculateCyclePredictions(cycles);
      
      if (predictions['nextCycleStart'] != null) {
        await scheduleCycleStartReminder(predictions['nextCycleStart']);
      }
      
      if (predictions['nextOvulation'] != null) {
        await scheduleOvulationReminder(predictions['nextOvulation']);
      }

      // If currently in a cycle, schedule end reminder
      final currentCycle = cycles.where((c) => c['end'] == null).firstOrNull;
      if (currentCycle != null && predictions['averageCycleLength'] != null) {
        DateTime startDate;
        if (currentCycle['start'] is DateTime) {
          startDate = currentCycle['start'];
        } else {
          startDate = (currentCycle['start'] as dynamic).toDate();
        }
        await scheduleCycleEndReminder(startDate, predictions['averageCycleLength']);
      }

    } catch (e) {
      debugPrint('Error updating cycle notifications: $e');
    }
  }

  /// Calculate cycle predictions based on historical data
  static Map<String, dynamic> _calculateCyclePredictions(List<Map<String, dynamic>> cycles) {
    if (cycles.length < 2) return {};

    try {
      // Calculate average cycle length from completed cycles
      final completedCycles = cycles.where((c) => c['end'] != null).toList();
      if (completedCycles.length < 2) return {};

      int totalDays = 0;
      int cycleCount = 0;

      for (final cycle in completedCycles) {
        DateTime startDate, endDate;
        
        if (cycle['start'] is DateTime) {
          startDate = cycle['start'];
        } else {
          startDate = (cycle['start'] as dynamic).toDate();
        }
        
        if (cycle['end'] is DateTime) {
          endDate = cycle['end'];
        } else {
          endDate = (cycle['end'] as dynamic).toDate();
        }

        final cycleDays = endDate.difference(startDate).inDays + 1;
        if (cycleDays > 0 && cycleDays < 60) { // Sanity check
          totalDays += cycleDays;
          cycleCount++;
        }
      }

      if (cycleCount == 0) return {};
      
      final averageCycleLength = (totalDays / cycleCount).round();
      
      // Predict next cycle start
      DateTime? lastCycleEnd;
      final lastCompletedCycle = completedCycles.first;
      if (lastCompletedCycle['end'] is DateTime) {
        lastCycleEnd = lastCompletedCycle['end'];
      } else {
        lastCycleEnd = (lastCompletedCycle['end'] as dynamic).toDate();
      }
      
      final nextCycleStart = lastCycleEnd?.add(Duration(days: averageCycleLength));
      
      // Predict ovulation (typically 14 days before next cycle)
      final nextOvulation = nextCycleStart?.subtract(const Duration(days: 14));

      return {
        'averageCycleLength': averageCycleLength,
        'nextCycleStart': nextCycleStart,
        'nextOvulation': nextOvulation,
      };
    } catch (e) {
      debugPrint('Error calculating predictions: $e');
      return {};
    }
  }
}
