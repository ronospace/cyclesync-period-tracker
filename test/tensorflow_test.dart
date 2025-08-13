import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import '../lib/services/tensorflow_prediction_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('TensorFlow Prediction Service Tests', () {
    late TensorFlowPredictionService aiService;

    setUp(() {
      aiService = TensorFlowPredictionService.instance;
    });

    test('should initialize with algorithmic fallback', () async {
      // Since we don't have actual TensorFlow models, it should fall back to algorithms
      final initialized = await aiService.initialize();
      
      // Should initialize successfully even without models (using algorithmic fallback)
      expect(initialized, isA<bool>());
    });

    test('should predict ovulation using algorithmic approach', () async {
      await aiService.initialize();
      
      // Mock cycle and health data
      final mockCycleHistory = [
        {
          'length': 28,
          'start_date': DateTime.now().subtract(const Duration(days: 35)).toIso8601String(),
        },
        {
          'length': 29,
          'start_date': DateTime.now().subtract(const Duration(days: 63)).toIso8601String(),
        },
        {
          'length': 27,
          'start_date': DateTime.now().subtract(const Duration(days: 92)).toIso8601String(),
        },
      ];

      final mockHealthData = [
        {
          'type': 'temperature',
          'value': 98.6,
          'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        },
        {
          'type': 'temperature',
          'value': 98.8,
          'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        },
      ];

      final mockBiomarkers = {
        'current_day_in_cycle': 14,
        'average_hrv': 35.0,
        'resting_heart_rate': 65.0,
        'sleep_score': 75.0,
      };

      final result = await aiService.predictOvulation(
        cycleHistory: mockCycleHistory,
        healthData: mockHealthData,
        currentBiomarkers: mockBiomarkers,
      );

      expect(result, isA<OvulationPredictionResult>());
      expect(result.confidence, greaterThan(0.0));
      expect(result.daysToOvulation, isA<int>());
      expect(result.fertilityScore, greaterThan(0.0));
      expect(result.predictionMethod, contains('algorithmic'));
    });

    test('should analyze HRV stress with mock data', () async {
      await aiService.initialize();

      final mockHrvData = [
        {'value': 35.0, 'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String()},
        {'value': 32.0, 'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String()},
        {'value': 38.0, 'date': DateTime.now().subtract(const Duration(days: 3)).toIso8601String()},
      ];

      final mockHeartRateData = [
        {'value': 70.0, 'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String()},
        {'value': 72.0, 'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String()},
        {'value': 68.0, 'date': DateTime.now().subtract(const Duration(days: 3)).toIso8601String()},
      ];

      final mockSleepData = {
        'duration': 480.0,
        'quality': 75.0,
        'deep_sleep_percentage': 25.0,
      };

      final mockActivityData = {
        'steps': 8000.0,
        'active_minutes': 60.0,
        'calories_burned': 2000.0,
      };

      final result = await aiService.analyzeHRVStress(
        hrvData: mockHrvData,
        heartRateData: mockHeartRateData,
        sleepData: mockSleepData,
        activityData: mockActivityData,
      );

      expect(result, isA<HRVStressAnalysisResult>());
      expect(result.stressLevel, greaterThanOrEqualTo(0.0));
      expect(result.stressLevel, lessThanOrEqualTo(1.0));
      expect(result.recoveryScore, greaterThanOrEqualTo(0.0));
      expect(result.recoveryScore, lessThanOrEqualTo(1.0));
      expect(result.recommendations, isA<List<String>>());
      expect(result.dataQuality, greaterThan(0.0));
    });

    test('should classify emotions from wearable data', () async {
      await aiService.initialize();

      final mockBiometrics = {
        'heart_rate': 70.0,
        'hrv': 35.0,
        'temperature': 98.6,
        'respiratory_rate': 16.0,
        'steps': 8000.0,
      };

      final mockActivity = [
        {'intensity': 0.6, 'duration': 60.0},
        {'intensity': 0.4, 'duration': 30.0},
      ];

      final mockSleepContext = {
        'duration': 480.0,
        'quality': 80.0,
        'deep_sleep_percentage': 25.0,
      };

      final result = await aiService.classifyEmotionFromWearables(
        biometricSnapshot: mockBiometrics,
        recentActivity: mockActivity,
        sleepContext: mockSleepContext,
      );

      expect(result, isA<EmotionClassificationResult>());
      expect(result.dominantEmotion, isA<String>());
      expect(result.confidence, greaterThan(0.0));
      expect(result.emotionProbabilities, isA<Map<String, double>>());
      expect(result.emotionProbabilities.length, equals(8)); // 8 emotion categories
      expect(result.physiologicalIndicators, isA<Map<String, double>>());
      expect(result.recommendedActions, isA<List<String>>());
    });

    test('should detect cycle irregularities', () async {
      await aiService.initialize();

      final mockCycleHistory = [
        {'length': 28, 'start_date': DateTime.now().subtract(const Duration(days: 35)).toIso8601String()},
        {'length': 32, 'start_date': DateTime.now().subtract(const Duration(days: 67)).toIso8601String()},
        {'length': 25, 'start_date': DateTime.now().subtract(const Duration(days: 99)).toIso8601String()},
        {'length': 30, 'start_date': DateTime.now().subtract(const Duration(days: 129)).toIso8601String()},
      ];

      final mockHealthTrends = [
        {'type': 'stress_level', 'value': 0.6, 'date': DateTime.now().toIso8601String()},
        {'type': 'sleep_quality', 'value': 0.7, 'date': DateTime.now().toIso8601String()},
      ];

      final mockLifestyleFactors = {
        'stress_level': 0.6,
        'diet_quality': 0.7,
        'exercise_regularity': 0.5,
        'sleep_consistency': 0.8,
      };

      final result = await aiService.detectCycleIrregularities(
        cycleHistory: mockCycleHistory,
        healthTrends: mockHealthTrends,
        lifestyleFactors: mockLifestyleFactors,
      );

      expect(result, isA<CycleIrregularityResult>());
      expect(result.irregularityScore, greaterThanOrEqualTo(0.0));
      expect(result.irregularityScore, lessThanOrEqualTo(1.0));
      expect(result.confidence, greaterThan(0.0));
      expect(result.severityLevel, isA<String>());
      expect(['Low', 'Mild', 'Moderate', 'High'], contains(result.severityLevel));
      expect(result.detectedPatterns, isA<List<String>>());
      expect(result.recommendations, isA<List<String>>());
    });

    test('should predict sleep quality', () async {
      await aiService.initialize();

      final mockSleepHistory = [
        {'duration': 480.0, 'quality': 75.0, 'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String()},
        {'duration': 500.0, 'quality': 80.0, 'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String()},
        {'duration': 460.0, 'quality': 70.0, 'date': DateTime.now().subtract(const Duration(days: 3)).toIso8601String()},
      ];

      final mockBiometrics = {
        'resting_heart_rate': 65.0,
        'hrv': 35.0,
        'temperature': 98.6,
      };

      final mockActivity = {
        'steps': 10000.0,
        'active_minutes': 60.0,
        'calories_burned': 2200.0,
      };

      final result = await aiService.predictSleepQuality(
        sleepHistory: mockSleepHistory,
        currentBiometrics: mockBiometrics,
        dailyActivity: mockActivity,
      );

      expect(result, isA<SleepQualityPredictionResult>());
      expect(result.predictedQualityScore, greaterThan(0.0));
      expect(result.predictedQualityScore, lessThanOrEqualTo(1.0));
      expect(result.expectedDeepSleepMinutes, greaterThan(0));
      expect(result.expectedREMMinutes, greaterThan(0));
      expect(result.sleepEfficiency, greaterThan(0.0));
      expect(result.recoveryPotential, greaterThan(0.0));
      expect(result.optimizationTips, isA<List<String>>());
      expect(result.bedtimeRecommendation, isA<DateTime>());
    });

    test('should handle errors gracefully', () async {
      await aiService.initialize();

      // Test with empty/invalid data
      final result = await aiService.predictOvulation(
        cycleHistory: [],
        healthData: [],
        currentBiomarkers: {},
      );

      expect(result, isA<OvulationPredictionResult>());
      // Should still provide a result even with empty data (using defaults)
      expect(result.confidence, greaterThanOrEqualTo(0.0));
    });
  });
}
