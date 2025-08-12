import 'dart:math';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  /// Calculate comprehensive cycle statistics
  static CycleStatistics calculateStatistics(List<Map<String, dynamic>> cycles) {
    if (cycles.isEmpty) {
      return CycleStatistics.empty();
    }

    // Filter completed cycles only
    final completedCycles = cycles
        .where((c) => c['end'] != null && c['start'] != null)
        .toList();

    if (completedCycles.isEmpty) {
      return CycleStatistics.empty();
    }

    // Calculate basic statistics
    final cycleLengths = <int>[];
    final cycleData = <CycleData>[];

    for (final cycle in completedCycles) {
      final startDate = _parseDate(cycle['start']);
      final endDate = _parseDate(cycle['end']);

      if (startDate != null && endDate != null) {
        final length = endDate.difference(startDate).inDays + 1;
        if (length > 0 && length <= 60) { // Sanity check
          cycleLengths.add(length);
          cycleData.add(CycleData(
            id: cycle['id'] ?? '',
            startDate: startDate,
            endDate: endDate,
            length: length,
            flow: cycle['flow']?.toString(),
            symptoms: _parseSymptoms(cycle['symptoms']),
            notes: cycle['notes']?.toString(),
          ));
        }
      }
    }

    if (cycleLengths.isEmpty) {
      return CycleStatistics.empty();
    }

    // Sort cycle data by date (most recent first)
    cycleData.sort((a, b) => b.startDate.compareTo(a.startDate));

    // Calculate statistics
    final averageLength = cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
    final shortestCycle = cycleLengths.reduce(min);
    final longestCycle = cycleLengths.reduce(max);
    
    // Calculate standard deviation
    final variance = cycleLengths
        .map((length) => pow(length - averageLength, 2))
        .reduce((a, b) => a + b) / cycleLengths.length;
    final standardDeviation = sqrt(variance);

    // Calculate trends
    final trends = _calculateTrends(cycleData);
    
    // Calculate prediction accuracy
    final predictionAccuracy = _calculatePredictionAccuracy(cycleData);

    // Calculate cycle regularity score (0-100, higher is more regular)
    final regularityScore = _calculateRegularityScore(cycleLengths, standardDeviation);

    return CycleStatistics(
      totalCycles: completedCycles.length,
      averageLength: averageLength,
      shortestCycle: shortestCycle,
      longestCycle: longestCycle,
      standardDeviation: standardDeviation,
      regularityScore: regularityScore,
      trends: trends,
      predictionAccuracy: predictionAccuracy,
      recentCycles: cycleData.take(6).toList(),
      cycleLengthHistory: cycleLengths,
    );
  }

  /// Calculate cycle trends over time
  static CycleTrends _calculateTrends(List<CycleData> cycles) {
    if (cycles.length < 3) {
      return CycleTrends.empty();
    }

    // Take last 6 cycles for trend analysis
    final recentCycles = cycles.take(6).toList();
    final lengths = recentCycles.map((c) => c.length.toDouble()).toList();

    // Calculate trend direction using linear regression
    final n = lengths.length;
    final sumX = List.generate(n, (i) => i + 1).reduce((a, b) => a + b);
    final sumY = lengths.reduce((a, b) => a + b);
    final sumXY = List.generate(n, (i) => (i + 1) * lengths[i]).reduce((a, b) => a + b);
    final sumX2 = List.generate(n, (i) => (i + 1) * (i + 1)).reduce((a, b) => a + b);

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    
    TrendDirection lengthTrend;
    if (slope.abs() < 0.1) {
      lengthTrend = TrendDirection.stable;
    } else if (slope > 0) {
      lengthTrend = TrendDirection.increasing;
    } else {
      lengthTrend = TrendDirection.decreasing;
    }

    // Analyze symptom patterns
    final symptomTrends = _analyzeSymptomTrends(recentCycles);

    return CycleTrends(
      lengthTrend: lengthTrend,
      lengthTrendValue: slope,
      symptomTrends: symptomTrends,
    );
  }

  /// Analyze symptom patterns and trends
  static Map<String, SymptomTrend> _analyzeSymptomTrends(List<CycleData> cycles) {
    final symptomFrequency = <String, List<bool>>{};
    
    for (final cycle in cycles) {
      final allPossibleSymptoms = ['cramps', 'headache', 'mood_swings', 'fatigue', 'bloating'];
      
      for (final symptom in allPossibleSymptoms) {
        symptomFrequency[symptom] ??= [];
        symptomFrequency[symptom]!.add(cycle.symptoms.contains(symptom));
      }
    }

    final trends = <String, SymptomTrend>{};
    
    for (final entry in symptomFrequency.entries) {
      final symptom = entry.key;
      final occurrences = entry.value;
      
      if (occurrences.length >= 3) {
        final recent = occurrences.take(3).where((x) => x).length;
        final older = occurrences.skip(3).where((x) => x).length;
        final olderTotal = max(1, occurrences.skip(3).length);
        
        final recentFreq = recent / 3.0;
        final olderFreq = older / olderTotal;
        
        final change = recentFreq - olderFreq;
        
        TrendDirection direction;
        if (change.abs() < 0.2) {
          direction = TrendDirection.stable;
        } else if (change > 0) {
          direction = TrendDirection.increasing;
        } else {
          direction = TrendDirection.decreasing;
        }
        
        trends[symptom] = SymptomTrend(
          frequency: recentFreq,
          trend: direction,
          change: change,
        );
      }
    }
    
    return trends;
  }

  /// Calculate prediction accuracy for recent cycles
  static double _calculatePredictionAccuracy(List<CycleData> cycles) {
    if (cycles.length < 3) return 0.0;

    double totalAccuracy = 0.0;
    int validPredictions = 0;

    for (int i = 1; i < min(cycles.length, 6); i++) {
      final actualCycle = cycles[i - 1];
      final previousCycles = cycles.skip(i).toList();
      
      if (previousCycles.length >= 2) {
        // Calculate predicted start date based on previous cycles
        final avgLength = previousCycles
            .take(3)
            .map((c) => c.length)
            .reduce((a, b) => a + b) / min(3, previousCycles.length);
        
        final lastCycleEnd = previousCycles.first.endDate;
        final predictedStart = lastCycleEnd.add(Duration(days: avgLength.round()));
        
        // Calculate accuracy (inverse of days difference, capped at 7 days)
        final daysDifference = (actualCycle.startDate.difference(predictedStart).inDays).abs();
        final accuracy = max(0.0, 1.0 - (daysDifference / 7.0));
        
        totalAccuracy += accuracy;
        validPredictions++;
      }
    }

    return validPredictions > 0 ? (totalAccuracy / validPredictions) * 100 : 0.0;
  }

  /// Calculate regularity score (0-100, higher = more regular)
  static double _calculateRegularityScore(List<int> lengths, double standardDeviation) {
    if (lengths.length < 2) return 100.0;

    // Score based on standard deviation (lower deviation = higher score)
    // Perfect regularity (std dev = 0) = 100, high variation (std dev > 7) = 0
    final regularityFromVariation = max(0.0, 100.0 - (standardDeviation * 14.3));

    // Bonus for having cycles within "normal" range (21-35 days)
    final normalCycles = lengths.where((l) => l >= 21 && l <= 35).length;
    final normalRatio = normalCycles / lengths.length;
    final normalBonus = normalRatio * 10;

    return min(100.0, regularityFromVariation + normalBonus);
  }

  /// Calculate next cycle predictions
  static CyclePrediction predictNextCycle(List<Map<String, dynamic>> cycles) {
    final completedCycles = cycles
        .where((c) => c['end'] != null && c['start'] != null)
        .toList();

    if (completedCycles.length < 2) {
      return CyclePrediction.empty();
    }

    // Get recent cycles for prediction
    final recentCycles = completedCycles
        .take(6)
        .map((c) => CycleData(
              id: c['id'] ?? '',
              startDate: _parseDate(c['start'])!,
              endDate: _parseDate(c['end'])!,
              length: _parseDate(c['end'])!.difference(_parseDate(c['start'])!).inDays + 1,
            ))
        .where((c) => c.length > 0 && c.length <= 60)
        .toList()
      ..sort((a, b) => b.endDate.compareTo(a.endDate));

    if (recentCycles.isEmpty) {
      return CyclePrediction.empty();
    }

    // Calculate weighted average (more weight to recent cycles)
    double weightedSum = 0;
    double totalWeight = 0;
    
    for (int i = 0; i < recentCycles.length; i++) {
      final weight = 1.0 / (i + 1); // More recent cycles get higher weight
      weightedSum += recentCycles[i].length * weight;
      totalWeight += weight;
    }
    
    final predictedLength = (weightedSum / totalWeight).round();
    
    // Predict next cycle start
    final lastCycleEnd = recentCycles.first.endDate;
    final predictedStart = lastCycleEnd.add(Duration(days: predictedLength));
    final predictedEnd = predictedStart.add(Duration(days: predictedLength - 1));
    
    // Calculate confidence based on regularity
    final lengths = recentCycles.map((c) => c.length).toList();
    final avgLength = lengths.reduce((a, b) => a + b) / lengths.length;
    final variance = lengths.map((l) => pow(l - avgLength, 2)).reduce((a, b) => a + b) / lengths.length;
    final standardDeviation = sqrt(variance);
    
    final confidence = max(0.5, 1.0 - (standardDeviation / 10.0));
    
    // Predict ovulation (typically 14 days before period, but can vary 12-16 days)
    final ovulationStart = predictedStart.subtract(const Duration(days: 16));
    final ovulationEnd = predictedStart.subtract(const Duration(days: 12));
    
    return CyclePrediction(
      nextCycleStart: predictedStart,
      nextCycleEnd: predictedEnd,
      predictedLength: predictedLength,
      confidence: confidence * 100,
      ovulationWindow: DateRange(ovulationStart, ovulationEnd),
      daysUntilNext: predictedStart.difference(DateTime.now()).inDays,
    );
  }

  /// Parse date from various formats
  static DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    
    try {
      if (date is DateTime) {
        return date;
      } else if (date.toString().contains('Timestamp')) {
        return (date as dynamic).toDate();
      } else {
        return DateTime.parse(date.toString());
      }
    } catch (e) {
      return null;
    }
  }

  /// Parse symptoms from various formats
  static List<String> _parseSymptoms(dynamic symptoms) {
    if (symptoms == null) return [];
    
    if (symptoms is List) {
      return symptoms.map((s) => s.toString()).toList();
    } else if (symptoms is String) {
      return symptoms.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }
    
    return [];
  }
}

