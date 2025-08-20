import 'cycle_models.dart';

// Core prediction models
class CycleDataPoint {
  final DateTime startDate;
  final DateTime? endDate;
  final int? length;
  final FlowIntensity? flowIntensity;

  CycleDataPoint({
    required this.startDate,
    this.endDate,
    this.length,
    this.flowIntensity,
  });
}

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

class PredictionRange {
  final int min;
  final int max;

  const PredictionRange({
    required this.min,
    required this.max,
  });
}

class NextCyclePrediction {
  final int cycleNumber;
  final DateTime predictedStartDate;
  final int predictedLength;
  final double confidence;
  final PredictionRange lengthRange;
  final FlowIntensityPrediction flowPrediction;

  NextCyclePrediction({
    required this.cycleNumber,
    required this.predictedStartDate,
    required this.predictedLength,
    required this.confidence,
    required this.lengthRange,
    required this.flowPrediction,
  });
}

class FlowIntensityPrediction {
  final FlowIntensity predicted;
  final double confidence;
  final Map<FlowIntensity, double> probabilities;

  FlowIntensityPrediction({
    required this.predicted,
    required this.confidence,
    required this.probabilities,
  });
}

class FertilityWindow {
  final int cycleNumber;
  final DateTime windowStart;
  final DateTime windowEnd;
  final DateTime peakFertility;
  final double confidence;

  FertilityWindow({
    required this.cycleNumber,
    required this.windowStart,
    required this.windowEnd,
    required this.peakFertility,
    required this.confidence,
  });
}

// Symptom analysis models
class SymptomPattern {
  final String symptomName;
  final double frequency; // 0.0 to 1.0
  final double confidence;
  final int typicalDayInCycle;
  final SeasonalPattern seasonalPattern;

  SymptomPattern({
    required this.symptomName,
    required this.frequency,
    required this.confidence,
    required this.typicalDayInCycle,
    required this.seasonalPattern,
  });
}

class SymptomOccurrence {
  final int cycleIndex;
  final DateTime cycleStart;
  final int dayInCycle;

  SymptomOccurrence({
    required this.cycleIndex,
    required this.cycleStart,
    required this.dayInCycle,
  });
}

enum SeasonalPattern {
  none,
  spring,
  summer,
  autumn,
  winter,
}

// Wellbeing prediction models
class WellbeingPrediction {
  final WellbeingType type;
  final double predictedValue;
  final double confidence;
  final WellbeingTrend trend;
  final Map<int, double> cycleDayVariations; // Day in cycle -> predicted value

  WellbeingPrediction({
    required this.type,
    required this.predictedValue,
    required this.confidence,
    required this.trend,
    required this.cycleDayVariations,
  });
}

enum WellbeingType {
  mood,
  energy,
  pain,
}

enum WellbeingTrend {
  improving,
  stable,
  declining,
}

// Insight and recommendation models
class PersonalizedInsight {
  final InsightType type;
  final String title;
  final String message;
  final double confidence;
  final InsightSeverity severity;
  final bool actionable;
  final List<String> recommendations;

  PersonalizedInsight({
    required this.type,
    required this.title,
    required this.message,
    required this.confidence,
    required this.severity,
    required this.actionable,
    required this.recommendations,
  });
}

enum InsightType {
  cycleRegularity,
  symptomPattern,
  wellbeingTrend,
  fertilityWindow,
  healthRisk,
  lifestyle,
}

enum InsightSeverity {
  positive,
  neutral,
  warning,
  critical,
}

class AIRecommendation {
  final RecommendationType type;
  final RecommendationPriority priority;
  final String title;
  final String description;
  final String action;
  final double confidence;

  AIRecommendation({
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    required this.action,
    required this.confidence,
  });
}

enum RecommendationType {
  dataCollection,
  healthIntegration,
  lifestyle,
  medical,
  tracking,
}

enum RecommendationPriority {
  low,
  medium,
  high,
  critical,
}

// Correlation analysis models
class CorrelationInsight {
  final String factor1;
  final String factor2;
  final double correlation; // -1.0 to 1.0
  final double confidence;
  final String description;
  final List<CorrelationExample> examples;

  CorrelationInsight({
    required this.factor1,
    required this.factor2,
    required this.correlation,
    required this.confidence,
    required this.description,
    required this.examples,
  });
}

class CorrelationExample {
  final DateTime date;
  final String description;
  final double impact;

  CorrelationExample({
    required this.date,
    required this.description,
    required this.impact,
  });
}

// Lifestyle factor models
class LifestyleFactor {
  final String name;
  final LifestyleFactorType type;
  final double impact; // -1.0 to 1.0
  final double confidence;
  final List<String> recommendations;

  LifestyleFactor({
    required this.name,
    required this.type,
    required this.impact,
    required this.confidence,
    required this.recommendations,
  });
}

enum LifestyleFactorType {
  sleep,
  stress,
  exercise,
  diet,
  medication,
  travel,
  illness,
}

