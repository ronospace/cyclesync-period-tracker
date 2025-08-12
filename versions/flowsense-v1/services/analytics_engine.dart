import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../models/cycle_models.dart';
import '../models/daily_log_models.dart';
import '../data/cache/data_cache_manager.dart';

/// Advanced analytics engine for health data processing and insights generation
/// Provides cycle predictions, pattern recognition, and health correlations
class AnalyticsEngine {
  static AnalyticsEngine? _instance;
  static AnalyticsEngine get instance => _instance ??= AnalyticsEngine._();

  AnalyticsEngine._();

  final DataCacheManager _cache = DataCacheManager.instance;

  /// Generate comprehensive cycle analytics
  Future<CycleAnalytics> generateCycleAnalytics(List<CycleData> cycles) async {
    if (cycles.isEmpty) {
      return CycleAnalytics.empty();
    }

    try {
      debugPrint('📊 Generating cycle analytics for ${cycles.length} cycles...');

      // Sort cycles by start date (most recent first)
      final sortedCycles = List<CycleData>.from(cycles)
        ..sort((a, b) => b.startDate.compareTo(a.startDate));

      // Calculate basic statistics
      final basicStats = _calculateBasicStats(sortedCycles);
      
      // Analyze cycle patterns
      final patterns = _analyzeCyclePatterns(sortedCycles);
      
      // Generate predictions
      final predictions = _generatePredictions(sortedCycles);
      
      // Analyze symptoms
      final symptomAnalysis = _analyzeSymptoms(sortedCycles);
      
      // Calculate health correlations
      final correlations = _calculateHealthCorrelations(sortedCycles);
      
      // Generate insights and recommendations
      final insights = _generateInsights(sortedCycles, basicStats, patterns);

      final analytics = CycleAnalytics(
        totalCycles: sortedCycles.length,
        averageCycleLength: basicStats.averageCycleLength,
        averagePeriodLength: basicStats.averagePeriodLength,
        cycleRegularity: patterns.regularity,
        predictedNextPeriod: predictions.nextPeriodDate,
        predictedOvulation: predictions.nextOvulationDate,
        fertileWindow: predictions.fertileWindow,
        commonSymptoms: symptomAnalysis.commonSymptoms,
        symptomPatterns: symptomAnalysis.patterns,
        healthCorrelations: correlations,
        insights: insights,
        trendData: patterns.trendData,
        generatedAt: DateTime.now(),
      );

      // Cache analytics for performance
      await _cacheAnalytics(analytics);

      debugPrint('✅ Cycle analytics generated successfully');
      return analytics;

    } catch (e) {
      debugPrint('❌ Error generating cycle analytics: $e');
      return CycleAnalytics.error(e.toString());
    }
  }

  /// Calculate basic cycle statistics
  _BasicCycleStats _calculateBasicStats(List<CycleData> cycles) {
    if (cycles.isEmpty) {
      return _BasicCycleStats.empty();
    }

    // Calculate cycle lengths for completed cycles
    final cycleLengths = <int>[];
    final periodLengths = <int>[];

    for (int i = 0; i < cycles.length - 1; i++) {
      final currentCycle = cycles[i];
      final nextCycle = cycles[i + 1];
      
      final cycleLength = currentCycle.startDate.difference(nextCycle.startDate).inDays;
      if (cycleLength > 0 && cycleLength <= 45) { // Valid cycle length
        cycleLengths.add(cycleLength);
      }
      
      if (currentCycle.endDate != null) {
        final periodLength = currentCycle.endDate!.difference(currentCycle.startDate).inDays;
        if (periodLength > 0 && periodLength <= 10) { // Valid period length
          periodLengths.add(periodLength);
        }
      }
    }

    final avgCycleLength = cycleLengths.isNotEmpty 
        ? cycleLengths.reduce((a, b) => a + b) / cycleLengths.length
        : 28.0;

    final avgPeriodLength = periodLengths.isNotEmpty 
        ? periodLengths.reduce((a, b) => a + b) / periodLengths.length
        : 5.0;

    return _BasicCycleStats(
      averageCycleLength: avgCycleLength,
      averagePeriodLength: avgPeriodLength,
      cycleLengthVariation: _calculateVariation(cycleLengths),
      periodLengthVariation: _calculateVariation(periodLengths),
      completedCycles: cycleLengths.length,
    );
  }

