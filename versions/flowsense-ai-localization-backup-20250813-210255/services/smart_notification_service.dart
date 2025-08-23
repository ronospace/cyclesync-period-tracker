import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:math';
import '../models/cycle_models.dart';
import '../models/daily_log_models.dart';
import 'notification_service.dart';
import 'firebase_service.dart';

/// 🚀 Nova Smart Notification Service
/// Advanced AI-powered notification system with pattern recognition,
/// personalized insights, and adaptive learning capabilities
class SmartNotificationService {
  // Remove instance - use static methods instead
  
  // Enhanced Notification Categories
  static const String _categoryPredictive = 'predictive';
  static const String _categoryInsights = 'insights';
  static const String _categoryHealth = 'health_alerts';
  static const String _categoryMedication = 'medication';
  static const String _categoryWellness = 'wellness';
  
  // Enhanced Notification IDs (1000+ range for smart notifications)
  static const int _baseID = 1000;
  static const int _predictiveStartID = 1001;
  static const int _predictiveEndID = 1002;
  static const int _moodPatternID = 1003;
  static const int _energyPatternID = 1004;
  static const int _healthInsightID = 1005;
  static const int _medicationReminderID = 1006;
  static const int _wellnessCheckID = 1007;
  static const int _irregularPatternID = 1008;
  static const int _symptomTrendID = 1009;
  static const int _weeklyInsightID = 1010;
  static const int _backupReminderID = 1011;

  /// Initialize smart notifications
  static Future<bool> initialize() async {
    return await NotificationService.initialize();
  }

  /// 🧠 Main Intelligence Engine - Analyzes data and schedules smart notifications
  static Future<void> runSmartAnalysis() async {
    if (!await NotificationService.areNotificationsEnabled()) return;

    try {
      debugPrint('🧠 Starting Smart Notification Analysis...');
      
      // Get user's recent data
      final cycleData = await FirebaseService.getCycles();
      final cycles = cycleData.map((c) => CycleData.fromFirestore(c)).toList();
      final dailyLogs = await _getDailyLogs();
      
      // Run all analysis modules
      await Future.wait([
        _analyzePredictivePatterns(cycles),
        _analyzeMoodAndEnergyPatterns(dailyLogs),
        _analyzeHealthTrends(cycles, dailyLogs),
        _scheduleMedicationReminders(cycles),
        _scheduleWellnessChecks(dailyLogs),
        _detectIrregularPatterns(cycles),
        _scheduleWeeklyInsights(cycles, dailyLogs),
      ]);
      
      debugPrint('✅ Smart Notification Analysis Complete');
    } catch (e) {
      debugPrint('❌ Error in smart analysis: $e');
    }
  }

  /// 🔮 Predictive Pattern Analysis
  static Future<void> _analyzePredictivePatterns(List<CycleData> cycles) async {
    if (cycles.length < 3) return;

    final predictions = _calculateAdvancedPredictions(cycles);
    
    // Enhanced cycle start prediction with confidence levels
    if (predictions['nextCycleStart'] != null) {
      final confidence = predictions['confidence'] ?? 0.0;
      final daysAway = predictions['nextCycleStart'].difference(DateTime.now()).inDays;
      
      if (daysAway >= 2 && daysAway <= 5) {
        String title, body;
        
        if (confidence > 0.8) {
          title = '🎯 High Confidence Prediction';
          body = 'Your cycle will likely start in $daysAway days (${(confidence * 100).toInt()}% confidence)';
        } else if (confidence > 0.6) {
          title = '📊 Cycle Prediction';
          body = 'Your cycle may start in $daysAway days. Track symptoms for better accuracy!';
        } else {
          title = '🤔 Uncertain Pattern';
          body = 'Your cycle data shows irregular patterns. Consider tracking more consistently.';
        }
        
        await _scheduleSmartNotification(
          id: _predictiveStartID,
          title: title,
          body: body,
          scheduledDate: DateTime.now().add(Duration(hours: 2)),
          category: _categoryPredictive,
          priority: confidence > 0.7 ? NotificationPriority.high : NotificationPriority.defaultPriority,
        );
      }
    }
  }

