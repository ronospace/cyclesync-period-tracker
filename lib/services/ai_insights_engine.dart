import 'dart:math';
import '../models/cycle_models.dart';
import '../models/daily_log_models.dart';
import '../services/enhanced_analytics_service.dart';

/// 🚀 Mission Gamma: AI-Powered Health Insights Engine
/// Advanced machine learning-inspired algorithms for personalized health recommendations
class AIInsightsEngine {
  /// Generate personalized insights for the smart daily log screen
  static Future<List<AIInsight>> generatePersonalizedInsights({
    required List<CycleData> cycles,
    required Map<String, dynamic> userPreferences,
  }) async {
    // Simulate AI processing
    await Future.delayed(const Duration(milliseconds: 300));

    final insights = <AIInsight>[];

    if (cycles.isEmpty) {
      insights.add(
        AIInsight(
          id: 'welcome_insight',
          type: InsightType.wellness,
          priority: InsightPriority.medium,
          title: 'Welcome to Smart Tracking!',
          message:
              'Start logging your daily symptoms and mood to unlock personalized AI insights.',
          createdAt: DateTime.now(),
        ),
      );
      return insights;
    }

    // Generate cycle pattern insights
    if (cycles.length >= 3) {
      final completedCycles = cycles.where((c) => c.isCompleted).toList();
      if (completedCycles.length >= 2) {
        final avgLength =
            completedCycles.fold(0, (sum, c) => sum + c.lengthInDays) /
            completedCycles.length;

        insights.add(
          AIInsight(
            id: 'cycle_pattern',
            type: InsightType.cycle,
            priority: InsightPriority.medium,
            title: 'Cycle Pattern Detected',
            message:
                'Your average cycle length is ${avgLength.toStringAsFixed(1)} days. This information helps predict your next cycle.',
            createdAt: DateTime.now(),
            metadata: {'average_length': avgLength},
          ),
        );
      }
    }

    // Generate symptom insights
    final symptomFrequency = <String, int>{};
    for (final cycle in cycles) {
      for (final symptom in cycle.symptoms) {
        symptomFrequency[symptom.name] =
            (symptomFrequency[symptom.name] ?? 0) + 1;
      }
    }

    final mostCommonSymptom = symptomFrequency.entries
        .where((e) => e.value >= cycles.length * 0.5)
        .map((e) => e.key)
        .firstOrNull;

    if (mostCommonSymptom != null) {
      insights.add(
        AIInsight(
          id: 'common_symptom',
          type: InsightType.symptom,
          priority: InsightPriority.high,
          title: 'Common Symptom Identified',
          message:
              'You frequently experience $mostCommonSymptom. Consider tracking triggers and discussing management options.',
          createdAt: DateTime.now(),
          metadata: {
            'symptom': mostCommonSymptom,
            'frequency': symptomFrequency[mostCommonSymptom],
          },
        ),
      );
    }

    // Generate wellness insights
    if (cycles.isNotEmpty) {
      final avgMood =
          cycles.fold(0.0, (sum, c) => sum + c.wellbeing.mood) / cycles.length;

      if (avgMood < 2.5) {
        insights.add(
          AIInsight(
            id: 'mood_support',
            type: InsightType.wellness,
            priority: InsightPriority.high,
            title: 'Mood Support Needed',
            message:
                'Your average mood has been lower lately. Consider stress management techniques or speaking with a healthcare provider.',
            createdAt: DateTime.now(),
            metadata: {'average_mood': avgMood},
          ),
        );
      } else if (avgMood > 4.0) {
        insights.add(
          AIInsight(
            id: 'positive_trend',
            type: InsightType.wellness,
            priority: InsightPriority.low,
            title: 'Great Progress!',
            message:
                'Your mood has been consistently positive. Keep up the good work with your current routine!',
            createdAt: DateTime.now(),
            metadata: {'average_mood': avgMood},
          ),
        );
      }
    }

    return insights;
  }

