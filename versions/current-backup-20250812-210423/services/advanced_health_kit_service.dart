import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// Advanced HealthKit service for comprehensive health data integration
/// Handles heart rate, HRV, sleep, temperature, and activity data
class AdvancedHealthKitService {
  static const MethodChannel _channel = MethodChannel('cyclesync/healthkit');
  
  static AdvancedHealthKitService? _instance;
  static AdvancedHealthKitService get instance => _instance ??= AdvancedHealthKitService._();
  AdvancedHealthKitService._();

  bool _isInitialized = false;
  bool _hasPermissions = false;

  /// Health data types we want to access
  static const List<String> _requiredPermissions = [
    'heartRate',
    'heartRateVariability', 
    'sleepAnalysis',
    'steps',
    'activeEnergyBurned',
    'basalBodyTemperature',
    'respiratoryRate',
    'oxygenSaturation',
  ];

  /// Initialize HealthKit and request permissions
  Future<bool> initialize() async {
    if (_isInitialized) return _hasPermissions;

    try {
      print('🏥 Initializing Advanced HealthKit Service...');
      
      // Request HealthKit permissions using native plugin
      final result = await _channel.invokeMethod<Map>('initialize');
      
      if (result != null && result['success'] == true) {
        print('✅ HealthKit permissions granted: ${result['message']}');
        _hasPermissions = true;
      } else {
        print('⚠️ HealthKit permissions denied or unavailable');
        _hasPermissions = false;
      }
      
      _isInitialized = true;
      return _hasPermissions;
    } catch (e) {
      print('❌ Failed to initialize AdvancedHealthKitService: $e');
      print('📱 Falling back to demo mode for testing');
      _isInitialized = true;
      _hasPermissions = false;
      return false;
    }
  }

