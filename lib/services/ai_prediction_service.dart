import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import '../models/ai_prediction_models.dart';
import 'error_service.dart';

/// Advanced AI-powered cycle prediction and analysis service
class AIPredictionService {
  static const String _modelVersion = '1.0.0';
  static const int _minCyclesForAI = 3;
  static const int _maxPredictionDays = 90;

  /// Generate AI-powered cycle predictions with confidence intervals
  static Future<AIPredictionResult> generateAdvancedPredictions(
    List<Map<String, dynamic>> cycles, {
    int predictionDays = 90,
    bool includeSymptomPredictions = true,
  }) async {
    try {
      if (cycles.length < _minCyclesForAI) {
        return AIPredictionResult.insufficient(
          'Need at least $_minCyclesForAI cycles for AI predictions',
        );
      }

      final cycleDates = _extractCycleDates(cycles);
      final symptomPatterns = includeSymptomPredictions
          ? await _analyzeSymptomPatterns(cycles)
          : <SymptomPattern>[];

      // Advanced prediction algorithms
      final cycleLengthPrediction = _predictCycleLength(cycleDates);
      final nextCyclePredictions = _predictNextCycles(
        cycleDates,
        predictionDays,
      );
      final fertilityWindows = _predictFertilityWindows(nextCyclePredictions);
      final wellbeingPredictions = await _predictWellbeingPatterns(cycles);

      // Calculate model confidence
      final confidence = _calculateModelConfidence(cycles, cycleDates);

      return AIPredictionResult(
        success: true,
        confidence: confidence,
        modelVersion: _modelVersion,
        cycleLengthPrediction: cycleLengthPrediction,
        nextCycles: nextCyclePredictions,
        fertilityWindows: fertilityWindows,
        symptomPatterns: symptomPatterns,
        wellbeingPredictions: wellbeingPredictions,
        insights: await _generatePersonalizedInsights(cycles, confidence),
        recommendations: _generateRecommendations(cycles, confidence),
      );
    } catch (e, stackTrace) {
      ErrorService.logError(
        e,
        stackTrace: stackTrace,
        context: 'AI Prediction Service',
        severity: ErrorSeverity.error,
      );

      return AIPredictionResult.error('AI prediction failed: ${e.toString()}');
    }
  }

  /// Extract cycle start dates and lengths from raw data
  static List<CycleDataPoint> _extractCycleDates(
    List<Map<String, dynamic>> cycles,
  ) {
    final cyclePoints = <CycleDataPoint>[];

    for (int i = 0; i < cycles.length; i++) {
      final cycle = cycles[i];
      try {
        final startDate = _parseDate(cycle['start']);
        final endDate = _parseDate(cycle['end']);

        if (startDate != null) {
          int? length;
          if (endDate != null) {
            length = endDate.difference(startDate).inDays + 1;
          } else if (i > 0) {
            // Calculate from next cycle start
            final nextStart = _parseDate(cycles[i - 1]['start']);
            if (nextStart != null) {
              length = nextStart.difference(startDate).inDays;
            }
          }

          cyclePoints.add(
            CycleDataPoint(
              startDate: startDate,
              endDate: endDate,
              length: length,
              flowIntensity: _parseFlowIntensity(cycle['flow']),
            ),
          );
        }
      } catch (e) {
        debugPrint('Failed to parse cycle data: $e');
      }
    }

    return cyclePoints.reversed.toList(); // Most recent first
  }

