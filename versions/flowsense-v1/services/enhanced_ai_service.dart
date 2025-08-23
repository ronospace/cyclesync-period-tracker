import 'dart:math' as math;
import 'advanced_health_kit_service.dart';

// Import the data models from AdvancedHealthKitService

/// Enhanced AI service that combines cycle data with biometric insights
/// for advanced predictions and personalized recommendations
class EnhancedAIService {
  static EnhancedAIService? _instance;
  static EnhancedAIService get instance => _instance ??= EnhancedAIService._();
  EnhancedAIService._();

  final AdvancedHealthKitService _healthKit = AdvancedHealthKitService.instance;

  /// Generate comprehensive cycle insights combining traditional tracking
  /// with wearable biometric data
  Future<EnhancedCycleInsights> generateEnhancedInsights({
    required List<Map<String, dynamic>> cycles,
    required DateTime analysisDate,
  }) async {
    try {
      print('🧠 Generating enhanced AI insights...');
      
      final insights = EnhancedCycleInsights();
      
      if (cycles.isEmpty) {
        insights.addRecommendation("Start logging your cycles to get personalized insights!");
        return insights;
      }

      // Traditional cycle analysis
      final traditionalInsights = _analyzeTraditionalCycleData(cycles);
      
      // Biometric analysis (if available)
      final biometricInsights = await _analyzeBiometricData(analysisDate);
      
      // Combine insights using AI correlation
      final combinedInsights = _combineInsights(traditionalInsights, biometricInsights);
      
      // Generate personalized predictions
      final predictions = await _generateAdvancedPredictions(cycles, biometricInsights);
      
      // Create actionable recommendations
      final recommendations = _generatePersonalizedRecommendations(
        combinedInsights, 
        predictions,
      );

      insights.currentPhase = predictions.currentPhase;
      insights.ovulationPrediction = predictions.ovulationDate;
      insights.nextPeriodPrediction = predictions.nextPeriodDate;
      insights.stressLevel = biometricInsights?.stressLevel ?? 0.5;
      insights.sleepQuality = biometricInsights?.sleepQuality ?? 0.5;
      insights.energyLevel = biometricInsights?.energyLevels ?? 0.5;
      insights.recommendations = recommendations;
      insights.confidence = predictions.confidenceScore;

      print('✅ Enhanced AI insights generated successfully');
      return insights;
    } catch (e) {
      print('❌ Failed to generate enhanced insights: $e');
      return EnhancedCycleInsights()
        ..addRecommendation("Continue tracking your cycle for better insights");
    }
  }

  /// Analyze traditional cycle data patterns
  TraditionalCycleInsights _analyzeTraditionalCycleData(List<Map<String, dynamic>> cycles) {
    final insights = TraditionalCycleInsights();
    
    if (cycles.length < 2) return insights;

    // Calculate cycle statistics
    final cycleLengths = <int>[];
    final completedCycles = cycles.where((c) => c['end_date'] != null).toList();
    
    for (final cycle in completedCycles) {
      final start = _parseDate(cycle['start_date']);
      final end = _parseDate(cycle['end_date']);
      if (start != null && end != null) {
        cycleLengths.add(end.difference(start).inDays + 1);
      }
    }

    if (cycleLengths.isNotEmpty) {
      insights.averageCycleLength = cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
      insights.cycleVariability = _calculateVariability(cycleLengths);
      insights.regularityScore = _calculateRegularityScore(cycleLengths);
    }

    // Analyze symptom patterns
    insights.commonSymptoms = _analyzeSymptomPatterns(cycles);
    insights.symptomTrends = _analyzeSymptomTrends(cycles);

    return insights;
  }

  /// Analyze biometric data from wearables
  Future<CycleHealthInsights?> _analyzeBiometricData(DateTime date) async {
    try {
      if (!await _healthKit.initialize()) {
        print('⚠️ HealthKit not available, skipping biometric analysis');
        return null;
      }

      // Get health data for the past 7 days for trend analysis
      final endDate = date;
      final startDate = date.subtract(const Duration(days: 7));

      return await _healthKit.analyzeCycleHealthPatterns(
        cycleStart: startDate,
        cycleEnd: endDate,
      );
    } catch (e) {
      print('❌ Failed to analyze biometric data: $e');
      return null;
    }
  }

  /// Combine traditional and biometric insights using AI correlation
  CombinedInsights _combineInsights(
    TraditionalCycleInsights traditional,
    CycleHealthInsights? biometric,
  ) {
    final combined = CombinedInsights();
    
    // Correlate HRV with cycle phases
    if (biometric != null && traditional.averageCycleLength != null) {
      combined.stressCycleCorrelation = _calculateStressCycleCorrelation(
        traditional,
        biometric,
      );
      
      combined.sleepCycleCorrelation = _calculateSleepCycleCorrelation(
        traditional,
        biometric,
      );
      
      combined.energyCycleCorrelation = _calculateEnergyCycleCorrelation(
        traditional,
        biometric,
      );
    }
    
    return combined;
  }