  /// Generate comprehensive AI-powered health insights
  static Future<AIHealthInsights> generateInsights({
    required List<CycleData> cycles,
    required List<DailyLogEntry> dailyLogs,
    required String userId,
  }) async {
    // Simulate AI processing delay
    await Future.delayed(const Duration(milliseconds: 500));

    final insights = AIHealthInsights(
      userId: userId,
      generatedAt: DateTime.now(),
      personalizedRecommendations: await _generatePersonalizedRecommendations(
        cycles,
        dailyLogs,
      ),
      predictiveAlerts: await _generatePredictiveAlerts(cycles, dailyLogs),
      symptomInsights: await _analyzeSymptomPatterns(cycles, dailyLogs),
      wellbeingCoaching: await _generateWellbeingCoaching(cycles, dailyLogs),
      cycleOptimization: await _generateCycleOptimization(cycles, dailyLogs),
      confidenceScore: _calculateConfidenceScore(cycles, dailyLogs),
    );

    return insights;
  }

  /// Generate personalized health recommendations using pattern analysis
  static Future<List<PersonalizedRecommendation>>
  _generatePersonalizedRecommendations(
    List<CycleData> cycles,
    List<DailyLogEntry> dailyLogs,
  ) async {
    final recommendations = <PersonalizedRecommendation>[];

    if (cycles.isEmpty) {
      recommendations.add(
        PersonalizedRecommendation(
          id: 'start_tracking',
          title: 'Start Your Health Journey',
          description:
              'Begin logging your cycles to unlock personalized insights',
          category: RecommendationCategory.tracking,
          priority: RecommendationPriority.high,
          actionable: true,
          aiConfidence: 0.9,
        ),
      );
      return recommendations;
    }

    // Analyze cycle regularity patterns
    final wellbeingTrends = EnhancedAnalyticsService.calculateWellbeingTrends(
      cycles,
      dailyLogs,
    );
    final healthScore = EnhancedAnalyticsService.calculateHealthScore(
      cycles,
      dailyLogs,
    );

    // Sleep optimization based on energy patterns
    if (wellbeingTrends.averageEnergy < 3.0) {
      recommendations.add(
        PersonalizedRecommendation(
          id: 'sleep_optimization',
          title: 'Optimize Your Sleep Schedule',
          description:
              'Your energy levels suggest potential sleep quality issues. Consider a consistent sleep routine 30 minutes earlier.',
          category: RecommendationCategory.lifestyle,
          priority: RecommendationPriority.high,
          actionable: true,
          aiConfidence: 0.85,
          suggestedActions: [
            'Set a bedtime reminder 30 minutes earlier',
            'Create a wind-down routine',
            'Limit screen time before bed',
            'Track sleep quality in daily logs',
          ],
        ),
      );
    }

    // Stress management based on mood patterns
    if (wellbeingTrends.averageMood < 3.0) {
      final moodTrend = _calculateTrend(wellbeingTrends.moodTrend);
      recommendations.add(
        PersonalizedRecommendation(
          id: 'stress_management',
          title: 'Enhance Mood Management',
          description: moodTrend < 0
              ? 'Your mood has been declining. Consider stress-reduction techniques.'
              : 'Your mood patterns suggest room for improvement through mindfulness practices.',
          category: RecommendationCategory.mentalHealth,
          priority: moodTrend < -0.5
              ? RecommendationPriority.high
              : RecommendationPriority.medium,
          actionable: true,
          aiConfidence: 0.78,
          suggestedActions: [
            'Practice 10-minute daily meditation',
            'Try deep breathing exercises',
            'Consider journaling before bed',
            'Schedule regular breaks during the day',
          ],
        ),
      );
    }

    // Pain management recommendations
    if (wellbeingTrends.averagePain > 2.5) {
      recommendations.add(
        PersonalizedRecommendation(
          id: 'pain_management',
          title: 'Natural Pain Relief Strategies',
          description:
              'Your pain levels are elevated. These natural approaches might help reduce discomfort.',
          category: RecommendationCategory.painRelief,
          priority: RecommendationPriority.high,
          actionable: true,
          aiConfidence: 0.82,
          suggestedActions: [
            'Apply heat therapy during discomfort',
            'Try gentle yoga or stretching',
            'Consider anti-inflammatory foods',
            'Stay hydrated throughout the day',
          ],
        ),
      );
    }

    // Cycle tracking optimization
    final completedCycles = cycles.where((c) => c.isCompleted).length;
    if (completedCycles < cycles.length * 0.7) {
      recommendations.add(
        PersonalizedRecommendation(
          id: 'tracking_consistency',
          title: 'Improve Tracking Consistency',
          description:
              'More complete cycle data will unlock better predictions and insights.',
          category: RecommendationCategory.tracking,
          priority: RecommendationPriority.medium,
          actionable: true,
          aiConfidence: 0.9,
          suggestedActions: [
            'Set daily logging reminders',
            'Use the quick-log feature',
            'Track symptoms as they occur',
            'Complete cycle entries promptly',
          ],
        ),
      );
    }

    // Nutrition recommendations based on symptom patterns
    final commonSymptoms = _getCommonSymptoms(cycles);
    if (commonSymptoms.contains('bloating') ||
        commonSymptoms.contains('digestive_issues')) {
      recommendations.add(
        PersonalizedRecommendation(
          id: 'nutrition_digestive',
          title: 'Digestive Health Support',
          description:
              'Your symptoms suggest digestive sensitivity. Consider these dietary adjustments.',
          category: RecommendationCategory.nutrition,
          priority: RecommendationPriority.medium,
          actionable: true,
          aiConfidence: 0.72,
          suggestedActions: [
            'Reduce processed foods during your cycle',
            'Increase fiber intake gradually',
            'Try probiotic-rich foods',
            'Stay hydrated with herbal teas',
          ],
        ),
      );
    }

    return recommendations;
  }