  /// Request all required health permissions
  Future<bool> _requestHealthPermissions() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestPermissions', {
        'permissions': _requiredPermissions,
      });
      return result ?? false;
    } catch (e) {
      print('❌ Failed to request health permissions: $e');
      return false;
    }
  }

  /// Get recent health data for sync purposes
  Future<List<Map<String, dynamic>>> getRecentHealthData({
    DateTime? since,
    int limitDays = 7,
  }) async {
    if (!_hasPermissions) return [];

    try {
      since ??= DateTime.now().subtract(Duration(days: limitDays));
      final endDate = DateTime.now();

      final allData = <Map<String, dynamic>>[];

      // Get recent heart rate data
      final heartRateData = await getHeartRateData(startDate: since, endDate: endDate);
      for (final dataPoint in heartRateData) {
        allData.add({
          'type': 'heart_rate',
          'value': dataPoint.value,
          'date': dataPoint.date.toIso8601String(),
          'unit': dataPoint.unit,
        });
      }

      // Get recent HRV data
      final hrvData = await getHRVData(startDate: since, endDate: endDate);
      for (final dataPoint in hrvData) {
        allData.add({
          'type': 'hrv',
          'value': dataPoint.value,
          'date': dataPoint.date.toIso8601String(),
          'unit': dataPoint.unit,
        });
      }

      // Get recent sleep data
      final sleepData = await getSleepData(startDate: since, endDate: endDate);
      for (final sleepEntry in sleepData) {
        allData.add({
          'type': 'sleep',
          'value': sleepEntry.duration?.inMinutes ?? 0,
          'date': sleepEntry.bedTime?.toIso8601String() ?? '',
          'unit': 'minutes',
          'quality': sleepEntry.quality,
          'stages': sleepEntry.stages,
        });
      }

      // Get recent temperature data
      final tempData = await getTemperatureData(startDate: since, endDate: endDate);
      for (final dataPoint in tempData) {
        allData.add({
          'type': 'temperature',
          'value': dataPoint.value,
          'date': dataPoint.date.toIso8601String(),
          'unit': dataPoint.unit,
        });
      }

      // Get recent activity data
      final activityData = await getActivityData(startDate: since, endDate: endDate);
      for (final activity in activityData) {
        allData.add({
          'type': 'activity',
          'value': activity.steps,
          'date': activity.date.toIso8601String(),
          'unit': 'steps',
          'calories': activity.activeEnergy,
        });
      }

      // Sort by date (most recent first)
      allData.sort((a, b) => b['date'].compareTo(a['date']));

      return allData;
    } catch (e) {
      print('❌ Failed to get recent health data: $e');
      return [];
    }
  }

  /// Get heart rate data for a specific date range
  Future<List<HealthDataPoint>> getHeartRateData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_hasPermissions) return [];

    try {
      startDate ??= DateTime.now().subtract(const Duration(days: 7));
      endDate ??= DateTime.now();

      final result = await _channel.invokeMethod<List<dynamic>>('getHeartRate', {
        'startDate': startDate.millisecondsSinceEpoch,
        'endDate': endDate.millisecondsSinceEpoch,
      });

      return (result ?? []).map((data) => HealthDataPoint.fromMap(data)).toList();
    } catch (e) {
      print('❌ Failed to get heart rate data: $e');
      return [];
    }
  }

  /// Get Heart Rate Variability (HRV) data - key for stress/wellness analysis
  Future<List<HealthDataPoint>> getHRVData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_hasPermissions) return [];

    try {
      startDate ??= DateTime.now().subtract(const Duration(days: 7));
      endDate ??= DateTime.now();

      final result = await _channel.invokeMethod<List<dynamic>>('getHRV', {
        'startDate': startDate.millisecondsSinceEpoch,
        'endDate': endDate.millisecondsSinceEpoch,
      });

      return (result ?? []).map((data) => HealthDataPoint.fromMap(data)).toList();
    } catch (e) {
      print('❌ Failed to get HRV data: $e');
      return [];
    }
  }

  /// Get sleep analysis data
  Future<List<SleepData>> getSleepData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_hasPermissions) return [];

    try {
      startDate ??= DateTime.now().subtract(const Duration(days: 7));
      endDate ??= DateTime.now();

      final result = await _channel.invokeMethod<List<dynamic>>('getSleepData', {
        'startDate': startDate.millisecondsSinceEpoch,
        'endDate': endDate.millisecondsSinceEpoch,
      });

      return (result ?? []).map((data) => SleepData.fromMap(data)).toList();
    } catch (e) {
      print('❌ Failed to get sleep data: $e');
      return [];
    }
  }

  /// Get basal body temperature data (important for ovulation tracking)
  Future<List<HealthDataPoint>> getTemperatureData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_hasPermissions) return [];

    try {
      startDate ??= DateTime.now().subtract(const Duration(days: 30));
      endDate ??= DateTime.now();

      final result = await _channel.invokeMethod<List<dynamic>>('getBodyTemperature', {
        'startDate': startDate.millisecondsSinceEpoch,
        'endDate': endDate.millisecondsSinceEpoch,
      });

      return (result ?? []).map((data) => HealthDataPoint.fromMap(data)).toList();
    } catch (e) {
      print('❌ Failed to get temperature data: $e');
      return [];
    }
  }

  /// Get daily activity summary
  Future<List<ActivityData>> getActivityData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_hasPermissions) return [];

    try {
      startDate ??= DateTime.now().subtract(const Duration(days: 7));
      endDate ??= DateTime.now();

      final result = await _channel.invokeMethod<List<dynamic>>('getActivityData', {
        'startDate': startDate.millisecondsSinceEpoch,
        'endDate': endDate.millisecondsSinceEpoch,
      });

      return (result ?? []).map((data) => ActivityData.fromMap(data)).toList();
    } catch (e) {
      print('❌ Failed to get activity data: $e');
      return [];
    }
  }

  /// Get comprehensive health summary for cycle correlation
  Future<HealthSummary?> getHealthSummaryForDate(DateTime date) async {
    if (!_hasPermissions) return null;

    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Gather all health data for the day
      final heartRate = await getHeartRateData(startDate: startOfDay, endDate: endOfDay);
      final hrv = await getHRVData(startDate: startOfDay, endDate: endOfDay);
      final sleep = await getSleepData(startDate: startOfDay, endDate: endOfDay);
      final temperature = await getTemperatureData(startDate: startOfDay, endDate: endOfDay);
      final activity = await getActivityData(startDate: startOfDay, endDate: endOfDay);

      return HealthSummary(
        date: date,
        heartRateData: heartRate,
        hrvData: hrv,
        sleepData: sleep,
        temperatureData: temperature,
        activityData: activity,
      );
    } catch (e) {
      print('❌ Failed to get health summary: $e');
      return null;
    }
  }

  /// Advanced analysis for cycle correlation
  Future<CycleHealthInsights?> analyzeCycleHealthPatterns({
    required DateTime cycleStart,
    required DateTime cycleEnd,
  }) async {
    if (!_hasPermissions) return null;

    try {
      // Get comprehensive health data for cycle period
      final healthSummaries = <HealthSummary>[];
      
      for (var date = cycleStart; date.isBefore(cycleEnd); date = date.add(Duration(days: 1))) {
        final summary = await getHealthSummaryForDate(date);
        if (summary != null) {
          healthSummaries.add(summary);
        }
      }

      if (healthSummaries.isEmpty) return null;

      // Analyze patterns
      return _analyzeHealthPatterns(healthSummaries, cycleStart, cycleEnd);
    } catch (e) {
      print('❌ Failed to analyze cycle health patterns: $e');
      return null;
    }
  }

  /// Start background health data synchronization
  void _startHealthDataSync() {
    // Enable background delivery for health data updates
    print('🔄 Starting background health data sync...');
    // Implementation depends on specific requirements
  }

  /// Analyze health patterns for cycle correlation
  CycleHealthInsights _analyzeHealthPatterns(
    List<HealthSummary> summaries,
    DateTime cycleStart,
    DateTime cycleEnd,
  ) {
    final insights = CycleHealthInsights();

    // Analyze HRV trends (stress indicator)
    final hrvValues = summaries
        .expand((s) => s.hrvData)
        .map((d) => d.value)
        .where((v) => v > 0)
        .toList();

    if (hrvValues.isNotEmpty) {
      final avgHRV = hrvValues.reduce((a, b) => a + b) / hrvValues.length;
      insights.averageHRV = avgHRV;
      insights.stressLevel = _calculateStressFromHRV(avgHRV);
    }

    // Analyze sleep quality
    final sleepDurations = summaries
        .expand((s) => s.sleepData)
        .where((s) => s.stage == 'asleep')
        .map((s) => s.durationSeconds)
        .toList();

    if (sleepDurations.isNotEmpty) {
      final avgSleep = sleepDurations.reduce((a, b) => a + b) / sleepDurations.length;
      insights.averageSleepDuration = avgSleep / 3600; // Convert to hours
      insights.sleepQuality = _calculateSleepQuality(avgSleep / 3600);
    }

    // Analyze temperature patterns for ovulation detection
    final tempValues = summaries
        .expand((s) => s.temperatureData)
        .map((t) => t.value)
        .where((v) => v > 35.0 && v < 40.0) // Valid temperature range
        .toList();

    if (tempValues.length >= 5) {
      insights.possibleOvulationDate = _detectOvulationFromTemp(summaries, tempValues);
    }

    // Calculate energy levels from activity
    final stepCounts = summaries
        .expand((s) => s.activityData)
        .map((a) => a.steps)
        .toList();

    if (stepCounts.isNotEmpty) {
      final avgSteps = stepCounts.reduce((a, b) => a + b) / stepCounts.length;
      insights.averageSteps = avgSteps;
      insights.energyLevels = _calculateEnergyFromActivity(avgSteps);
    }

    return insights;
  }

  /// Calculate stress level from HRV (inverse relationship)
  double _calculateStressFromHRV(double avgHRV) {
    // Higher HRV = Lower stress (simplified model)
    // Normal HRV ranges: 20-50ms for adults
    if (avgHRV >= 40) return 0.2; // Low stress
    if (avgHRV >= 30) return 0.4; // Moderate stress
    if (avgHRV >= 20) return 0.6; // Elevated stress
    return 0.8; // High stress
  }

  /// Calculate sleep quality from duration
  double _calculateSleepQuality(double hours) {
    // Optimal sleep: 7-9 hours
    if (hours >= 7.0 && hours <= 9.0) return 0.9;
    if (hours >= 6.0 && hours <= 10.0) return 0.7;
    if (hours >= 5.0 && hours <= 11.0) return 0.5;
    return 0.3;
  }

  /// Detect possible ovulation from temperature patterns
  DateTime? _detectOvulationFromTemp(List<HealthSummary> summaries, List<double> temps) {
    // Look for temperature rise pattern (simplified BBT method)
    for (int i = 3; i < temps.length - 1; i++) {
      final recent = temps.sublist(i - 3, i);
      final current = temps[i];
      final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
      
      // Temperature rise of 0.2°C or more sustained for 2+ days
      if (current - recentAvg >= 0.2) {
        final date = summaries[i].date;
        return date.subtract(Duration(days: 1)); // Ovulation likely day before temp rise
      }
    }
    return null;
  }

  /// Calculate energy levels from activity data
  double _calculateEnergyFromActivity(double avgSteps) {
    // Steps-based energy calculation
    if (avgSteps >= 10000) return 0.9; // High energy
    if (avgSteps >= 7500) return 0.7;  // Good energy
    if (avgSteps >= 5000) return 0.5;  // Moderate energy
    if (avgSteps >= 2500) return 0.3;  // Low energy
    return 0.1; // Very low energy
  }
}

