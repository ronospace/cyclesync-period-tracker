import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/ai_insights_service.dart';
import '../services/firebase_service.dart';
import '../models/ai_models.dart';

class AIInsightsScreen extends StatefulWidget {
  const AIInsightsScreen({super.key});

  @override
  State<AIInsightsScreen> createState() => _AIInsightsScreenState();
}

class _AIInsightsScreenState extends State<AIInsightsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  CycleInsights? _insights;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadInsights();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInsights() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final cycles = await FirebaseService.getCycles();
      final insights = AIInsightsService.generateInsights(cycles);
      
      setState(() {
        _insights = insights;
        _isLoading = false;
      });
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
      appBar: AppBar(
        title: const Text('🔮 AI Insights'),
        backgroundColor: Colors.purple.shade50,
        foregroundColor: Colors.purple.shade700,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.purple.shade700),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.purple.shade700,
          unselectedLabelColor: Colors.purple.shade300,
          indicatorColor: Colors.purple.shade700,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_today), text: 'Predictions'),
            Tab(icon: Icon(Icons.insights), text: 'Patterns'),
            Tab(icon: Icon(Icons.trending_up), text: 'Trends'),
            Tab(icon: Icon(Icons.recommend), text: 'Health Tips'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInsights,
          ),
        ],
      ),
      body: _buildBody(),
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
            Text('🤖 AI is analyzing your cycles...'),
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
            Text('Failed to load insights: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadInsights,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_insights == null || _insights!.totalCyclesAnalyzed == 0) {
      return _buildNoDataView();
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildPredictionsTab(),
        _buildPatternsTab(),
        _buildTrendsTab(),
        _buildRecommendationsTab(),
      ],
    );
  }

  Widget _buildNoDataView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology,
              size: 80,
              color: Colors.purple.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              'Start Your AI Journey',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade700,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Log at least 3 cycles to unlock AI-powered insights, predictions, and personalized health recommendations.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/log-cycle'),
              icon: const Icon(Icons.add_circle),
              label: const Text('Log Your First Cycle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionsTab() {
    final prediction = _insights!.nextCyclePrediction;
    final regularity = _insights!.cycleRegularity;
    final lengthAnalysis = _insights!.cycleLengthAnalysis;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Data Quality Card
          _buildDataQualityCard(),
          const SizedBox(height: 16),

          // Next Cycle Prediction
          _buildNextCyclePredictionCard(prediction),
          const SizedBox(height: 16),

          // Cycle Regularity
          _buildRegularityCard(regularity),
          const SizedBox(height: 16),

          // Cycle Length Analysis
          _buildCycleLengthCard(lengthAnalysis),
        ],
      ),
    );
  }

  Widget _buildPatternsTab() {
    final patterns = _insights!.symptomPatterns;
    final fertility = _insights!.fertilityInsights;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Symptom Patterns
          _buildSymptomPatternsCard(patterns),
          const SizedBox(height: 16),

          // Fertility Insights
          _buildFertilityInsightsCard(fertility),
          const SizedBox(height: 16),

          // Pattern Correlations
          _buildCorrelationsCard(patterns),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    final trends = _insights!.trendsAnalysis;

    if (trends.cycleLengthTrend == 0 && trends.moodTrend == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.trending_up, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'More Data Needed for Trends',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Track cycles for 6+ months to see meaningful trends and patterns.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTrendsCard(trends),
          const SizedBox(height: 16),
          _buildProgressCard(),
        ],
      ),
    );
  }

  Widget _buildRecommendationsTab() {
    final recommendations = _insights!.healthRecommendations;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (recommendations.isEmpty)
            _buildNoRecommendationsCard()
          else
            ...recommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildRecommendationCard(rec),
            )),
        ],
      ),
    );
  }

  Widget _buildDataQualityCard() {
    final quality = _insights!.dataQuality;
    
    Color qualityColor;
    IconData qualityIcon;
    String qualityText;

    switch (quality.level) {
      case QualityLevel.excellent:
        qualityColor = Colors.green;
        qualityIcon = Icons.star;
        qualityText = 'Excellent';
        break;
      case QualityLevel.good:
        qualityColor = Colors.blue;
        qualityIcon = Icons.thumb_up;
        qualityText = 'Good';
        break;
      case QualityLevel.fair:
        qualityColor = Colors.orange;
        qualityIcon = Icons.warning;
        qualityText = 'Fair';
        break;
      case QualityLevel.poor:
        qualityColor = Colors.red;
        qualityIcon = Icons.priority_high;
        qualityText = 'Needs Improvement';
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(qualityIcon, color: qualityColor),
                const SizedBox(width: 8),
                Text(
                  'Data Quality: $qualityText',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: qualityColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (quality.completeness + quality.consistency) / 2,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(qualityColor),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_insights!.totalCyclesAnalyzed)} cycles analyzed • '
              '${(quality.completeness * 100).round()}% complete data',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextCyclePredictionCard(SimpleNextCyclePrediction prediction) {
    if (prediction.predictedStartDate == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.calendar_month, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Prediction Not Available',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Track 3+ complete cycles for AI predictions.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final daysUntil = prediction.predictedStartDate!.difference(DateTime.now()).inDays;
    
    return Card(
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.purple.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Next Cycle Prediction',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Countdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.shade600,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    daysUntil > 0 ? '$daysUntil days' : 'Expected today',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'until next cycle',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPredictionStat(
                  'Confidence',
                  '${prediction.confidencePercentage}%',
                  Icons.psychology,
                ),
                _buildPredictionStat(
                  'Est. Length',
                  '${prediction.estimatedLength} days',
                  Icons.timeline,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.purple.shade600),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildRegularityCard(CycleRegularity regularity) {
    Color statusColor;
    IconData statusIcon;

    switch (regularity.status) {
      case RegularityStatus.regular:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case RegularityStatus.somewhatRegular:
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      case RegularityStatus.irregular:
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      case RegularityStatus.insufficient:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor),
                const SizedBox(width: 8),
                const Text(
                  'Cycle Regularity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              regularity.description,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            if (regularity.variationDays > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Max variation: ${regularity.variationDays} days',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCycleLengthCard(CycleLengthAnalysis analysis) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Cycle Length Analysis',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLengthStat('Average', '${analysis.averageLength} days'),
                _buildLengthStat('Shortest', '${analysis.shortestCycle} days'),
                _buildLengthStat('Longest', '${analysis.longestCycle} days'),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Trend: ${analysis.trend}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLengthStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildSymptomPatternsCard(SymptomPatterns patterns) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.healing, color: Colors.pink.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Common Symptoms',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (patterns.mostCommonSymptoms.isEmpty)
              const Text('No symptom data available yet.')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: patterns.mostCommonSymptoms.map((symptom) {
                  final frequency = patterns.symptomFrequency[symptom] ?? 0;
                  return Chip(
                    label: Text(_formatSymptomName(symptom)),
                    avatar: CircleAvatar(
                      backgroundColor: Colors.pink.shade100,
                      child: Text('$frequency'),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFertilityInsightsCard(FertilityInsights insights) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: Colors.red.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Fertility Insights',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Average ovulation day: Day ${insights.averageOvulationDay}'),
            const SizedBox(height: 8),
            Text('Luteal phase: ${insights.lutealPhaseLength} days'),
            if (insights.fertilitySignsFrequency.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Fertility signs tracked:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              ...insights.fertilitySignsFrequency.entries.map((entry) =>
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text('${_formatSymptomName(entry.key)}: ${entry.value} times'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCorrelationsCard(SymptomPatterns patterns) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.hub, color: Colors.teal.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Pattern Insights',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (patterns.correlations.isEmpty)
              const Text('Track more symptoms to discover patterns.')
            else
              ...patterns.correlations.map((correlation) =>
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb, size: 16, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(child: Text(correlation)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsCard(TrendsAnalysis trends) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Health Trends',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTrendItem(
              'Cycle Length',
              trends.cycleLengthTrend,
              'days',
            ),
            _buildTrendItem(
              'Mood',
              trends.moodTrend,
              'level',
            ),
            _buildTrendItem(
              'Overall Health',
              trends.overallHealthTrend,
              '',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendItem(String label, double trend, String unit) {
    IconData icon;
    Color color;
    String trendText;

    if (trend > 0.1) {
      icon = Icons.trending_up;
      color = Colors.green;
      trendText = 'Improving';
    } else if (trend < -0.1) {
      icon = Icons.trending_down;
      color = Colors.red;
      trendText = 'Declining';
    } else {
      icon = Icons.trending_flat;
      color = Colors.blue;
      trendText = 'Stable';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Text(trendText, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.green.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Your Progress',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProgressStat('Cycles Tracked', '${_insights!.totalCyclesAnalyzed}'),
                _buildProgressStat('Consistency', '${(_insights!.dataQuality.consistency * 100).round()}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade600,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildRecommendationCard(HealthRecommendation recommendation) {
    Color priorityColor;
    IconData priorityIcon;

    switch (recommendation.priority) {
      case RecommendationPriority.critical:
        priorityColor = Colors.red;
        priorityIcon = Icons.warning;
        break;
      case RecommendationPriority.high:
        priorityColor = Colors.orange;
        priorityIcon = Icons.priority_high;
        break;
      case RecommendationPriority.medium:
        priorityColor = Colors.blue;
        priorityIcon = Icons.info;
        break;
      case RecommendationPriority.low:
        priorityColor = Colors.green;
        priorityIcon = Icons.lightbulb;
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(priorityIcon, color: priorityColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recommendation.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(recommendation.description),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: priorityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: priorityColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation.actionable,
                      style: TextStyle(color: priorityColor, fontWeight: FontWeight.w500),
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

  Widget _buildNoRecommendationsCard() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green.shade600),
            const SizedBox(height: 16),
            Text(
              'Great job! 🎉',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your cycle tracking looks healthy. Keep up the consistent logging!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatSymptomName(String symptom) {
    return symptom.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }
}
