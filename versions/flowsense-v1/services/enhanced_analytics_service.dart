import 'dart:math';
import 'package:flutter/material.dart';
import '../models/cycle_models.dart';
import '../models/daily_log_models.dart';

/// 🚀 Enhanced Analytics Service for Mission Alpha
/// Advanced data processing for interactive charts and correlations
class EnhancedAnalyticsService {
  
  /// Calculate mood, energy, and pain trends over time
  static WellbeingTrends calculateWellbeingTrends(
    List<CycleData> cycles, 
    List<DailyLogEntry> dailyLogs
  ) {
    if (cycles.isEmpty && dailyLogs.isEmpty) {
      return WellbeingTrends.empty();
    }

    // Combine data from both cycles and daily logs
    final moodData = <DateTime, double>{};
    final energyData = <DateTime, double>{};
    final painData = <DateTime, double>{};

    // Add cycle data
    for (final cycle in cycles) {
      moodData[cycle.startDate] = cycle.wellbeing.mood;
      energyData[cycle.startDate] = cycle.wellbeing.energy;
      painData[cycle.startDate] = cycle.wellbeing.pain;
    }

    // Add daily log data (prioritize over cycle data for same dates)
    for (final log in dailyLogs) {
      if (log.mood != null) moodData[log.date] = log.mood!;
      if (log.energy != null) energyData[log.date] = log.energy!;
      if (log.pain != null) painData[log.date] = log.pain!;
    }

    return WellbeingTrends(
      moodTrend: _createTrendData(moodData),
      energyTrend: _createTrendData(energyData),
      painTrend: _createTrendData(painData),
      averageMood: _calculateAverage(moodData.values),
      averageEnergy: _calculateAverage(energyData.values),
      averagePain: _calculateAverage(painData.values),
    );
  }

  /// Calculate symptom correlation matrix
  static SymptomCorrelationMatrix calculateSymptomCorrelations(
    List<CycleData> cycles,
    List<DailyLogEntry> dailyLogs
  ) {
    final allSymptoms = <String>{};
    final symptomOccurrences = <String, List<bool>>{};
    final entryCount = cycles.length + dailyLogs.length;

    // Collect all symptoms
    for (final cycle in cycles) {
      for (final symptom in cycle.symptoms) {
        allSymptoms.add(symptom.name);
      }
    }
    for (final log in dailyLogs) {
      allSymptoms.addAll(log.symptoms);
    }

    // Initialize occurrence tracking
    for (final symptom in allSymptoms) {
      symptomOccurrences[symptom] = List.filled(entryCount, false);
    }

    // Track symptom occurrences
    int index = 0;
    for (final cycle in cycles) {
      for (final symptom in cycle.symptoms) {
        symptomOccurrences[symptom.name]![index] = true;
      }
      index++;
    }
    for (final log in dailyLogs) {
      for (final symptom in log.symptoms) {
        symptomOccurrences[symptom]![index] = true;
      }
      index++;
    }

    // Calculate correlations
    final correlations = <String, Map<String, double>>{};
    final symptoms = allSymptoms.toList();

    for (int i = 0; i < symptoms.length; i++) {
      correlations[symptoms[i]] = {};
      for (int j = 0; j < symptoms.length; j++) {
        if (i == j) {
          correlations[symptoms[i]]![symptoms[j]] = 1.0;
        } else {
          final correlation = _calculateCorrelation(
            symptomOccurrences[symptoms[i]]!,
            symptomOccurrences[symptoms[j]]!,
          );
          correlations[symptoms[i]]![symptoms[j]] = correlation;
        }
      }
    }

    return SymptomCorrelationMatrix(
      symptoms: symptoms,
      correlations: correlations,
    );
  }