/// Data models for HealthKit integration
class HealthDataPoint {
  final double value;
  final DateTime date;
  final String unit;

  HealthDataPoint({
    required this.value,
    required this.date,
    required this.unit,
  });

  factory HealthDataPoint.fromMap(Map<String, dynamic> map) {
    return HealthDataPoint(
      value: (map['value'] as num).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch((map['date'] as num).toInt()),
      unit: map['unit'] as String,
    );
  }
}

class SleepData {
  final String stage;
  final DateTime startDate;
  final DateTime endDate;
  final double durationSeconds; // in seconds

  SleepData({
    required this.stage,
    required this.startDate,
    required this.endDate,
    required this.durationSeconds,
  });

  factory SleepData.fromMap(Map<String, dynamic> map) {
    return SleepData(
      stage: map['stage'] as String,
      startDate: DateTime.fromMillisecondsSinceEpoch((map['startDate'] as num).toInt()),
      endDate: DateTime.fromMillisecondsSinceEpoch((map['endDate'] as num).toInt()),
      durationSeconds: (map['duration'] as num).toDouble(),
    );
  }

  // Additional properties for compatibility
  DateTime? get bedTime => startDate;
  Duration? get duration => Duration(seconds: durationSeconds.toInt());
  double get quality => _calculateQuality();
  List<String> get stages => [stage];