// Risk assessment models
class HealthRiskAssessment {
  final RiskType type;
  final RiskLevel level;
  final double probability;
  final String description;
  final List<String> riskFactors;
  final List<String> recommendations;

  HealthRiskAssessment({
    required this.type,
    required this.level,
    required this.probability,
    required this.description,
    required this.riskFactors,
    required this.recommendations,
  });
}

enum RiskType {
  irregularity,
  pcos,
  endometriosis,
  thyroid,
  fertility,
  other,
}

enum RiskLevel {
  low,
  medium,
  high,
  critical,
}

// Advanced analytics models
class CyclePhaseAnalysis {
  final List<CyclePhase> phases;
  final Map<CyclePhase, WellbeingProfile> phaseProfiles;
  final List<PhaseTransition> transitions;

  CyclePhaseAnalysis({
    required this.phases,
    required this.phaseProfiles,
    required this.transitions,
  });
}

enum CyclePhase {
  menstrual,
  follicular,
  ovulatory,
  luteal,
}

class WellbeingProfile {
  final CyclePhase phase;
  final double avgMood;
  final double avgEnergy;
  final double avgPain;
  final List<String> commonSymptoms;
  final List<String> recommendations;

  WellbeingProfile({
    required this.phase,
    required this.avgMood,
    required this.avgEnergy,
    required this.avgPain,
    required this.commonSymptoms,
    required this.recommendations,
  });
}

class PhaseTransition {
  final CyclePhase fromPhase;
  final CyclePhase toPhase;
  final int typicalDay;
  final double confidence;
  final List<String> transitionMarkers;

  PhaseTransition({
    required this.fromPhase,
    required this.toPhase,
    required this.typicalDay,
    required this.confidence,
    required this.transitionMarkers,
  });
}

// Time series analysis
class TimeSeriesAnalysis {
  final List<DataPoint> dataPoints;
  final TrendAnalysis trend;
  final SeasonalityAnalysis seasonality;
  final List<Anomaly> anomalies;

  TimeSeriesAnalysis({
    required this.dataPoints,
    required this.trend,
    required this.seasonality,
    required this.anomalies,
  });
}

class DataPoint {
  final DateTime timestamp;
  final double value;
  final String metric;

  DataPoint({
    required this.timestamp,
    required this.value,
    required this.metric,
  });
}

class TrendAnalysis {
  final TrendDirection direction;
  final double slope;
  final double confidence;
  final String interpretation;

  TrendAnalysis({
    required this.direction,
    required this.slope,
    required this.confidence,
    required this.interpretation,
  });
}

enum TrendDirection {
  increasing,
  decreasing,
  stable,
  cyclical,
}

class SeasonalityAnalysis {
  final bool hasSeasonality;
  final int periodDays;
  final double strength;
  final Map<int, double> seasonalFactors; // Day of cycle -> adjustment factor

  SeasonalityAnalysis({
    required this.hasSeasonality,
    required this.periodDays,
    required this.strength,
    required this.seasonalFactors,
  });
}

class Anomaly {
  final DateTime date;
  final double value;
  final double expectedValue;
  final double severity;
  final String description;
  final List<String> possibleCauses;

  Anomaly({
    required this.date,
    required this.value,
    required this.expectedValue,
    required this.severity,
    required this.description,
    required this.possibleCauses,
  });
}

// Model performance tracking
class ModelPerformance {
  final String modelName;
  final String version;
  final double accuracy;
  final double precision;
  final double recall;
  final Map<String, double> metrics;
  final DateTime lastTrainingDate;
  final int samplesUsed;

  ModelPerformance({
    required this.modelName,
    required this.version,
    required this.accuracy,
    required this.precision,
    required this.recall,
    required this.metrics,
    required this.lastTrainingDate,
    required this.samplesUsed,
  });
}

// Export data structures for JSON serialization
// Simple AI Insights classes for the UI
class CycleInsights {
  final CycleLengthAnalysis cycleLengthAnalysis;
  final SimpleNextCyclePrediction nextCyclePrediction;
  final FertilityInsights fertilityInsights;
  final SymptomPatterns symptomPatterns;
  final List<HealthRecommendation> healthRecommendations;
  final CycleRegularity cycleRegularity;
  final TrendsAnalysis trendsAnalysis;
  final int totalCyclesAnalyzed;
  final DataQuality dataQuality;

  CycleInsights({
    required this.cycleLengthAnalysis,
    required this.nextCyclePrediction,
    required this.fertilityInsights,
    required this.symptomPatterns,
    required this.healthRecommendations,
    required this.cycleRegularity,
    required this.trendsAnalysis,
    required this.totalCyclesAnalyzed,
    required this.dataQuality,
  });

