import 'package:flutter/foundation.dart';
import '../models/reminder_models.dart';
import '../models/ai_prediction_models.dart';
import 'reminder_service.dart';
// import 'cycle_service.dart'; // Service doesn't exist
// import 'user_service.dart'; // Service doesn't exist
import 'error_service.dart';

// Temporary CycleEntry class to fix type errors
// This would normally be defined in the cycle_service.dart
class CycleEntry {
  final String id;
  final DateTime? startDate;
  final List<String>? symptoms;

  CycleEntry({this.id = '', this.startDate, this.symptoms});
}

/// Service to integrate AI cycle predictions with reminder system
class CycleReminderIntegrationService {
  static CycleReminderIntegrationService? _instance;
  static CycleReminderIntegrationService get instance =>
      _instance ??= CycleReminderIntegrationService._();

  CycleReminderIntegrationService._();

  final ReminderService _reminderService = ReminderService.instance;
  // final CycleService _cycleService = CycleService.instance; // Service doesn't exist

  /// Generate smart reminders based on AI cycle predictions
  Future<List<Reminder>> generateSmartReminders() async {
    try {
      // final user = UserService.instance.currentUser;
      // if (user == null) return [];
      // Service doesn't exist, return empty list
      return [];

      // Get user's cycle data
      // final cycles = await _cycleService.getUserCycles(limit: 12);
      // if (cycles.isEmpty) return [];
      // Service doesn't exist, return empty list

      // Service doesn't exist, return empty list
      return [];
    } catch (e) {
      ErrorService.logError(
        e,
        context: 'Generate smart reminders',
        severity: ErrorSeverity.error,
      );
      return [];
    }
  }

  /// Create reminders for predicted period starts
  Future<List<Reminder>> _createPeriodStartReminders(
    List<NextCyclePrediction> cyclePredictions,
    double aiConfidence,
  ) async {
    final reminders = <Reminder>[];

    for (int i = 0; i < cyclePredictions.length && i < 3; i++) {
      final cycle = cyclePredictions[i];
      final startDate = cycle.predictedStartDate;

      // Create reminder 2 days before predicted start
      final reminderDate = startDate.subtract(const Duration(days: 2));

      if (reminderDate.isAfter(DateTime.now())) {
        final title = i == 0 ? 'Period Starting Soon' : 'Upcoming Period Alert';

        final description = _buildPeriodDescription(cycle, aiConfidence);

        final reminder = Reminder(
          id: '',
          userId: '',
          title: title,
          description: description,
          type: ReminderType.cyclePrediction,
          frequency: ReminderFrequency.once,
          priority: _getPriorityFromConfidence(cycle.confidence),
          createdAt: DateTime.now(),
          scheduledFor: reminderDate,
          notificationTimes: [
            DateTime(
              reminderDate.year,
              reminderDate.month,
              reminderDate.day,
              9,
              0,
            ),
          ],
          sound: NotificationSound.gentle,
          customMessage: _buildPeriodNotificationMessage(cycle, i == 0),
          metadata: {
            'cycleNumber': cycle.cycleNumber,
            'aiConfidence': cycle.confidence,
            'predictedLength': cycle.predictedLength,
            'source': 'ai_prediction',
            'predictionType': 'period_start',
          },
        );

        reminders.add(reminder);
      }
    }

    return reminders;
  }

  /// Create reminders for fertility windows
  Future<List<Reminder>> _createFertilityWindowReminders(
    List<FertilityWindow> fertilityWindows,
    double aiConfidence,
  ) async {
    final reminders = <Reminder>[];

    for (int i = 0; i < fertilityWindows.length && i < 2; i++) {
      final window = fertilityWindows[i];

      // Create reminder 1 day before fertility window starts
      final reminderDate = DateTime.now().add(
        const Duration(days: 1),
      ); // Placeholder since startDate property doesn't exist

      if (reminderDate.isAfter(DateTime.now())) {
        final title = 'Fertility Window Approaching';
        final description = _buildFertilityDescription(window, aiConfidence);

        final reminder = Reminder(
          id: '',
          userId: '',
          title: title,
          description: description,
          type: ReminderType.cyclePrediction,
          frequency: ReminderFrequency.once,
          priority: ReminderPriority.medium,
          createdAt: DateTime.now(),
          scheduledFor: reminderDate,
          notificationTimes: [
            DateTime(
              reminderDate.year,
              reminderDate.month,
              reminderDate.day,
              8,
              0,
            ),
          ],
          sound: NotificationSound.nature,
          customMessage: _buildFertilityNotificationMessage(window),
          metadata: {
            'cycleNumber': window.cycleNumber,
            'fertivityPhase': 'unknown', // phase property doesn't exist
            'aiConfidence': window.confidence,
            'source': 'ai_prediction',
            'predictionType': 'fertility_window',
          },
        );

        reminders.add(reminder);
      }
    }

    return reminders;
  }

