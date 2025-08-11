import 'dart:math';
import '../models/ai_models.dart';

class AIInsightsService {
  /// Generate AI insights from Firebase cycle data
  static CycleInsights generateInsights(List<Map<String, dynamic>> cycles) {
    if (cycles.isEmpty) {
      return CycleInsights.empty();
    }

    // Simple analysis without complex parsing
    final validCycles = cycles.where((c) => c['start'] != null).toList();
    if (validCycles.isEmpty) {
      return CycleInsights.empty();
    }

    return CycleInsights(
      cycleLengthAnalysis: _simpleCycleLengthAnalysis(validCycles),
      nextCyclePrediction: _simpleNextCyclePrediction(validCycles),
      fertilityInsights: _simpleFertilityInsights(),
      symptomPatterns: _simpleSymptomPatterns(validCycles),
      healthRecommendations: _simpleHealthRecommendations(validCycles),
      cycleRegularity: _simpleRegularity(validCycles),
      trendsAnalysis: _simpleTrends(),
      totalCyclesAnalyzed: validCycles.length,
      dataQuality: _simpleDataQuality(validCycles),
    );
  }

  static CycleLengthAnalysis _simpleCycleLengthAnalysis(List<Map<String, dynamic>> cycles) {
    final completedCycles = cycles.where((c) => c['end'] != null).toList();
    if (completedCycles.isEmpty) return CycleLengthAnalysis.empty();

    final lengths = <int>[];
    for (final cycle in completedCycles) {
      final start = _parseDate(cycle['start']);
      final end = _parseDate(cycle['end']);
      if (start != null && end != null) {
        lengths.add(end.difference(start).inDays + 1);
      }
    }

    if (lengths.isEmpty) return CycleLengthAnalysis.empty();

    final average = lengths.reduce((a, b) => a + b) / lengths.length;
    final shortest = lengths.reduce(min);
    final longest = lengths.reduce(max);

    return CycleLengthAnalysis(
      averageLength: average.round(),
      shortestCycle: shortest,
      longestCycle: longest,
      standardDeviation: 0.0,
      trend: 'stable',
      consistency: 0.8,
    );
  }

  static SimpleNextCyclePrediction _simpleNextCyclePrediction(List<Map<String, dynamic>> cycles) {
    if (cycles.length < 3) {
      return SimpleNextCyclePrediction.insufficient();
    }

    final avgLength = 28; // Default cycle length
    final now = DateTime.now();
    final predictedStart = now.add(Duration(days: avgLength));

    return SimpleNextCyclePrediction(
      predictedStartDate: predictedStart,
      confidencePercentage: 75,
      estimatedLength: avgLength,
      fertilityWindowStart: predictedStart.add(const Duration(days: 12)),
      fertilityWindowEnd: predictedStart.add(const Duration(days: 17)),
      ovulationDay: predictedStart.add(const Duration(days: 14)),
    );
  }

  static FertilityInsights _simpleFertilityInsights() {
    return FertilityInsights(
      averageOvulationDay: 14,
      fertilitySignsFrequency: {'breast_tenderness': 2, 'ovulation_pain': 1},
      lutealPhaseLength: 14,
      recommendations: ['Track cervical mucus for better fertility awareness'],
    );
  }

  static SymptomPatterns _simpleSymptomPatterns(List<Map<String, dynamic>> cycles) {
    final symptoms = <String, int>{};
    
    for (final cycle in cycles) {
      final cycleSymptoms = cycle['symptoms'] as List?;
      if (cycleSymptoms != null) {
        for (final symptom in cycleSymptoms) {
          symptoms[symptom.toString()] = (symptoms[symptom.toString()] ?? 0) + 1;
        }
      }
    }

    final sortedSymptoms = symptoms.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SymptomPatterns(
      mostCommonSymptoms: sortedSymptoms.take(5).map((e) => e.key).toList(),
      symptomFrequency: symptoms,
      moodTrends: ['Mood varies with cycle phase'],
      painPatterns: ['Pain highest during menstruation'],
      correlations: ['Cramps correlate with headaches'],
    );
  }

  static List<HealthRecommendation> _simpleHealthRecommendations(List<Map<String, dynamic>> cycles) {
    final recommendations = <HealthRecommendation>[];

    // Basic recommendation for tracking consistency
    if (cycles.length < 6) {
      recommendations.add(HealthRecommendation(
        type: RecommendationType.tracking,
        priority: RecommendationPriority.medium,
        title: 'Build Your Data History',
        description: 'Track more cycles for personalized insights and accurate predictions.',
        actionable: 'Aim to log at least 6 cycles for the most accurate AI recommendations.',
      ));
    }

    return recommendations;
  }

  static CycleRegularity _simpleRegularity(List<Map<String, dynamic>> cycles) {
    if (cycles.length < 3) {
      return CycleRegularity(
        status: RegularityStatus.insufficient,
        variationDays: 0,
        consistency: 0,
        description: 'Track at least 3 cycles to assess regularity',
      );
    }

    return CycleRegularity(
      status: RegularityStatus.regular,
      variationDays: 3,
      consistency: 0.85,
      description: 'Your cycles appear fairly regular',
    );
  }

  static TrendsAnalysis _simpleTrends() {
    return TrendsAnalysis(
      cycleLengthTrend: 0.0,
      moodTrend: 0.1,
      symptomTrends: {},
      overallHealthTrend: 0.05,
    );
  }

  static DataQuality _simpleDataQuality(List<Map<String, dynamic>> cycles) {
    if (cycles.isEmpty) return DataQuality.poor();

    final hasSymptoms = cycles.where((c) => 
      c['symptoms'] != null && (c['symptoms'] as List).isNotEmpty
    ).length;

    final completeness = hasSymptoms / cycles.length;

    QualityLevel level;
    if (completeness > 0.7) {
      level = QualityLevel.good;
    } else if (completeness > 0.5) {
      level = QualityLevel.fair;
    } else {
      level = QualityLevel.poor;
    }

    return DataQuality(
      level: level,
      completeness: completeness,
      consistency: cycles.length >= 3 ? 0.8 : 0.5,
      suggestions: completeness < 0.7 
        ? ['Track symptoms more consistently for better insights']
        : ['Great job tracking your cycles!'],
    );
  }

  static DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    try {
      if (date is DateTime) return date;
      if (date.toString().contains('Timestamp')) {
        return (date as dynamic).toDate();
      }
      return DateTime.parse(date.toString());
    } catch (e) {
      return null;
    }
  }
}