  /// Generate advanced predictions using ML-style algorithms
  Future<AdvancedPredictions> _generateAdvancedPredictions(
    List<Map<String, dynamic>> cycles,
    CycleHealthInsights? biometric,
  ) async {
    final predictions = AdvancedPredictions();
    
    if (cycles.isEmpty) return predictions;

    final now = DateTime.now();
    final lastCycle = cycles.first;
    final lastStart = _parseDate(lastCycle['start_date']);
    
    if (lastStart == null) return predictions;

    // Enhanced ovulation prediction using temperature data
    if (biometric?.possibleOvulationDate != null) {
      predictions.ovulationDate = biometric!.possibleOvulationDate!;
      predictions.ovulationConfidence = 0.85; // High confidence with biometric data
    } else {
      // Fallback to traditional calculation
      predictions.ovulationDate = _predictOvulationTraditional(cycles);
      predictions.ovulationConfidence = 0.65;
    }

    // Enhanced period prediction
    predictions.nextPeriodDate = _predictNextPeriod(cycles, biometric);
    predictions.periodConfidence = biometric != null ? 0.80 : 0.70;
    
    // Current phase detection
    predictions.currentPhase = _detectCurrentPhase(lastStart, predictions.ovulationDate);
    predictions.confidenceScore = (predictions.ovulationConfidence + predictions.periodConfidence) / 2;

    return predictions;
  }

  /// Generate personalized recommendations based on insights
  List<String> _generatePersonalizedRecommendations(
    CombinedInsights combined,
    AdvancedPredictions predictions,
  ) {
    final recommendations = <String>[];

    // Cycle phase specific recommendations
    switch (predictions.currentPhase) {
      case CyclePhase.menstrual:
        recommendations.add("💧 Stay hydrated and consider gentle stretching for cramps");
        recommendations.add("🛌 Prioritize rest - your body is working hard");
        break;
      case CyclePhase.follicular:
        recommendations.add("💪 Great time for high-intensity workouts - energy is increasing!");
        recommendations.add("🥗 Focus on iron-rich foods to replenish");
        break;
      case CyclePhase.ovulatory:
        recommendations.add("❤️ You're in your fertile window - plan accordingly");
        recommendations.add("🌟 Social energy is high - great time for important meetings");
        break;
      case CyclePhase.luteal:
        recommendations.add("🧘 Practice stress management - PMS may be approaching");
        recommendations.add("🍯 Consider magnesium supplements for mood support");
        break;
    }

    // Biometric-based recommendations
    if (combined.stressCycleCorrelation > 0.7) {
      recommendations.add("😌 Your stress levels seem to correlate with your cycle - try meditation");
    }
    
    if (combined.sleepCycleCorrelation < 0.4) {
      recommendations.add("😴 Poor sleep may be affecting your cycle - establish a bedtime routine");
    }

    // Predictive recommendations
    if (predictions.nextPeriodDate.difference(DateTime.now()).inDays <= 3) {
      recommendations.add("📅 Period predicted in ${predictions.nextPeriodDate.difference(DateTime.now()).inDays} days - prepare supplies");
    }

    return recommendations;
  }