  /// 🧡 Mood and Energy Pattern Analysis
  static Future<void> _analyzeMoodAndEnergyPatterns(List<DailyLogEntry> dailyLogs) async {
    if (dailyLogs.length < 7) return;

    final recentLogs = dailyLogs.take(7).toList();
    final moodTrend = _calculateTrend(recentLogs.map((l) => l.mood?.toDouble() ?? 5.0).toList());
    final energyTrend = _calculateTrend(recentLogs.map((l) => l.energy?.toDouble() ?? 5.0).toList());
    
    // Detect concerning patterns
    if (moodTrend < -0.5 && energyTrend < -0.3) {
      await _scheduleSmartNotification(
        id: _moodPatternID,
        title: '💙 Wellness Check',
        body: 'I noticed your mood and energy have been declining. Consider some self-care activities today.',
        scheduledDate: DateTime.now().add(Duration(hours: 1)),
        category: _categoryWellness,
        priority: NotificationPriority.high,
      );
    }
    
    // Positive pattern recognition
    if (moodTrend > 0.5 && energyTrend > 0.3) {
      await _scheduleSmartNotification(
        id: _energyPatternID,
        title: '✨ Great Momentum!',
        body: 'Your mood and energy are trending upward! This might be a great time for new activities.',
        scheduledDate: DateTime.now().add(Duration(hours: 3)),
        category: _categoryInsights,
        priority: NotificationPriority.defaultPriority,
      );
    }
  }

  /// 🏥 Health Trends Analysis
  static Future<void> _analyzeHealthTrends(List<CycleData> cycles, List<DailyLogEntry> dailyLogs) async {
    final insights = <String>[];
    
    // Analyze cycle irregularity
    if (cycles.length >= 3) {
      final lengths = cycles.where((c) => c.lengthInDays > 0).map((c) => c.lengthInDays).toList();
      if (lengths.isNotEmpty) {
        final avgLength = lengths.reduce((a, b) => a + b) / lengths.length;
        final variance = lengths.map((l) => pow(l - avgLength, 2)).reduce((a, b) => a + b) / lengths.length;
        
        if (variance > 16) { // High variance in cycle length
          insights.add('Your cycle length varies significantly. Consider consulting with a healthcare provider.');
        }
      }
    }
    
    // Analyze pain patterns
    final recentPain = dailyLogs.take(14).where((l) => l.pain != null).map((l) => l.pain!).toList();
    if (recentPain.isNotEmpty) {
      final avgPain = recentPain.reduce((a, b) => a + b) / recentPain.length;
      if (avgPain > 7) {
        insights.add('Your pain levels have been consistently high. Consider tracking specific symptoms and discussing with a doctor.');
      }
    }
    
    if (insights.isNotEmpty) {
      await _scheduleSmartNotification(
        id: _healthInsightID,
        title: '🏥 Health Insight',
        body: insights.first,
        scheduledDate: DateTime.now().add(Duration(hours: 4)),
        category: _categoryHealth,
        priority: NotificationPriority.high,
      );
    }
  }

  /// 💊 Intelligent Medication Reminders
  static Future<void> _scheduleMedicationReminders(List<CycleData> cycles) async {
    if (cycles.isEmpty) return;
    
    // Predict when user might need pain medication based on cycle phase
    final currentCycle = cycles.firstWhere(
      (c) => c.endDate == null,
      orElse: () => cycles.first,
    );
    
    final daysSinceStart = DateTime.now().difference(currentCycle.startDate!).inDays;
    
    // Day 1-3: Likely to need pain relief
    if (daysSinceStart >= 0 && daysSinceStart <= 3) {
      await _scheduleSmartNotification(
        id: _medicationReminderID,
        title: '💊 Medication Reminder',
        body: 'Based on your cycle phase, you might want to have pain relief ready today.',
        scheduledDate: DateTime.now().add(Duration(hours: 2)),
        category: _categoryMedication,
        priority: NotificationPriority.defaultPriority,
      );
    }
    }

  /// 🌸 Wellness Check Scheduling
  static Future<void> _scheduleWellnessChecks(List<DailyLogEntry> dailyLogs) async {
    final lastLog = dailyLogs.isNotEmpty ? dailyLogs.first.date : DateTime.now().subtract(Duration(days: 2));
    final daysSinceLastLog = DateTime.now().difference(lastLog).inDays;
    
    if (daysSinceLastLog >= 3) {
      await _scheduleSmartNotification(
        id: _wellnessCheckID,
        title: '🌸 Wellness Check-in',
        body: 'It\'s been a few days since your last log. How are you feeling today?',
        scheduledDate: DateTime.now().add(Duration(hours: 1)),
        category: _categoryWellness,
        priority: NotificationPriority.defaultPriority,
      );
    }
  }

