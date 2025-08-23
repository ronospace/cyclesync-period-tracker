import 'package:flutter/foundation.dart';
import '../models/cycle_models.dart';

/// Minimal analytics engine aligned with CycleAnalytics API in cycle_models.dart
class AnalyticsEngine {
  static AnalyticsEngine? _instance;
  static AnalyticsEngine get instance => _instance ??= AnalyticsEngine._();

  AnalyticsEngine._();

  Future<CycleAnalytics> generateCycleAnalytics(List<CycleData> cycles) async {
    try {
      debugPrint(
        '📊 Generating cycle analytics for ${cycles.length} cycles...',
      );
      return CycleAnalytics.fromCycles(cycles);
    } catch (e) {
      debugPrint('❌ Error generating cycle analytics: $e');
      return CycleAnalytics(
        cycles: cycles,
        averageCycleLength: 0,
        regularityScore: 0,
        symptomFrequency: const {},
        wellbeingAverages: const {},
      );
    }
  }

  CyclePrediction? getNextPrediction(List<CycleData> cycles) {
    try {
      return CycleAnalytics.fromCycles(cycles).nextCyclePrediction;
    } catch (_) {
      return null;
    }
  }
}