  factory CycleInsights.empty() {
    return CycleInsights(
      cycleLengthAnalysis: CycleLengthAnalysis.empty(),
      nextCyclePrediction: SimpleNextCyclePrediction.insufficient(),
      fertilityInsights: FertilityInsights.empty(),
      symptomPatterns: SymptomPatterns.empty(),
      healthRecommendations: [],
      cycleRegularity: CycleRegularity(
        status: RegularityStatus.insufficient,
        variationDays: 0,
        consistency: 0,
        description: 'No data available',
      ),
      trendsAnalysis: TrendsAnalysis.insufficient(),
      totalCyclesAnalyzed: 0,
      dataQuality: DataQuality.poor(),
    );
  }
}

class CycleLengthAnalysis {
  final int averageLength;
  final int shortestCycle;
  final int longestCycle;
  final double standardDeviation;
  final String trend;
  final double consistency;

  CycleLengthAnalysis({
    required this.averageLength,
    required this.shortestCycle,
    required this.longestCycle,
    required this.standardDeviation,
    required this.trend,
    required this.consistency,
  });

  factory CycleLengthAnalysis.empty() {
    return CycleLengthAnalysis(
      averageLength: 0,
      shortestCycle: 0,
      longestCycle: 0,
      standardDeviation: 0,
      trend: 'unknown',
      consistency: 0,
    );
  }
}

// Simple NextCyclePrediction for UI
class SimpleNextCyclePrediction {
  final DateTime? predictedStartDate;
  final int confidencePercentage;
  final int estimatedLength;
  final DateTime? fertilityWindowStart;
  final DateTime? fertilityWindowEnd;
  final DateTime? ovulationDay;

  SimpleNextCyclePrediction({
    required this.predictedStartDate,
    required this.confidencePercentage,
    required this.estimatedLength,
    required this.fertilityWindowStart,
    required this.fertilityWindowEnd,
    required this.ovulationDay,
  });

  factory SimpleNextCyclePrediction.insufficient() {
    return SimpleNextCyclePrediction(
      predictedStartDate: null,
      confidencePercentage: 0,
      estimatedLength: 0,
      fertilityWindowStart: null,
      fertilityWindowEnd: null,
      ovulationDay: null,
    );
  }
}

class FertilityInsights {
  final int averageOvulationDay;
  final Map<String, int> fertilitySignsFrequency;
  final int lutealPhaseLength;
  final List<String> recommendations;

  FertilityInsights({
    required this.averageOvulationDay,
    required this.fertilitySignsFrequency,
    required this.lutealPhaseLength,
    required this.recommendations,
  });

  factory FertilityInsights.empty() {
    return FertilityInsights(
      averageOvulationDay: 0,
      fertilitySignsFrequency: {},
      lutealPhaseLength: 0,
      recommendations: [],
    );
  }
}

class SymptomPatterns {
  final List<String> mostCommonSymptoms;
  final Map<String, int> symptomFrequency;
  final List<String> moodTrends;
  final List<String> painPatterns;
  final List<String> correlations;

  SymptomPatterns({
    required this.mostCommonSymptoms,
    required this.symptomFrequency,
    required this.moodTrends,
    required this.painPatterns,
    required this.correlations,
  });

  factory SymptomPatterns.empty() {
    return SymptomPatterns(
      mostCommonSymptoms: [],
      symptomFrequency: {},
      moodTrends: [],
      painPatterns: [],
      correlations: [],
    );
  }
}

class HealthRecommendation {
  final RecommendationType type;
  final RecommendationPriority priority;
  final String title;
  final String description;
  final String actionable;

  HealthRecommendation({
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    required this.actionable,
  });
}

class CycleRegularity {
  final RegularityStatus status;
  final int variationDays;
  final double consistency;
  final String description;

  CycleRegularity({
    required this.status,
    required this.variationDays,
    required this.consistency,
    required this.description,
  });
}

class TrendsAnalysis {
  final double cycleLengthTrend;
  final double moodTrend;
  final Map<String, double> symptomTrends;
  final double overallHealthTrend;

  TrendsAnalysis({
    required this.cycleLengthTrend,
    required this.moodTrend,
    required this.symptomTrends,
    required this.overallHealthTrend,
  });

  factory TrendsAnalysis.insufficient() {
    return TrendsAnalysis(
      cycleLengthTrend: 0,
      moodTrend: 0,
      symptomTrends: {},
      overallHealthTrend: 0,
    );
  }
}

class DataQuality {
  final QualityLevel level;
  final double completeness;
  final double consistency;
  final List<String> suggestions;

  DataQuality({
    required this.level,
    required this.completeness,
    required this.consistency,
    required this.suggestions,
  });

  factory DataQuality.poor() {
    return DataQuality(
      level: QualityLevel.poor,
      completeness: 0,
      consistency: 0,
      suggestions: ['Start tracking cycles regularly'],
    );
  }
}

enum RegularityStatus { regular, somewhatRegular, irregular, insufficient }
enum QualityLevel { poor, fair, good, excellent }