  /// Analyze cycle patterns and regularity
  _CyclePatterns _analyzeCyclePatterns(List<CycleData> cycles) {
    if (cycles.length < 3) {
      return _CyclePatterns.insufficient();
    }

    // Calculate cycle length variations
    final cycleLengths = <int>[];
    for (int i = 0; i < cycles.length - 1; i++) {
      final length = cycles[i].startDate.difference(cycles[i + 1].startDate).inDays;
      if (length > 0 && length <= 45) {
        cycleLengths.add(length);
      }
    }

    if (cycleLengths.isEmpty) {
      return _CyclePatterns.insufficient();
    }

    // Calculate regularity score
    final variation = _calculateVariation(cycleLengths);
    final regularity = _calculateRegularityScore(variation);
    
    // Analyze seasonal patterns
    final seasonalPatterns = _analyzeSeasonalPatterns(cycles);
    
    // Generate trend data for charts
    final trendData = _generateTrendData(cycles);

    return _CyclePatterns(
      regularity: regularity,
      cycleLengthTrend: _calculateTrend(cycleLengths),
      seasonalPatterns: seasonalPatterns,
      trendData: trendData,
    );
  }

  /// Generate cycle predictions
  _CyclePredictions _generatePredictions(List<CycleData> cycles) {
    if (cycles.isEmpty) {
      return _CyclePredictions.empty();
    }

    final mostRecentCycle = cycles.first;
    final basicStats = _calculateBasicStats(cycles);
    
    // Predict next period based on average cycle length
    final avgCycleLength = basicStats.averageCycleLength.round();
    final nextPeriodDate = mostRecentCycle.startDate.add(Duration(days: avgCycleLength));
    
    // Predict ovulation (typically 14 days before next period)
    final nextOvulationDate = nextPeriodDate.subtract(const Duration(days: 14));
    
    // Calculate fertile window (5 days before to 1 day after ovulation)
    final fertileStart = nextOvulationDate.subtract(const Duration(days: 5));
    final fertileEnd = nextOvulationDate.add(const Duration(days: 1));
    
    return _CyclePredictions(
      nextPeriodDate: nextPeriodDate,
      nextOvulationDate: nextOvulationDate,
      fertileWindow: DateRange(start: fertileStart, end: fertileEnd),
      confidence: _calculatePredictionConfidence(cycles),
    );
  }

  /// Analyze symptom patterns
  _SymptomAnalysis _analyzeSymptoms(List<CycleData> cycles) {
    final symptomCounts = <String, int>{};
    final symptomByPhase = <CyclePhase, Map<String, int>>{};
    
    for (final cycle in cycles) {
      for (final symptom in cycle.symptoms) {
        // Count overall symptom frequency
        symptomCounts[symptom.name] = (symptomCounts[symptom.name] ?? 0) + 1;
        
        // Analyze symptom by cycle phase
        final phase = _getCyclePhase(cycle, symptom.date ?? cycle.startDate);
        symptomByPhase.putIfAbsent(phase, () => {});
        symptomByPhase[phase]![symptom.name] = 
            (symptomByPhase[phase]![symptom.name] ?? 0) + 1;
      }
    }
    
    // Get most common symptoms
    final sortedSymptoms = symptomCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final commonSymptoms = sortedSymptoms.take(10)
        .map((entry) => SymptomFrequency(
          name: entry.key,
          frequency: entry.value / cycles.length,
          percentage: (entry.value / cycles.length * 100).round(),
        ))
        .toList();

    return _SymptomAnalysis(
      commonSymptoms: commonSymptoms,
      patterns: symptomByPhase,
      totalUniqueSymptoms: symptomCounts.length,
    );
  }

  /// Calculate health correlations
  Map<String, double> _calculateHealthCorrelations(List<CycleData> cycles) {
    final correlations = <String, double>{};
    
    if (cycles.length < 5) return correlations;

    // Analyze correlation between cycle length and symptoms
    final cycleLengths = <double>[];
    final symptomCounts = <double>[];
    
    for (int i = 0; i < cycles.length - 1; i++) {
      final cycle = cycles[i];
      final nextCycle = cycles[i + 1];
      
      final length = cycle.startDate.difference(nextCycle.startDate).inDays.toDouble();
      if (length > 0 && length <= 45) {
        cycleLengths.add(length);
        symptomCounts.add(cycle.symptoms.length.toDouble());
      }
    }
    
    if (cycleLengths.length >= 3) {
      correlations['cycle_length_symptoms'] = 
          _calculateCorrelation(cycleLengths, symptomCounts);
    }
    
    // Add more correlations as needed
    correlations['mood_energy'] = _analyzeMoodEnergyCorrelation(cycles);
    correlations['stress_cycle_regularity'] = _analyzeStressCycleCorrelation(cycles);
    
    return correlations;
  }