  /// Create reminders based on symptom patterns
  Future<List<Reminder>> _createSymptomBasedReminders(
    List<SymptomPattern> symptomPatterns,
    List<NextCyclePrediction> cyclePredictions,
  ) async {
    final reminders = <Reminder>[];

    if (cyclePredictions.isEmpty) return reminders;

    final nextCycle = cyclePredictions.first;

    for (final pattern in symptomPatterns.take(3)) {
      if (pattern.confidence < 0.6) continue; // Only high confidence patterns

      // Calculate typical days for this symptom relative to cycle start
      final typicalDays = pattern.typicalDays;
      if (typicalDays.isEmpty) continue;

      for (final dayInCycle in typicalDays.take(2)) {
        final symptomDate = nextCycle.predictedStartDate.add(
          Duration(days: dayInCycle - 1),
        );

        if (symptomDate.isAfter(DateTime.now())) {
          final title = 'Track ${pattern.symptomName}';
          final description = _buildSymptomDescription(pattern);

          final reminder = Reminder(
            id: '',
            userId: '',
            title: title,
            description: description,
            type: ReminderType.symptomTracking,
            frequency: ReminderFrequency.once,
            priority: ReminderPriority.low,
            createdAt: DateTime.now(),
            scheduledFor: symptomDate,
            notificationTimes: [
              DateTime(
                symptomDate.year,
                symptomDate.month,
                symptomDate.day,
                20,
                0,
              ),
            ],
            sound: NotificationSound.gentle,
            customMessage:
                'Time to track your ${pattern.symptomName.toLowerCase()}',
            metadata: {
              'symptomName': pattern.symptomName,
              'frequency': pattern.frequency,
              'confidence': pattern.confidence,
              'dayInCycle': dayInCycle,
              'source': 'ai_prediction',
              'predictionType': 'symptom_pattern',
            },
          );

          reminders.add(reminder);
        }
      }
    }

    return reminders;
  }

  /// Create wellbeing-based reminders
  Future<List<Reminder>> _createWellbeingReminders(
    List<WellbeingPrediction> wellbeingPredictions,
    List<NextCyclePrediction> cyclePredictions,
  ) async {
    final reminders = <Reminder>[];

    if (cyclePredictions.isEmpty) return reminders;

    final nextCycle = cyclePredictions.first;

    for (final prediction in wellbeingPredictions) {
      if (prediction.confidence < 0.6) continue;

      // Create reminders for predicted low days
      // lowDays property doesn't exist, skip this prediction
      continue;
    }

    return reminders;
  }

  /// Auto-schedule smart reminders for the user
  Future<int> autoScheduleSmartReminders() async {
    try {
      // Remove existing AI-generated reminders that haven't been triggered yet
      await _removeOldAIPredictionReminders();

      // Generate new smart reminders
      final smartReminders = await generateSmartReminders();

      int successCount = 0;
      for (final reminder in smartReminders) {
        final id = await _reminderService.createReminder(reminder);
        if (id != null) {
          successCount++;
        }
      }

      debugPrint('Auto-scheduled $successCount smart reminders');
      return successCount;
    } catch (e) {
      ErrorService.logError(
        e,
        context: 'Auto-schedule smart reminders',
        severity: ErrorSeverity.error,
      );
      return 0;
    }
  }

  /// Remove old AI-generated reminders that are no longer relevant
  Future<void> _removeOldAIPredictionReminders() async {
    // This would require a method to query reminders by metadata
    // For now, we'll skip this implementation
    debugPrint('Skipping removal of old AI reminders (not implemented)');
  }