  /// Generate predictive health alerts based on pattern analysis
  static Future<List<PredictiveAlert>> _generatePredictiveAlerts(
    List<CycleData> cycles,
    List<DailyLogEntry> dailyLogs,
  ) async {
    final alerts = <PredictiveAlert>[];

    if (cycles.length < 3) return alerts;

    final completedCycles = cycles.where((c) => c.isCompleted).toList();
    if (completedCycles.length < 3) return alerts;

    // Analyze cycle length irregularity
    final lengths = completedCycles.map((c) => c.lengthInDays).toList();
    final avgLength = lengths.reduce((a, b) => a + b) / lengths.length;
    final variance =
        lengths.map((l) => pow(l - avgLength, 2)).reduce((a, b) => a + b) /
        lengths.length;

    if (variance > 25) {
      // High irregularity threshold
      alerts.add(
        PredictiveAlert(
          id: 'cycle_irregularity',
          title: 'Cycle Irregularity Detected',
          description:
              'Your cycles show increasing variability. This could indicate hormonal changes.',
          severity: AlertSeverity.medium,
          category: AlertCategory.cycleHealth,
          predictedDate: DateTime.now().add(const Duration(days: 7)),
          confidence: 0.75,
          recommendedActions: [
            'Consider consulting with a healthcare provider',
            'Track additional symptoms for patterns',
            'Monitor stress levels and lifestyle changes',
            'Continue consistent tracking for better insights',
          ],
        ),
      );
    }

    // Predict potential symptom flare-ups
    final recentSymptoms = _analyzeRecentSymptomTrends(cycles);
    if (recentSymptoms.contains('severe_cramps')) {
      final nextCycleStart = _predictNextCycleStart(completedCycles);
      alerts.add(
        PredictiveAlert(
          id: 'pain_flareup',
          title: 'Pain Management Preparation',
          description:
              'Based on your patterns, prepare for potential discomfort around your next cycle.',
          severity: AlertSeverity.low,
          category: AlertCategory.symptomManagement,
          predictedDate: nextCycleStart.subtract(const Duration(days: 2)),
          confidence: 0.68,
          recommendedActions: [
            'Stock up on pain relief supplies',
            'Plan lighter activities during this time',
            'Consider preventive pain management',
            'Ensure adequate rest leading up to your cycle',
          ],
        ),
      );
    }

    // Mood pattern alerts
    final wellbeingTrends = EnhancedAnalyticsService.calculateWellbeingTrends(
      cycles,
      dailyLogs,
    );
    final moodTrend = _calculateTrend(wellbeingTrends.moodTrend);

    if (moodTrend < -0.3) {
      // Declining mood trend
      alerts.add(
        PredictiveAlert(
          id: 'mood_decline',
          title: 'Mood Support Needed',
          description:
              'Your mood patterns suggest you might benefit from additional emotional support.',
          severity: AlertSeverity.medium,
          category: AlertCategory.mentalHealth,
          predictedDate: DateTime.now().add(const Duration(days: 3)),
          confidence: 0.71,
          recommendedActions: [
            'Reach out to supportive friends or family',
            'Consider professional counseling if needed',
            'Practice self-care activities',
            'Monitor and log mood daily for better insights',
          ],
        ),
      );
    }

    return alerts;
  }