  /// 🚨 Irregular Pattern Detection
  static Future<void> _detectIrregularPatterns(List<CycleData> cycles) async {
    if (cycles.length < 3) return;
    
    // Detect very long or very short cycles
    final recentCycles = cycles.take(3).where((c) => c.lengthInDays > 0).toList();
    if (recentCycles.isNotEmpty) {
      final lengths = recentCycles.map((c) => c.lengthInDays).toList();
      final hasIrregular = lengths.any((l) => l < 21 || l > 35);
      
      if (hasIrregular) {
        await _scheduleSmartNotification(
          id: _irregularPatternID,
          title: '⚠️ Pattern Alert',
          body: 'Your recent cycles show irregular lengths. Consider tracking more details and consulting a healthcare provider.',
          scheduledDate: DateTime.now().add(Duration(hours: 6)),
          category: _categoryHealth,
          priority: NotificationPriority.high,
        );
      }
    }
  }

  /// 📊 Weekly Insights Summary
  static Future<void> _scheduleWeeklyInsights(List<CycleData> cycles, List<DailyLogEntry> dailyLogs) async {
    final now = DateTime.now();
    final isMonday = now.weekday == 1;
    final isMorning = now.hour >= 8 && now.hour <= 10;
    
    if (!isMonday || !isMorning) return;
    
    final insights = _generateWeeklyInsights(cycles, dailyLogs);
    
    if (insights.isNotEmpty) {
      await _scheduleSmartNotification(
        id: _weeklyInsightID,
        title: '📊 Your Weekly Insights',
        body: insights,
        scheduledDate: DateTime.now().add(Duration(minutes: 30)),
        category: _categoryInsights,
        priority: NotificationPriority.defaultPriority,
      );
    }
  }

  /// 💡 Helper Methods