  /// Calculate cycle phase analysis
  static CyclePhaseAnalysis analyzeCyclePhases(List<CycleData> cycles) {
    if (cycles.isEmpty) return CyclePhaseAnalysis.empty();

    final completedCycles = cycles.where((c) => c.isCompleted).toList();
    if (completedCycles.isEmpty) return CyclePhaseAnalysis.empty();

    final menstrualPhase = PhaseData(name: 'Menstrual', days: 1, dayRange: [1, 5]);
    final follicularPhase = PhaseData(name: 'Follicular', days: 6, dayRange: [6, 13]);
    final ovulatoryPhase = PhaseData(name: 'Ovulatory', days: 14, dayRange: [14, 16]);
    final lutealPhase = PhaseData(name: 'Luteal', days: 17, dayRange: [17, 28]);

    // Analyze symptoms by phase
    final phaseSymptoms = <String, Map<String, int>>{
      'Menstrual': {},
      'Follicular': {},
      'Ovulatory': {},
      'Luteal': {},
    };

    final phaseWellbeing = <String, List<double>>{
      'Menstrual': [0, 0, 0], // mood, energy, pain
      'Follicular': [0, 0, 0],
      'Ovulatory': [0, 0, 0],
      'Luteal': [0, 0, 0],
    };

    for (final cycle in completedCycles) {
      final cycleLength = cycle.lengthInDays;
      final adjustedPhases = _adjustPhasesForCycleLength(cycleLength);
      
      // Assign symptoms to phases (simplified - using cycle start for now)
      final phase = _getPhaseForDay(1, adjustedPhases);
      
      for (final symptom in cycle.symptoms) {
        phaseSymptoms[phase]![symptom.name] = 
            (phaseSymptoms[phase]![symptom.name] ?? 0) + 1;
      }

      // Add wellbeing data
      phaseWellbeing[phase]![0] += cycle.wellbeing.mood;
      phaseWellbeing[phase]![1] += cycle.wellbeing.energy;
      phaseWellbeing[phase]![2] += cycle.wellbeing.pain;
    }

    // Calculate averages
    final phaseCount = completedCycles.length / 4; // Rough estimate
    for (final phase in phaseWellbeing.keys) {
      if (phaseCount > 0) {
        phaseWellbeing[phase]![0] /= phaseCount;
        phaseWellbeing[phase]![1] /= phaseCount;
        phaseWellbeing[phase]![2] /= phaseCount;
      }
    }

    return CyclePhaseAnalysis(
      menstrualPhase: menstrualPhase,
      follicularPhase: follicularPhase,
      ovulatoryPhase: ovulatoryPhase,
      lutealPhase: lutealPhase,
      phaseSymptoms: phaseSymptoms,
      phaseWellbeing: phaseWellbeing,
    );
  }

  /// Generate advanced cycle predictions with confidence intervals
  static AdvancedPrediction generateAdvancedPredictions(List<CycleData> cycles) {
    if (cycles.length < 3) return AdvancedPrediction.empty();

    final completedCycles = cycles.where((c) => c.isCompleted).toList();
    if (completedCycles.length < 3) return AdvancedPrediction.empty();

    // Sort by most recent first
    completedCycles.sort((a, b) => b.startDate.compareTo(a.startDate));

    final lengths = completedCycles.take(6).map((c) => c.lengthInDays).toList();
    final avgLength = lengths.reduce((a, b) => a + b) / lengths.length;
    
    // Calculate variance for confidence
    final variance = lengths.map((l) => pow(l - avgLength, 2)).reduce((a, b) => a + b) / lengths.length;
    final stdDev = sqrt(variance);
    final confidence = max(0.5, min(0.95, 1.0 - (stdDev / avgLength)));

    final lastCycle = completedCycles.first;
    final nextStart = lastCycle.endDate!.add(Duration(days: avgLength.round()));
    
    // Confidence intervals
    final lowerBound = nextStart.subtract(Duration(days: (stdDev * 1.96).round()));
    final upperBound = nextStart.add(Duration(days: (stdDev * 1.96).round()));

    // Ovulation prediction (14 days before next cycle, typically)
    final ovulationDate = nextStart.subtract(const Duration(days: 14));
    final fertileStart = ovulationDate.subtract(const Duration(days: 5));
    final fertileEnd = ovulationDate.add(const Duration(days: 1));

    return AdvancedPrediction(
      nextCycleStart: nextStart,
      confidence: confidence,
      confidenceLowerBound: lowerBound,
      confidenceUpperBound: upperBound,
      ovulationDate: ovulationDate,
      fertileWindowStart: fertileStart,
      fertileWindowEnd: fertileEnd,
      predictedLength: avgLength.round(),
      basedOnCycles: completedCycles.length,
    );
  }

