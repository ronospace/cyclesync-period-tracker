import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../services/ai_insights_engine.dart';
import '../services/firebase_service.dart';
import '../models/cycle_models.dart';
import '../models/daily_log_models.dart';

/// 🚀 Mission Gamma: AI-Powered Health Coach Screen
/// Intelligent personal health assistant with ML-powered insights and coaching
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

  // Mock user data for now
  List<CycleData> _cycles = [];
  List<DailyLogEntry> _dailyLogs = [];

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
      // Load cycle data
      final cycleData = await FirebaseService.getCycles(limit: 100);
      final cycles = cycleData.map((cycleMap) => CycleData(
        id: cycleMap['id'] ?? '',
        startDate: (cycleMap['start_date'] as DateTime?) ?? DateTime.now(),
        endDate: cycleMap['end_date'] as DateTime?,
        symptoms: (cycleMap['symptoms'] as List<dynamic>?)?.map((s) => 
          Symptom.fromName(s['name'] ?? '') ?? Symptom.allSymptoms.first
        ).toList() ?? [],
        wellbeing: WellbeingData(
          mood: (cycleMap['mood'] as num?)?.toDouble() ?? 3.0,
          energy: (cycleMap['energy'] as num?)?.toDouble() ?? 3.0,
          pain: (cycleMap['pain'] as num?)?.toDouble() ?? 1.0,
        ),
        notes: cycleMap['notes'] as String? ?? '',
        createdAt: (cycleMap['created_at'] as DateTime?) ?? DateTime.now(),
        updatedAt: (cycleMap['updated_at'] as DateTime?) ?? DateTime.now(),
      )).toList();

      // For now, daily logs are empty but structure is ready
      final dailyLogs = <DailyLogEntry>[];

      // Generate AI insights
      final insights = await AIInsightsEngine.generateInsights(
        cycles: cycles,
        dailyLogs: dailyLogs,
        userId: 'current_user_id', // Replace with actual user ID
      );

      setState(() {
        _cycles = cycles;
        _dailyLogs = dailyLogs;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.deepPurple.shade50,
            foregroundColor: Colors.deepPurple.shade700,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.deepPurple.shade700),
              onPressed: () => context.go('/home'),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.psychology, color: Colors.deepPurple.shade700, size: 24),
                  const SizedBox(width: 8),
                  const Text('AI Health Coach'),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.deepPurple.shade100,
                      Colors.purple.shade50,
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.deepPurple.shade700),
                onPressed: _loadAIInsights,
              ),
            ],
            bottom: _isLoading || _error != null 
              ? null 
              : TabBar(
                  controller: _tabController,
                  labelColor: Colors.deepPurple.shade700,
                  unselectedLabelColor: Colors.deepPurple.shade400,
                  indicatorColor: Colors.deepPurple.shade600,
                  tabs: const [
                    Tab(text: 'Coach', icon: Icon(Icons.psychology, size: 16)),
                    Tab(text: 'Insights', icon: Icon(Icons.lightbulb, size: 16)),
                    Tab(text: 'Alerts', icon: Icon(Icons.warning_amber, size: 16)),
                    Tab(text: 'Optimize', icon: Icon(Icons.tune, size: 16)),
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
          _buildCoachingTab(),
          _buildInsightsTab(),
          _buildAlertsTab(),
          _buildOptimizationTab(),
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
    
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade100, Colors.purple.shade50],
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
                  color: Colors.white.withOpacity(0.9),
                ),
                child: CircularProgressIndicator(
                  value: confidence,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation(Colors.deepPurple.shade600),
                  strokeWidth: 6,
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
                        color: Colors.deepPurple.shade700,
                      ),
                    ),
                    Text(
                      '$percentage% confident in recommendations',
                      style: TextStyle(color: Colors.deepPurple.shade600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      confidence > 0.8 
                        ? 'High-quality insights based on your data'
                        : confidence > 0.6 
                          ? 'Good insights - more data will improve accuracy'
                          : 'Building insights - keep tracking for better results',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
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
        color: _getCategoryColor(rec.category).withOpacity(0.1),
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
                    color: _getSymptomTrendColor(insight.trend).withOpacity(0.2),
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
                    color: _getCategoryColor(rec.category).withOpacity(0.2),
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
                    color: _getPriorityColor(rec.priority).withOpacity(0.2),
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
                      color: _getAlertSeverityColor(alert.severity).withOpacity(0.2),
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
}