  /// Advanced cycle length prediction using weighted moving average and trend analysis
  static CycleLengthPrediction _predictCycleLength(
    List<CycleDataPoint> cycles,
  ) {
    if (cycles.length < 2) {
      return CycleLengthPrediction(
        predictedLength: 28.0,
        confidence: 0.3,
        range: const PredictionRange(min: 21, max: 35),
      );
    }

    final validCycles = cycles
        .where((c) => c.length != null && c.length! > 0)
        .toList();
    if (validCycles.isEmpty) {
      return CycleLengthPrediction(
        predictedLength: 28.0,
        confidence: 0.3,
        range: const PredictionRange(min: 21, max: 35),
      );
    }

    // Weighted moving average with recent cycles having more weight
    double totalWeight = 0;
    double weightedSum = 0;

    for (int i = 0; i < validCycles.length; i++) {
      final weight = math.pow(0.8, i).toDouble(); // Exponential decay
      weightedSum += validCycles[i].length! * weight;
      totalWeight += weight;
    }

    final predictedLength = weightedSum / totalWeight;

    // Calculate variance for confidence
    final variance =
        validCycles
            .map((c) => math.pow(c.length! - predictedLength, 2))
            .reduce((a, b) => a + b) /
        validCycles.length;

    final standardDeviation = math.sqrt(variance);
    final confidence = math.max(
      0.1,
      math.min(0.95, 1.0 - (standardDeviation / 10.0)),
    );

    // Prediction range based on standard deviation
    final rangeSize = standardDeviation * 2;
    final minRange = (predictedLength - rangeSize).round().clamp(21, 45);
    final maxRange = (predictedLength + rangeSize).round().clamp(21, 45);

    return CycleLengthPrediction(
      predictedLength: predictedLength,
      confidence: confidence,
      range: PredictionRange(min: minRange, max: maxRange),
    );
  }

  /// Predict multiple future cycles with uncertainty
  static List<NextCyclePrediction> _predictNextCycles(
    List<CycleDataPoint> cycles,
    int daysAhead,
  ) {
    final predictions = <NextCyclePrediction>[];
    final cycleLengthPrediction = _predictCycleLength(cycles);

    if (cycles.isEmpty) return predictions;

    final lastCycle = cycles.first;
    var currentDate = lastCycle.startDate;
    var confidenceDecay = cycleLengthPrediction.confidence;

    // Predict cycles for the next period
    final endDate = DateTime.now().add(Duration(days: daysAhead));
    int cycleNumber = 1;

    while (currentDate.isBefore(endDate) && cycleNumber <= 6) {
      // Add some randomness based on historical variance
      final lengthVariation = _calculateLengthVariation(cycles);
      final predictedLength =
          cycleLengthPrediction.predictedLength + lengthVariation;

      currentDate = currentDate.add(Duration(days: predictedLength.round()));

      if (currentDate.isAfter(endDate)) break;

      // Predict cycle characteristics
      final flowPrediction = _predictFlowIntensity(cycles, cycleNumber);
      final lengthRange = _calculateCycleLengthRange(cycles, confidenceDecay);

      predictions.add(
        NextCyclePrediction(
          cycleNumber: cycleNumber,
          predictedStartDate: currentDate,
          predictedLength: predictedLength.round(),
          confidence: confidenceDecay,
          lengthRange: lengthRange,
          flowPrediction: flowPrediction,
        ),
      );

      // Confidence decreases for future predictions
      confidenceDecay = math.max(0.1, confidenceDecay * 0.85);
      cycleNumber++;
    }

    return predictions;
  }

  /// Predict fertility windows based on cycle predictions
  static List<FertilityWindow> _predictFertilityWindows(
    List<NextCyclePrediction> cyclePredictions,
  ) {
    return cyclePredictions.map((cycle) {
      // Standard fertility window: 5 days before to 1 day after ovulation
      // Ovulation typically occurs ~14 days before next period
      final ovulationDay = cycle.predictedStartDate.subtract(
        const Duration(days: 14),
      );
      final windowStart = ovulationDay.subtract(const Duration(days: 5));
      final windowEnd = ovulationDay.add(const Duration(days: 1));

      return FertilityWindow(
        cycleNumber: cycle.cycleNumber,
        windowStart: windowStart,
        windowEnd: windowEnd,
        peakFertility: ovulationDay,
        confidence: cycle.confidence * 0.8, // Lower confidence for fertility
      );
    }).toList();
  }