  /// Analyze symptom patterns using AI-inspired algorithms
  static Future<List<SymptomInsight>> _analyzeSymptomPatterns(
    List<CycleData> cycles,
    List<DailyLogEntry> dailyLogs,
  ) async {
    final insights = <SymptomInsight>[];

    if (cycles.isEmpty) return insights;

    // Calculate symptom frequency and correlation
    final symptomFrequency = <String, int>{};
    final symptomCorrelations = <String, Map<String, int>>{};

    for (final cycle in cycles) {
      final cycleSymptoms = cycle.symptoms.map((s) => s.name).toSet();

      for (final symptom in cycleSymptoms) {
        symptomFrequency[symptom] = (symptomFrequency[symptom] ?? 0) + 1;

        // Track co-occurrence
        for (final otherSymptom in cycleSymptoms) {
          if (symptom != otherSymptom) {
            symptomCorrelations.putIfAbsent(symptom, () => {});
            symptomCorrelations[symptom]![otherSymptom] =
                (symptomCorrelations[symptom]![otherSymptom] ?? 0) + 1;
          }
        }
      }
    }

    // Generate insights for frequent symptoms
    final totalCycles = cycles.length;
    for (final entry in symptomFrequency.entries) {
      final symptom = entry.key;
      final frequency = entry.value;
      final percentage = (frequency / totalCycles * 100).round();

      if (percentage >= 30) {
        // Frequent symptoms (30%+ of cycles)
        final correlatedSymptoms =
            symptomCorrelations[symptom]?.entries
                .where((e) => e.value >= frequency * 0.6)
                .map((e) => e.key)
                .toList() ??
            [];

        insights.add(
          SymptomInsight(
            symptomName: symptom,
            frequency: percentage,
            trend: _analyzeSymptomTrend(cycles, symptom),
            correlatedSymptoms: correlatedSymptoms,
            severity: _analyzeSymptomSeverity(cycles, symptom),
            recommendation: _getSymptomRecommendation(
              symptom,
              percentage,
              correlatedSymptoms,
            ),
            confidence: _calculateSymptomConfidence(frequency, totalCycles),
          ),
        );
      }
    }

    return insights;
  }