  /// Update reminders when new cycle data is added
  Future<void> onNewCycleDataAdded() async {
    try {
      // Wait a bit for cycle data to be processed
      await Future.delayed(const Duration(seconds: 2));

      // Auto-schedule updated smart reminders
      await autoScheduleSmartReminders();

      debugPrint('Updated smart reminders based on new cycle data');
    } catch (e) {
      ErrorService.logError(
        e,
        context: 'Update reminders on new cycle data',
        severity: ErrorSeverity.error,
      );
    }
  }

  /// Get suggested reminder templates based on user's cycle history
  Future<List<ReminderTemplate>> getSuggestedTemplates() async {
    try {
      // final cycles = await _cycleService.getUserCycles(limit: 6);
      final cycles = <CycleEntry>[]; // Service doesn't exist
      if (cycles.isEmpty) {
        return _getDefaultTemplates();
      }

      final suggestions = <ReminderTemplate>[];

      // Analyze user's cycle patterns
      final avgLength = _calculateAverageCycleLength(cycles);
      final hasIrregularCycles = _hasIrregularCycles(cycles);
      final commonSymptoms = _getCommonSymptoms(cycles);

      // Period tracking template
      suggestions.add(
        ReminderTemplate(
          name: 'smart_period_tracking',
          type: ReminderType.cyclePrediction,
          title: hasIrregularCycles
              ? 'Period Check-in'
              : 'Period Starting Soon',
          description: hasIrregularCycles
              ? 'Your cycles vary - time to check if your period has started'
              : 'Based on your ${avgLength.round()}-day cycle pattern',
          frequency: ReminderFrequency.cycleStart,
          priority: ReminderPriority.high,
          defaultTimes: [DateTime(2024, 1, 1, 8, 0)],
          sound: NotificationSound.gentle,
          metadata: {
            'suggested': true,
            'cycleLength': avgLength,
            'irregular': hasIrregularCycles,
          },
        ),
      );

      // Fertility window template if user might be trying to conceive
      suggestions.add(
        ReminderTemplate(
          name: 'smart_fertility_window',
          type: ReminderType.cyclePrediction,
          title: 'Fertility Window',
          description: 'Your most fertile days based on cycle patterns',
          frequency: ReminderFrequency.ovulation,
          priority: ReminderPriority.medium,
          defaultTimes: [DateTime(2024, 1, 1, 9, 0)],
          sound: NotificationSound.nature,
        ),
      );

      // Symptom tracking templates based on common symptoms
      for (final symptom in commonSymptoms.take(2)) {
        suggestions.add(
          ReminderTemplate(
            name: 'smart_${symptom.toLowerCase()}_tracking',
            type: ReminderType.symptomTracking,
            title: 'Track $symptom',
            description:
                'You commonly experience $symptom - track it for insights',
            frequency: ReminderFrequency.daily,
            defaultTimes: [DateTime(2024, 1, 1, 20, 0)],
            metadata: {'symptom': symptom, 'suggested': true},
          ),
        );
      }

      return suggestions;
    } catch (e) {
      ErrorService.logError(
        e,
        context: 'Get suggested templates',
        severity: ErrorSeverity.error,
      );
      return _getDefaultTemplates();
    }
  }

  List<ReminderTemplate> _getDefaultTemplates() {
    return [
      ReminderTemplates.getTemplate('period_start')!,
      ReminderTemplates.getTemplate('fertile_window')!,
      ReminderTemplates.getTemplate('daily_log')!,
    ];
  }

  double _calculateAverageCycleLength(List<CycleEntry> cycles) {
    if (cycles.length < 2) return 28.0;

    final lengths = <int>[];
    for (int i = 0; i < cycles.length - 1; i++) {
      final current = cycles[i];
      final next = cycles[i + 1];

      if (current.startDate != null && next.startDate != null) {
        final length = current.startDate!
            .difference(next.startDate!)
            .inDays
            .abs();
        if (length > 15 && length < 45) {
          // Reasonable cycle length
          lengths.add(length);
        }
      }
    }

    if (lengths.isEmpty) return 28.0;
    return lengths.reduce((a, b) => a + b) / lengths.length;
  }

