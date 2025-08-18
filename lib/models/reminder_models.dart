import 'package:flutter/foundation.dart';

/// Types of reminders available in the app
enum ReminderType {
  cyclePrediction,    // Period start, fertility window, ovulation
  medication,         // Birth control, supplements, prescriptions
  appointment,        // Doctor visits, check-ups
  symptomTracking,    // Daily tracking reminders
  waterIntake,        // Hydration reminders
  exercise,           // Workout or activity reminders
  selfCare,           // Meditation, relaxation, wellness
  custom,             // User-defined reminders
}

/// How often a reminder should repeat
enum ReminderFrequency {
  once,               // One-time reminder
  daily,              // Every day
  weekly,             // Every week
  monthly,            // Every month
  cycleStart,         // At the start of each cycle
  ovulation,          // During ovulation window
  custom,             // Custom interval
}

/// Priority levels for reminders
enum ReminderPriority {
  low,
  medium,
  high,
  critical,
}

/// Status of a reminder
enum ReminderStatus {
  active,
  paused,
  completed,
  missed,
  snoozed,
}

/// Sound options for notifications
enum NotificationSound {
  defaultSound,
  gentle,
  chime,
  bell,
  nature,
  silent,
}

/// Days of the week for weekly reminders
enum WeekDay {
  monday(1),
  tuesday(2),
  wednesday(3),
  thursday(4),
  friday(5),
  saturday(6),
  sunday(7);

  const WeekDay(this.value);
  final int value;
}

/// Main reminder model
class Reminder {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final ReminderType type;
  final ReminderFrequency frequency;
  final ReminderPriority priority;
  final ReminderStatus status;
  
  // Scheduling
  final DateTime createdAt;
  final DateTime? scheduledFor;
  final DateTime? nextOccurrence;
  final DateTime? lastTriggered;
  final List<WeekDay>? weeklyDays;
  final int? customIntervalDays;
  final int? customIntervalHours;
  
  // Notification settings
  final bool isEnabled;
  final List<DateTime> notificationTimes;
  final NotificationSound sound;
  final bool vibrate;
  final String? customMessage;
  final Map<String, dynamic>? metadata;
  
  // Tracking
  final int timesTriggered;
  final int timesCompleted;
  final int timesMissed;
  final DateTime? completedAt;
  final List<ReminderLog> logs;

  const Reminder({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.type,
    required this.frequency,
    this.priority = ReminderPriority.medium,
    this.status = ReminderStatus.active,
    required this.createdAt,
    this.scheduledFor,
    this.nextOccurrence,
    this.lastTriggered,
    this.weeklyDays,
    this.customIntervalDays,
    this.customIntervalHours,
    this.isEnabled = true,
    this.notificationTimes = const [],
    this.sound = NotificationSound.defaultSound,
    this.vibrate = true,
    this.customMessage,
    this.metadata,
    this.timesTriggered = 0,
    this.timesCompleted = 0,
    this.timesMissed = 0,
    this.completedAt,
    this.logs = const [],
  });