  /// Generate wellbeing coaching recommendations
  static Future<WellbeingCoaching> _generateWellbeingCoaching(
    List<CycleData> cycles,
    List<DailyLogEntry> dailyLogs,
  ) async {
    if (cycles.isEmpty) {
      return WellbeingCoaching(
        weeklyGoals: ['Start tracking your first cycle'],
        dailyHabits: ['Download CycleSync and begin logging'],
        motivationalMessage:
            'Every health journey begins with a single step. Start tracking today!',
        progressInsights: [],
      );
    }

    final wellbeingTrends = EnhancedAnalyticsService.calculateWellbeingTrends(
      cycles,
      dailyLogs,
    );
    final weeklyGoals = <String>[];
    final dailyHabits = <String>[];
    final progressInsights = <String>[];

    // Generate weekly goals based on current patterns
    if (wellbeingTrends.averageEnergy < 3.0) {
      weeklyGoals.add('Increase energy levels by 0.5 points');
      dailyHabits.add('Take a 15-minute walk daily');
      dailyHabits.add('Drink an extra glass of water each day');
    }

    if (wellbeingTrends.averageMood < 3.0) {
      weeklyGoals.add('Improve mood stability');
      dailyHabits.add('Practice 5-minute gratitude reflection');
      dailyHabits.add('Spend 10 minutes in natural light');
    }

    if (wellbeingTrends.averagePain > 2.0) {
      weeklyGoals.add('Reduce pain levels naturally');
      dailyHabits.add('Do gentle stretching for 10 minutes');
      dailyHabits.add('Apply heat therapy when needed');
    }

    // Generate progress insights
    if (cycles.length >= 3) {
      final recentCycles = cycles.take(3).toList();
      final olderCycles = cycles.skip(3).take(3).toList();

      if (olderCycles.isNotEmpty) {
        final recentAvgMood =
            recentCycles.map((c) => c.wellbeing.mood).reduce((a, b) => a + b) /
            recentCycles.length;
        final olderAvgMood =
            olderCycles.map((c) => c.wellbeing.mood).reduce((a, b) => a + b) /
            olderCycles.length;

        if (recentAvgMood > olderAvgMood + 0.3) {
          progressInsights.add(
            'Your mood has improved by ${((recentAvgMood - olderAvgMood) * 20).round()}% recently!',
          );
        }
      }
    }

    final motivationalMessages = [
      'You\'re making great progress on your health journey!',
      'Every day of tracking brings you closer to better health insights.',
      'Your commitment to tracking is already paying off!',
      'Small daily habits create lasting health improvements.',
      'You\'re building a powerful foundation for long-term wellness.',
    ];

    return WellbeingCoaching(
      weeklyGoals: weeklyGoals.isEmpty
          ? ['Continue consistent tracking']
          : weeklyGoals,
      dailyHabits: dailyHabits.isEmpty
          ? ['Log your daily symptoms and mood']
          : dailyHabits,
      motivationalMessage:
          motivationalMessages[Random().nextInt(motivationalMessages.length)],
      progressInsights: progressInsights,
    );
  }