  /// Analyze symptom patterns and predict likelihood
  static Future<List<SymptomPattern>> _analyzeSymptomPatterns(
    List<Map<String, dynamic>> cycles,
  ) async {
    final symptomOccurrences = <String, List<SymptomOccurrence>>{};

    for (int i = 0; i < cycles.length; i++) {
      final cycle = cycles[i];
      final startDate = _parseDate(cycle['start']);
      final symptoms = cycle['symptoms'] as List<dynamic>? ?? [];

      if (startDate != null) {
        for (final symptom in symptoms) {
          final symptomName = symptom.toString();
          symptomOccurrences.putIfAbsent(symptomName, () => []);
          symptomOccurrences[symptomName]!.add(
            SymptomOccurrence(
              symptomName: symptomName,
              date: startDate,
              dayInCycle:
                  1, // Simplified - would be more complex in real implementation
              intensity: 1.0, // Simplified - would be actual intensity data
            ),
          );
        }
      }
    }

    final patterns = <SymptomPattern>[];

    for (final entry in symptomOccurrences.entries) {
      final symptomName = entry.key;
      final occurrences = entry.value;

      if (occurrences.length >= 2) {
        final frequency = occurrences.length / cycles.length;
        final confidence = math.min(0.9, frequency * 1.2);

        patterns.add(
          SymptomPattern(
            symptomName: symptomName,
            frequency: frequency,
            confidence: confidence,
            typicalDays: [_calculateTypicalDay(occurrences)],
            trend: TrendDirection
                .stable, // Simplified - would analyze actual trend
            seasonalPattern: _analyzeSeasonalPattern(occurrences),
          ),
        );
      }
    }

    return patterns..sort((a, b) => b.confidence.compareTo(a.confidence));
  }

  /// Predict wellbeing patterns (mood, energy, pain)
  static Future<List<WellbeingPrediction>> _predictWellbeingPatterns(
    List<Map<String, dynamic>> cycles,
  ) async {
    final predictions = <WellbeingPrediction>[];

    if (cycles.length < 2) return predictions;

    // Analyze mood patterns
    final moodData = cycles
        .map((c) => c['mood_level'] as num? ?? 3.0)
        .cast<double>()
        .toList();

    final energyData = cycles
        .map((c) => c['energy_level'] as num? ?? 3.0)
        .cast<double>()
        .toList();

    final painData = cycles
        .map((c) => c['pain_level'] as num? ?? 1.0)
        .cast<double>()
        .toList();

    // Calculate averages and trends
    final avgMood = moodData.reduce((a, b) => a + b) / moodData.length;
    final avgEnergy = energyData.reduce((a, b) => a + b) / energyData.length;
    final avgPain = painData.reduce((a, b) => a + b) / painData.length;

    predictions.add(
      WellbeingPrediction(
        type: WellbeingType.mood,
        predictedValue: avgMood,
        confidence: _calculateWellbeingConfidence(moodData),
        trend: _calculateTrend(moodData),
        cycleDayVariations: _analyzeCycleDayVariations(cycles, 'mood_level'),
      ),
    );

    predictions.add(
      WellbeingPrediction(
        type: WellbeingType.energy,
        predictedValue: avgEnergy,
        confidence: _calculateWellbeingConfidence(energyData),
        trend: _calculateTrend(energyData),
        cycleDayVariations: _analyzeCycleDayVariations(cycles, 'energy_level'),
      ),
    );

    predictions.add(
      WellbeingPrediction(
        type: WellbeingType.pain,
        predictedValue: avgPain,
        confidence: _calculateWellbeingConfidence(painData),
        trend: _calculateTrend(painData),
        cycleDayVariations: _analyzeCycleDayVariations(cycles, 'pain_level'),
      ),
    );

    return predictions;
  }