  static Future<List<DailyLogEntry>> _getDailyLogs() async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: 30));
      return await FirebaseService.getDailyLogs(
        startDate: startDate,
        endDate: endDate,
      ).then((logs) => logs.map((log) => _convertToDailyLogEntry(log)).toList());
    } catch (e) {
      debugPrint('Error fetching daily logs: $e');
      return [];
    }
  }

  static Map<String, dynamic> _calculateAdvancedPredictions(List<CycleData> cycles) {
    if (cycles.length < 3) return {};
    
    final completedCycles = cycles.where((c) => c.lengthInDays > 0).toList();
    if (completedCycles.length < 3) return {};
    
    final lengths = completedCycles.take(6).map((c) => c.lengthInDays).toList();
    final avgLength = lengths.reduce((a, b) => a + b) / lengths.length;
    
    // Calculate confidence based on consistency
    final variance = lengths.map((l) => pow(l - avgLength, 2)).reduce((a, b) => a + b) / lengths.length;
    final confidence = max(0.0, min(1.0, 1.0 - (variance / 25.0))); // Normalize variance to confidence
    
    // Find most recent cycle end
    final lastCycle = completedCycles.first;
    final nextStart = lastCycle.endDate?.add(Duration(days: avgLength.round()));
    
    return {
      'nextCycleStart': nextStart,
      'averageLength': avgLength.round(),
      'confidence': confidence,
      'variance': variance,
    };
  }

  static double _calculateTrend(List<double> values) {
    if (values.length < 2) return 0.0;
    
    final n = values.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumXX = 0;
    
    for (int i = 0; i < n; i++) {
      sumX += i;
      sumY += values[i];
      sumXY += i * values[i];
      sumXX += i * i;
    }
    
    final slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    return slope.isNaN ? 0.0 : slope;
  }

  static String _generateWeeklyInsights(List<CycleData> cycles, List<DailyLogEntry> dailyLogs) {
    final insights = <String>[];
    
    // Cycle insights
    if (cycles.isNotEmpty) {
      final completedCycles = cycles.where((c) => c.lengthInDays > 0).toList();
      if (completedCycles.isNotEmpty) {
        final avgLength = completedCycles
            .map((c) => c.lengthInDays)
            .fold(0, (a, b) => a + b) / completedCycles.length;
        insights.add('Average cycle: ${avgLength.round()} days');
      }
    }
    
    // Mood insights
    final recentMoods = dailyLogs.take(7).where((l) => l.mood != null).map((l) => l.mood!).toList();
    if (recentMoods.isNotEmpty) {
      final avgMood = recentMoods.reduce((a, b) => a + b) / recentMoods.length;
      insights.add('Weekly mood avg: ${avgMood.toStringAsFixed(1)}/10');
    }
    
    return insights.join(' • ');
  }

  static Future<void> _scheduleSmartNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String category,
    NotificationPriority priority = NotificationPriority.defaultPriority,
    String? payload,
  }) async {
    // Use enhanced notification details based on category
    final details = _buildNotificationDetails(category, priority);
    
    try {
      await FlutterLocalNotificationsPlugin().zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload ?? category,
      );
      
      debugPrint('🔔 Scheduled smart notification: $title');
    } catch (e) {
      debugPrint('❌ Error scheduling smart notification: $e');
    }
  }

  static NotificationDetails _buildNotificationDetails(String category, NotificationPriority priority) {
    String channelId, channelName, channelDescription;
    Importance importance;
    Priority androidPriority;
    
    switch (category) {
      case _categoryPredictive:
        channelId = 'predictive_notifications';
        channelName = 'Predictive Insights';
        channelDescription = 'AI-powered cycle predictions and forecasts';
        importance = Importance.high;
        androidPriority = Priority.high;
        break;
      case _categoryHealth:
        channelId = 'health_alerts';
        channelName = 'Health Alerts';
        channelDescription = 'Important health pattern alerts and recommendations';
        importance = Importance.max;
        androidPriority = Priority.max;
        break;
      case _categoryMedication:
        channelId = 'medication_reminders';
        channelName = 'Medication Reminders';
        channelDescription = 'Smart medication and supplement reminders';
        importance = Importance.high;
        androidPriority = Priority.high;
        break;
      case _categoryWellness:
        channelId = 'wellness_checks';
        channelName = 'Wellness Check-ins';
        channelDescription = 'Gentle wellness reminders and check-ins';
        importance = Importance.defaultImportance;
        androidPriority = Priority.defaultPriority;
        break;
      case _categoryInsights:
        channelId = 'insights';
        channelName = 'Personal Insights';
        channelDescription = 'Personalized health insights and trends';
        importance = Importance.defaultImportance;
        androidPriority = Priority.defaultPriority;
        break;
      default:
        channelId = 'smart_notifications';
        channelName = 'Smart Notifications';
        channelDescription = 'AI-powered health notifications';
        importance = Importance.defaultImportance;
        androidPriority = Priority.defaultPriority;
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: importance,
      priority: androidPriority,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: const BigTextStyleInformation(''),
      when: DateTime.now().millisecondsSinceEpoch,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.active,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );
  }

  /// Cancel specific smart notification category
  static Future<void> cancelSmartNotifications(String category) async {
    // Cancel notifications by category (would need to track IDs by category in production)
    switch (category) {
      case _categoryPredictive:
        await NotificationService.cancelNotification(_predictiveStartID);
        await NotificationService.cancelNotification(_predictiveEndID);
        break;
      case _categoryHealth:
        await NotificationService.cancelNotification(_healthInsightID);
        await NotificationService.cancelNotification(_irregularPatternID);
        break;
      // Add other categories as needed
    }
  }

  /// Convert Firestore data to DailyLogEntry
  static DailyLogEntry _convertToDailyLogEntry(Map<String, dynamic> data) {
    DateTime parseDate(String? dateString) {
      if (dateString == null) return DateTime.now();
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        return DateTime.now();
      }
    }

    return DailyLogEntry(
      id: data['id']?.toString() ?? '',
      date: parseDate(data['date']?.toString()),
      mood: data['mood']?.toDouble(),
      energy: data['energy']?.toDouble(),
      pain: data['pain']?.toDouble(),
      symptoms: List<String>.from(data['symptoms'] ?? []),
      notes: data['notes']?.toString() ?? '',
      createdAt: parseDate(data['created_at']?.toString()),
      updatedAt: parseDate(data['updated_at']?.toString()),
    );
  }

  /// Update notification preferences and reschedule
  static Future<void> updateSmartPreferences(Map<String, bool> preferences) async {
    // Cancel disabled notification categories
    for (final entry in preferences.entries) {
      if (!entry.value) {
        await cancelSmartNotifications(entry.key);
      }
    }
    
    // Run analysis again to reschedule enabled notifications
    if (preferences.values.any((enabled) => enabled)) {
      await runSmartAnalysis();
    }
  }
}

/// Notification priority levels
enum NotificationPriority {
  min,
  low,
  defaultPriority,
  high,
  max,
}