  /// Generate cycle optimization recommendations
  static Future<CycleOptimization> _generateCycleOptimization(
    List<CycleData> cycles,
    List<DailyLogEntry> dailyLogs,
  ) async {
    if (cycles.length < 3) {
      return CycleOptimization(
        optimalActivities: {},
        nutritionTiming: {},
        energyPredictions: {},
        lifestyleAdjustments: [
          'Focus on consistent sleep schedule',
          'Stay hydrated throughout your cycle',
        ],
      );
    }

    final completedCycles = cycles.where((c) => c.isCompleted).toList();
    if (completedCycles.isEmpty) {
      return CycleOptimization(
        optimalActivities: {},
        nutritionTiming: {},
        energyPredictions: {},
        lifestyleAdjustments: [
          'Complete your cycle tracking for better optimization',
        ],
      );
    }

    // Analyze energy patterns throughout cycle phases
    final energyPatterns = _analyzeEnergyPatterns(completedCycles);
    final optimalActivities = <String, List<String>>{};
    final nutritionTiming = <String, List<String>>{};
    final energyPredictions = <String, double>{};

    // Generate phase-specific recommendations
    for (final phase in ['Menstrual', 'Follicular', 'Ovulatory', 'Luteal']) {
      final phaseEnergy = energyPatterns[phase] ?? 3.0;
      energyPredictions[phase] = phaseEnergy;

      if (phaseEnergy >= 4.0) {
        optimalActivities[phase] = [
          'High-intensity workouts',
          'Social activities',
          'Creative projects',
          'Challenging tasks at work',
        ];
        nutritionTiming[phase] = [
          'Focus on protein for sustained energy',
          'Complex carbohydrates pre-workout',
          'Antioxidant-rich foods for recovery',
        ];
      } else if (phaseEnergy >= 3.0) {
        optimalActivities[phase] = [
          'Moderate exercise like yoga',
          'Light social activities',
          'Routine tasks',
          'Meal prep and planning',
        ];
        nutritionTiming[phase] = [
          'Balanced meals with protein and fiber',
          'Iron-rich foods if needed',
          'Hydrating foods like fruits',
        ];
      } else {
        optimalActivities[phase] = [
          'Gentle stretching',
          'Meditation and relaxation',
          'Light reading',
          'Restorative activities',
        ];
        nutritionTiming[phase] = [
          'Comfort foods in moderation',
          'Warm, nourishing soups',
          'Magnesium-rich foods for cramps',
        ];
      }
    }

    final lifestyleAdjustments = [
      'Schedule important meetings during high-energy phases',
      'Plan rest days during low-energy phases',
      'Adjust workout intensity based on cycle phase',
      'Practice self-compassion during challenging phases',
    ];

    return CycleOptimization(
      optimalActivities: optimalActivities,
      nutritionTiming: nutritionTiming,
      energyPredictions: energyPredictions,
      lifestyleAdjustments: lifestyleAdjustments,
    );
  }

  // Helper methods for AI analysis

  static double _calculateTrend(List<TrendPoint> trendPoints) {
    if (trendPoints.length < 2) return 0.0;

    final firstHalf = trendPoints.take(trendPoints.length ~/ 2);
    final secondHalf = trendPoints.skip(trendPoints.length ~/ 2);

    if (firstHalf.isEmpty || secondHalf.isEmpty) return 0.0;

    final firstAvg =
        firstHalf.map((p) => p.value).reduce((a, b) => a + b) /
        firstHalf.length;
    final secondAvg =
        secondHalf.map((p) => p.value).reduce((a, b) => a + b) /
        secondHalf.length;

    return secondAvg - firstAvg;
  }

  static List<String> _getCommonSymptoms(List<CycleData> cycles) {
    final symptomCounts = <String, int>{};

    for (final cycle in cycles) {
      for (final symptom in cycle.symptoms) {
        symptomCounts[symptom.name] = (symptomCounts[symptom.name] ?? 0) + 1;
      }
    }

    final threshold = max(1, cycles.length * 0.3);
    return symptomCounts.entries
        .where((entry) => entry.value >= threshold)
        .map((entry) => entry.key)
        .toList();
  }

  static List<String> _analyzeRecentSymptomTrends(List<CycleData> cycles) {
    final recentCycles = cycles.take(3);
    final recentSymptoms = <String>[];

    for (final cycle in recentCycles) {
      for (final symptom in cycle.symptoms) {
        if (symptom.severity >= 3) {
          // Moderate to severe symptoms
          recentSymptoms.add(symptom.name);
        }
      }
    }

    return recentSymptoms;
  }

  static DateTime _predictNextCycleStart(List<CycleData> completedCycles) {
    if (completedCycles.isEmpty)
      return DateTime.now().add(const Duration(days: 28));

    final avgLength =
        completedCycles.map((c) => c.lengthInDays).reduce((a, b) => a + b) /
        completedCycles.length;

    final lastCycle = completedCycles.first;
    return lastCycle.endDate?.add(Duration(days: avgLength.round())) ??
        DateTime.now().add(Duration(days: avgLength.round()));
  }

