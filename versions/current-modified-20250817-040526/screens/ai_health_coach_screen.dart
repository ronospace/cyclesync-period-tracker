import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/app_branding_service.dart';
// Mock data models for AI insights
class AIHealthInsights {
  final double confidenceScore;
  final WellbeingCoaching wellbeingCoaching;
  final List<SymptomInsight> symptomInsights;
  final List<PersonalizedRecommendation> personalizedRecommendations;
  final List<PredictiveAlert> predictiveAlerts;
  final CycleOptimization cycleOptimization;

  AIHealthInsights({
    required this.confidenceScore,
    required this.wellbeingCoaching,
    required this.symptomInsights,
    required this.personalizedRecommendations,
    required this.predictiveAlerts,
    required this.cycleOptimization,
  });
}

class WellbeingCoaching {
  final String motivationalMessage;
  final List<String> progressInsights;
  final List<String> weeklyGoals;
  final List<String> dailyHabits;

  WellbeingCoaching({
    required this.motivationalMessage,
    required this.progressInsights,
    required this.weeklyGoals,
    required this.dailyHabits,
  });
}

class SymptomInsight {
  final String symptomName;
  final int frequency;
  final SymptomTrend trend;
  final String recommendation;
  final List<String> correlatedSymptoms;

  SymptomInsight({
    required this.symptomName,
    required this.frequency,
    required this.trend,
    required this.recommendation,
    required this.correlatedSymptoms,
  });
}

class PersonalizedRecommendation {
  final String title;
  final String description;
  final RecommendationCategory category;
  final RecommendationPriority priority;
  final double aiConfidence;
  final List<String> suggestedActions;

  PersonalizedRecommendation({
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.aiConfidence,
    required this.suggestedActions,
  });
}

class PredictiveAlert {
  final String title;
  final String description;
  final AlertSeverity severity;
  final DateTime predictedDate;
  final List<String> recommendedActions;

  PredictiveAlert({
    required this.title,
    required this.description,
    required this.severity,
    required this.predictedDate,
    required this.recommendedActions,
  });
}

class CycleOptimization {
  final Map<String, double> energyPredictions;
  final Map<String, List<String>> optimalActivities;
  final Map<String, List<String>> nutritionTiming;
  final List<String> lifestyleAdjustments;

  CycleOptimization({
    required this.energyPredictions,
    required this.optimalActivities,
    required this.nutritionTiming,
    required this.lifestyleAdjustments,
  });
}

enum SymptomTrend { increasing, stable, decreasing }
enum RecommendationCategory { lifestyle, nutrition, exercise, mentalHealth, painRelief, tracking, medical }
enum RecommendationPriority { low, medium, high, urgent }
enum AlertSeverity { low, medium, high, critical }

class AIHealthCoachScreen extends StatefulWidget {
  const AIHealthCoachScreen({super.key});

  @override
  State<AIHealthCoachScreen> createState() => _AIHealthCoachScreenState();
}

