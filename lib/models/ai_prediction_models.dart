import 'package:flutter/foundation.dart';

/// Result of AI prediction analysis
class AIPredictionResult {
  final bool success;
  final double confidence;
  final String? error;
  final String modelVersion;
  final CycleLengthPrediction? cycleLengthPrediction;
  final List<NextCyclePrediction> nextCycles;
  final List<FertilityWindow> fertilityWindows;
  final List<SymptomPattern> symptomPatterns;
  final List<WellbeingPrediction> wellbeingPredictions;
  final List<PersonalizedInsight> insights;
  final List<AIRecommendation> recommendations;

  AIPredictionResult({
    required this.success,
    required this.confidence,
    this.error,
    required this.modelVersion,
    this.cycleLengthPrediction,
    this.nextCycles = const [],
    this.fertilityWindows = const [],
    this.symptomPatterns = const [],
    this.wellbeingPredictions = const [],
    this.insights = const [],
    this.recommendations = const [],
  });

  factory AIPredictionResult.insufficient(String message) => AIPredictionResult(
    success: false,
    confidence: 0.0,
    error: message,
    modelVersion: '1.0.0',
  );

  factory AIPredictionResult.error(String message) => AIPredictionResult(
    success: false,
    confidence: 0.0,
    error: message,
    modelVersion: '1.0.0',
  );
}

/// Data point representing a cycle for AI analysis
class CycleDataPoint {
  final DateTime startDate;
  final DateTime? endDate;
  final int? length;
  final FlowIntensity? flowIntensity;
  final int? dayInCycle;

  CycleDataPoint({
    required this.startDate,
    this.endDate,
    this.length,
    this.flowIntensity,
    this.dayInCycle,
  });
}

/// Cycle length prediction with confidence
class CycleLengthPrediction {
  final double predictedLength;
  final double confidence;
  final PredictionRange range;

  CycleLengthPrediction({
    required this.predictedLength,
    required this.confidence,
    required this.range,
  });
}

/// Range for predictions
class PredictionRange {
  final int min;
  final int max;

  const PredictionRange({required this.min, required this.max});
}

/// Prediction for next cycle
class NextCyclePrediction {
  final int cycleNumber;
  final DateTime predictedStartDate;
  final int predictedLength;
  final double confidence;
  final PredictionRange lengthRange;
  final FlowIntensityPrediction? flowPrediction;

  NextCyclePrediction({
    required this.cycleNumber,
    required this.predictedStartDate,
    required this.predictedLength,
    required this.confidence,
    required this.lengthRange,
    this.flowPrediction,
  });
}

/// Flow intensity prediction
class FlowIntensityPrediction {
  final FlowIntensity predictedIntensity;
  final double confidence;
  final Map<FlowIntensity, double> probabilityDistribution;

  FlowIntensityPrediction({
    required this.predictedIntensity,
    required this.confidence,
    required this.probabilityDistribution,
  });
}

/// Fertility window prediction
class FertilityWindow {
  final int cycleNumber;
  final DateTime startDate;
  final DateTime endDate;
  final double confidence;
  final FertilityPhase phase;

  FertilityWindow({
    required this.cycleNumber,
    required this.startDate,
    required this.endDate,
    required this.confidence,
    required this.phase,
  });
}

enum FertilityPhase {
  menstrual,
  follicular,
  ovulation,
  luteal,
}

/// Symptom pattern analysis
class SymptomPattern {
  final String symptomName;
  final double frequency;
  final List<int> typicalDays;
  final double confidence;
  final TrendDirection trend;
  final SeasonalPattern? seasonalPattern;

  SymptomPattern({
    required this.symptomName,
    required this.frequency,
    required this.typicalDays,
    required this.confidence,
    required this.trend,
    this.seasonalPattern,
  });
}

enum TrendDirection { increasing, decreasing, stable }

/// Seasonal pattern for symptoms
class SeasonalPattern {
  final Map<String, double> monthlyVariation;
  final double confidence;

  SeasonalPattern({
    required this.monthlyVariation,
    required this.confidence,
  });
}

/// Symptom occurrence data
class SymptomOccurrence {
  final String symptomName;
  final DateTime date;
  final int dayInCycle;
  final double intensity;

  SymptomOccurrence({
    required this.symptomName,
    required this.date,
    required this.dayInCycle,
    required this.intensity,
  });
}

/// Wellbeing prediction
class WellbeingPrediction {
  final WellbeingType type;
  final double predictedValue;
  final double confidence;
  final List<int> peakDays;
  final List<int> lowDays;
  final WellbeingTrend trend;

  WellbeingPrediction({
    required this.type,
    required this.predictedValue,
    required this.confidence,
    required this.peakDays,
    required this.lowDays,
    required this.trend,
  });
}

enum WellbeingType { mood, energy, pain }

/// Wellbeing trend analysis
class WellbeingTrend {
  final TrendDirection direction;
  final double magnitude;
  final double confidence;

  WellbeingTrend({
    required this.direction,
    required this.magnitude,
    required this.confidence,
  });
}

/// Personalized insight from AI analysis
class PersonalizedInsight {
  final String title;
  final String description;
  final InsightType type;
  final InsightPriority priority;
  final double confidence;
  final List<String> actionItems;
  final DateTime? relevantDate;

  PersonalizedInsight({
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.confidence,
    this.actionItems = const [],
    this.relevantDate,
  });
}

enum InsightType { cycle, symptom, wellness, prediction }
enum InsightPriority { low, medium, high, urgent }

/// AI-generated recommendation
class AIRecommendation {
  final String title;
  final String description;
  final RecommendationType type;
  final RecommendationPriority priority;
  final List<String> actionSteps;
  final DateTime? dueDate;
  final bool isPersonalized;

  AIRecommendation({
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.actionSteps,
    this.dueDate,
    this.isPersonalized = true,
  });
}

enum RecommendationType { lifestyle, medical, tracking, wellness }
enum RecommendationPriority { low, medium, high }

/// Flow intensity enum for cycle tracking
enum FlowIntensity {
  light,
  normal,
  heavy,
  veryHeavy;

  String get displayName {
    switch (this) {
      case FlowIntensity.light:
        return 'Light';
      case FlowIntensity.normal:
        return 'Normal';
      case FlowIntensity.heavy:
        return 'Heavy';
      case FlowIntensity.veryHeavy:
        return 'Very Heavy';
    }
  }
}
