import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io';
import 'dart:math';

import '../models/reminder_models.dart';
import 'firebase_service.dart';
import 'user_service.dart';
import 'error_service.dart';
import 'ai_prediction_service.dart';

/// Service for managing reminders and notifications
class ReminderService {
  static ReminderService? _instance;
  static ReminderService get instance => _instance ??= ReminderService._();
  
  ReminderService._() {
    _initialize();
  }

  final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection references
  CollectionReference get _remindersCollection =>
      _firestore.collection('reminders');
  
  /// Initialize the reminder service and notifications
  Future<void> _initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize timezone data
      tz.initializeTimeZones();
      
      // Configure notification settings
      await _initializeNotifications();
      
      _isInitialized = true;
      debugPrint('ReminderService initialized successfully');
    } catch (e) {
      ErrorService.logError(
        e,
        context: 'ReminderService initialization',
        severity: ErrorSeverity.error,
      );
    }
  }

  /// Initialize local notifications
  Future<void> _initializeNotifications() async {
    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Create notification channels for Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }
  }

  /// Create notification channels for different reminder types
  Future<void> _createNotificationChannels() async {
    const channels = [
      AndroidNotificationChannel(
        'cycle_predictions',
        'Cycle Predictions',
        description: 'Notifications for period and fertility predictions',
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound('gentle'),
      ),
      AndroidNotificationChannel(
        'medications',
        'Medications',
        description: 'Medication and supplement reminders',
        importance: Importance.max,
        sound: RawResourceAndroidNotificationSound('chime'),
      ),
      AndroidNotificationChannel(
        'appointments',
        'Appointments',
        description: 'Doctor appointments and check-ups',
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        'daily_tracking',
        'Daily Tracking',
        description: 'Daily symptom and mood tracking reminders',
        importance: Importance.defaultImportance,
      ),
      AndroidNotificationChannel(
        'wellness',
        'Wellness',
        description: 'Water intake, exercise, and self-care reminders',
        importance: Importance.defaultImportance,
        sound: RawResourceAndroidNotificationSound('nature'),
      ),
    ];

    final plugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (plugin != null) {
      for (final channel in channels) {
        await plugin.createNotificationChannel(channel);
      }
    }
  }

  /// Handle notification tap events
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      // Parse reminder ID from payload and handle action
      _handleNotificationAction(payload);
    }
  }

  /// Handle different notification actions
  Future<void> _handleNotificationAction(String payload) async {
    try {
      // Parse payload (format: "reminderId:action")
      final parts = payload.split(':');
      if (parts.length < 2) return;
      
      final reminderId = parts[0];
      final action = parts[1];
      
      switch (action) {
        case 'complete':
          await markReminderCompleted(reminderId);
          break;
        case 'snooze':
          await snoozeReminder(reminderId, Duration(minutes: 15));
          break;
        case 'view':
          // Navigate to reminder details
          break;
      }
    } catch (e) {
      ErrorService.logError(e, context: 'Notification action handling');
    }
  }

  /// Request notification permissions
  Future<bool> requestNotificationPermissions() async {
    try {
      if (Platform.isAndroid) {
        final plugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        
        return await plugin?.requestNotificationsPermission() ?? false;
      } else if (Platform.isIOS) {
        final plugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        
        return await plugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ?? false;
      }
      return false;
    } catch (e) {
      ErrorService.logError(e, context: 'Request notification permissions');
      return false;
    }
  }

  /// Create a new reminder
  Future<String?> createReminder(Reminder reminder) async {
    try {
      final user = UserService.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Generate ID if not provided
      final reminderId = reminder.id.isEmpty 
          ? _remindersCollection.doc().id 
          : reminder.id;
      
      // Calculate next occurrence
      final nextOccurrence = _calculateNextOccurrence(reminder);
      
      final updatedReminder = reminder.copyWith(
        id: reminderId,
        userId: user.uid,
        nextOccurrence: nextOccurrence,
      );

      // Save to Firestore
      await _remindersCollection.doc(reminderId).set(updatedReminder.toMap());
      
      // Schedule notification
      await _scheduleNotification(updatedReminder);
      
      // Log creation
      await _logReminderAction(reminderId, ReminderAction.created);
      
      debugPrint('Reminder created: $reminderId');
      return reminderId;
    } catch (e) {
      ErrorService.logError(e, context: 'Create reminder');
      return null;
    }
  }

  /// Update an existing reminder
  Future<bool> updateReminder(Reminder reminder) async {
    try {
      final user = UserService.instance.currentUser;
      if (user == null || reminder.userId != user.uid) return false;

      // Recalculate next occurrence
      final nextOccurrence = _calculateNextOccurrence(reminder);
      final updatedReminder = reminder.copyWith(nextOccurrence: nextOccurrence);

      // Update in Firestore
      await _remindersCollection.doc(reminder.id).update(updatedReminder.toMap());
      
      // Reschedule notification
      await _cancelNotification(reminder.id);
      await _scheduleNotification(updatedReminder);
      
      // Log update
      await _logReminderAction(reminder.id, ReminderAction.updated);
      
      return true;
    } catch (e) {
      ErrorService.logError(e, context: 'Update reminder');
      return false;
    }
  }

  /// Delete a reminder
  Future<bool> deleteReminder(String reminderId) async {
    try {
      final user = UserService.instance.currentUser;
      if (user == null) return false;

      // Cancel notification
      await _cancelNotification(reminderId);
      
      // Delete from Firestore
      await _remindersCollection.doc(reminderId).delete();
      
      // Log deletion
      await _logReminderAction(reminderId, ReminderAction.deleted);
      
      return true;
    } catch (e) {
      ErrorService.logError(e, context: 'Delete reminder');
      return false;
    }
  }

  /// Get user's reminders
  Stream<List<Reminder>> getUserReminders({ReminderStatus? status}) {
    final user = UserService.instance.currentUser;
    if (user == null) return Stream.value([]);

    Query query = _remindersCollection
        .where('userId', isEqualTo: user.uid)
        .orderBy('nextOccurrence', descending: false);
    
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Reminder.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  /// Get reminders by type
  Stream<List<Reminder>> getRemindersByType(ReminderType type) {
    final user = UserService.instance.currentUser;
    if (user == null) return Stream.value([]);

    return _remindersCollection
        .where('userId', isEqualTo: user.uid)
        .where('type', isEqualTo: type.name)
        .where('status', isEqualTo: ReminderStatus.active.name)
        .orderBy('nextOccurrence')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Reminder.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();
        });
  }

  /// Get today's reminders
  Future<List<Reminder>> getTodaysReminders() async {
    final user = UserService.instance.currentUser;
    if (user == null) return [];

    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _remindersCollection
          .where('userId', isEqualTo: user.uid)
          .where('status', isEqualTo: ReminderStatus.active.name)
          .where('nextOccurrence', isGreaterThanOrEqualTo: startOfDay)
          .where('nextOccurrence', isLessThan: endOfDay)
          .get();

      return snapshot.docs.map((doc) {
        return Reminder.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      ErrorService.logError(e, context: 'Get today\'s reminders');
      return [];
    }
  }

  /// Mark reminder as completed
  Future<bool> markReminderCompleted(String reminderId) async {
    try {
      final doc = await _remindersCollection.doc(reminderId).get();
      if (!doc.exists) return false;

      final reminder = Reminder.fromMap(doc.data() as Map<String, dynamic>);
      final now = DateTime.now();
      
      // Update reminder
      final updatedReminder = reminder.copyWith(
        timesCompleted: reminder.timesCompleted + 1,
        lastTriggered: now,
        completedAt: now,
        nextOccurrence: _calculateNextOccurrence(reminder, from: now),
      );

      await _remindersCollection.doc(reminderId).update(updatedReminder.toMap());
      
      // Schedule next occurrence if recurring
      if (reminder.frequency != ReminderFrequency.once) {
        await _scheduleNotification(updatedReminder);
      }
      
      // Log completion
      await _logReminderAction(reminderId, ReminderAction.completed);
      
      return true;
    } catch (e) {
      ErrorService.logError(e, context: 'Mark reminder completed');
      return false;
    }
  }

  /// Snooze a reminder
  Future<bool> snoozeReminder(String reminderId, Duration snoozeDuration) async {
    try {
      final doc = await _remindersCollection.doc(reminderId).get();
      if (!doc.exists) return false;

      final reminder = Reminder.fromMap(doc.data() as Map<String, dynamic>);
      final snoozeUntil = DateTime.now().add(snoozeDuration);
      
      // Update next occurrence
      final updatedReminder = reminder.copyWith(
        nextOccurrence: snoozeUntil,
        status: ReminderStatus.snoozed,
      );

      await _remindersCollection.doc(reminderId).update(updatedReminder.toMap());
      
      // Reschedule notification
      await _cancelNotification(reminderId);
      await _scheduleNotification(updatedReminder);
      
      // Log snooze
      await _logReminderAction(reminderId, ReminderAction.snoozed);
      
      return true;
    } catch (e) {
      ErrorService.logError(e, context: 'Snooze reminder');
      return false;
    }
  }

  /// Create reminder from template
  Future<String?> createReminderFromTemplate(
    ReminderTemplate template, {
    DateTime? scheduledFor,
    List<DateTime>? customTimes,
  }) async {
    final user = UserService.instance.currentUser;
    if (user == null) return null;

    final reminder = template.toReminder(
      userId: user.uid,
      scheduledFor: scheduledFor,
      customTimes: customTimes,
    );

    return await createReminder(reminder);
  }

  /// Calculate next occurrence for a reminder
  DateTime? _calculateNextOccurrence(Reminder reminder, {DateTime? from}) {
    final baseTime = from ?? DateTime.now();
    
    switch (reminder.frequency) {
      case ReminderFrequency.once:
        return reminder.scheduledFor ?? baseTime;
        
      case ReminderFrequency.daily:
        if (reminder.notificationTimes.isNotEmpty) {
          final nextTime = _getNextTimeOccurrence(reminder.notificationTimes, baseTime);
          return nextTime;
        }
        return baseTime.add(const Duration(days: 1));
        
      case ReminderFrequency.weekly:
        if (reminder.weeklyDays != null && reminder.weeklyDays!.isNotEmpty) {
          return _getNextWeeklyOccurrence(reminder.weeklyDays!, baseTime, reminder.notificationTimes);
        }
        return baseTime.add(const Duration(days: 7));
        
      case ReminderFrequency.monthly:
        return DateTime(baseTime.year, baseTime.month + 1, baseTime.day, 
                       baseTime.hour, baseTime.minute);
        
      case ReminderFrequency.custom:
        final days = reminder.customIntervalDays ?? 0;
        final hours = reminder.customIntervalHours ?? 0;
        return baseTime.add(Duration(days: days, hours: hours));
        
      case ReminderFrequency.cycleStart:
      case ReminderFrequency.ovulation:
        // These will be handled by cycle prediction integration
        return reminder.scheduledFor ?? baseTime.add(const Duration(days: 28));
    }
  }

  /// Get next time occurrence for daily reminders
  DateTime _getNextTimeOccurrence(List<DateTime> times, DateTime from) {
    final today = DateTime(from.year, from.month, from.day);
    
    // Check if any time today is still in the future
    for (final time in times) {
      final todayTime = DateTime(today.year, today.month, today.day, 
                               time.hour, time.minute);
      if (todayTime.isAfter(from)) {
        return todayTime;
      }
    }
    
    // All times today have passed, use first time tomorrow
    final tomorrow = today.add(const Duration(days: 1));
    final firstTime = times.first;
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 
                    firstTime.hour, firstTime.minute);
  }

  /// Get next weekly occurrence
  DateTime _getNextWeeklyOccurrence(
    List<WeekDay> weekDays, 
    DateTime from, 
    List<DateTime> times,
  ) {
    final today = DateTime(from.year, from.month, from.day);
    final currentWeekday = from.weekday;
    
    // Sort weekdays and find next occurrence
    final sortedDays = [...weekDays]..sort((a, b) => a.value.compareTo(b.value));
    
    for (final weekDay in sortedDays) {
      if (weekDay.value >= currentWeekday) {
        final daysUntil = weekDay.value - currentWeekday;
        final targetDate = today.add(Duration(days: daysUntil));
        
        if (times.isNotEmpty) {
          final time = times.first;
          final targetDateTime = DateTime(targetDate.year, targetDate.month, 
                                        targetDate.day, time.hour, time.minute);
          
          // If it's today and time hasn't passed, return it
          if (daysUntil == 0 && targetDateTime.isAfter(from)) {
            return targetDateTime;
          } else if (daysUntil > 0) {
            return targetDateTime;
          }
        } else if (daysUntil > 0) {
          return targetDate;
        }
      }
    }
    
    // No valid day this week, use first day next week
    final firstDay = sortedDays.first;
    final daysUntilNext = 7 - currentWeekday + firstDay.value;
    final nextDate = today.add(Duration(days: daysUntilNext));
    
    if (times.isNotEmpty) {
      final time = times.first;
      return DateTime(nextDate.year, nextDate.month, nextDate.day, 
                     time.hour, time.minute);
    }
    
    return nextDate;
  }

  /// Schedule notification for a reminder
  Future<void> _scheduleNotification(Reminder reminder) async {
    if (!reminder.isEnabled || reminder.nextOccurrence == null) return;
    
    try {
      final scheduledDate = tz.TZDateTime.from(
        reminder.nextOccurrence!,
        tz.local,
      );
      
      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        return; // Don't schedule past notifications
      }

      final notificationDetails = _buildNotificationDetails(reminder);
      
      await _notificationsPlugin.zonedSchedule(
        reminder.id.hashCode,
        reminder.displayTitle,
        reminder.customMessage ?? reminder.description ?? 'Reminder',
        scheduledDate,
        notificationDetails,
        payload: '${reminder.id}:view',
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      
      debugPrint('Scheduled notification for ${reminder.id} at $scheduledDate');
    } catch (e) {
      ErrorService.logError(e, context: 'Schedule notification');
    }
  }

  /// Build notification details based on reminder type
  NotificationDetails _buildNotificationDetails(Reminder reminder) {
    String channelId;
    switch (reminder.type) {
      case ReminderType.cyclePrediction:
        channelId = 'cycle_predictions';
        break;
      case ReminderType.medication:
        channelId = 'medications';
        break;
      case ReminderType.appointment:
        channelId = 'appointments';
        break;
      case ReminderType.symptomTracking:
        channelId = 'daily_tracking';
        break;
      default:
        channelId = 'wellness';
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelId.replaceAll('_', ' ').toUpperCase(),
      importance: _getImportanceFromPriority(reminder.priority),
      priority: _getPriorityFromReminderPriority(reminder.priority),
      enableVibration: reminder.vibrate,
      playSound: reminder.sound != NotificationSound.silent,
      sound: _getAndroidSound(reminder.sound),
      actions: _buildAndroidActions(reminder),
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: reminder.sound != NotificationSound.silent,
      sound: _getIOSSound(reminder.sound),
    );

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  /// Build Android notification actions
  List<AndroidNotificationAction> _buildAndroidActions(Reminder reminder) {
    final actions = <AndroidNotificationAction>[
      const AndroidNotificationAction(
        'complete',
        '✓ Complete',
        titleColor: Color.fromARGB(255, 76, 175, 80),
      ),
      const AndroidNotificationAction(
        'snooze',
        '⏰ Snooze 15m',
      ),
    ];

    return actions;
  }

  /// Cancel notification for a reminder
  Future<void> _cancelNotification(String reminderId) async {
    try {
      await _notificationsPlugin.cancel(reminderId.hashCode);
      debugPrint('Cancelled notification for $reminderId');
    } catch (e) {
      ErrorService.logError(e, context: 'Cancel notification');
    }
  }

  /// Log reminder action
  Future<void> _logReminderAction(
    String reminderId,
    ReminderAction action, {
    String? note,
    Map<String, dynamic>? data,
  }) async {
    try {
      final log = ReminderLog(
        id: _firestore.collection('reminder_logs').doc().id,
        reminderId: reminderId,
        timestamp: DateTime.now(),
        action: action,
        note: note,
        data: data,
      );

      await _firestore
          .collection('reminder_logs')
          .doc(log.id)
          .set(log.toMap());
    } catch (e) {
      ErrorService.logError(e, context: 'Log reminder action');
    }
  }

  /// Check and trigger due reminders
  Future<void> checkDueReminders() async {
    try {
      final user = UserService.instance.currentUser;
      if (user == null) return;

      final now = DateTime.now();
      final snapshot = await _remindersCollection
          .where('userId', isEqualTo: user.uid)
          .where('status', isEqualTo: ReminderStatus.active.name)
          .where('isEnabled', isEqualTo: true)
          .where('nextOccurrence', isLessThanOrEqualTo: now)
          .get();

      for (final doc in snapshot.docs) {
        final reminder = Reminder.fromMap(doc.data());
        await _triggerReminder(reminder);
      }
    } catch (e) {
      ErrorService.logError(e, context: 'Check due reminders');
    }
  }

  /// Trigger a reminder (mark as triggered and schedule next)
  Future<void> _triggerReminder(Reminder reminder) async {
    try {
      final now = DateTime.now();
      final nextOccurrence = reminder.frequency == ReminderFrequency.once
          ? null
          : _calculateNextOccurrence(reminder, from: now);

      final updatedReminder = reminder.copyWith(
        timesTriggered: reminder.timesTriggered + 1,
        lastTriggered: now,
        nextOccurrence: nextOccurrence,
        status: reminder.frequency == ReminderFrequency.once
            ? ReminderStatus.completed
            : ReminderStatus.active,
      );

      await _remindersCollection
          .doc(reminder.id)
          .update(updatedReminder.toMap());

      // Schedule next occurrence if recurring
      if (nextOccurrence != null) {
        await _scheduleNotification(updatedReminder);
      }

      // Log trigger
      await _logReminderAction(reminder.id, ReminderAction.triggered);

      debugPrint('Triggered reminder: ${reminder.id}');
    } catch (e) {
      ErrorService.logError(e, context: 'Trigger reminder');
    }
  }

  // Helper methods for notification configuration
  Importance _getImportanceFromPriority(ReminderPriority priority) {
    switch (priority) {
      case ReminderPriority.low:
        return Importance.low;
      case ReminderPriority.medium:
        return Importance.defaultImportance;
      case ReminderPriority.high:
        return Importance.high;
      case ReminderPriority.critical:
        return Importance.max;
    }
  }

  Priority _getPriorityFromReminderPriority(ReminderPriority priority) {
    switch (priority) {
      case ReminderPriority.low:
        return Priority.low;
      case ReminderPriority.medium:
        return Priority.defaultPriority;
      case ReminderPriority.high:
        return Priority.high;
      case ReminderPriority.critical:
        return Priority.max;
    }
  }

  RawResourceAndroidNotificationSound? _getAndroidSound(NotificationSound sound) {
    switch (sound) {
      case NotificationSound.gentle:
        return const RawResourceAndroidNotificationSound('gentle');
      case NotificationSound.chime:
        return const RawResourceAndroidNotificationSound('chime');
      case NotificationSound.bell:
        return const RawResourceAndroidNotificationSound('bell');
      case NotificationSound.nature:
        return const RawResourceAndroidNotificationSound('nature');
      case NotificationSound.silent:
      case NotificationSound.defaultSound:
        return null;
    }
  }

  String? _getIOSSound(NotificationSound sound) {
    switch (sound) {
      case NotificationSound.gentle:
        return 'gentle.aiff';
      case NotificationSound.chime:
        return 'chime.aiff';
      case NotificationSound.bell:
        return 'bell.aiff';
      case NotificationSound.nature:
        return 'nature.aiff';
      case NotificationSound.silent:
        return null;
      case NotificationSound.defaultSound:
        return 'default';
    }
  }

  /// Cleanup method to cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('Cancelled all notifications');
    } catch (e) {
      ErrorService.logError(e, context: 'Cancel all notifications');
    }
  }

  /// Get reminder statistics
  Future<Map<String, dynamic>> getReminderStatistics() async {
    try {
      final user = UserService.instance.currentUser;
      if (user == null) return {};

      final snapshot = await _remindersCollection
          .where('userId', isEqualTo: user.uid)
          .get();

      final reminders = snapshot.docs
          .map((doc) => Reminder.fromMap(doc.data()))
          .toList();

      final stats = <String, dynamic>{
        'total': reminders.length,
        'active': reminders.where((r) => r.status == ReminderStatus.active).length,
        'completed_today': reminders.where((r) => 
          r.completedAt != null && 
          _isSameDay(r.completedAt!, DateTime.now())
        ).length,
        'completion_rate': reminders.isEmpty 
          ? 0.0 
          : reminders.map((r) => r.timesCompleted).reduce((a, b) => a + b) / 
            reminders.map((r) => r.timesTriggered).fold(1, (a, b) => a + b),
        'by_type': _groupByType(reminders),
      };

      return stats;
    } catch (e) {
      ErrorService.logError(e, context: 'Get reminder statistics');
      return {};
    }
  }

  Map<String, int> _groupByType(List<Reminder> reminders) {
    final grouped = <String, int>{};
    for (final reminder in reminders) {
      final type = reminder.type.name;
      grouped[type] = (grouped[type] ?? 0) + 1;
    }
    return grouped;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}