// Data Models

class CycleStatistics {
  final int totalCycles;
  final double averageLength;
  final int shortestCycle;
  final int longestCycle;
  final double standardDeviation;
  final double regularityScore;
  final CycleTrends trends;
  final double predictionAccuracy;
  final List<CycleData> recentCycles;
  final List<int> cycleLengthHistory;

  CycleStatistics({
    required this.totalCycles,
    required this.averageLength,
    required this.shortestCycle,
    required this.longestCycle,
    required this.standardDeviation,
    required this.regularityScore,
    required this.trends,
    required this.predictionAccuracy,
    required this.recentCycles,
    required this.cycleLengthHistory,
  });

  factory CycleStatistics.empty() => CycleStatistics(
        totalCycles: 0,
        averageLength: 0,
        shortestCycle: 0,
        longestCycle: 0,
        standardDeviation: 0,
        regularityScore: 0,
        trends: CycleTrends.empty(),
        predictionAccuracy: 0,
        recentCycles: [],
        cycleLengthHistory: [],
      );
}

class CycleData {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final int length;
  final String? flow;
  final List<String> symptoms;
  final String? notes;

  CycleData({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.length,
    this.flow,
    this.symptoms = const [],
    this.notes,
  });
}

class CycleTrends {
  final TrendDirection lengthTrend;
  final double lengthTrendValue;
  final Map<String, SymptomTrend> symptomTrends;

