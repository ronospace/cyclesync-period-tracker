import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/advanced_health_kit_service.dart';
import '../services/enhanced_ai_service.dart';
import '../services/firebase_service.dart';
import '../services/sample_health_data.dart';
import '../widgets/advanced_health_charts.dart';

class HealthInsightsScreen extends StatefulWidget {
  const HealthInsightsScreen({super.key});

  @override
  State<HealthInsightsScreen> createState() => _HealthInsightsScreenState();
}

class _HealthInsightsScreenState extends State<HealthInsightsScreen>
    with SingleTickerProviderStateMixin {
  final AdvancedHealthKitService _healthKit = AdvancedHealthKitService.instance;
  final EnhancedAIService _aiService = EnhancedAIService.instance;
  late TabController _tabController;

  bool _isLoading = true;
  bool _healthKitAvailable = false;
  String _statusMessage = '';
  
  // Health data
  List<HealthDataPoint> _heartRateData = [];
  List<HealthDataPoint> _hrvData = [];
  List<SleepData> _sleepData = [];
  List<HealthDataPoint> _temperatureData = [];
  List<ActivityData> _activityData = [];
  
  // AI Insights
  EnhancedCycleInsights? _cycleInsights;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeHealthKit();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeHealthKit() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Initializing HealthKit...';
    });

    try {
      final initialized = await _healthKit.initialize();
      
      if (initialized) {
        setState(() {
          _healthKitAvailable = true;
          _statusMessage = 'HealthKit connected successfully!';
        });
        
        await _loadHealthData();
        await _generateAIInsights();
      } else {
        setState(() {
          _healthKitAvailable = false;
          _statusMessage = 'HealthKit not available - using sample data for demo';
        });
        
        // Load sample data for demonstration
        await _loadSampleData();
        await _generateAIInsights();
      }
    } catch (e) {
      setState(() {
        _healthKitAvailable = false;
        _statusMessage = 'Failed to initialize HealthKit: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadHealthData() async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 7));
    
    setState(() {
      _statusMessage = 'Loading health data...';
    });

    try {
      // Load different types of health data
      final futures = await Future.wait([
        _healthKit.getHeartRateData(startDate: startDate, endDate: endDate),
        _healthKit.getHRVData(startDate: startDate, endDate: endDate),
        _healthKit.getSleepData(startDate: startDate, endDate: endDate),
        _healthKit.getTemperatureData(startDate: startDate, endDate: endDate),
        _healthKit.getActivityData(startDate: startDate, endDate: endDate),
      ]);

      setState(() {
        _heartRateData = futures[0] as List<HealthDataPoint>;
        _hrvData = futures[1] as List<HealthDataPoint>;
        _sleepData = futures[2] as List<SleepData>;
        _temperatureData = futures[3] as List<HealthDataPoint>;
        _activityData = futures[4] as List<ActivityData>;
        _statusMessage = 'Health data loaded successfully!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to load health data: $e';
      });
    }
  }

  Future<void> _loadSampleData() async {
    setState(() {
      _statusMessage = 'Loading sample health data...';
    });

    try {
      // Generate sample data for demonstration
      setState(() {
        _heartRateData = SampleHealthData.generateHeartRateData(days: 7);
        _hrvData = SampleHealthData.generateHRVData(days: 7);
        _sleepData = SampleHealthData.generateSleepData(days: 7);
        _temperatureData = SampleHealthData.generateTemperatureData(days: 28);
        _activityData = SampleHealthData.generateActivityData(days: 7);
        _statusMessage = 'Sample health data loaded successfully!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to load sample data: $e';
      });
    }
  }

  Future<void> _generateAIInsights() async {
    setState(() {
      _statusMessage = 'Generating AI insights...';
    });

    try {
      // Get user's cycle data
      final cycles = await FirebaseService.getCycles();
      
      // Generate enhanced insights
      final insights = await _aiService.generateEnhancedInsights(
        cycles: cycles,
        analysisDate: DateTime.now(),
      );
      
      setState(() {
        _cycleInsights = insights;
        _statusMessage = 'AI insights generated successfully!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to generate AI insights: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Insights'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/home');
            }
          },
        ),
        bottom: !_isLoading && (_heartRateData.isNotEmpty || _hrvData.isNotEmpty || _sleepData.isNotEmpty || _temperatureData.isNotEmpty || _activityData.isNotEmpty) ? TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.favorite), text: 'Heart'),
            Tab(icon: Icon(Icons.bedtime), text: 'Sleep'),
            Tab(icon: Icon(Icons.device_thermostat), text: 'Temperature'),
            Tab(icon: Icon(Icons.directions_run), text: 'Activity'),
          ],
        ) : null,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF6366F1)),
            const SizedBox(height: 16),
            Text(_statusMessage),
          ],
        ),
      );
    }

    // Show charts if we have any data (real or sample)
    final hasData = _heartRateData.isNotEmpty || _hrvData.isNotEmpty || 
                   _sleepData.isNotEmpty || _temperatureData.isNotEmpty || _activityData.isNotEmpty;
    
    if (!hasData) {
      return _buildUnavailableView();
    }

    return Column(
      children: [
        _buildAIInsightsCard(),
        if (!_healthKitAvailable)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Demo Mode: Showing sample health data for visualization',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildHeartDataTab(),
              _buildSleepDataTab(),
              _buildTemperatureDataTab(),
              _buildActivityDataTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUnavailableView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.health_and_safety_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              'HealthKit Integration',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeHealthKit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Retry Setup'),
            ),
            const SizedBox(height: 16),
            const Text(
              'This feature requires:\n• iOS device with HealthKit\n• Health app with data\n• Permissions granted',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIInsightsCard() {
    if (_cycleInsights == null) return Container();
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              const Text(
                'AI Health Insights',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInsightRow('Current Phase', _cycleInsights!.currentPhase.displayName),
          _buildInsightRow('Stress Level', _formatPercentage(_cycleInsights!.stressLevel)),
          _buildInsightRow('Sleep Quality', _formatPercentage(_cycleInsights!.sleepQuality)),
          _buildInsightRow('Energy Level', _formatPercentage(_cycleInsights!.energyLevel)),
          if (_cycleInsights!.ovulationPrediction != null)
            _buildInsightRow('Next Ovulation', _formatDate(_cycleInsights!.ovulationPrediction!)),
          if (_cycleInsights!.nextPeriodPrediction != null)
            _buildInsightRow('Next Period', _formatDate(_cycleInsights!.nextPeriodPrediction!)),
          const SizedBox(height: 12),
          Text(
            'Confidence: ${(_cycleInsights!.confidence * 100).toInt()}%',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartDataTab() {
    if (_heartRateData.isEmpty && _hrvData.isEmpty) {
      return _buildNoDataMessage('Heart rate data');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_heartRateData.isNotEmpty) ...[
            _buildDataCard(
              'Heart Rate Trend',
              'Average: ${_heartRateData.map((h) => h.value).reduce((a, b) => a + b) / _heartRateData.length} bpm',
              _buildHeartRateChart(),
            ),
            const SizedBox(height: 16),
          ],
          if (_hrvData.isNotEmpty) ...[
            _buildDataCard(
              'Heart Rate Variability',
              'Recent: ${_hrvData.last.value.toStringAsFixed(1)} ms',
              _buildHRVChart(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSleepDataTab() {
    if (_sleepData.isEmpty) {
      return _buildNoDataMessage('Sleep data');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDataCard(
            'Sleep Analysis',
            'Recent nights: ${_sleepData.length}',
            _buildSleepChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureDataTab() {
    if (_temperatureData.isEmpty) {
      return _buildNoDataMessage('Temperature data');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDataCard(
            'Body Temperature',
            'Recent: ${_temperatureData.last.value.toStringAsFixed(1)}°C',
            _buildTemperatureChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityDataTab() {
    if (_activityData.isEmpty) {
      return _buildNoDataMessage('Activity data');
    }

    final avgSteps = _activityData.map((a) => a.steps).reduce((a, b) => a + b) / _activityData.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDataCard(
            'Daily Activity',
            'Average: ${avgSteps.toInt()} steps/day',
            _buildActivityChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(String title, String subtitle, Widget chart) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: chart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataMessage(String dataType) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.data_usage_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No $dataType available',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Make sure to sync your Health app data',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // Advanced chart widgets using fl_chart
  Widget _buildHeartRateChart() {
    return AdvancedHealthCharts.buildHeartRateChart(_heartRateData, height: 300);
  }

  Widget _buildHRVChart() {
    return AdvancedHealthCharts.buildHRVChart(_hrvData, height: 300);
  }

  Widget _buildSleepChart() {
    return AdvancedHealthCharts.buildSleepChart(_sleepData, height: 300);
  }

  Widget _buildTemperatureChart() {
    return AdvancedHealthCharts.buildTemperatureChart(_temperatureData, height: 300);
  }

  Widget _buildActivityChart() {
    return AdvancedHealthCharts.buildActivityChart(_activityData, height: 300);
  }

  String _formatPercentage(double value) {
    if (value >= 0.8) return 'High';
    if (value >= 0.6) return 'Good';
    if (value >= 0.4) return 'Fair';
    return 'Low';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;
    
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff > 0) return 'In $diff days';
    return '${-diff} days ago';
  }
}