  // Helper methods
  DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is DateTime) return date;
    if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  double _calculateVariability(List<int> lengths) {
    if (lengths.length < 2) return 0;
    final mean = lengths.reduce((a, b) => a + b) / lengths.length;
    final variance = lengths.map((l) => math.pow(l - mean, 2)).reduce((a, b) => a + b) / lengths.length;
    return math.sqrt(variance);
  }

  double _calculateRegularityScore(List<int> lengths) {
    final variability = _calculateVariability(lengths);
    return math.max(0, 100 - (variability * 10)); // Higher variability = lower score
  }

  Map<String, int> _analyzeSymptomPatterns(List<Map<String, dynamic>> cycles) {
    final symptomCounts = <String, int>{};
    
    for (final cycle in cycles) {
      final symptoms = cycle['symptoms'] as List?;
      if (symptoms != null) {
        for (final symptom in symptoms) {
          final symptomName = symptom is String ? symptom : symptom['name']?.toString();
          if (symptomName != null) {
            symptomCounts[symptomName] = (symptomCounts[symptomName] ?? 0) + 1;
          }
        }
      }
    }
    
    return symptomCounts;
  }

  Map<String, double> _analyzeSymptomTrends(List<Map<String, dynamic>> cycles) {
    // Simplified trend analysis - in real implementation, this would be more sophisticated
    final trends = <String, double>{};
    final symptoms = _analyzeSymptomPatterns(cycles);
    
    for (final entry in symptoms.entries) {
      final frequency = entry.value / cycles.length;
      trends[entry.key] = frequency;
    }
    
    return trends;
  }

  double _calculateStressCycleCorrelation(
    TraditionalCycleInsights traditional,
    CycleHealthInsights biometric,
  ) {
    // Simplified correlation - real implementation would use proper correlation algorithms
    return (biometric.stressLevel ?? 0.5) > 0.7 ? 0.8 : 0.4;
  }

  double _calculateSleepCycleCorrelation(
    TraditionalCycleInsights traditional,
    CycleHealthInsights biometric,
  ) {
    return (biometric.sleepQuality ?? 0.5) > 0.7 ? 0.8 : 0.3;
  }

  double _calculateEnergyCycleCorrelation(
    TraditionalCycleInsights traditional,
    CycleHealthInsights biometric,
  ) {
    return (biometric.energyLevels ?? 0.5) > 0.6 ? 0.7 : 0.5;
  }

  DateTime _predictOvulationTraditional(List<Map<String, dynamic>> cycles) {
    // Simple traditional ovulation prediction
    final now = DateTime.now();
    return now.add(const Duration(days: 14)); // Simplified
  }

  DateTime _predictNextPeriod(List<Map<String, dynamic>> cycles, CycleHealthInsights? biometric) {
    if (cycles.isEmpty) return DateTime.now().add(const Duration(days: 28));
    
    // Calculate average cycle length
    final lengths = <int>[];
    for (final cycle in cycles) {
      final start = _parseDate(cycle['start_date']);
      final end = _parseDate(cycle['end_date']);
      if (start != null && end != null) {
        lengths.add(end.difference(start).inDays + 1);
      }
    }
    
    final avgLength = lengths.isNotEmpty ? 
        lengths.reduce((a, b) => a + b) / lengths.length : 28;
    
    final lastStart = _parseDate(cycles.first['start_date']) ?? DateTime.now();
    return lastStart.add(Duration(days: avgLength.round()));
  }

  CyclePhase _detectCurrentPhase(DateTime lastPeriodStart, DateTime? predictedOvulation) {
    final now = DateTime.now();
    final daysSinceStart = now.difference(lastPeriodStart).inDays;
    
    if (daysSinceStart <= 5) return CyclePhase.menstrual;
    if (predictedOvulation != null && now.difference(predictedOvulation).inDays.abs() <= 2) {
      return CyclePhase.ovulatory;
    }
    if (daysSinceStart <= 13) return CyclePhase.follicular;
    return CyclePhase.luteal;
  }
}

// Data classes for enhanced insights
class EnhancedCycleInsights {
  CyclePhase currentPhase = CyclePhase.follicular;
  DateTime? ovulationPrediction;
  DateTime? nextPeriodPrediction;
  double stressLevel = 0.5;
  double sleepQuality = 0.5;
  double energyLevel = 0.5;
  double confidence = 0.0;
  List<String> recommendations = [];
  
  void addRecommendation(String rec) => recommendations.add(rec);
}

class TraditionalCycleInsights {
  double? averageCycleLength;
  double cycleVariability = 0;
  double regularityScore = 0;
  Map<String, int> commonSymptoms = {};
  Map<String, double> symptomTrends = {};
}

class CombinedInsights {
  double stressCycleCorrelation = 0;
  double sleepCycleCorrelation = 0;
  double energyCycleCorrelation = 0;
}

class AdvancedPredictions {
  DateTime? ovulationDate;
  DateTime nextPeriodDate = DateTime.now().add(const Duration(days: 28));
  CyclePhase currentPhase = CyclePhase.follicular;
  double ovulationConfidence = 0;
  double periodConfidence = 0;
  double confidenceScore = 0;
}

enum CyclePhase { 
  menstrual, 
  follicular, 
  ovulatory, 
  luteal 
}

extension CyclePhaseExtension on CyclePhase {
  String get displayName {
    switch (this) {
      case CyclePhase.menstrual: return 'Menstrual';
      case CyclePhase.follicular: return 'Follicular';
      case CyclePhase.ovulatory: return 'Ovulatory';
      case CyclePhase.luteal: return 'Luteal';
    }
  }
  
  String get description {
    switch (this) {
      case CyclePhase.menstrual: return 'Time to rest and recharge';
      case CyclePhase.follicular: return 'Energy building phase';
      case CyclePhase.ovulatory: return 'Peak fertility window';
      case CyclePhase.luteal: return 'Pre-menstrual preparation';
    }
  }
}