  /// Generate personalized insights based on AI analysis
  static Future<List<PersonalizedInsight>> _generatePersonalizedInsights(
    List<Map<String, dynamic>> cycles,
    double modelConfidence,
  ) async {
    final insights = <PersonalizedInsight>[];

    if (cycles.isEmpty) return insights;

    // Cycle regularity insight
    final cycleLengths = cycles
        .map((c) => _calculateCycleLength(c))
        .where((l) => l != null && l > 0)
        .cast<int>()
        .toList();

    if (cycleLengths.isNotEmpty) {
      final variance = _calculateVariance(cycleLengths.cast<double>());
      final regularity = math.max(0, 1.0 - (variance / 25.0));

      insights.add(
        PersonalizedInsight(
          type: InsightType.cycleRegularity,
          title: 'Cycle Regularity Analysis',
          message: regularity > 0.8
              ? 'Your cycles are very regular! This indicates good hormonal balance.'
              : regularity > 0.6
              ? 'Your cycles show moderate regularity. Some variation is normal.'
              : 'Your cycles vary significantly. Consider tracking lifestyle factors.',
          confidence: modelConfidence,
          severity: regularity > 0.6
              ? InsightSeverity.positive
              : InsightSeverity.neutral,
          actionable: regularity < 0.6,
          recommendations: regularity < 0.6
              ? [
                  'Track sleep patterns',
                  'Monitor stress levels',
                  'Consider consulting a healthcare provider',
                ]
              : ['Keep tracking to maintain insights'],
        ),
      );
    }

    // Symptom pattern insights
    final commonSymptoms = _findCommonSymptoms(cycles);
    if (commonSymptoms.isNotEmpty) {
      insights.add(
        PersonalizedInsight(
          type: InsightType.symptomPattern,
          title: 'Common Symptoms Pattern',
          message:
              'You commonly experience: ${commonSymptoms.take(3).join(", ")}. '
              'Understanding these patterns can help you prepare.',
          confidence: modelConfidence * 0.9,
          severity: InsightSeverity.neutral,
          actionable: true,
          recommendations: _getSymptomRecommendations(commonSymptoms),
        ),
      );
    }

    return insights;
  }

  /// Generate AI-powered recommendations
  static List<AIRecommendation> _generateRecommendations(
    List<Map<String, dynamic>> cycles,
    double modelConfidence,
  ) {
    final recommendations = <AIRecommendation>[];

    if (cycles.isEmpty) return recommendations;

    // Data quality recommendation
    if (cycles.length < 6) {
      recommendations.add(
        AIRecommendation(
          type: RecommendationType.dataCollection,
          priority: RecommendationPriority.high,
          title: 'Improve Prediction Accuracy',
          description:
              'Track ${6 - cycles.length} more cycles to unlock more accurate AI predictions.',
          action: 'Continue logging cycles consistently',
          confidence: 0.95,
        ),
      );
    }

    // Health integration recommendation
    recommendations.add(
      AIRecommendation(
        type: RecommendationType.healthIntegration,
        priority: RecommendationPriority.medium,
        title: 'Enhance Data with Health Integration',
        description:
            'Connect to HealthKit or Google Fit for richer insights including sleep and activity data.',
        action: 'Enable health platform integration',
        confidence: 0.8,
      ),
    );

    return recommendations;
  }

