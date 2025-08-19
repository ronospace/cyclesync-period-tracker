import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../services/firebase_service.dart';
import '../services/analytics_service.dart' as analytics hide CycleData;
import '../services/enhanced_analytics_service.dart';
import '../widgets/enhanced_chart_widgets.dart';
import '../widgets/coming_soon_widget.dart';
import '../models/cycle_models.dart';
import '../models/daily_log_models.dart';

class AdvancedAnalyticsScreen extends StatefulWidget {
  const AdvancedAnalyticsScreen({super.key});

  @override
  State<AdvancedAnalyticsScreen> createState() => _AdvancedAnalyticsScreenState();
}

class _AdvancedAnalyticsScreenState extends State<AdvancedAnalyticsScreen> with TickerProviderStateMixin {
  List<Map<String, dynamic>> _cycles = [];
  List<CycleData> _cycleModels = [];
  List<DailyLogEntry> _dailyLogs = [];
  analytics.CycleStatistics? _statistics;
  analytics.CyclePrediction? _prediction;
  WellbeingTrends? _wellbeingTrends;
  SymptomCorrelationMatrix? _correlationMatrix;
  AdvancedPrediction? _advancedPrediction;
  HealthScore? _healthScore;
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;
  String _selectedWellbeingMetric = 'Mood';

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

  Future<void> _generateSampleDataIfNeeded() async {
    // Check if we have any cycles
    final existingCycles = await FirebaseService.getCycles(limit: 1);
    if (existingCycles.isNotEmpty) return; // Already have data
    
    debugPrint('🔄 Generating sample cycle data...');
    
    // Sample cycle data
    final sampleCycles = [
      {
        'start_date': DateTime.now().subtract(const Duration(days: 150)),
        'end_date': DateTime.now().subtract(const Duration(days: 146)),
        'length': 4,
        'flow_intensity': 'medium',
        'symptoms': ['cramps', 'mood_swings'],
        'notes': 'Normal cycle, moderate flow',
      },
      {
        'start_date': DateTime.now().subtract(const Duration(days: 122)),
        'end_date': DateTime.now().subtract(const Duration(days: 117)),
        'length': 5,
        'flow_intensity': 'heavy',
        'symptoms': ['cramps', 'fatigue', 'bloating'],
        'notes': 'Heavy flow cycle with stronger symptoms',
      },
      {
        'start_date': DateTime.now().subtract(const Duration(days: 94)),
        'end_date': DateTime.now().subtract(const Duration(days: 90)),
        'length': 4,
        'flow_intensity': 'light',
        'symptoms': ['mood_swings'],
        'notes': 'Light cycle with minimal symptoms',
      },
      {
        'start_date': DateTime.now().subtract(const Duration(days: 66)),
        'end_date': DateTime.now().subtract(const Duration(days: 62)),
        'length': 4,
        'flow_intensity': 'medium',
        'symptoms': ['cramps', 'headache'],
        'notes': 'Regular cycle with headaches',
      },
      {
        'start_date': DateTime.now().subtract(const Duration(days: 38)),
        'end_date': DateTime.now().subtract(const Duration(days: 34)),
        'length': 4,
        'flow_intensity': 'medium',
        'symptoms': ['cramps'],
        'notes': 'Normal cycle',
      },
      {
        'start_date': DateTime.now().subtract(const Duration(days: 10)),
        'end_date': DateTime.now().subtract(const Duration(days: 6)),
        'length': 4,
        'flow_intensity': 'medium',
        'symptoms': ['cramps', 'mood_swings'],
        'notes': 'Recent cycle',
      },
    ];
    
    // Add cycles to Firebase
    for (final cycle in sampleCycles) {
      await FirebaseService.saveCycleWithSymptoms(cycleData: cycle);
    }
    
    debugPrint('✅ Generated ${sampleCycles.length} sample cycles');
  }

  Future<void> _loadCycles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      debugPrint('🔄 Loading analytics data...');
      
      // Step 1: Generate sample data if needed
      await _generateSampleDataIfNeeded();
      debugPrint('✅ Sample data check complete');
      
      // Step 2: Load cycles with timeout
      final cycles = await FirebaseService.getCycles(limit: 100)
          .timeout(const Duration(seconds: 30));
      debugPrint('✅ Loaded ${cycles.length} cycles');
      