  /// Generate actionable insights
  List<HealthInsight> _generateInsights(
    List<CycleData> cycles,
    _BasicCycleStats stats,
    _CyclePatterns patterns,
  ) {
    final insights = <HealthInsight>[];

    // Cycle regularity insights
    if (patterns.regularity < 0.7) {
      insights.add(HealthInsight(
        type: InsightType.warning,
        title: 'Irregular Cycles Detected',
        description: 'Your cycles show irregular patterns. Consider tracking lifestyle factors that might affect regularity.',
        priority: InsightPriority.high,
        recommendation: 'Track sleep, stress levels, and exercise to identify patterns.',
        category: InsightCategory.cycle,
      ));
    } else if (patterns.regularity > 0.9) {
      insights.add(HealthInsight(
        type: InsightType.positive,
        title: 'Highly Regular Cycles',
        description: 'Your cycles are very regular, indicating good hormonal balance.',
        priority: InsightPriority.low,
        recommendation: 'Continue your current lifestyle habits.',
        category: InsightCategory.cycle,
      ));
    }

    // Cycle length insights
    if (stats.averageCycleLength < 21) {
      insights.add(HealthInsight(
        type: InsightType.warning,
        title: 'Short Cycles',
        description: 'Your average cycle length is ${stats.averageCycleLength.toStringAsFixed(1)} days, which is shorter than typical.',
        priority: InsightPriority.medium,
        recommendation: 'Consider consulting a healthcare provider if this is a new pattern.',
        category: InsightCategory.cycle,
      ));
    } else if (stats.averageCycleLength > 35) {
      insights.add(HealthInsight(
        type: InsightType.warning,
        title: 'Long Cycles',
        description: 'Your average cycle length is ${stats.averageCycleLength.toStringAsFixed(1)} days, which is longer than typical.',
        priority: InsightPriority.medium,
        recommendation: 'Track ovulation signs and consider consulting a healthcare provider.',
        category: InsightCategory.cycle,
      ));
    }

    // Symptom insights
    final symptomAnalysis = _analyzeSymptoms(cycles);
    if (symptomAnalysis.commonSymptoms.isNotEmpty) {
      final topSymptom = symptomAnalysis.commonSymptoms.first;
      if (topSymptom.frequency > 0.7) {
        insights.add(HealthInsight(
          type: InsightType.info,
          title: 'Common Symptom Pattern',
          description: '${topSymptom.name} occurs in ${topSymptom.percentage}% of your cycles.',
          priority: InsightPriority.low,
          recommendation: 'Consider tracking triggers and management strategies.',
          category: InsightCategory.symptoms,
        ));
      }
    }

    // Predictive insights
    if (cycles.length >= 6) {
      insights.add(HealthInsight(
        type: InsightType.positive,
        title: 'Prediction Accuracy Improving',
        description: 'With ${cycles.length} cycles tracked, predictions are becoming more accurate.',
        priority: InsightPriority.low,
        recommendation: 'Continue consistent tracking for better insights.',
        category: InsightCategory.tracking,
      ));
    }

    return insights;
  }

  /// Calculate statistical variation
  double _calculateVariation(List<int> values) {
    if (values.length < 2) return 0.0;
    
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values
        .map((value) => math.pow(value - mean, 2))
        .reduce((a, b) => a + b) / values.length;
    
    return math.sqrt(variance);
  }

  /// Calculate regularity score (0-1, where 1 is perfectly regular)
  double _calculateRegularityScore(double variation) {
    // Lower variation = higher regularity
    // Normalize variation to 0-1 scale
    return math.max(0.0, 1.0 - (variation / 7.0)); // 7 days max acceptable variation
  }

  /// Calculate correlation coefficient between two data series
  double _calculateCorrelation(List<double> x, List<double> y) {
    if (x.length != y.length || x.length < 3) return 0.0;
    
    final n = x.length;
    final meanX = x.reduce((a, b) => a + b) / n;
    final meanY = y.reduce((a, b) => a + b) / n;
    
    double numerator = 0.0;
    double denomX = 0.0;
    double denomY = 0.0;
    
    for (int i = 0; i < n; i++) {
      final diffX = x[i] - meanX;
      final diffY = y[i] - meanY;
      
      numerator += diffX * diffY;
      denomX += diffX * diffX;
      denomY += diffY * diffY;
    }
    
    final denominator = math.sqrt(denomX * denomY);
    return denominator != 0 ? numerator / denominator : 0.0;
  }