  /// Calculate health score based on multiple factors
  static HealthScore calculateHealthScore(
    List<CycleData> cycles,
    List<DailyLogEntry> dailyLogs,
  ) {
    if (cycles.isEmpty && dailyLogs.isEmpty) {
      return HealthScore(overall: 0, breakdown: {});
    }

    final scores = <String, double>{};

    // Regularity score (0-100)
    if (cycles.length >= 3) {
      final completedCycles = cycles.where((c) => c.isCompleted).toList();
      if (completedCycles.length >= 3) {
        final lengths = completedCycles.map((c) => c.lengthInDays).toList();
        final avgLength = lengths.reduce((a, b) => a + b) / lengths.length;
        final variance = lengths.map((l) => pow(l - avgLength, 2)).reduce((a, b) => a + b) / lengths.length;
        final regularityScore = max(0.0, 100 - (variance * 3));
        scores['Cycle Regularity'] = regularityScore;
      }
    }

    // Mood stability score
    final allMoodData = <double>[];
    for (final cycle in cycles) {
      allMoodData.add(cycle.wellbeing.mood);
    }
    for (final log in dailyLogs) {
      if (log.mood != null) allMoodData.add(log.mood!);
    }
    
    if (allMoodData.isNotEmpty) {
      final avgMood = allMoodData.reduce((a, b) => a + b) / allMoodData.length;
      final moodVariance = allMoodData.map((m) => pow(m - avgMood, 2)).reduce((a, b) => a + b) / allMoodData.length;
      final moodScore = max(0.0, min(100.0, (avgMood * 20) - (moodVariance * 10)));
      scores['Mood Stability'] = moodScore;
    }

    // Energy level score
    final allEnergyData = <double>[];
    for (final cycle in cycles) {
      allEnergyData.add(cycle.wellbeing.energy);
    }
    for (final log in dailyLogs) {
      if (log.energy != null) allEnergyData.add(log.energy!);
    }
    
    if (allEnergyData.isNotEmpty) {
      final avgEnergy = allEnergyData.reduce((a, b) => a + b) / allEnergyData.length;
      final energyScore = (avgEnergy * 20).clamp(0.0, 100.0);
      scores['Energy Level'] = energyScore;
    }

    // Pain management score (lower pain = higher score)
    final allPainData = <double>[];
    for (final cycle in cycles) {
      allPainData.add(cycle.wellbeing.pain);
    }
    for (final log in dailyLogs) {
      if (log.pain != null) allPainData.add(log.pain!);
    }
    
    if (allPainData.isNotEmpty) {
      final avgPain = allPainData.reduce((a, b) => a + b) / allPainData.length;
      final painScore = max(0.0, 100 - (avgPain * 20));
      scores['Pain Management'] = painScore;
    }

    // Overall score (weighted average)
    final overall = scores.values.isEmpty 
        ? 0.0 
        : scores.values.reduce((a, b) => a + b) / scores.length;

    return HealthScore(
      overall: overall,
      breakdown: scores,
    );
  }

  // Helper methods

  static List<TrendPoint> _createTrendData(Map<DateTime, double> data) {
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    return sortedEntries.map((entry) => TrendPoint(
      date: entry.key,
      value: entry.value,
    )).toList();
  }

  static double _calculateAverage(Iterable<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  static double _calculateCorrelation(List<bool> x, List<bool> y) {
    if (x.length != y.length || x.isEmpty) return 0.0;

    final n = x.length;
    final xInt = x.map((v) => v ? 1 : 0).toList();
    final yInt = y.map((v) => v ? 1 : 0).toList();

    final sumX = xInt.reduce((a, b) => a + b);
    final sumY = yInt.reduce((a, b) => a + b);
    final sumXY = List.generate(n, (i) => xInt[i] * yInt[i]).reduce((a, b) => a + b);
    final sumX2 = xInt.map((v) => v * v).reduce((a, b) => a + b);
    final sumY2 = yInt.map((v) => v * v).reduce((a, b) => a + b);

    final numerator = (n * sumXY) - (sumX * sumY);
    final denominator = sqrt(((n * sumX2) - (sumX * sumX)) * ((n * sumY2) - (sumY * sumY)));

    if (denominator == 0) return 0.0;
    return (numerator / denominator).clamp(-1.0, 1.0);
  }

  static Map<String, List<int>> _adjustPhasesForCycleLength(int cycleLength) {
    // Adjust phase lengths proportionally
    final ratio = cycleLength / 28.0;
    return {
      'Menstrual': [1, (5 * ratio).round()],
      'Follicular': [(5 * ratio).round() + 1, (13 * ratio).round()],
      'Ovulatory': [(13 * ratio).round() + 1, (16 * ratio).round()],
      'Luteal': [(16 * ratio).round() + 1, cycleLength],
    };
  }

  static String _getPhaseForDay(int day, Map<String, List<int>> phases) {
    for (final entry in phases.entries) {
      if (day >= entry.value[0] && day <= entry.value[1]) {
        return entry.key;
      }
    }
    return 'Unknown';
  }
}

// Data models for enhanced analytics

class WellbeingTrends {
  final List<TrendPoint> moodTrend;
  final List<TrendPoint> energyTrend;
  final List<TrendPoint> painTrend;
  final double averageMood;
  final double averageEnergy;
  final double averagePain;