  /// Create a copy of this reminder with updated fields
  Reminder copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    ReminderType? type,
    ReminderFrequency? frequency,
    ReminderPriority? priority,
    ReminderStatus? status,
    DateTime? createdAt,
    DateTime? scheduledFor,
    DateTime? nextOccurrence,
    DateTime? lastTriggered,
    List<WeekDay>? weeklyDays,
    int? customIntervalDays,
    int? customIntervalHours,
    bool? isEnabled,
    List<DateTime>? notificationTimes,
    NotificationSound? sound,
    bool? vibrate,
    String? customMessage,
    Map<String, dynamic>? metadata,
    int? timesTriggered,
    int? timesCompleted,
    int? timesMissed,
    DateTime? completedAt,
    List<ReminderLog>? logs,
  }) {
    return Reminder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      nextOccurrence: nextOccurrence ?? this.nextOccurrence,
      lastTriggered: lastTriggered ?? this.lastTriggered,
      weeklyDays: weeklyDays ?? this.weeklyDays,
      customIntervalDays: customIntervalDays ?? this.customIntervalDays,
      customIntervalHours: customIntervalHours ?? this.customIntervalHours,
      isEnabled: isEnabled ?? this.isEnabled,
      notificationTimes: notificationTimes ?? this.notificationTimes,
      sound: sound ?? this.sound,
      vibrate: vibrate ?? this.vibrate,
      customMessage: customMessage ?? this.customMessage,
      metadata: metadata ?? this.metadata,
      timesTriggered: timesTriggered ?? this.timesTriggered,
      timesCompleted: timesCompleted ?? this.timesCompleted,
      timesMissed: timesMissed ?? this.timesMissed,
      completedAt: completedAt ?? this.completedAt,
      logs: logs ?? this.logs,
    );
  }

  /// Convert to map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'type': type.name,
      'frequency': frequency.name,
      'priority': priority.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'scheduledFor': scheduledFor?.toIso8601String(),
      'nextOccurrence': nextOccurrence?.toIso8601String(),
      'lastTriggered': lastTriggered?.toIso8601String(),
      'weeklyDays': weeklyDays?.map((d) => d.name).toList(),
      'customIntervalDays': customIntervalDays,
      'customIntervalHours': customIntervalHours,
      'isEnabled': isEnabled,
      'notificationTimes': notificationTimes.map((t) => t.toIso8601String()).toList(),
      'sound': sound.name,
      'vibrate': vibrate,
      'customMessage': customMessage,
      'metadata': metadata,
      'timesTriggered': timesTriggered,
      'timesCompleted': timesCompleted,
      'timesMissed': timesMissed,
      'completedAt': completedAt?.toIso8601String(),
      'logs': logs.map((log) => log.toMap()).toList(),
    };
  }

  /// Create from Firestore map
  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      type: ReminderType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ReminderType.custom,
      ),
      frequency: ReminderFrequency.values.firstWhere(
        (e) => e.name == map['frequency'],
        orElse: () => ReminderFrequency.once,
      ),
      priority: ReminderPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => ReminderPriority.medium,
      ),
      status: ReminderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ReminderStatus.active,
      ),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      scheduledFor: map['scheduledFor'] != null ? DateTime.parse(map['scheduledFor']) : null,
      nextOccurrence: map['nextOccurrence'] != null ? DateTime.parse(map['nextOccurrence']) : null,
      lastTriggered: map['lastTriggered'] != null ? DateTime.parse(map['lastTriggered']) : null,
      weeklyDays: (map['weeklyDays'] as List<dynamic>?)
          ?.map((d) => WeekDay.values.firstWhere((w) => w.name == d))
          .toList(),
      customIntervalDays: map['customIntervalDays'],
      customIntervalHours: map['customIntervalHours'],
      isEnabled: map['isEnabled'] ?? true,
      notificationTimes: (map['notificationTimes'] as List<dynamic>? ?? [])
          .map((t) => DateTime.parse(t))
          .toList(),
      sound: NotificationSound.values.firstWhere(
        (e) => e.name == map['sound'],
        orElse: () => NotificationSound.defaultSound,
      ),
      vibrate: map['vibrate'] ?? true,
      customMessage: map['customMessage'],
      metadata: map['metadata'],
      timesTriggered: map['timesTriggered'] ?? 0,
      timesCompleted: map['timesCompleted'] ?? 0,
      timesMissed: map['timesMissed'] ?? 0,
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
      logs: (map['logs'] as List<dynamic>? ?? [])
          .map((log) => ReminderLog.fromMap(log))
          .toList(),
    );
  }

  /// Check if reminder is active and should trigger notifications
  bool get shouldTrigger {
    return isEnabled && 
           status == ReminderStatus.active &&
           (nextOccurrence?.isBefore(DateTime.now()) ?? false);
  }

  /// Get display title with emoji based on type
  String get displayTitle {
    final emoji = _getTypeEmoji();
    return '$emoji $title';
  }

  String _getTypeEmoji() {
    switch (type) {
      case ReminderType.cyclePrediction:
        return '🌸';
      case ReminderType.medication:
        return '💊';
      case ReminderType.appointment:
        return '📅';
      case ReminderType.symptomTracking:
        return '📝';
      case ReminderType.waterIntake:
        return '💧';
      case ReminderType.exercise:
        return '🏃‍♀️';
      case ReminderType.selfCare:
        return '🧘‍♀️';
      case ReminderType.custom:
        return '⏰';
    }
  }
}

/// Log entry for reminder history
class ReminderLog {
  final String id;
  final String reminderId;
  final DateTime timestamp;
  final ReminderAction action;
  final String? note;
  final Map<String, dynamic>? data;