      // Step 3: Calculate statistics with error handling
      late final analytics.CycleStatistics statistics;
      late final analytics.CyclePrediction prediction;
      
      try {
        statistics = analytics.AnalyticsService.calculateStatistics(cycles);
        prediction = analytics.AnalyticsService.predictNextCycle(cycles);
        debugPrint('✅ Analytics calculations complete');
      } catch (e) {
        debugPrint('⚠️ Analytics calculation error: $e');
        // Provide fallback statistics
        statistics = _createFallbackStatistics(cycles);
        prediction = _createFallbackPrediction();
      }
      
      // Convert raw cycle data to models
      final cycleModels = cycles.map((cycleMap) {
        try {
          return CycleData(
            id: cycleMap['id'] ?? '',
            startDate: _parseDateTime(cycleMap['start_date']) ?? DateTime.now(),
            endDate: _parseDateTime(cycleMap['end_date']),
            symptoms: (cycleMap['symptoms'] as List<dynamic>?)?.map((s) {
              final symptomName = s is String ? s : (s['name'] ?? '');
              final symptom = Symptom.fromName(symptomName);
              return symptom;
            }).where((s) => s != null).cast<Symptom>().toList() ?? [],
            wellbeing: WellbeingData(
              mood: (cycleMap['mood'] as num?)?.toDouble() ?? 3.0,
              energy: (cycleMap['energy'] as num?)?.toDouble() ?? 3.0,
              pain: (cycleMap['pain'] as num?)?.toDouble() ?? 1.0,
            ),
            notes: cycleMap['notes'] as String? ?? '',
            createdAt: _parseDateTime(cycleMap['created_at']) ?? DateTime.now(),
            updatedAt: _parseDateTime(cycleMap['updated_at']) ?? DateTime.now(),
          );
        } catch (e) {
          debugPrint('⚠️ Error converting cycle data: $e');
          // Return a basic cycle with safe defaults
          return CycleData(
            id: cycleMap['id']?.toString() ?? '',
            startDate: DateTime.now(),
            endDate: null,
            symptoms: [],
            wellbeing: WellbeingData(mood: 3.0, energy: 3.0, pain: 1.0),
            notes: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
      }).toList();
      
      // Load daily logs (in a real app, this would be a separate service call)
      final dailyLogs = <DailyLogEntry>[];
      
      // Calculate enhanced analytics (simplified for now)
      final wellbeingTrends = _createMockWellbeingTrends();
      final correlationMatrix = _createMockCorrelationMatrix();
      final advancedPrediction = _createMockAdvancedPrediction();
      final healthScore = _createMockHealthScore();
      
      setState(() {
        _cycles = cycles;
        _cycleModels = cycleModels;
        _dailyLogs = dailyLogs;
        _statistics = statistics;
        _prediction = prediction;
        _wellbeingTrends = wellbeingTrends;
        _correlationMatrix = correlationMatrix;
        _advancedPrediction = advancedPrediction;
        _healthScore = healthScore;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading analytics: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Try to provide fallback data or helpful error message
      String errorMessage;
      if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Connection timeout - please check your internet connection and try again';
      } else if (e.toString().contains('FirebaseException')) {
        errorMessage = 'Database connection error - please try again in a moment';
      } else if (e.toString().contains('FormatException') || e.toString().contains('type')) {
        errorMessage = 'Data format error - some data may be corrupted';
      } else {
        errorMessage = 'Unable to load analytics data: ${e.toString()}';
      }
      
      setState(() {
        _error = errorMessage;
        _isLoading = false;
      });
    }
  }

  // Helper method to parse DateTime from various formats
  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    
    if (value is DateTime) {
      return value;
    }
    
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        debugPrint('⚠️ Failed to parse DateTime from string: $value, error: $e');
        return null;
      }
    }
    
    // Handle Firestore Timestamp objects if needed
    if (value.runtimeType.toString().contains('Timestamp')) {
      try {
        return (value as dynamic).toDate();
      } catch (e) {
        debugPrint('⚠️ Failed to parse DateTime from Timestamp: $value, error: $e');
        return null;
      }
    }
    
    debugPrint('⚠️ Unknown DateTime format: ${value.runtimeType} - $value');
    return null;
  }

  // Fallback methods for error handling
  analytics.CycleStatistics _createFallbackStatistics(List<Map<String, dynamic>> cycles) {
    debugPrint('🔄 Creating fallback statistics for ${cycles.length} cycles');
    
    // Basic calculations with error protection
    final totalCycles = cycles.length;
    double averageLength = 28.0; // default
    List<int> cycleLengths = [];
    
    try {
      // Calculate cycle lengths safely
      for (final cycle in cycles) {
        final startDate = cycle['start_date'] as DateTime?;
        final endDate = cycle['end_date'] as DateTime?;
        if (startDate != null && endDate != null) {
          final length = endDate.difference(startDate).inDays;
          if (length > 0 && length < 60) { // reasonable bounds
            cycleLengths.add(length);
          }
        }
      }
      
      if (cycleLengths.isNotEmpty) {
        averageLength = cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
      }
    } catch (e) {
      debugPrint('⚠️ Error calculating cycle lengths: $e');
    }
    
    // Create fallback statistics
    return analytics.CycleStatistics(
      totalCycles: totalCycles,
      averageLength: averageLength,
      shortestCycle: cycleLengths.isNotEmpty ? cycleLengths.reduce((a, b) => a < b ? a : b) : 28,
      longestCycle: cycleLengths.isNotEmpty ? cycleLengths.reduce((a, b) => a > b ? a : b) : 28,
      standardDeviation: cycleLengths.length > 1 ? _calculateStandardDeviation(cycleLengths, averageLength) : 0.0,
      regularityScore: totalCycles >= 3 ? 75.0 : 0.0,
      predictionAccuracy: totalCycles >= 3 ? 65.0 : 0.0,
      cycleLengthHistory: cycleLengths.isNotEmpty ? cycleLengths : [28, 29, 27, 28],
      recentCycles: [], // Empty for fallback
      trends: analytics.CycleTrends(
        lengthTrend: analytics.TrendDirection.stable,
        lengthTrendValue: 0.0, // stable trend value
        symptomTrends: {},
      ),
    );
  }
  
  double _calculateStandardDeviation(List<int> values, double mean) {
    if (values.length <= 1) return 0.0;
    
    double sumSquaredDifferences = 0.0;
    for (final value in values) {
      final difference = value - mean;
      sumSquaredDifferences += difference * difference;
    }
    
    final variance = sumSquaredDifferences / values.length;
    return math.sqrt(variance);
  }
  
  analytics.CyclePrediction _createFallbackPrediction() {
    debugPrint('🔄 Creating fallback prediction');
    
    final now = DateTime.now();
    final nextCycleStart = now.add(const Duration(days: 28));
    
    return analytics.CyclePrediction(
      nextCycleStart: nextCycleStart,
      nextCycleEnd: nextCycleStart.add(const Duration(days: 4)),
      predictedLength: 28,
      daysUntilNext: 28,
      ovulationWindow: analytics.DateRange(
        nextCycleStart.add(const Duration(days: 12)),
        nextCycleStart.add(const Duration(days: 16)),
      ),
      confidence: 50.0, // low confidence for fallback
    );
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
                  _statistics!.trends.lengthTrend == analytics.TrendDirection.increasing
                      ? Icons.trending_up
                      : _statistics!.trends.lengthTrend == analytics.TrendDirection.decreasing
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

  Widget _buildSymptomTrendCard(String symptom, analytics.SymptomTrend trend) {
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

  Color _getTrendColor(analytics.TrendDirection trend) {
    switch (trend) {
      case analytics.TrendDirection.increasing:
        return Colors.red;
      case analytics.TrendDirection.decreasing:
        return Colors.green;
      case analytics.TrendDirection.stable:
        return Colors.blue;
    }
  }

  IconData _getTrendIcon(analytics.TrendDirection trend) {
    switch (trend) {
      case analytics.TrendDirection.increasing:
        return Icons.trending_up;
      case analytics.TrendDirection.decreasing:
        return Icons.trending_down;
      case analytics.TrendDirection.stable:
        return Icons.trending_flat;
    }
  }

  String _formatSymptomName(String symptom) {
    return symptom.split('_').map((word) => 
        word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  // 🚀 Mission Alpha Enhanced Tabs
  Widget _buildWellbeingTab() {
    if (_wellbeingTrends == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.psychology, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No wellbeing data available yet'),
            Text(
              'Log cycles with mood, energy, and pain data to see trends',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
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
          // Health Score Card
          if (_healthScore != null) _buildHealthScoreCard(),
          const SizedBox(height: 24),
          
          // Interactive Wellbeing Trends Chart
          WellbeingTrendChart(
            trends: _wellbeingTrends!,
            selectedMetric: _selectedWellbeingMetric,
            onMetricChanged: (metric) {
              setState(() {
                _selectedWellbeingMetric = metric;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCorrelationsTab() {
    if (_correlationMatrix == null || _correlationMatrix!.symptoms.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grid_view, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No symptom correlation data available yet'),
            Text(
              'Log cycles with multiple symptoms to discover patterns',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Symptom Correlation Heatmap
          SymptomCorrelationHeatmap(matrix: _correlationMatrix!),
        ],
      ),
    );
  }

  Widget _buildAdvancedPredictionsTab() {
    if (_advancedPrediction == null || _advancedPrediction!.basedOnCycles == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Advanced Predictions Unavailable',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Log at least 3 completed cycles to unlock\nadvanced predictions with confidence intervals',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/log-cycle'),
              child: const Text('Log More Cycles'),
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
          // Advanced Prediction Card with Confidence Intervals
          _buildAdvancedPredictionCard(),
          const SizedBox(height: 24),
          
          // Cycle Phase Analysis
          _buildCyclePhaseCard(),
        ],
      ),
    );
  }

  Widget _buildHealthScoreCard() {
    final score = _healthScore!;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [score.gradeColor.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.health_and_safety, color: score.gradeColor, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Health Score',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${score.overall.toInt()}/100 • ${score.overallGrade}',
                          style: TextStyle(
                            fontSize: 16,
                            color: score.gradeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircularProgressIndicator(
                    value: score.overall / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(score.gradeColor),
                    strokeWidth: 8,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (score.breakdown.isNotEmpty) ...[
                Text(
                  'Breakdown',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...score.breakdown.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        '${entry.value.toInt()}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _getAccuracyColor(entry.value),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedPredictionCard() {
    final prediction = _advancedPrediction!;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.indigo.shade600, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Advanced Predictions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Based on ${prediction.basedOnCycles} cycles with ${(prediction.confidence * 100).toInt()}% confidence',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Next Cycle with Confidence Range
            _buildAdvancedPredictionItem(
              title: 'Next Cycle Start',
              primaryDate: prediction.nextCycleStart,
              confidenceRange: '${DateFormat.MMMd().format(prediction.confidenceLowerBound)} - ${DateFormat.MMMd().format(prediction.confidenceUpperBound)}',
              icon: Icons.calendar_today,
              color: Colors.blue,
            ),
            
            const SizedBox(height: 16),
            
            // Ovulation Prediction
            _buildAdvancedPredictionItem(
              title: 'Ovulation Date',
              primaryDate: prediction.ovulationDate,
              confidenceRange: '${DateFormat.MMMd().format(prediction.fertileWindowStart)} - ${DateFormat.MMMd().format(prediction.fertileWindowEnd)} fertile window',
              icon: Icons.favorite,
              color: Colors.pink,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedPredictionItem({
    required String title,
    required DateTime primaryDate,
    required String confidenceRange,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  DateFormat.yMMMd().format(primaryDate),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  confidenceRange,
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
    );
  }

  Widget _buildCyclePhaseCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: Colors.purple.shade600, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Cycle Phase Analysis',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Discover patterns in your symptoms and wellbeing across cycle phases',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            
            // Phase breakdown (simplified for now)
            _buildPhaseRow('Menstrual', '1-5 days', Colors.red),
            _buildPhaseRow('Follicular', '6-13 days', Colors.green),
            _buildPhaseRow('Ovulatory', '14-16 days', Colors.orange),
            _buildPhaseRow('Luteal', '17-28 days', Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseRow(String name, String days, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            days,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Advanced Analytics'),
        backgroundColor: Colors.purple.shade50,
        foregroundColor: Colors.purple.shade700,
        iconTheme: IconThemeData(color: Colors.purple.shade700),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.purple.shade700),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        child: ComingSoonSection(
          title: '📊 Advanced Analytics Dashboard',
          features: [
            ComingSoonFeatures.advancedAnalytics,
            const ComingSoonWidget(
              title: 'AI-Powered Correlations',
              description: 'Discover hidden patterns and correlations between symptoms, mood, and cycle phases',
              icon: Icons.hub,
              estimatedDate: 'Q2 2024',
              status: 'In Development',
              accentColor: Colors.indigo,
              showDetails: true,
              features: [
                'Symptom correlation heatmaps',
                'AI-driven pattern recognition',
                'Predictive health modeling',
                'Cross-cycle trend analysis',
                'Statistical significance testing',
              ],
            ),
            const ComingSoonWidget(
              title: 'Wellbeing Analytics',
              description: 'Advanced mood, energy, and wellness tracking with predictive insights',
              icon: Icons.psychology,
              estimatedDate: 'Q3 2024',
              status: 'Design Phase',
              accentColor: Colors.teal,
              showDetails: true,
              features: [
                'Mood pattern analysis across cycles',
                'Energy level predictions',
                'Sleep quality correlation tracking',
                'Stress impact assessment',
                'Wellness score calculations',
              ],
            ),
            const ComingSoonWidget(
              title: 'Professional Health Reports',
              description: 'Comprehensive health reports suitable for sharing with healthcare providers',
              icon: Icons.article,
              estimatedDate: 'Q4 2024',
              status: 'Research Phase',
              accentColor: Colors.red,
              showDetails: true,
              features: [
                'Medical-grade analytics reports',
                'Shareable PDF health summaries',
                'Healthcare provider integration',
                'HIPAA-compliant data handling',
                'Customizable report templates',
              ],
            ),
            const ComingSoonWidget(
              title: 'Comparative Analytics',
              description: 'Compare your patterns with anonymized population data for deeper insights',
              icon: Icons.compare_arrows,
              estimatedDate: 'Q1 2025',
              status: 'Planning Phase',
              accentColor: Colors.amber,
              showDetails: true,
              features: [
                'Anonymous population comparisons',
                'Age-group trend analysis',
                'Geographic health insights',
                'Statistical benchmarking',
                'Privacy-first data aggregation',
              ],
            ),
          ],
        ),
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

// Mock data methods for testing
extension _MockData on _AdvancedAnalyticsScreenState {
  WellbeingTrends _createMockWellbeingTrends() {
    return WellbeingTrends(
      moodTrend: TrendData(
        values: [3.5, 4.0, 3.8, 4.2, 3.9, 4.1],
        dates: _generateDates(6),
        trend: analytics.TrendDirection.increasing,
      ),
      energyTrend: TrendData(
        values: [3.2, 3.8, 3.5, 3.9, 3.7, 4.0],
        dates: _generateDates(6),
        trend: analytics.TrendDirection.increasing,
      ),
      painTrend: TrendData(
        values: [2.1, 1.8, 2.3, 1.9, 2.0, 1.7],
        dates: _generateDates(6),
        trend: analytics.TrendDirection.decreasing,
      ),
      averageMood: 3.9,
      averageEnergy: 3.7,
      averagePain: 1.9,
    );
  }

  SymptomCorrelationMatrix _createMockCorrelationMatrix() {
    return SymptomCorrelationMatrix(
      symptoms: ['cramps', 'headache', 'mood_swings', 'fatigue'],
      correlations: {
        'cramps': {'cramps': 1.0, 'headache': 0.6, 'mood_swings': 0.3, 'fatigue': 0.7},
        'headache': {'cramps': 0.6, 'headache': 1.0, 'mood_swings': 0.5, 'fatigue': 0.4},
        'mood_swings': {'cramps': 0.3, 'headache': 0.5, 'mood_swings': 1.0, 'fatigue': 0.2},
        'fatigue': {'cramps': 0.7, 'headache': 0.4, 'mood_swings': 0.2, 'fatigue': 1.0},
      },
    );
  }

  AdvancedPrediction _createMockAdvancedPrediction() {
    final now = DateTime.now();
    return AdvancedPrediction(
      nextCycleStart: now.add(const Duration(days: 7)),
      ovulationDate: now.add(const Duration(days: 21)),
      fertileWindowStart: now.add(const Duration(days: 19)),
      fertileWindowEnd: now.add(const Duration(days: 23)),
      confidence: 0.85,
      basedOnCycles: 5,
      confidenceLowerBound: now.add(const Duration(days: 5)),
      confidenceUpperBound: now.add(const Duration(days: 9)),
    );
  }

  HealthScore _createMockHealthScore() {
    return HealthScore(
      overall: 82.0,
      overallGrade: 'B+',
      gradeColor: Colors.green,
      breakdown: {
        'Regularity': 85.0,
        'Symptoms': 78.0,
        'Wellbeing': 84.0,
        'Data Quality': 90.0,
      },
    );
  }

  List<DateTime> _generateDates(int count) {
    final now = DateTime.now();
    return List.generate(count, (i) => now.subtract(Duration(days: (count - 1 - i) * 28)));
  }
}

// Mock data classes
class WellbeingTrends {
  final TrendData moodTrend;
  final TrendData energyTrend;
  final TrendData painTrend;
  final double averageMood;
  final double averageEnergy;
  final double averagePain;

  WellbeingTrends({
    required this.moodTrend,
    required this.energyTrend,
    required this.painTrend,
    required this.averageMood,
    required this.averageEnergy,
    required this.averagePain,
  });
}

class TrendData {
  final List<double> values;
  final List<DateTime> dates;
  final analytics.TrendDirection trend;

  TrendData({
    required this.values,
    required this.dates,
    required this.trend,
  });
}

class SymptomCorrelationMatrix {
  final List<String> symptoms;
  final Map<String, Map<String, double>> correlations;

  SymptomCorrelationMatrix({
    required this.symptoms,
    required this.correlations,
  });
}

class AdvancedPrediction {
  final DateTime nextCycleStart;
  final DateTime ovulationDate;
  final DateTime fertileWindowStart;
  final DateTime fertileWindowEnd;
  final double confidence;
  final int basedOnCycles;
  final DateTime confidenceLowerBound;
  final DateTime confidenceUpperBound;

  AdvancedPrediction({
    required this.nextCycleStart,
    required this.ovulationDate,
    required this.fertileWindowStart,
    required this.fertileWindowEnd,
    required this.confidence,
    required this.basedOnCycles,
    required this.confidenceLowerBound,
    required this.confidenceUpperBound,
  });
}

class HealthScore {
  final double overall;
  final String overallGrade;
  final Color gradeColor;
  final Map<String, double> breakdown;

  HealthScore({
    required this.overall,
    required this.overallGrade,
    required this.gradeColor,
    required this.breakdown,
  });
}

// Simplified chart widgets
class WellbeingTrendChart extends StatelessWidget {
  final WellbeingTrends trends;
  final String selectedMetric;
  final Function(String) onMetricChanged;

  const WellbeingTrendChart({
    super.key,
    required this.trends,
    required this.selectedMetric,
    required this.onMetricChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wellbeing Trends',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildMetricButton('Mood', trends.averageMood, Colors.blue),
                const SizedBox(width: 8),
                _buildMetricButton('Energy', trends.averageEnergy, Colors.orange),
                const SizedBox(width: 8),
                _buildMetricButton('Pain', trends.averagePain, Colors.red),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Average scores over recent cycles',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricButton(String name, double value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SymptomCorrelationHeatmap extends StatelessWidget {
  final SymptomCorrelationMatrix matrix;

  const SymptomCorrelationHeatmap({super.key, required this.matrix});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Symptom Correlations',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Add X-axis header row
            Row(
              children: [
                const SizedBox(
                  width: 100,
                  child: Text(''),  // Empty space for Y-axis labels
                ),
                Expanded(
                  child: Row(
                    children: matrix.symptoms.map((symptom) {
                      return Expanded(
                        child: Container(
                          height: 30,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          child: Center(
                            child: Text(
                              _formatSymptomName(symptom),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...matrix.symptoms.map((symptom) {
              final correlations = matrix.correlations[symptom] ?? {};
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        _formatSymptomName(symptom),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: matrix.symptoms.map((otherSymptom) {
                          final correlation = correlations[otherSymptom] ?? 0.0;
                          return Expanded(
                            child: Container(
                              height: 30,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                color: _getCorrelationColor(correlation),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  correlation.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _formatSymptomName(String symptom) {
    return symptom.split('_').map((word) => 
        word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  Color _getCorrelationColor(double correlation) {
    if (correlation >= 0.7) return Colors.red.shade700;
    if (correlation >= 0.4) return Colors.orange.shade600;
    if (correlation >= 0.2) return Colors.yellow.shade700;
    return Colors.grey.shade400;
  }
}