  /// Analyze seasonal patterns
  Map<String, double> _analyzeSeasonalPatterns(List<CycleData> cycles) {
    final seasonalData = <String, List<double>>{
      'Spring': [],
      'Summer': [],
      'Fall': [],
      'Winter': [],
    };
    
    for (int i = 0; i < cycles.length - 1; i++) {
      final cycle = cycles[i];
      final nextCycle = cycles[i + 1];
      
      final length = cycle.startDate.difference(nextCycle.startDate).inDays.toDouble();
      if (length > 0 && length <= 45) {
        final season = _getSeason(cycle.startDate);
        seasonalData[season]!.add(length);
      }
    }
    
    final seasonalAverages = <String, double>{};
    for (final entry in seasonalData.entries) {
      if (entry.value.isNotEmpty) {
        seasonalAverages[entry.key] = 
            entry.value.reduce((a, b) => a + b) / entry.value.length;
      }
    }
    
    return seasonalAverages;
  }

  /// Get season for a given date
  String _getSeason(DateTime date) {
    final month = date.month;
    if (month >= 3 && month <= 5) return 'Spring';
    if (month >= 6 && month <= 8) return 'Summer';
    if (month >= 9 && month <= 11) return 'Fall';
    return 'Winter';
  }

  /// Get cycle phase for a given date within a cycle
  CyclePhase _getCyclePhase(CycleData cycle, DateTime date) {
    final dayInCycle = date.difference(cycle.startDate).inDays + 1;
    
    if (dayInCycle <= 5) return CyclePhase.menstrual;
    if (dayInCycle <= 9) return CyclePhase.follicular;
    if (dayInCycle <= 16) return CyclePhase.ovulation;
    return CyclePhase.luteal;
  }

  /// Calculate trend (positive, negative, or stable)
  double _calculateTrend(List<int> values) {
    if (values.length < 3) return 0.0;
    
    // Simple linear regression slope
    final n = values.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumXX = 0;
    
    for (int i = 0; i < n; i++) {
      sumX += i;
      sumY += values[i];
      sumXY += i * values[i];
      sumXX += i * i;
    }
    
    final slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    return slope;
  }

  /// Calculate prediction confidence based on data quality and consistency
  double _calculatePredictionConfidence(List<CycleData> cycles) {
    if (cycles.length < 3) return 0.3;
    if (cycles.length < 6) return 0.6;
    if (cycles.length < 12) return 0.8;
    return 0.9;
  }

  /// Generate trend data for visualization
  List<TrendDataPoint> _generateTrendData(List<CycleData> cycles) {
    final trendData = <TrendDataPoint>[];
    
    for (int i = 0; i < cycles.length - 1; i++) {
      final cycle = cycles[cycles.length - 1 - i]; // Reverse order for chronological
      final nextCycle = cycles[cycles.length - 2 - i];
      
      final length = nextCycle.startDate.difference(cycle.startDate).inDays;
      if (length > 0 && length <= 45) {
        trendData.add(TrendDataPoint(
          date: cycle.startDate,
          value: length.toDouble(),
          label: 'Cycle ${cycles.length - i}',
        ));
      }
    }
    
    return trendData;
  }

  /// Analyze mood-energy correlation
  double _analyzeMoodEnergyCorrelation(List<CycleData> cycles) {
    final moodValues = <double>[];
    final energyValues = <double>[];
    
    for (final cycle in cycles) {
      if (cycle.mood != null && cycle.energyLevel != null) {
        moodValues.add(cycle.mood!.index.toDouble());
        energyValues.add(cycle.energyLevel!.toDouble());
      }
    }
    
    return _calculateCorrelation(moodValues, energyValues);
  }

  /// Analyze stress-cycle regularity correlation
  double _analyzeStressCycleCorrelation(List<CycleData> cycles) {
    // Simplified stress analysis based on symptom severity
    final stressValues = <double>[];
    final cycleLengths = <double>[];
    
    for (int i = 0; i < cycles.length - 1; i++) {
      final cycle = cycles[i];
      final nextCycle = cycles[i + 1];
      
      final length = cycle.startDate.difference(nextCycle.startDate).inDays.toDouble();
      if (length > 0 && length <= 45) {
        cycleLengths.add(length);
        
        // Calculate stress proxy from symptom severity
        final stressProxy = cycle.symptoms
            .where((s) => s.severity == SymptomSeverity.severe)
            .length
            .toDouble();
        stressValues.add(stressProxy);
      }
    }
    
    return _calculateCorrelation(stressValues, cycleLengths);
  }

  /// Cache analytics results
  Future<void> _cacheAnalytics(CycleAnalytics analytics) async {
    try {
      await _cache.cacheAnalytics(
        'cycle_analytics_${DateTime.now().millisecondsSinceEpoch}',
        analytics.toJson(),
      );
    } catch (e) {
      debugPrint('⚠️ Failed to cache analytics: $e');
    }
  }

