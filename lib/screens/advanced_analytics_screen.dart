import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../services/firebase_service.dart';
import '../services/analytics_service.dart';

class AdvancedAnalyticsScreen extends StatefulWidget {
  const AdvancedAnalyticsScreen({super.key});

  @override
  State<AdvancedAnalyticsScreen> createState() => _AdvancedAnalyticsScreenState();
}

class _AdvancedAnalyticsScreenState extends State<AdvancedAnalyticsScreen> with TickerProviderStateMixin {
  List<Map<String, dynamic>> _cycles = [];
  CycleStatistics? _statistics;
  CyclePrediction? _prediction;
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCycles();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCycles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final cycles = await FirebaseService.getCycles(limit: 100);
      final statistics = AnalyticsService.calculateStatistics(cycles);
      final prediction = AnalyticsService.predictNextCycle(cycles);
      
      setState(() {
        _cycles = cycles;
        _statistics = statistics;
        _prediction = prediction;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildOverviewTab() {
    if (_statistics == null) return const Center(child: Text('No data available'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics Cards
          _buildStatsGrid(),
          const SizedBox(height: 24),
          
          // Cycle Length Chart
          _buildCycleLengthChart(),
          const SizedBox(height: 24),
          
          // Predictions
          _buildPredictionsCard(),
          const SizedBox(height: 24),

          // Quick Actions
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = _statistics!;
    
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          title: 'Total Cycles',
          value: '${stats.totalCycles}',
          icon: Icons.calendar_today,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'Average Length',
          value: '${stats.averageLength.toStringAsFixed(1)} days',
          icon: Icons.timeline,
          color: Colors.green,
        ),
        _buildStatCard(
          title: 'Regularity Score',
          value: '${stats.regularityScore.toInt()}%',
          icon: Icons.track_changes,
          color: _getRegularityColor(stats.regularityScore),
          subtitle: _getRegularityLabel(stats.regularityScore),
        ),
        _buildStatCard(
          title: 'Prediction Accuracy',
          value: '${stats.predictionAccuracy.toInt()}%',
          icon: Icons.precision_manufacturing,
          color: _getAccuracyColor(stats.predictionAccuracy),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCycleLengthChart() {
    if (_statistics?.cycleLengthHistory.isEmpty ?? true) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Not enough data for chart'),
        ),
      );
    }

    final cycleLengths = _statistics!.cycleLengthHistory.reversed.toList();
    final spots = cycleLengths
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.toDouble()))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, color: Colors.purple.shade600),
                const SizedBox(width: 8),
                Text(
                  'Cycle Length Trends',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}',
                              style: const TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final cycleIndex = cycleLengths.length - value.toInt() - 1;
                          return Text('${cycleLengths.length - value.toInt()}',
                              style: const TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.purple.shade400,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.purple.shade100,
                      ),
                    ),
                  ],
                  minY: (cycleLengths.reduce((a, b) => a < b ? a : b) - 2).toDouble(),
                  maxY: (cycleLengths.reduce((a, b) => a > b ? a : b) + 2).toDouble(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _statistics!.trends.lengthTrend == TrendDirection.increasing
                      ? Icons.trending_up
                      : _statistics!.trends.lengthTrend == TrendDirection.decreasing
                          ? Icons.trending_down
                          : Icons.trending_flat,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  'Trend: ${_statistics!.trends.lengthTrend.displayName}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionsCard() {
    if (_prediction == null || _prediction!.confidence == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.schedule, color: Colors.grey.shade400, size: 48),
              const SizedBox(height: 8),
              const Text('Need more cycles for predictions'),
              const SizedBox(height: 4),
              Text(
                'Log at least 3 completed cycles to see predictions',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Text(
                  'Predictions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Next Cycle Prediction
            _buildPredictionItem(
              icon: Icons.calendar_today,
              title: 'Next Cycle Start',
              value: DateFormat.yMMMd().format(_prediction!.nextCycleStart),
              subtitle: '${_prediction!.daysUntilNext} days from now',
              confidence: _prediction!.confidence,
            ),
            
            const SizedBox(height: 12),
            
            // Ovulation Window
            _buildPredictionItem(
              icon: Icons.favorite,
              title: 'Fertile Window',
              value: '${DateFormat.MMMd().format(_prediction!.ovulationWindow.start)} - ${DateFormat.MMMd().format(_prediction!.ovulationWindow.end)}',
              subtitle: 'Estimated ovulation period',
              confidence: _prediction!.confidence,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionItem({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required double confidence,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue.shade400, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                value,
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            Text(
              '${confidence.toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getAccuracyColor(confidence),
              ),
            ),
            Text(
              'confidence',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrendsTab() {
    if (_statistics == null || _statistics!.trends.symptomTrends.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No symptom trends available'),
            Text(
              'Log cycles with symptoms to see trends',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Symptom Trends',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ..._statistics!.trends.symptomTrends.entries.map((entry) {
            final symptom = entry.key;
            final trend = entry.value;
            return _buildSymptomTrendCard(symptom, trend);
          }),
        ],
      ),
    );
  }

  Widget _buildSymptomTrendCard(String symptom, SymptomTrend trend) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: _getTrendColor(trend.trend).withOpacity(0.1),
              child: Icon(
                _getTrendIcon(trend.trend),
                color: _getTrendColor(trend.trend),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatSymptomName(symptom),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Frequency: ${(trend.frequency * 100).toInt()}%',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  Text(
                    'Trend: ${trend.trend.displayName}',
                    style: TextStyle(
                      color: _getTrendColor(trend.trend),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Progress indicator
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                value: trend.frequency,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(_getTrendColor(trend.trend)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsTab() {
    if (_statistics == null) {
      return const Center(child: Text('No insights available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Insights',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ..._generateInsights().map((insight) => _buildInsightCard(insight)),
        ],
      ),
    );
  }

  List<InsightData> _generateInsights() {
    final insights = <InsightData>[];
    final stats = _statistics!;

    // Regularity insight
    if (stats.regularityScore >= 80) {
      insights.add(InsightData(
        title: 'Excellent Regularity',
        description: 'Your cycles are very consistent, which is a good sign of hormonal balance.',
        icon: Icons.check_circle,
        color: Colors.green,
        priority: InsightPriority.positive,
      ));
    } else if (stats.regularityScore >= 60) {
      insights.add(InsightData(
        title: 'Moderate Regularity',
        description: 'Your cycles show some variation, which is normal. Continue tracking for better insights.',
        icon: Icons.info,
        color: Colors.orange,
        priority: InsightPriority.neutral,
      ));
    } else {
      insights.add(InsightData(
        title: 'Irregular Cycles',
        description: 'Your cycles show significant variation. Consider consulting with a healthcare provider.',
        icon: Icons.warning,
        color: Colors.red,
        priority: InsightPriority.attention,
      ));
    }

    // Cycle length insight
    if (stats.averageLength >= 21 && stats.averageLength <= 35) {
      insights.add(InsightData(
        title: 'Normal Cycle Length',
        description: 'Your average cycle length of ${stats.averageLength.toStringAsFixed(1)} days is within the normal range.',
        icon: Icons.timeline,
        color: Colors.green,
        priority: InsightPriority.positive,
      ));
    } else {
      insights.add(InsightData(
        title: stats.averageLength < 21 ? 'Short Cycles' : 'Long Cycles',
        description: stats.averageLength < 21 
            ? 'Your cycles are shorter than typical. This could be normal for you or worth discussing with a doctor.'
            : 'Your cycles are longer than typical. This could be normal for you or worth discussing with a doctor.',
        icon: Icons.schedule,
        color: Colors.orange,
        priority: InsightPriority.neutral,
      ));
    }

    // Prediction accuracy insight
    if (stats.predictionAccuracy >= 70) {
      insights.add(InsightData(
        title: 'Reliable Predictions',
        description: 'Our predictions are ${stats.predictionAccuracy.toInt()}% accurate for your cycles.',
        icon: Icons.precision_manufacturing,
        color: Colors.blue,
        priority: InsightPriority.positive,
      ));
    } else if (stats.predictionAccuracy > 0) {
      insights.add(InsightData(
        title: 'Improving Predictions',
        description: 'Keep logging cycles to improve prediction accuracy (currently ${stats.predictionAccuracy.toInt()}%).',
        icon: Icons.trending_up,
        color: Colors.orange,
        priority: InsightPriority.neutral,
      ));
    }

    // Data quality insight
    if (stats.totalCycles >= 6) {
      insights.add(InsightData(
        title: 'Great Data Quality',
        description: 'You have ${stats.totalCycles} cycles logged, providing excellent insights.',
        icon: Icons.data_usage,
        color: Colors.green,
        priority: InsightPriority.positive,
      ));
    } else {
      insights.add(InsightData(
        title: 'Building Your Profile',
        description: 'Log ${6 - stats.totalCycles} more cycles for even better insights and predictions.',
        icon: Icons.add_chart,
        color: Colors.blue,
        priority: InsightPriority.neutral,
      ));
    }

    return insights..sort((a, b) => a.priority.index.compareTo(b.priority.index));
  }

  Widget _buildInsightCard(InsightData insight) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: insight.color.withOpacity(0.1),
          child: Icon(insight.icon, color: insight.color),
        ),
        title: Text(
          insight.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(insight.description),
        trailing: Icon(
          insight.priority == InsightPriority.attention
              ? Icons.priority_high
              : insight.priority == InsightPriority.positive
                  ? Icons.thumb_up
                  : Icons.info_outline,
          color: insight.color.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.go('/log-cycle'),
                icon: const Icon(Icons.add),
                label: const Text('Log Cycle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.go('/cycle-history'),
                icon: const Icon(Icons.history),
                label: const Text('View History'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getRegularityColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getRegularityLabel(double score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Poor';
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 70) return Colors.green;
    if (accuracy >= 50) return Colors.orange;
    return Colors.red;
  }

  Color _getTrendColor(TrendDirection trend) {
    switch (trend) {
      case TrendDirection.increasing:
        return Colors.red;
      case TrendDirection.decreasing:
        return Colors.green;
      case TrendDirection.stable:
        return Colors.blue;
    }
  }

  IconData _getTrendIcon(TrendDirection trend) {
    switch (trend) {
      case TrendDirection.increasing:
        return Icons.trending_up;
      case TrendDirection.decreasing:
        return Icons.trending_down;
      case TrendDirection.stable:
        return Icons.trending_flat;
    }
  }

  String _formatSymptomName(String symptom) {
    return symptom.split('_').map((word) => 
        word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Advanced Analytics'),
        backgroundColor: Colors.purple.shade50,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCycles,
          ),
        ],
        bottom: _isLoading || _error != null || _cycles.isEmpty
            ? null
            : TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Overview', icon: Icon(Icons.dashboard, size: 16)),
                  Tab(text: 'Trends', icon: Icon(Icons.trending_up, size: 16)),
                  Tab(text: 'Insights', icon: Icon(Icons.lightbulb, size: 16)),
                ],
              ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analyzing your cycles...'),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load analytics',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text('Please try again'),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadCycles,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _cycles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.analytics,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No cycle data yet',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          const Text('Log some cycles to see your analytics'),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => context.go('/log-cycle'),
                            child: const Text('Log Your First Cycle'),
                          ),
                        ],
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOverviewTab(),
                        _buildTrendsTab(),
                        _buildInsightsTab(),
                      ],
                    ),
    );
  }
}

// Supporting data classes
class InsightData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final InsightPriority priority;

  InsightData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.priority,
  });
}

enum InsightPriority { attention, neutral, positive }