  WellbeingTrends({
    required this.moodTrend,
    required this.energyTrend,
    required this.painTrend,
    required this.averageMood,
    required this.averageEnergy,
    required this.averagePain,
  });

  factory WellbeingTrends.empty() => WellbeingTrends(
    moodTrend: [],
    energyTrend: [],
    painTrend: [],
    averageMood: 0,
    averageEnergy: 0,
    averagePain: 0,
  );
}

class TrendPoint {
  final DateTime date;
  final double value;

  TrendPoint({required this.date, required this.value});
}

class SymptomCorrelationMatrix {
  final List<String> symptoms;
  final Map<String, Map<String, double>> correlations;

  SymptomCorrelationMatrix({
    required this.symptoms,
    required this.correlations,
  });

  double getCorrelation(String symptom1, String symptom2) {
    return correlations[symptom1]?[symptom2] ?? 0.0;
  }
}

class CyclePhaseAnalysis {
  final PhaseData menstrualPhase;
  final PhaseData follicularPhase;
  final PhaseData ovulatoryPhase;
  final PhaseData lutealPhase;
  final Map<String, Map<String, int>> phaseSymptoms;
  final Map<String, List<double>> phaseWellbeing;

  CyclePhaseAnalysis({
    required this.menstrualPhase,
    required this.follicularPhase,
    required this.ovulatoryPhase,
    required this.lutealPhase,
    required this.phaseSymptoms,
    required this.phaseWellbeing,
  });

  factory CyclePhaseAnalysis.empty() => CyclePhaseAnalysis(
    menstrualPhase: PhaseData(name: 'Menstrual', days: 1, dayRange: [1, 5]),
    follicularPhase: PhaseData(name: 'Follicular', days: 6, dayRange: [6, 13]),
    ovulatoryPhase: PhaseData(name: 'Ovulatory', days: 14, dayRange: [14, 16]),
    lutealPhase: PhaseData(name: 'Luteal', days: 17, dayRange: [17, 28]),
    phaseSymptoms: {},
    phaseWellbeing: {},
  );
}

class PhaseData {
  final String name;
  final int days;
  final List<int> dayRange;

  PhaseData({required this.name, required this.days, required this.dayRange});
}

class AdvancedPrediction {
  final DateTime nextCycleStart;
  final double confidence;
  final DateTime confidenceLowerBound;
  final DateTime confidenceUpperBound;
  final DateTime ovulationDate;
  final DateTime fertileWindowStart;
  final DateTime fertileWindowEnd;
  final int predictedLength;
  final int basedOnCycles;

  AdvancedPrediction({
    required this.nextCycleStart,
    required this.confidence,
    required this.confidenceLowerBound,
    required this.confidenceUpperBound,
    required this.ovulationDate,
    required this.fertileWindowStart,
    required this.fertileWindowEnd,
    required this.predictedLength,
    required this.basedOnCycles,
  });

  factory AdvancedPrediction.empty() => AdvancedPrediction(
    nextCycleStart: DateTime.now(),
    confidence: 0,
    confidenceLowerBound: DateTime.now(),
    confidenceUpperBound: DateTime.now(),
    ovulationDate: DateTime.now(),
    fertileWindowStart: DateTime.now(),
    fertileWindowEnd: DateTime.now(),
    predictedLength: 0,
    basedOnCycles: 0,
  );
}

class HealthScore {
  final double overall;
  final Map<String, double> breakdown;

  HealthScore({required this.overall, required this.breakdown});

  String get overallGrade {
    if (overall >= 90) return 'Excellent';
    if (overall >= 80) return 'Very Good';
    if (overall >= 70) return 'Good';
    if (overall >= 60) return 'Fair';
    return 'Needs Attention';
  }

  Color get gradeColor {
    if (overall >= 80) return const Color(0xFF4CAF50); // Green
    if (overall >= 60) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336); // Red
  }
}
