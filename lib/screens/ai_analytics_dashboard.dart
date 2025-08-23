import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/tensorflow_prediction_service.dart';
import '../services/advanced_health_kit_service.dart';
import '../providers/cycle_provider.dart';

/// Phase 2 Enhanced AI Analytics Dashboard with TensorFlow Predictions
/// Extraordinary biometric analysis and machine learning insights
class AIAnalyticsDashboard extends StatefulWidget {
  const AIAnalyticsDashboard({Key? key}) : super(key: key);

  @override
  State<AIAnalyticsDashboard> createState() => _AIAnalyticsDashboardState();
}

class _AIAnalyticsDashboardState extends State<AIAnalyticsDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TensorFlowPredictionService _aiService =
      TensorFlowPredictionService.instance;
  final AdvancedHealthKitService _healthService =
      AdvancedHealthKitService.instance;

  // AI Prediction Results
  OvulationPredictionResult? _ovulationPrediction;
  HRVStressAnalysisResult? _stressAnalysis;
  EmotionClassificationResult? _emotionClassification;
  CycleIrregularityResult? _cycleIrregularity;
  SleepQualityPredictionResult? _sleepPrediction;

  // Loading states
  bool _isLoadingPredictions = false;
  bool _isLoadingHealthData = false;

  // Health data
  Map<String, dynamic> _currentBiometrics = {};
  List<Map<String, dynamic>> _recentHealthData = [];
  List<Map<String, dynamic>> _cycleHistory = [];

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    // Initialize animation controllers
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _initializeAI();
    _loadHealthData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _initializeAI() async {
    setState(() => _isLoadingPredictions = true);

    try {
      // Initialize TensorFlow Lite models
      final initialized = await _aiService.initialize();

      if (initialized) {
        debugPrint('🧠 AI Models initialized successfully');
        await _runAIPredictions();
      } else {
        debugPrint(
          '⚠️ AI Models initialization failed - using algorithmic fallback',
        );
        await _runAIPredictions(); // Still run predictions with algorithmic fallback
      }
    } catch (e) {
      debugPrint('❌ AI initialization error: $e');
      _showErrorSnackBar('AI initialization failed: $e');
    } finally {
      setState(() => _isLoadingPredictions = false);
    }
  }

  Future<void> _loadHealthData() async {
    setState(() => _isLoadingHealthData = true);

    try {
      // Load recent health data from HealthKit
      final healthData = await _healthService.fetchComprehensiveHealthData(
        days: 30,
        includeHRV: true,
        includeTemperature: true,
        includeSleep: true,
        includeActivity: true,
      );

      // Get cycle history from provider
      final cycleProvider = Provider.of<CycleProvider>(context, listen: false);
      _cycleHistory = cycleProvider.cycles
          .map(
            (cycle) => {
              'length': cycle.lengthInDays,
              'start_date': cycle.startDate.toIso8601String(),
              'symptoms': cycle.symptoms,
            },
          )
          .toList();

      // Extract current biometrics
      _currentBiometrics = _extractCurrentBiometrics(healthData);
      _recentHealthData = healthData;
    } catch (e) {
      debugPrint('❌ Health data loading error: $e');
      _showErrorSnackBar('Failed to load health data: $e');
    } finally {
      setState(() => _isLoadingHealthData = false);
    }
  }

  Map<String, dynamic> _extractCurrentBiometrics(
    List<Map<String, dynamic>> healthData,
  ) {
    // Extract the most recent values for each metric
    final today = DateTime.now();
    final todayData = healthData.where((data) {
      final date = DateTime.parse(data['date'] as String);
      return date.day == today.day && date.month == today.month;
    }).toList();

    return {
      'heart_rate': _getLatestValue(todayData, 'heart_rate') ?? 70.0,
      'hrv': _getLatestValue(todayData, 'hrv') ?? 35.0,
      'temperature': _getLatestValue(todayData, 'temperature') ?? 98.6,
      'steps': _getLatestValue(todayData, 'steps') ?? 8000.0,
      'sleep_score': _getLatestValue(todayData, 'sleep_quality') ?? 75.0,
      'resting_heart_rate':
          _getLatestValue(todayData, 'resting_heart_rate') ?? 65.0,
      'current_day_in_cycle': _getCurrentDayInCycle(),
      'respiratory_rate':
          _getLatestValue(todayData, 'respiratory_rate') ?? 16.0,
    };
  }

  double? _getLatestValue(List<Map<String, dynamic>> data, String type) {
    final filtered = data.where((d) => d['type'] == type).toList();
    if (filtered.isEmpty) return null;
    filtered.sort(
      (a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])),
    );
    return (filtered.first['value'] as num?)?.toDouble();
  }

  int _getCurrentDayInCycle() {
    final cycleProvider = Provider.of<CycleProvider>(context, listen: false);
    final currentCycle = cycleProvider.currentCycle;
    if (currentCycle == null) return 14;

    return DateTime.now().difference(currentCycle.startDate).inDays + 1;
  }

  Future<void> _runAIPredictions() async {
    try {
      // Run all AI predictions concurrently for better performance
      final predictions = await Future.wait([
        _aiService.predictOvulation(
          cycleHistory: _cycleHistory,
          healthData: _recentHealthData,
          currentBiomarkers: _currentBiometrics,
        ),
        _aiService.analyzeHRVStress(
          hrvData: _filterHealthData('hrv'),
          heartRateData: _filterHealthData('heart_rate'),
          sleepData: _extractSleepData(),
          activityData: _extractActivityData(),
        ),
        _aiService.classifyEmotionFromWearables(
          biometricSnapshot: _currentBiometrics,
          recentActivity: _filterHealthData('activity_intensity'),
          sleepContext: _extractSleepData(),
        ),
        _aiService.detectCycleIrregularities(
          cycleHistory: _cycleHistory,
          healthTrends: _recentHealthData,
          lifestyleFactors: _extractLifestyleFactors(),
        ),
        _aiService.predictSleepQuality(
          sleepHistory: _filterHealthData('sleep_quality'),
          currentBiometrics: _currentBiometrics,
          dailyActivity: _extractActivityData(),
        ),
      ]);

      setState(() {
        _ovulationPrediction = predictions[0] as OvulationPredictionResult;
        _stressAnalysis = predictions[1] as HRVStressAnalysisResult;
        _emotionClassification = predictions[2] as EmotionClassificationResult;
        _cycleIrregularity = predictions[3] as CycleIrregularityResult;
        _sleepPrediction = predictions[4] as SleepQualityPredictionResult;
      });

      debugPrint('🎯 All AI predictions completed successfully');
    } catch (e) {
      debugPrint('❌ AI prediction error: $e');
      _showErrorSnackBar('AI prediction failed: $e');
    }
  }

  List<Map<String, dynamic>> _filterHealthData(String type) {
    return _recentHealthData.where((data) => data['type'] == type).toList();
  }

  Map<String, dynamic> _extractSleepData() {
    final sleepData = _filterHealthData('sleep_quality');
    if (sleepData.isEmpty) {
      return {
        'duration': 480.0,
        'quality': 75.0,
        'deep_sleep_percentage': 25.0,
      };
    }

    final latest = sleepData.first;
    return {
      'duration': latest['duration'] ?? 480.0,
      'quality': latest['value'] ?? 75.0,
      'deep_sleep_percentage': latest['deep_percentage'] ?? 25.0,
    };
  }

  Map<String, dynamic> _extractActivityData() {
    return {
      'steps': _currentBiometrics['steps'] ?? 8000.0,
      'active_minutes':
          _getLatestValue(_recentHealthData, 'active_minutes') ?? 60.0,
      'calories_burned':
          _getLatestValue(_recentHealthData, 'calories') ?? 2000.0,
    };
  }

  Map<String, dynamic> _extractLifestyleFactors() {
    // In a real app, this would come from user input or additional tracking
    return {
      'stress_level': 0.5,
      'diet_quality': 0.7,
      'exercise_regularity': 0.6,
      'sleep_consistency': 0.75,
    };
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: _buildAppBar(),
      body: _isLoadingPredictions || _isLoadingHealthData
          ? _buildLoadingView()
          : _buildDashboardContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF6C5CE7,
                      ).withValues(alpha: 0.3 + 0.3 * _glowController.value),
                      blurRadius: 10 + 5 * _glowController.value,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Color(0xFF6C5CE7),
                  size: 24,
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          const Text(
            'AI Analytics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () async {
            await _loadHealthData();
            await _runAIPredictions();
          },
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: const Color(0xFF6C5CE7),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        tabs: const [
          Tab(text: 'Ovulation'),
          Tab(text: 'Wellness'),
          Tab(text: 'Emotion'),
          Tab(text: 'Cycles'),
          Tab(text: 'Sleep'),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + 0.3 * _pulseController.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6C5CE7).withValues(alpha: 0.3),
                        const Color(0xFF6C5CE7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C5CE7).withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            _isLoadingHealthData
                ? 'Loading Health Data...'
                : 'Initializing AI Models...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _isLoadingHealthData
                ? 'Fetching your biometric data from HealthKit'
                : 'Loading TensorFlow Lite models for predictions',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOvulationTab(),
        _buildWellnessTab(),
        _buildEmotionTab(),
        _buildCycleTab(),
        _buildSleepTab(),
      ],
    );
  }

  Widget _buildOvulationTab() {
    if (_ovulationPrediction == null) {
      return const Center(
        child: Text(
          'No ovulation prediction available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final prediction = _ovulationPrediction!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPredictionCard(
            title: 'Ovulation Prediction',
            icon: Icons.pregnant_woman,
            color: const Color(0xFF6C5CE7),
            confidence: prediction.confidence,
            child: Column(
              children: [
                _buildMetricRow(
                  'Days to Ovulation',
                  '${prediction.daysToOvulation}',
                ),
                _buildMetricRow(
                  'Fertility Score',
                  '${(prediction.fertilityScore * 100).round()}%',
                ),
                _buildMetricRow(
                  'LH Surge Probability',
                  '${(prediction.lhSurgeProbability * 100).round()}%',
                ),
                _buildMetricRow(
                  'Temperature Shift',
                  '${(prediction.temperatureShiftProbability * 100).round()}%',
                ),
                const SizedBox(height: 16),
                _buildFertilityWindow(prediction.fertilityWindow),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildMethodCard(
            prediction.predictionMethod,
            prediction.modelVersion,
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessTab() {
    if (_stressAnalysis == null) {
      return const Center(
        child: Text(
          'No wellness analysis available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final analysis = _stressAnalysis!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPredictionCard(
            title: 'HRV Stress Analysis',
            icon: Icons.favorite,
            color: const Color(0xFFE17055),
            confidence: 1.0 - analysis.stressLevel,
            child: Column(
              children: [
                _buildStressGauge(analysis.stressLevel),
                const SizedBox(height: 16),
                _buildMetricRow(
                  'Recovery Score',
                  '${(analysis.recoveryScore * 100).round()}%',
                ),
                _buildMetricRow(
                  'Autonomic Balance',
                  '${(analysis.autonomicBalance * 100).round()}%',
                ),
                _buildMetricRow(
                  'Wellness Trend',
                  '${(analysis.wellnessTrend * 100).round()}%',
                ),
                _buildMetricRow(
                  'Data Quality',
                  '${(analysis.dataQuality * 100).round()}%',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildRecommendationsCard(
            'Wellness Recommendations',
            analysis.recommendations,
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionTab() {
    if (_emotionClassification == null) {
      return const Center(
        child: Text(
          'No emotion analysis available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final emotion = _emotionClassification!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPredictionCard(
            title: 'Emotion Classification',
            icon: Icons.mood,
            color: const Color(0xFF00B894),
            confidence: emotion.confidence,
            child: Column(
              children: [
                _buildEmotionDisplay(
                  emotion.dominantEmotion,
                  emotion.confidence,
                ),
                const SizedBox(height: 16),
                _buildEmotionChart(emotion.emotionProbabilities),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildPhysiologicalIndicators(emotion.physiologicalIndicators),
          const SizedBox(height: 16),
          _buildRecommendationsCard(
            'Emotion-Based Actions',
            emotion.recommendedActions,
          ),
        ],
      ),
    );
  }

  Widget _buildCycleTab() {
    if (_cycleIrregularity == null) {
      return const Center(
        child: Text(
          'No cycle analysis available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final cycle = _cycleIrregularity!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPredictionCard(
            title: 'Cycle Irregularity Analysis',
            icon: Icons.timeline,
            color: const Color(0xFFFD79A8),
            confidence: cycle.confidence,
            child: Column(
              children: [
                _buildIrregularityGauge(cycle.irregularityScore),
                const SizedBox(height: 16),
                _buildMetricRow('Severity Level', cycle.severityLevel),
                _buildMetricRow(
                  'Stress Impact',
                  '${(cycle.stressImpactFactor * 100).round()}%',
                ),
                _buildBooleanRow('Hormonal Concern', cycle.hormonalConcernFlag),
                _buildBooleanRow('Health Concern', cycle.healthConcernFlag),
                _buildTrendRow('Trend Direction', cycle.trendDirection),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildPatternsCard(cycle.detectedPatterns),
          const SizedBox(height: 16),
          _buildRecommendationsCard(
            'Cycle Recommendations',
            cycle.recommendations,
          ),
        ],
      ),
    );
  }

  Widget _buildSleepTab() {
    if (_sleepPrediction == null) {
      return const Center(
        child: Text(
          'No sleep analysis available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final sleep = _sleepPrediction!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPredictionCard(
            title: 'Sleep Quality Prediction',
            icon: Icons.bedtime,
            color: const Color(0xFF74B9FF),
            confidence: sleep.predictedQualityScore,
            child: Column(
              children: [
                _buildSleepQualityGauge(sleep.predictedQualityScore),
                const SizedBox(height: 16),
                _buildMetricRow(
                  'Deep Sleep',
                  '${sleep.expectedDeepSleepMinutes} min',
                ),
                _buildMetricRow('REM Sleep', '${sleep.expectedREMMinutes} min'),
                _buildMetricRow(
                  'Sleep Efficiency',
                  '${(sleep.sleepEfficiency * 100).round()}%',
                ),
                _buildMetricRow(
                  'Recovery Potential',
                  '${(sleep.recoveryPotential * 100).round()}%',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildBedtimeRecommendation(sleep.bedtimeRecommendation),
          const SizedBox(height: 16),
          _buildRecommendationsCard(
            'Sleep Optimization',
            sleep.optimizationTips,
          ),
        ],
      ),
    );
  }

  // Helper widgets would continue here...
  // [Additional helper widget methods for building various UI components]

  Widget _buildPredictionCard({
    required String title,
    required IconData icon,
    required Color color,
    required double confidence,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildConfidenceBadge(confidence),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceBadge(double confidence) {
    final percentage = (confidence * 100).round();
    Color color;

    if (percentage >= 80) {
      color = const Color(0xFF00B894);
    } else if (percentage >= 60) {
      color = const Color(0xFFE17055);
    } else {
      color = const Color(0xFF6C5CE7);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        '${percentage}%',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[300], fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBooleanRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[300], fontSize: 14)),
          Icon(
            value ? Icons.warning : Icons.check_circle,
            color: value ? Colors.orange : Colors.green,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendRow(String label, double value) {
    IconData icon;
    Color color;
    String text;

    if (value > 0.5) {
      icon = Icons.trending_up;
      color = Colors.green;
      text = 'Improving';
    } else if (value < -0.5) {
      icon = Icons.trending_down;
      color = Colors.red;
      text = 'Declining';
    } else {
      icon = Icons.trending_flat;
      color = Colors.orange;
      text = 'Stable';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[300], fontSize: 14)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                text,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFertilityWindow(Map<String, DateTime> window) {
    if (window.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fertility Window',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildDateRow('Start', window['start']!),
          _buildDateRow('Peak', window['peak']!),
          _buildDateRow('End', window['end']!),
        ],
      ),
    );
  }

  Widget _buildDateRow(String label, DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          Text(
            DateFormat('MMM dd').format(date),
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(String title, List<String> recommendations) {
    if (recommendations.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, color: Color(0xFFFD79A8), size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...recommendations
              .map(
                (rec) => Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 8,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 6, right: 8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFD79A8),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          rec,
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildMethodCard(String method, String version) {
    final isML = method.contains('tensorflow');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isML ? const Color(0xFF00B894) : const Color(0xFFE17055),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isML ? Icons.psychology : Icons.functions,
            color: isML ? const Color(0xFF00B894) : const Color(0xFFE17055),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isML ? 'TensorFlow Lite Model' : 'Algorithmic Analysis',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Version: $version',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStressGauge(double stressLevel) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: stressLevel,
                strokeWidth: 8,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(
                  stressLevel > 0.7
                      ? Colors.red
                      : stressLevel > 0.4
                      ? Colors.orange
                      : Colors.green,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(stressLevel * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Stress',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionDisplay(String emotion, double confidence) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _getEmotionIcon(emotion),
          const SizedBox(width: 12),
          Column(
            children: [
              Text(
                emotion.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(confidence * 100).round()}% confidence',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getEmotionIcon(String emotion) {
    IconData icon;
    Color color;

    switch (emotion.toLowerCase()) {
      case 'happy':
        icon = Icons.sentiment_very_satisfied;
        color = Colors.green;
        break;
      case 'sad':
        icon = Icons.sentiment_very_dissatisfied;
        color = Colors.blue;
        break;
      case 'anxious':
        icon = Icons.sentiment_dissatisfied;
        color = Colors.orange;
        break;
      case 'stressed':
        icon = Icons.sentiment_dissatisfied;
        color = Colors.red;
        break;
      case 'energized':
        icon = Icons.bolt;
        color = Colors.yellow;
        break;
      case 'tired':
        icon = Icons.sentiment_neutral;
        color = Colors.grey;
        break;
      case 'calm':
        icon = Icons.sentiment_satisfied;
        color = Colors.lightBlue;
        break;
      default:
        icon = Icons.sentiment_neutral;
        color = Colors.grey;
    }

    return Icon(icon, color: color, size: 32);
  }

  Widget _buildEmotionChart(Map<String, double> probabilities) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 1.0,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final emotions = probabilities.keys.toList();
                  if (value.toInt() < emotions.length) {
                    return Text(
                      emotions[value.toInt()].substring(0, 3).toUpperCase(),
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: probabilities.entries.toList().asMap().entries.map((
            entry,
          ) {
            final index = entry.key;
            final emotion = entry.value.key;
            final probability = entry.value.value;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: probability,
                  color: _getEmotionColor(emotion),
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return Colors.green;
      case 'sad':
        return Colors.blue;
      case 'anxious':
        return Colors.orange;
      case 'stressed':
        return Colors.red;
      case 'energized':
        return Colors.yellow;
      case 'tired':
        return Colors.grey;
      case 'calm':
        return Colors.lightBlue;
      default:
        return const Color(0xFF6C5CE7);
    }
  }

  Widget _buildPhysiologicalIndicators(Map<String, double> indicators) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Physiological Indicators',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...indicators.entries
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 8,
                  ),
                  child: _buildMetricRow(
                    entry.key.replaceAll('_', ' ').toUpperCase(),
                    entry.value.toStringAsFixed(1),
                  ),
                ),
              )
              .toList(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildIrregularityGauge(double score) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: score,
                strokeWidth: 8,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(
                  score > 0.7
                      ? Colors.red
                      : score > 0.4
                      ? Colors.orange
                      : Colors.green,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(score * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Irregularity',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternsCard(List<String> patterns) {
    if (patterns.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.analytics, color: Color(0xFF74B9FF), size: 20),
                SizedBox(width: 8),
                Text(
                  'Detected Patterns',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...patterns
              .map(
                (pattern) => Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 8,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 6, right: 8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF74B9FF),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          pattern,
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSleepQualityGauge(double quality) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: quality,
                strokeWidth: 8,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(
                  quality > 0.8
                      ? Colors.green
                      : quality > 0.6
                      ? Colors.orange
                      : Colors.red,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(quality * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Quality',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBedtimeRecommendation(DateTime bedtime) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF74B9FF).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule, color: Color(0xFF74B9FF), size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Optimal Bedtime',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                DateFormat('h:mm a').format(bedtime),
                style: const TextStyle(
                  color: Color(0xFF74B9FF),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