  static SymptomTrend _analyzeSymptomTrend(
    List<CycleData> cycles,
    String symptom,
  ) {
    final recentCycles = cycles.take(3).toList();
    final olderCycles = cycles.skip(3).take(3).toList();

    if (olderCycles.isEmpty) return SymptomTrend.stable;

    final recentCount = recentCycles
        .where((c) => c.symptoms.any((s) => s.name == symptom))
        .length;
    final olderCount = olderCycles
        .where((c) => c.symptoms.any((s) => s.name == symptom))
        .length;

    if (recentCount > olderCount) return SymptomTrend.increasing;
    if (recentCount < olderCount) return SymptomTrend.decreasing;
    return SymptomTrend.stable;
  }

  static double _analyzeSymptomSeverity(
    List<CycleData> cycles,
    String symptom,
  ) {
    final severities = cycles
        .expand((c) => c.symptoms)
        .where((s) => s.name == symptom)
        .map((s) => s.severity.toDouble())
        .toList();

    if (severities.isEmpty) return 0.0;
    return severities.reduce((a, b) => a + b) / severities.length;
  }

  static String _getSymptomRecommendation(
    String symptom,
    int frequency,
    List<String> correlatedSymptoms,
  ) {
    final recommendations = {
      'cramps':
          'Consider heat therapy, gentle exercise, and magnesium supplements.',
      'bloating':
          'Try reducing sodium intake and increasing water consumption.',
      'mood_swings':
          'Practice mindfulness, maintain stable blood sugar, and ensure adequate sleep.',
      'fatigue':
          'Focus on iron-rich foods, regular sleep schedule, and gentle movement.',
      'headache': 'Stay hydrated, manage stress, and monitor trigger foods.',
      'acne':
          'Maintain consistent skincare routine and consider dairy reduction.',
    };

    final base =
        recommendations[symptom] ??
        'Monitor patterns and consider lifestyle adjustments.';

    if (correlatedSymptoms.isNotEmpty) {
      return '$base These symptoms often occur together, suggesting a common underlying cause.';
    }

    return base;
  }

  static double _calculateSymptomConfidence(int frequency, int totalCycles) {
    if (totalCycles == 0) return 0.0;
    final ratio = frequency / totalCycles;
    return (ratio * 0.8 + (totalCycles >= 6 ? 0.2 : totalCycles * 0.033));
  }

  static Map<String, double> _analyzeEnergyPatterns(
    List<CycleData> completedCycles,
  ) {
    // Simplified phase analysis - in a real app, this would use actual cycle day data
    final patterns = <String, List<double>>{
      'Menstrual': [],
      'Follicular': [],
      'Ovulatory': [],
      'Luteal': [],
    };

    for (final cycle in completedCycles) {
      // Simplified: distribute energy across phases
      patterns['Menstrual']!.add(
        cycle.wellbeing.energy * 0.8,
      ); // Lower during menstruation
      patterns['Follicular']!.add(
        cycle.wellbeing.energy * 1.1,
      ); // Higher in follicular
      patterns['Ovulatory']!.add(
        cycle.wellbeing.energy * 1.2,
      ); // Highest during ovulation
      patterns['Luteal']!.add(
        cycle.wellbeing.energy * 0.9,
      ); // Moderate in luteal
    }

    return patterns.map(
      (phase, energies) => MapEntry(
        phase,
        energies.isEmpty
            ? 3.0
            : energies.reduce((a, b) => a + b) / energies.length,
      ),
    );
  }