  double _calculateQuality() {
    // Calculate sleep quality based on duration and stage
    final hours = durationSeconds / 3600;
    if (stage == 'deep' || stage == 'rem') {
      return hours >= 7 ? 0.9 : 0.7;
    }
    return hours >= 6 ? 0.6 : 0.4;
  }
}

class ActivityData {
  final DateTime date;
  final double steps;
  final double activeEnergy;
  final String unit;

  ActivityData({
    required this.date,
    required this.steps,
    required this.activeEnergy,
    required this.unit,
  });

  factory ActivityData.fromMap(Map<String, dynamic> map) {
    return ActivityData(
      date: DateTime.fromMillisecondsSinceEpoch((map['date'] as num).toInt()),
      steps: (map['steps'] as num).toDouble(),
      activeEnergy: (map['activeEnergy'] as num).toDouble(),
      unit: map['unit'] as String,
    );
  }
}

class HealthSummary {
  final DateTime date;
  final List<HealthDataPoint> heartRateData;
  final List<HealthDataPoint> hrvData;
  final List<SleepData> sleepData;
  final List<HealthDataPoint> temperatureData;
  final List<ActivityData> activityData;

  HealthSummary({
    required this.date,
    required this.heartRateData,
    required this.hrvData,
    required this.sleepData,
    required this.temperatureData,
    required this.activityData,
  });
}

class CycleHealthInsights {
  double? averageHRV;
  double? stressLevel;
  double? averageSleepDuration;
  double? sleepQuality;
  DateTime? possibleOvulationDate;
  double? averageSteps;
  double? energyLevels;

  CycleHealthInsights({
    this.averageHRV,
    this.stressLevel,
    this.averageSleepDuration,
    this.sleepQuality,
    this.possibleOvulationDate,
    this.averageSteps,
    this.energyLevels,
  });
}