  const ReminderLog({
    required this.id,
    required this.reminderId,
    required this.timestamp,
    required this.action,
    this.note,
    this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reminderId': reminderId,
      'timestamp': timestamp.toIso8601String(),
      'action': action.name,
      'note': note,
      'data': data,
    };
  }

  factory ReminderLog.fromMap(Map<String, dynamic> map) {
    return ReminderLog(
      id: map['id'] ?? '',
      reminderId: map['reminderId'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      action: ReminderAction.values.firstWhere(
        (e) => e.name == map['action'],
        orElse: () => ReminderAction.created,
      ),
      note: map['note'],
      data: map['data'],
    );
  }
}

/// Actions that can be performed on reminders
enum ReminderAction {
  created,
  triggered,
  completed,
  snoozed,
  dismissed,
  missed,
  updated,
  deleted,
}

/// Template for creating common reminders
class ReminderTemplate {
  final String name;
  final ReminderType type;
  final String title;
  final String description;
  final ReminderFrequency frequency;
  final ReminderPriority priority;
  final List<DateTime> defaultTimes;
  final NotificationSound sound;
  final Map<String, dynamic>? metadata;

  const ReminderTemplate({
    required this.name,
    required this.type,
    required this.title,
    required this.description,
    required this.frequency,
    this.priority = ReminderPriority.medium,
    this.defaultTimes = const [],
    this.sound = NotificationSound.defaultSound,
    this.metadata,
  });

  /// Convert template to reminder
  Reminder toReminder({
    required String userId,
    DateTime? scheduledFor,
    List<DateTime>? customTimes,
  }) {
    return Reminder(
      id: '', // Will be generated
      userId: userId,
      title: title,
      description: description,
      type: type,
      frequency: frequency,
      priority: priority,
      createdAt: DateTime.now(),
      scheduledFor: scheduledFor,
      notificationTimes: customTimes ?? defaultTimes,
      sound: sound,
      metadata: metadata,
    );
  }
}

/// Predefined reminder templates
class ReminderTemplates {
  static final List<ReminderTemplate> templates = [
    // Cycle predictions
    const ReminderTemplate(
      name: 'period_start',
      type: ReminderType.cyclePrediction,
      title: 'Period Starting Soon',
      description: 'Your period is expected to start in the next few days',
      frequency: ReminderFrequency.cycleStart,
      priority: ReminderPriority.high,
      sound: NotificationSound.gentle,
    ),
    
    const ReminderTemplate(
      name: 'fertile_window',
      type: ReminderType.cyclePrediction,
      title: 'Fertile Window',
      description: 'You are entering your most fertile period',
      frequency: ReminderFrequency.ovulation,
      priority: ReminderPriority.medium,
    ),
    
    // Daily tracking
    const ReminderTemplate(
      name: 'daily_log',
      type: ReminderType.symptomTracking,
      title: 'Daily Cycle Log',
      description: 'Time to log your daily symptoms and mood',
      frequency: ReminderFrequency.daily,
    ),
    
    // Birth control
    const ReminderTemplate(
      name: 'birth_control',
      type: ReminderType.medication,
      title: 'Birth Control Pill',
      description: 'Time to take your daily birth control pill',
      frequency: ReminderFrequency.daily,
      priority: ReminderPriority.critical,
      sound: NotificationSound.chime,
    ),
    
    // Water intake
    const ReminderTemplate(
      name: 'hydration',
      type: ReminderType.waterIntake,
      title: 'Stay Hydrated',
      description: 'Remember to drink water throughout the day',
      frequency: ReminderFrequency.daily,
      sound: NotificationSound.nature,
    ),
    
    // Self-care
    const ReminderTemplate(
      name: 'self_care',
      type: ReminderType.selfCare,
      title: 'Self-Care Time',
      description: 'Take a few minutes for yourself today',
      frequency: ReminderFrequency.daily,
      sound: NotificationSound.gentle,
    ),
  ];

  /// Get template by name
  static ReminderTemplate? getTemplate(String name) {
    return templates.cast<ReminderTemplate?>().firstWhere(
      (template) => template?.name == name,
      orElse: () => null,
    );
  }

  /// Get templates by type
  static List<ReminderTemplate> getTemplatesByType(ReminderType type) {
    return templates.where((template) => template.type == type).toList();
  }
}