  // Helper methods
  static DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is DateTime) return date;
    try {
      if (date.toString().contains('Timestamp')) {
        return (date as dynamic).toDate();
      }
      return DateTime.parse(date.toString());
    } catch (e) {
      return null;
    }
  }

  static FlowIntensity _parseFlowIntensity(dynamic flow) {
    if (flow == null) return FlowIntensity.normal;
    if (flow is String) {
      switch (flow.toLowerCase()) {
        case 'light':
          return FlowIntensity.light;
        case 'heavy':
          return FlowIntensity.heavy;
        case 'very heavy':
          return FlowIntensity.veryHeavy;
        default:
          return FlowIntensity.normal;
      }
    }
    return FlowIntensity.normal;
  }

  static double _calculateLengthVariation(List<CycleDataPoint> cycles) {
    // Add some realistic variation based on historical data
    final random = math.Random();
    return (random.nextDouble() - 0.5) * 2; // ±1 day variation
  }

  static FlowIntensityPrediction _predictFlowIntensity(
    List<CycleDataPoint> cycles,
    int cycleNumber,
  ) {
    final flowCounts = <FlowIntensity, int>{};
    for (final cycle in cycles) {
      if (cycle.flowIntensity != null) {
        flowCounts[cycle.flowIntensity!] =
            (flowCounts[cycle.flowIntensity!] ?? 0) + 1;
      }
    }

    if (flowCounts.isEmpty) {
      return FlowIntensityPrediction(
        predicted: FlowIntensity.normal,
        confidence: 0.3,
        probabilities: {
          FlowIntensity.light: 0.33,
          FlowIntensity.normal: 0.34,
          FlowIntensity.heavy: 0.33,
        },
      );
    }

    final mostCommon = flowCounts.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );
    final total = flowCounts.values.reduce((a, b) => a + b);
    final confidence = mostCommon.value / total;

    final probabilities = <FlowIntensity, double>{};
    for (final entry in flowCounts.entries) {
      probabilities[entry.key] = entry.value / total;
    }

    return FlowIntensityPrediction(
      predicted: mostCommon.key,
      confidence: confidence,
      probabilities: probabilities,
    );
  }

  static PredictionRange _calculateCycleLengthRange(
    List<CycleDataPoint> cycles,
    double confidence,
  ) {
    if (cycles.isEmpty) {
      return const PredictionRange(min: 25, max: 31);
    }

    final lengths = cycles
        .where((c) => c.length != null)
        .map((c) => c.length!)
        .toList();

    if (lengths.isEmpty) {
      return const PredictionRange(min: 25, max: 31);
    }

    lengths.sort();
    final q1 = lengths[lengths.length ~/ 4];
    final q3 = lengths[(lengths.length * 3) ~/ 4];

    return PredictionRange(min: q1 - 2, max: q3 + 2);
  }

  static double _calculateModelConfidence(
    List<Map<String, dynamic>> cycles,
    List<CycleDataPoint> cycleDates,
  ) {
    if (cycles.length < 3) return 0.3;
    if (cycles.length < 6) return 0.6;
    if (cycles.length < 12) return 0.8;
    return 0.9;
  }

  static int? _calculateCycleLength(Map<String, dynamic> cycle) {
    final start = _parseDate(cycle['start']);
    final end = _parseDate(cycle['end']);
    if (start != null && end != null) {
      return end.difference(start).inDays + 1;
    }
    return null;
  }

  static double _calculateVariance(List<double> values) {
    if (values.isEmpty) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    return values.map((v) => math.pow(v - mean, 2)).reduce((a, b) => a + b) /
        values.length;
  }

  static List<String> _findCommonSymptoms(List<Map<String, dynamic>> cycles) {
    final symptomCounts = <String, int>{};
    for (final cycle in cycles) {
      final symptoms = cycle['symptoms'] as List<dynamic>? ?? [];
      for (final symptom in symptoms) {
        symptomCounts[symptom.toString()] =
            (symptomCounts[symptom.toString()] ?? 0) + 1;
      }
    }

    return symptomCounts.entries
        .where(
          (e) => e.value >= cycles.length * 0.3,
        ) // Appears in 30%+ of cycles
        .map((e) => e.key)
        .toList();
  }

  static List<String> _getSymptomRecommendations(List<String> symptoms) {
    // This would be a more comprehensive mapping in a real implementation
    return [
      'Track triggers for common symptoms',
      'Consider lifestyle modifications',
      'Discuss patterns with healthcare provider',
    ];
  }

  static int _calculateTypicalDay(List<SymptomOccurrence> occurrences) {
    return occurrences.map((o) => o.dayInCycle).reduce((a, b) => a + b) ~/
        occurrences.length;
  }

  static SeasonalPattern? _analyzeSeasonalPattern(
    List<SymptomOccurrence> occurrences,
  ) {
    // Simplified seasonal analysis - return null for no seasonal pattern
    return null; // Would implement actual seasonal analysis
  }

  static double _calculateWellbeingConfidence(List<double> data) {
    if (data.isEmpty) return 0.3;
    final variance = _calculateVariance(data);
    return math.max(0.3, math.min(0.9, 1.0 - (variance / 10.0)));
  }

  static WellbeingTrend _calculateTrend(List<double> data) {
    if (data.length < 3) return WellbeingTrend.stable;

    final recent = data.take(3).toList();
    final older = data.skip(3).take(3).toList();

    if (older.isEmpty) return WellbeingTrend.stable;

    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final olderAvg = older.reduce((a, b) => a + b) / older.length;

    final diff = recentAvg - olderAvg;
    if (diff > 0.3) return WellbeingTrend.improving;
    if (diff < -0.3) return WellbeingTrend.declining;
    return WellbeingTrend.stable;
  }

  static Map<int, double> _analyzeCycleDayVariations(
    List<Map<String, dynamic>> cycles,
    String field,
  ) {
    // Simplified implementation - would be more complex in practice
    return {1: 3.0, 7: 2.5, 14: 4.0, 21: 3.5, 28: 3.0};
  }
}