  /// Generate daily wellness insights
  List<String> generateDailyWellnessInsights(DailyLogEntry log) {
    final insights = <String>[];
    
    // Wellness score insights
    final score = log.calculateWellnessScore();
    if (score >= 80) {
      insights.add('Excellent wellness day! Your body is functioning optimally.');
    } else if (score >= 60) {
      insights.add('Good wellness day with room for improvement in some areas.');
    } else if (score >= 40) {
      insights.add('Moderate wellness day. Consider focusing on key health areas.');
    } else {
      insights.add('Lower wellness day. Your body may need extra care and rest.');
    }

    // Sleep insights
    if (log.sleepHours != null) {
      if (log.sleepHours! < 6) {
        insights.add('Sleep duration is below optimal. Aim for 7-9 hours for better health.');
      } else if (log.sleepHours! > 10) {
        insights.add('Long sleep duration detected. Monitor for underlying health factors.');
      }
    }

    // Activity insights
    if (log.stepsCount != null) {
      if (log.stepsCount! >= 10000) {
        insights.add('Great activity level! You\'ve exceeded the recommended daily steps.');
      } else if (log.stepsCount! < 2000) {
        insights.add('Low activity detected. Try to incorporate more movement into your day.');
      }
    }

    return insights;
  }
}

// Supporting data classes
class _BasicCycleStats {
  final double averageCycleLength;
  final double averagePeriodLength;
  final double cycleLengthVariation;
  final double periodLengthVariation;
  final int completedCycles;

  _BasicCycleStats({
    required this.averageCycleLength,
    required this.averagePeriodLength,
    required this.cycleLengthVariation,
    required this.periodLengthVariation,
    required this.completedCycles,
  });

  factory _BasicCycleStats.empty() => _BasicCycleStats(
    averageCycleLength: 28.0,
    averagePeriodLength: 5.0,
    cycleLengthVariation: 0.0,
    periodLengthVariation: 0.0,
    completedCycles: 0,
  );
}

class _CyclePatterns {
  final double regularity;
  final double cycleLengthTrend;
  final Map<String, double> seasonalPatterns;
  final List<TrendDataPoint> trendData;

  _CyclePatterns({
    required this.regularity,
    required this.cycleLengthTrend,
    required this.seasonalPatterns,
    required this.trendData,
  });

  factory _CyclePatterns.insufficient() => _CyclePatterns(
    regularity: 0.5,
    cycleLengthTrend: 0.0,
    seasonalPatterns: {},
    trendData: [],
  );
}

class _CyclePredictions {
  final DateTime nextPeriodDate;
  final DateTime nextOvulationDate;
  final DateRange fertileWindow;
  final double confidence;

  _CyclePredictions({
    required this.nextPeriodDate,
    required this.nextOvulationDate,
    required this.fertileWindow,
    required this.confidence,
  });

  factory _CyclePredictions.empty() => _CyclePredictions(
    nextPeriodDate: DateTime.now().add(const Duration(days: 28)),
    nextOvulationDate: DateTime.now().add(const Duration(days: 14)),
    fertileWindow: DateRange(
      start: DateTime.now().add(const Duration(days: 9)),
      end: DateTime.now().add(const Duration(days: 15)),
    ),
    confidence: 0.3,
  );
}

class _SymptomAnalysis {
  final List<SymptomFrequency> commonSymptoms;
  final Map<CyclePhase, Map<String, int>> patterns;
  final int totalUniqueSymptoms;

  _SymptomAnalysis({
    required this.commonSymptoms,
    required this.patterns,
    required this.totalUniqueSymptoms,
  });
}

enum CyclePhase { menstrual, follicular, ovulation, luteal }

class SymptomFrequency {
  final String name;
  final double frequency;
  final int percentage;

  SymptomFrequency({
    required this.name,
    required this.frequency,
    required this.percentage,
  });
}

class TrendDataPoint {
  final DateTime date;
  final double value;
  final String label;

  TrendDataPoint({
    required this.date,
    required this.value,
    required this.label,
  });
}

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});
}

class HealthInsight {
  final InsightType type;
  final String title;
  final String description;
  final InsightPriority priority;
  final String recommendation;
  final InsightCategory category;

  HealthInsight({
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
    required this.recommendation,
    required this.category,
  });
}

enum InsightType { positive, warning, info }
enum InsightPriority { low, medium, high }
enum InsightCategory { cycle, symptoms, tracking, health }