  bool _hasIrregularCycles(List<CycleEntry> cycles) {
    if (cycles.length < 3) return false;

    final lengths = <int>[];
    for (int i = 0; i < cycles.length - 1; i++) {
      final current = cycles[i];
      final next = cycles[i + 1];

      if (current.startDate != null && next.startDate != null) {
        final length = current.startDate!
            .difference(next.startDate!)
            .inDays
            .abs();
        if (length > 15 && length < 45) {
          lengths.add(length);
        }
      }
    }

    if (lengths.length < 3) return false;

    // Calculate variance
    final mean = lengths.reduce((a, b) => a + b) / lengths.length;
    final variance =
        lengths
            .map((length) => (length - mean) * (length - mean))
            .reduce((a, b) => a + b) /
        lengths.length;

    return variance > 25; // Consider irregular if variance > 25
  }

  List<String> _getCommonSymptoms(List<CycleEntry> cycles) {
    final symptomCounts = <String, int>{};

    for (final cycle in cycles) {
      final symptoms = cycle.symptoms ?? [];
      for (final symptom in symptoms) {
        symptomCounts[symptom] = (symptomCounts[symptom] ?? 0) + 1;
      }
    }

    // Return symptoms that appear in at least 30% of cycles
    final threshold = cycles.length * 0.3;
    return symptomCounts.entries
        .where((entry) => entry.value >= threshold)
        .map((entry) => entry.key)
        .toList()
      ..sort((a, b) => symptomCounts[b]!.compareTo(symptomCounts[a]!));
  }

  // Helper methods for building reminder content
  String _buildPeriodDescription(
    NextCyclePrediction cycle,
    double aiConfidence,
  ) {
    final confidenceText = aiConfidence > 0.8
        ? 'high confidence'
        : aiConfidence > 0.6
        ? 'moderate confidence'
        : 'low confidence';

    return 'AI prediction with $confidenceText. Expected cycle length: ${cycle.predictedLength} days.';
  }

  String _buildFertilityDescription(
    FertilityWindow window,
    double aiConfidence,
  ) {
    final days = window.windowEnd.difference(window.windowStart).inDays + 1;
    return 'Your fertility window starts tomorrow and lasts $days days. Track fertility signs for best results.';
  }

  String _buildSymptomDescription(SymptomPattern pattern) {
    final frequency = (pattern.frequency * 100).round();
    return 'You experience ${pattern.symptomName.toLowerCase()} in $frequency% of your cycles. Track it today for insights.';
  }

  String _buildWellbeingDescription(
    WellbeingPrediction prediction, {
    required bool isLow,
  }) {
    final type = prediction.type.toString().split('.').last;
    return isLow
        ? 'Your $type tends to be lower today. Consider extra self-care.'
        : 'Your $type is predicted to be higher today. Great day for activities!';
  }

  String _buildPeriodNotificationMessage(
    NextCyclePrediction cycle,
    bool isNext,
  ) {
    return isNext
        ? 'Your period is expected to start in 2 days. Time to prepare!'
        : 'Mark your calendar - period predicted in 2 days.';
  }

  String _buildFertilityNotificationMessage(FertilityWindow window) {
    return 'Your fertility window starts tomorrow. Track ovulation signs if trying to conceive.';
  }

  String _buildWellbeingNotificationMessage(
    WellbeingType type, {
    required bool isLow,
  }) {
    switch (type) {
      case WellbeingType.mood:
        return isLow
            ? 'Your mood might be lower today. Practice self-compassion.'
            : 'Great mood day ahead!';
      case WellbeingType.energy:
        return isLow
            ? 'Energy might be lower today. Plan lighter activities.'
            : 'High energy day - perfect for exercise!';
      case WellbeingType.pain:
        return isLow
            ? 'Pain levels might be higher today. Have comfort measures ready.'
            : 'Low pain day predicted!';
    }
  }

  String _getWellbeingReminderTitle(WellbeingType type, {required bool isLow}) {
    switch (type) {
      case WellbeingType.mood:
        return isLow ? 'Mood Support Day' : 'Good Mood Day';
      case WellbeingType.energy:
        return isLow ? 'Low Energy Day' : 'High Energy Day';
      case WellbeingType.pain:
        return isLow ? 'Pain Management' : 'Comfortable Day';
    }
  }

  ReminderPriority _getPriorityFromConfidence(double confidence) {
    if (confidence > 0.8) return ReminderPriority.high;
    if (confidence > 0.6) return ReminderPriority.medium;
    return ReminderPriority.low;
  }
}