  static double _calculateConfidenceScore(
    List<CycleData> cycles,
    List<DailyLogEntry> dailyLogs,
  ) {
    if (cycles.isEmpty) return 0.1;

    double score = 0.0;

    // Data quantity score
    final dataQuantityScore = min(
      1.0,
      cycles.length / 6.0,
    ); // Max score at 6 cycles
    score += dataQuantityScore * 0.4;

    // Data completeness score
    final completedCycles = cycles.where((c) => c.isCompleted).length;
    final completenessScore = cycles.isEmpty
        ? 0.0
        : completedCycles / cycles.length;
    score += completenessScore * 0.3;

    // Data recency score (higher score for more recent data)
    final now = DateTime.now();
    final daysSinceLastEntry = cycles.isEmpty
        ? 365
        : now.difference(cycles.first.startDate).inDays;
    final recencyScore = max(
      0.0,
      1.0 - daysSinceLastEntry / 90.0,
    ); // Max score for entries within 90 days
    score += recencyScore * 0.2;

    // Consistency score (regular tracking)
    final consistencyScore = dailyLogs.length >= cycles.length * 7 ? 1.0 : 0.5;
    score += consistencyScore * 0.1;

    return score.clamp(0.1, 0.95); // Keep within reasonable bounds
  }
}

// Data models for AI insights

class AIHealthInsights {
  final String userId;
  final DateTime generatedAt;
  final List<PersonalizedRecommendation> personalizedRecommendations;
  final List<PredictiveAlert> predictiveAlerts;
  final List<SymptomInsight> symptomInsights;
  final WellbeingCoaching wellbeingCoaching;
  final CycleOptimization cycleOptimization;
  final double confidenceScore;

  AIHealthInsights({
    required this.userId,
    required this.generatedAt,
    required this.personalizedRecommendations,
    required this.predictiveAlerts,
    required this.symptomInsights,
    required this.wellbeingCoaching,
    required this.cycleOptimization,
    required this.confidenceScore,
  });
}

class PersonalizedRecommendation {
  final String id;
  final String title;
  final String description;
  final RecommendationCategory category;
  final RecommendationPriority priority;
  final bool actionable;
  final double aiConfidence;
  final List<String> suggestedActions;

  PersonalizedRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.actionable,
    required this.aiConfidence,
    this.suggestedActions = const [],
  });
}

enum RecommendationCategory {
  lifestyle,
  nutrition,
  exercise,
  mentalHealth,
  painRelief,
  tracking,
  medical,
}

enum RecommendationPriority { low, medium, high, urgent }

class PredictiveAlert {
  final String id;
  final String title;
  final String description;
  final AlertSeverity severity;
  final AlertCategory category;
  final DateTime predictedDate;
  final double confidence;
  final List<String> recommendedActions;

  PredictiveAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.category,
    required this.predictedDate,
    required this.confidence,
    required this.recommendedActions,
  });
}

enum AlertSeverity { low, medium, high, critical }

enum AlertCategory { cycleHealth, symptomManagement, mentalHealth, lifestyle }

class SymptomInsight {
  final String symptomName;
  final int frequency; // Percentage
  final SymptomTrend trend;
  final List<String> correlatedSymptoms;
  final double severity;
  final String recommendation;
  final double confidence;

  SymptomInsight({
    required this.symptomName,
    required this.frequency,
    required this.trend,
    required this.correlatedSymptoms,
    required this.severity,
    required this.recommendation,
    required this.confidence,
  });
}

enum SymptomTrend { increasing, stable, decreasing }

class WellbeingCoaching {
  final List<String> weeklyGoals;
  final List<String> dailyHabits;
  final String motivationalMessage;
  final List<String> progressInsights;

  WellbeingCoaching({
    required this.weeklyGoals,
    required this.dailyHabits,
    required this.motivationalMessage,
    required this.progressInsights,
  });
}

class CycleOptimization {
  final Map<String, List<String>> optimalActivities;
  final Map<String, List<String>> nutritionTiming;
  final Map<String, double> energyPredictions;
  final List<String> lifestyleAdjustments;

  CycleOptimization({
    required this.optimalActivities,
    required this.nutritionTiming,
    required this.energyPredictions,
    required this.lifestyleAdjustments,
  });
}