  CycleTrends({
    required this.lengthTrend,
    required this.lengthTrendValue,
    required this.symptomTrends,
  });

  factory CycleTrends.empty() => CycleTrends(
        lengthTrend: TrendDirection.stable,
        lengthTrendValue: 0,
        symptomTrends: {},
      );
}

class SymptomTrend {
  final double frequency; // 0.0 to 1.0
  final TrendDirection trend;
  final double change;

  SymptomTrend({
    required this.frequency,
    required this.trend,
    required this.change,
  });
}

class CyclePrediction {
  final DateTime nextCycleStart;
  final DateTime nextCycleEnd;
  final int predictedLength;
  final double confidence; // 0-100
  final DateRange ovulationWindow;
  final int daysUntilNext;

  CyclePrediction({
    required this.nextCycleStart,
    required this.nextCycleEnd,
    required this.predictedLength,
    required this.confidence,
    required this.ovulationWindow,
    required this.daysUntilNext,
  });

  factory CyclePrediction.empty() => CyclePrediction(
        nextCycleStart: DateTime.now(),
        nextCycleEnd: DateTime.now(),
        predictedLength: 0,
        confidence: 0,
        ovulationWindow: DateRange(DateTime.now(), DateTime.now()),
        daysUntilNext: 0,
      );
}

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange(this.start, this.end);
}

enum TrendDirection { increasing, decreasing, stable }

extension TrendDirectionExtension on TrendDirection {
  String get displayName {
    switch (this) {
      case TrendDirection.increasing:
        return 'Increasing';
      case TrendDirection.decreasing:
        return 'Decreasing';
      case TrendDirection.stable:
        return 'Stable';
    }
  }

  String get icon {
    switch (this) {
      case TrendDirection.increasing:
        return '📈';
      case TrendDirection.decreasing:
        return '📉';
      case TrendDirection.stable:
        return '➡️';
    }
  }
}