class _AIHealthCoachScreenState extends State<AIHealthCoachScreen> with TickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;
  AIHealthInsights? _insights;
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadAIInsights();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAIInsights() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Simulate AI processing delay
      await Future.delayed(const Duration(seconds: 2));

      // Generate mock AI insights
      final insights = _generateMockInsights();

      setState(() {
        _insights = insights;
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  AIHealthInsights _generateMockInsights() {
    return AIHealthInsights(
      confidenceScore: 0.85,
      wellbeingCoaching: WellbeingCoaching(
        motivationalMessage: "You're doing great with your tracking! Your consistent data helps FlowSense AI provide better insights for your health journey.",
        progressInsights: [
          "Your cycle regularity has improved by 15% over the past 3 months",
          "You've successfully reduced symptom severity through lifestyle changes",
          "Your wellness tracking consistency is excellent - 92% completion rate"
        ],
        weeklyGoals: [
          "Track daily mood and energy levels",
          "Maintain consistent sleep schedule",
          "Practice stress-reduction techniques 3x this week",
          "Stay hydrated with 8+ glasses of water daily"
        ],
        dailyHabits: [
          "Morning stretching or yoga (10 minutes)",
          "Mindful check-in with body signals",
          "Evening reflection and symptom logging",
          "Limit caffeine after 2 PM for better sleep"
        ],
      ),
      symptomInsights: [
        SymptomInsight(
          symptomName: "headaches",
          frequency: 65,
          trend: SymptomTrend.decreasing,
          recommendation: "Your headaches are showing a positive decreasing trend. Consider continuing your current stress management routine and maintain consistent sleep patterns.",
          correlatedSymptoms: ["fatigue", "mood_changes"],
        ),
        SymptomInsight(
          symptomName: "cramping",
          frequency: 78,
          trend: SymptomTrend.stable,
          recommendation: "Cramping appears stable. Try incorporating magnesium-rich foods and gentle exercise during your luteal phase to potentially reduce severity.",
          correlatedSymptoms: ["bloating", "back_pain"],
        ),
      ],
      personalizedRecommendations: [
        PersonalizedRecommendation(
          title: "Optimize Sleep for Better Cycle Health",
          description: "Based on your patterns, improving sleep quality could reduce symptom severity by up to 25%. Your data shows correlation between poor sleep and increased symptoms.",
          category: RecommendationCategory.lifestyle,
          priority: RecommendationPriority.high,
          aiConfidence: 0.87,
          suggestedActions: [
            "Aim for 7-9 hours of sleep nightly",
            "Create a consistent bedtime routine",
            "Avoid screens 1 hour before bed",
            "Keep bedroom temperature cool (65-68°F)"
          ],
        ),
        PersonalizedRecommendation(
          title: "Anti-Inflammatory Nutrition Focus",
          description: "Your symptom patterns suggest inflammation may be a key factor. Incorporating anti-inflammatory foods could provide significant relief.",
          category: RecommendationCategory.nutrition,
          priority: RecommendationPriority.medium,
          aiConfidence: 0.82,
          suggestedActions: [
            "Increase omega-3 rich foods (salmon, walnuts, flax)",
            "Add turmeric and ginger to meals",
            "Reduce processed foods and refined sugars",
            "Include leafy greens and berries daily"
          ],
        ),
        PersonalizedRecommendation(
          title: "Stress Management Protocol",
          description: "High stress levels correlate with 40% of your most severe symptom days. Implementing regular stress reduction could significantly improve your experience.",
          category: RecommendationCategory.mentalHealth,
          priority: RecommendationPriority.high,
          aiConfidence: 0.91,
          suggestedActions: [
            "Practice deep breathing exercises daily",
            "Try meditation apps (10-15 minutes)",
            "Schedule regular downtime and self-care",
            "Consider journaling for emotional release"
          ],
        ),
        PersonalizedRecommendation(
          title: "Gentle Exercise Routine",
          description: "Light, consistent movement during different cycle phases can help regulate hormones and reduce symptoms naturally.",
          category: RecommendationCategory.exercise,
          priority: RecommendationPriority.medium,
          aiConfidence: 0.78,
          suggestedActions: [
            "Walk 20-30 minutes daily",
            "Try yoga during luteal phase",
            "Swimming for low-impact cardio",
            "Strength training 2x per week (follicular phase)"
          ],
        ),
      ],
      predictiveAlerts: [
        // For demo, we'll show no alerts for a positive experience
      ],
      cycleOptimization: CycleOptimization(
        energyPredictions: {
          "Menstrual": 2.8,
          "Follicular": 4.2,
          "Ovulatory": 4.8,
          "Luteal": 3.5,
        },
        optimalActivities: {
          "Menstrual": [
            "Gentle yoga and stretching",
            "Light walking or swimming",
            "Meditation and rest",
            "Warm baths for comfort"
          ],
          "Follicular": [
            "Try new activities and challenges",
            "Strength training and HIIT",
            "Social activities and networking",
            "Creative projects and brainstorming"
          ],
          "Ovulatory": [
            "High-intensity workouts",
            "Important meetings and presentations",
            "Social events and dating",
            "Problem-solving and decision making"
          ],
          "Luteal": [
            "Routine maintenance tasks",
            "Moderate cardio and yoga",
            "Detail-oriented work",
            "Meal prep and organization"
          ],
        },
        nutritionTiming: {
          "Menstrual": [
            "Iron-rich foods (spinach, lean meats)",
            "Warming foods and herbal teas",
            "Anti-inflammatory spices",
            "Complex carbs for stable energy"
          ],
          "Follicular": [
            "Fresh fruits and vegetables",
            "Lean proteins and healthy fats",
            "Fermented foods for gut health",
            "Green tea and antioxidants"
          ],
          "Ovulatory": [
            "Fiber-rich foods for detoxification",
            "Raw fruits and vegetables",
            "Healthy fats (avocado, nuts)",
            "Anti-inflammatory foods"
          ],
          "Luteal": [
            "Complex carbs to stabilize mood",
            "Magnesium-rich foods (dark chocolate, nuts)",
            "B-vitamin sources (leafy greens)",
            "Herbal teas (chamomile, raspberry leaf)"
          ],
        },
        lifestyleAdjustments: [
          "Schedule important tasks during high-energy phases (follicular/ovulatory)",
          "Plan rest and self-care during menstrual phase",
          "Use cycle tracking for better life planning",
          "Adjust social commitments based on energy predictions",
          "Optimize work schedules around natural rhythms",
          "Practice extra self-compassion during PMS phase"
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brandingService = Provider.of<AppBrandingService>(context);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: brandingService.primaryColor.withValues(alpha: 0.1),
            foregroundColor: brandingService.primaryColor,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: brandingService.primaryColor),
              onPressed: () => context.go('/home'),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.psychology, color: brandingService.primaryColor, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Health Insights',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: brandingService.appGradient,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, color: brandingService.primaryColor),
                onPressed: _loadAIInsights,
              ),
            ],
            bottom: _isLoading || _error != null 
              ? null 
              : TabBar(
                  controller: _tabController,
                  labelColor: brandingService.primaryColor,
                  unselectedLabelColor: brandingService.primaryColor.withValues(alpha: 0.6),
                  indicatorColor: brandingService.secondaryColor,
                  tabs: [
                    Tab(text: 'Clinical Summary', icon: Icon(Icons.medical_information, size: 16)),
                    Tab(text: 'Diagnostics', icon: Icon(Icons.analytics, size: 16)),
                    Tab(text: 'Risk Assessment', icon: Icon(Icons.warning_amber, size: 16)),
                    Tab(text: 'Treatment Plans', icon: Icon(Icons.medication, size: 16)),
                  ],
                ),
          ),
          SliverFillRemaining(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('AI is analyzing your health patterns...'),
            SizedBox(height: 8),
            Text(
              'This may take a moment',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            const Text('Failed to load AI insights'),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAIInsights,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_insights == null) {
      return const Center(
        child: Text('No insights available'),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildClinicalSummaryTab(),
          _buildDiagnosticsTab(),
          _buildRiskAssessmentTab(),
          _buildTreatmentPlansTab(),
        ],
      ),
    );
  }

  // Clinical Summary Tab - Medical overview with key metrics
  Widget _buildClinicalSummaryTab() {
    final coaching = _insights!.wellbeingCoaching;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient Overview Card
          _buildPatientOverviewCard(),
          const SizedBox(height: 20),
          
          // Clinical Confidence Score
          _buildClinicalConfidenceCard(),
          const SizedBox(height: 20),

          // Key Clinical Findings
          _buildClinicalFindingsCard(),
          const SizedBox(height: 20),

          // Current Treatment Response
          _buildTreatmentResponseCard(),
          const SizedBox(height: 20),

          // Next Appointment Recommendations
          _buildNextAppointmentCard(),
        ],
      ),
    );
  }

  // Diagnostics Tab - AI analysis and clinical insights
  Widget _buildDiagnosticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Diagnostic Analysis Header
          Card(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.indigo.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade600, Colors.indigo.shade600],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.analytics, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Diagnostic Analysis',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        Text(
                          'Clinical-grade pattern recognition and symptom analysis',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Cycle Pattern Analysis
          if (_insights!.symptomInsights.isNotEmpty) ...[
            Text(
              'Cycle Pattern Analysis',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._insights!.symptomInsights.map((insight) => _buildClinicalSymptomCard(insight)),
            const SizedBox(height: 24),
          ],

          // Hormonal Indicators
          _buildHormonalIndicatorsCard(),
          const SizedBox(height: 20),

          // Clinical Recommendations
          Text(
            'Clinical Recommendations',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._insights!.personalizedRecommendations.map((rec) => _buildClinicalRecommendationCard(rec)),
        ],
      ),
    );
  }

  // Risk Assessment Tab - Clinical risk factors and alerts
  Widget _buildRiskAssessmentTab() {
    final alerts = _insights!.predictiveAlerts;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Risk Assessment Header
          Card(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade50, Colors.red.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade600, Colors.red.shade600],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.warning_amber, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Clinical Risk Assessment',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade800,
                          ),
                        ),
                        Text(
                          'AI-powered risk stratification and predictive alerts',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Risk Factors
          _buildRiskFactorsCard(),
          const SizedBox(height: 20),
          
          // Predictive Alerts
          if (alerts.isEmpty) ...[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: Colors.green.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Low Risk Profile',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No immediate clinical concerns identified.\nContinue monitoring and regular follow-ups.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ] else ...[
            Text(
              'Active Risk Alerts',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 16),
            ...alerts.map((alert) => _buildClinicalAlertCard(alert)),
          ],
        ],
      ),
    );
  }

  // Treatment Plans Tab - Clinical recommendations and protocols
  Widget _buildTreatmentPlansTab() {
    final optimization = _insights!.cycleOptimization;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Treatment Plan Header
          Card(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade50, Colors.teal.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade600, Colors.teal.shade600],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.medication, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Clinical Treatment Protocol',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                        Text(
                          'Evidence-based treatment recommendations and monitoring',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Primary Treatment Plan
          _buildPrimaryTreatmentCard(),
          const SizedBox(height: 20),

          // Pharmacological Recommendations
          _buildPharmacologicalCard(),
          const SizedBox(height: 20),

          // Lifestyle Medicine Interventions
          if (optimization.lifestyleAdjustments.isNotEmpty) ...[
            _buildLifestyleMedicineCard(optimization.lifestyleAdjustments),
            const SizedBox(height: 20),
          ],

          // Monitoring Protocol
          _buildMonitoringProtocolCard(),
          const SizedBox(height: 20),

          // Follow-up Schedule
          _buildFollowUpScheduleCard(),
        ],
      ),
    );
  }

  Widget _buildCoachingTab() {
    final coaching = _insights!.wellbeingCoaching;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Confidence Score
          _buildConfidenceCard(),
          const SizedBox(height: 20),

          // Motivational Message
          _buildMotivationCard(coaching.motivationalMessage),
          const SizedBox(height: 20),

          // Progress Insights
          if (coaching.progressInsights.isNotEmpty) ...[
            _buildProgressInsightsCard(coaching.progressInsights),
            const SizedBox(height: 20),
          ],

          // Weekly Goals
          _buildGoalsCard('This Week\'s Goals', coaching.weeklyGoals, Icons.flag, Colors.blue),
          const SizedBox(height: 20),

          // Daily Habits
          _buildGoalsCard('Daily Habits', coaching.dailyHabits, Icons.wb_sunny, Colors.orange),
          const SizedBox(height: 20),

          // Personalized Recommendations
          _buildRecommendationsPreview(),
        ],
      ),
    );
  }

  Widget _buildInsightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Symptom Insights
          if (_insights!.symptomInsights.isNotEmpty) ...[
            Text(
              'Symptom Insights',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._insights!.symptomInsights.map((insight) => _buildSymptomInsightCard(insight)),
            const SizedBox(height: 24),
          ],

          // Personalized Recommendations
          Text(
            'Personalized Recommendations',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._insights!.personalizedRecommendations.map((rec) => _buildRecommendationCard(rec)),
        ],
      ),
    );
  }

  Widget _buildAlertsTab() {
    final alerts = _insights!.predictiveAlerts;

    if (alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.green.shade300),
            const SizedBox(height: 16),
            Text(
              'All Clear!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.green.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No predictive health alerts at this time.\nKeep up the great tracking!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildAlertCard(alerts[index]),
        );
      },
    );
  }

  Widget _buildOptimizationTab() {
    final optimization = _insights!.cycleOptimization;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Energy Predictions
          if (optimization.energyPredictions.isNotEmpty) ...[
            _buildEnergyPredictionsCard(optimization.energyPredictions),
            const SizedBox(height: 20),
          ],

          // Optimal Activities by Phase
          if (optimization.optimalActivities.isNotEmpty) ...[
            Text(
              'Optimal Activities by Cycle Phase',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...optimization.optimalActivities.entries.map((entry) => 
              _buildPhaseCard(entry.key, entry.value, Icons.fitness_center, Colors.green)
            ),
            const SizedBox(height: 20),
          ],

          // Nutrition Timing
          if (optimization.nutritionTiming.isNotEmpty) ...[
            Text(
              'Nutrition Recommendations',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...optimization.nutritionTiming.entries.map((entry) => 
              _buildPhaseCard(entry.key, entry.value, Icons.restaurant, Colors.orange)
            ),
            const SizedBox(height: 20),
          ],

          // Lifestyle Adjustments
          if (optimization.lifestyleAdjustments.isNotEmpty) ...[
            _buildLifestyleCard(optimization.lifestyleAdjustments),
          ],
        ],
      ),
    );
  }

  Widget _buildConfidenceCard() {
    final confidence = _insights!.confidenceScore;
    final percentage = (confidence * 100).round();
    final brandingService = Provider.of<AppBrandingService>(context, listen: false);
    
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: brandingService.appGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                child: Center(
                  child: Stack(
                    children: [
                      CircularProgressIndicator(
                        value: confidence,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation(brandingService.secondaryColor),
                        strokeWidth: 6,
                      ),
                      Positioned.fill(
                        child: Center(
                          child: Text(
                            '$percentage%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: brandingService.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Confidence Score',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$percentage% confident in recommendations',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      confidence > 0.8 
                        ? 'High-quality insights based on your data'
                        : confidence > 0.6 
                          ? 'Good insights - more data will improve accuracy'
                          : 'Building insights - keep tracking for better results',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMotivationCard(String message) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.pink.shade50, Colors.orange.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.favorite,
              color: Colors.pink.shade400,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressInsightsCard(List<String> insights) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green.shade600),
                const SizedBox(width: 8),
                Text(
                  'Progress Insights',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...insights.map((insight) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.celebration, color: Colors.orange.shade500, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(insight)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsCard(String title, List<String> items, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(item)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsPreview() {
    final topRecommendations = _insights!.personalizedRecommendations.take(2);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top Recommendations',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => _tabController.animateTo(1),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...topRecommendations.map((rec) => _buildMiniRecommendationCard(rec)),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniRecommendationCard(PersonalizedRecommendation rec) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
            color: _getCategoryColor(rec.category).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(_getCategoryIcon(rec.category), color: _getCategoryColor(rec.category)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rec.title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  rec.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomInsightCard(SymptomInsight insight) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getSymptomTrendColor(insight.trend).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${insight.frequency}% of cycles',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getSymptomTrendColor(insight.trend),
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  _getSymptomTrendIcon(insight.trend),
                  color: _getSymptomTrendColor(insight.trend),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _formatSymptomName(insight.symptomName),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(insight.recommendation),
            if (insight.correlatedSymptoms.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Often occurs with:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: insight.correlatedSymptoms.map((symptom) => Chip(
                  label: Text(
                    _formatSymptomName(symptom),
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: Colors.grey.shade200,
                  side: BorderSide.none,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(PersonalizedRecommendation rec) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(rec.category).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(rec.category),
                    color: _getCategoryColor(rec.category),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rec.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${(rec.aiConfidence * 100).round()}% AI Confidence',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(rec.priority).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    rec.priority.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getPriorityColor(rec.priority),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(rec.description),
            if (rec.suggestedActions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Suggested Actions:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              ...rec.suggestedActions.map((action) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_right,
                      color: _getCategoryColor(rec.category),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(action, style: const TextStyle(fontSize: 14))),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(PredictiveAlert alert) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getAlertSeverityColor(alert.severity),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getAlertIcon(alert.severity),
                    color: _getAlertSeverityColor(alert.severity),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      alert.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getAlertSeverityColor(alert.severity).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      alert.severity.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getAlertSeverityColor(alert.severity),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Expected: ${DateFormat.MMMd().format(alert.predictedDate)}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(alert.description),
              const SizedBox(height: 16),
              Text(
                'Recommended Actions:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              ...alert.recommendedActions.map((action) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: _getAlertSeverityColor(alert.severity),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(action, style: const TextStyle(fontSize: 14))),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnergyPredictionsCard(Map<String, double> predictions) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Energy Predictions by Cycle Phase',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...predictions.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: LinearProgressIndicator(
                      value: entry.value / 5.0,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(_getEnergyColor(entry.value)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${entry.value.toStringAsFixed(1)}/5',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getEnergyColor(entry.value),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseCard(String phase, List<String> items, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  '$phase Phase',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item, style: const TextStyle(fontSize: 14))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildLifestyleCard(List<String> adjustments) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber.shade600),
                const SizedBox(width: 8),
                Text(
                  'Lifestyle Optimization Tips',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...adjustments.map((adjustment) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber.shade600, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(adjustment)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  // Helper methods for colors and icons

  Color _getCategoryColor(RecommendationCategory category) {
    switch (category) {
      case RecommendationCategory.lifestyle:
        return Colors.blue;
      case RecommendationCategory.nutrition:
        return Colors.green;
      case RecommendationCategory.exercise:
        return Colors.orange;
      case RecommendationCategory.mentalHealth:
        return Colors.purple;
      case RecommendationCategory.painRelief:
        return Colors.red;
      case RecommendationCategory.tracking:
        return Colors.cyan;
      case RecommendationCategory.medical:
        return Colors.pink;
    }
  }

  IconData _getCategoryIcon(RecommendationCategory category) {
    switch (category) {
      case RecommendationCategory.lifestyle:
        return Icons.home;
      case RecommendationCategory.nutrition:
        return Icons.restaurant;
      case RecommendationCategory.exercise:
        return Icons.fitness_center;
      case RecommendationCategory.mentalHealth:
        return Icons.psychology;
      case RecommendationCategory.painRelief:
        return Icons.healing;
      case RecommendationCategory.tracking:
        return Icons.timeline;
      case RecommendationCategory.medical:
        return Icons.medical_services;
    }
  }

  Color _getPriorityColor(RecommendationPriority priority) {
    switch (priority) {
      case RecommendationPriority.low:
        return Colors.green;
      case RecommendationPriority.medium:
        return Colors.orange;
      case RecommendationPriority.high:
        return Colors.red;
      case RecommendationPriority.urgent:
        return Colors.purple;
    }
  }

  Color _getAlertSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return Colors.blue;
      case AlertSeverity.medium:
        return Colors.orange;
      case AlertSeverity.high:
        return Colors.red;
      case AlertSeverity.critical:
        return Colors.purple;
    }
  }

  IconData _getAlertIcon(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return Icons.info;
      case AlertSeverity.medium:
        return Icons.warning;
      case AlertSeverity.high:
        return Icons.error;
      case AlertSeverity.critical:
        return Icons.dangerous;
    }
  }

  Color _getSymptomTrendColor(SymptomTrend trend) {
    switch (trend) {
      case SymptomTrend.increasing:
        return Colors.red;
      case SymptomTrend.stable:
        return Colors.blue;
      case SymptomTrend.decreasing:
        return Colors.green;
    }
  }

  IconData _getSymptomTrendIcon(SymptomTrend trend) {
    switch (trend) {
      case SymptomTrend.increasing:
        return Icons.trending_up;
      case SymptomTrend.stable:
        return Icons.trending_flat;
      case SymptomTrend.decreasing:
        return Icons.trending_down;
    }
  }

  Color _getEnergyColor(double energy) {
    if (energy >= 4.0) return Colors.green;
    if (energy >= 3.0) return Colors.orange;
    return Colors.red;
  }

  String _formatSymptomName(String symptom) {
    return symptom.split('_').map((word) => 
        word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  // Clinical Helper Methods
  Widget _buildPatientOverviewCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.cyan.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_outline, color: Colors.blue.shade700, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Patient Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem('Age', '28', Icons.cake),
                ),
                Expanded(
                  child: _buildMetricItem('BMI', '22.1', Icons.monitor_weight),
                ),
                Expanded(
                  child: _buildMetricItem('Cycles', '156', Icons.calendar_month),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicalConfidenceCard() {
    final confidence = _insights!.confidenceScore;
    final percentage = (confidence * 100).round();
    
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.indigo.shade600, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                child: Center(
                  child: Stack(
                    children: [
                      CircularProgressIndicator(
                        value: confidence,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation(Colors.blue.shade600),
                        strokeWidth: 6,
                      ),
                      Positioned.fill(
                        child: Center(
                          child: Text(
                            '$percentage%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo.shade700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clinical AI Confidence',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Diagnostic accuracy: $percentage%',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      confidence > 0.8 
                        ? 'High clinical confidence - reliable insights'
                        : confidence > 0.6 
                          ? 'Moderate confidence - additional data recommended'
                          : 'Building baseline - continue monitoring',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClinicalFindingsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Key Clinical Findings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFindingItem(
              'Cycle Regularity',
              'Normal (28 ± 3 days)',
              Icons.check_circle,
              Colors.green,
              'Consistent cycle length indicates normal ovarian function',
            ),
            const SizedBox(height: 12),
            _buildFindingItem(
              'Symptom Severity',
              'Mild to Moderate',
              Icons.info,
              Colors.orange,
              'Manageable symptoms with lifestyle interventions',
            ),
            const SizedBox(height: 12),
            _buildFindingItem(
              'Overall Health Trend',
              'Improving',
              Icons.trending_up,
              Colors.green,
              '15% improvement in symptom management over 3 months',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentResponseCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Treatment Response',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildResponseMetric('Symptom Reduction', '25%', Colors.green),
                ),
                Expanded(
                  child: _buildResponseMetric('Sleep Quality', '+18%', Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Patient responding well to current treatment protocol',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextAppointmentCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.purple.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Next Appointment Recommendations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAppointmentRecommendation(
              'Follow-up Schedule',
              '3 months',
              'Continue current monitoring protocol',
            ),
            const SizedBox(height: 8),
            _buildAppointmentRecommendation(
              'Laboratory Tests',
              'Not required',
              'Current data sufficient for assessment',
            ),
            const SizedBox(height: 8),
            _buildAppointmentRecommendation(
              'Discussion Points',
              '3 items',
              'Lifestyle modifications, symptom management, contraceptive options',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade600, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.blue.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildFindingItem(String title, String value, IconData icon, Color color, String description) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResponseMetric(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentRecommendation(String title, String value, String description) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.purple.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade600,
                    ),
                  ),
                ],
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Placeholder methods for clinical tabs (implement these based on your needs)
  Widget _buildClinicalSymptomCard(SymptomInsight insight) => _buildSymptomInsightCard(insight);
  Widget _buildHormonalIndicatorsCard() => SizedBox(height: 100, child: Center(child: Text('Hormonal Indicators')));
  Widget _buildClinicalRecommendationCard(PersonalizedRecommendation rec) => _buildRecommendationCard(rec);
  Widget _buildRiskFactorsCard() => SizedBox(height: 100, child: Center(child: Text('Risk Factors')));
  Widget _buildClinicalAlertCard(PredictiveAlert alert) => _buildAlertCard(alert);
  Widget _buildPrimaryTreatmentCard() => SizedBox(height: 100, child: Center(child: Text('Primary Treatment')));
  Widget _buildPharmacologicalCard() => SizedBox(height: 100, child: Center(child: Text('Pharmacological Recommendations')));
  Widget _buildLifestyleMedicineCard(List<String> adjustments) => _buildLifestyleCard(adjustments);
  Widget _buildMonitoringProtocolCard() => SizedBox(height: 100, child: Center(child: Text('Monitoring Protocol')));
  Widget _buildFollowUpScheduleCard() => SizedBox(height: 100, child: Center(child: Text('Follow-up Schedule')));
}
