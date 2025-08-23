import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/advanced_health_kit_service.dart';
import '../services/enhanced_ai_service.dart';
import '../services/firebase_service.dart';
import '../services/sample_health_data.dart';
import '../services/theme_service.dart';
import '../widgets/advanced_health_charts.dart';
import '../theme/dimensional_theme.dart';

class HealthInsightsScreen extends StatefulWidget {
  const HealthInsightsScreen({Key? key}) : super(key: key);

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
  int _currentTabIndex = 0;

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
    _tabController.addListener(_onTabChanged);
    _initializeHealthKit();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;

    final newIndex = _tabController.index;
    if (newIndex != _currentTabIndex) {
      setState(() {
        _currentTabIndex = newIndex;
        debugPrint('📊 Tab changed to index: $_currentTabIndex');
      });

      // Optional: Load specific data for the new tab if needed
      _loadTabSpecificData(newIndex);
    }
  }

  void _loadTabSpecificData(int tabIndex) {
    // This method can be used to load specific data when a tab is selected
    // For now, we'll just ensure the UI rebuilds
    switch (tabIndex) {
      case 0: // Heart tab
        debugPrint('💓 Loading Heart tab data');
        break;
      case 1: // Sleep tab
        debugPrint('😴 Loading Sleep tab data');
        break;
      case 2: // Temperature tab
        debugPrint('🌡️ Loading Temperature tab data');
        break;
      case 3: // Activity tab
        debugPrint('🏃 Loading Activity tab data');
        break;
    }
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
          _statusMessage =
              'HealthKit not available - using sample data for demo';
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
    final themeService = Provider.of<ThemeService>(context);

    return Scaffold(
      backgroundColor: themeService.getBackgroundColor(context),
      body: Column(
        children: [
          // Dimensional Header
          DimensionalTheme.getDimensionalHeader(
            title: 'Health Insights',
            subtitle: _healthKitAvailable
                ? 'Real-time data from HealthKit'
                : 'Sample data visualization',
            icon: Icons.health_and_safety,
            gradient: DimensionalTheme.gradients['health'],
            trailing: IconButton(
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  context.go('/home');
                }
              },
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),

          // Enhanced Tab Bar (if data available)
          if (!_isLoading &&
              (_heartRateData.isNotEmpty ||
                  _hrvData.isNotEmpty ||
                  _sleepData.isNotEmpty ||
                  _temperatureData.isNotEmpty ||
                  _activityData.isNotEmpty))
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: DimensionalTheme.getElevatedShadow(2),
              ),
              child: TabBar(
                controller: _tabController,
                onTap: (index) {
                  setState(() {
                    _currentTabIndex = index;
                    debugPrint('📊 Manual tab tap to index: $index');
                  });
                  _loadTabSpecificData(index);
                },
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: DimensionalTheme.gradients['health']!
                        .take(2)
                        .toList(),
                  ),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                tabs: const [
                  Tab(icon: Icon(Icons.favorite), text: 'Heart'),
                  Tab(icon: Icon(Icons.bedtime), text: 'Sleep'),
                  Tab(icon: Icon(Icons.device_thermostat), text: 'Temp'),
                  Tab(icon: Icon(Icons.directions_run), text: 'Activity'),
                ],
              ),
            ),

          Expanded(child: _buildBody()),
        ],
      ),
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
    final hasData =
        _heartRateData.isNotEmpty ||
        _hrvData.isNotEmpty ||
        _sleepData.isNotEmpty ||
        _temperatureData.isNotEmpty ||
        _activityData.isNotEmpty;

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
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.orange.withValues(alpha: 0.2)
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.orange.withValues(alpha: 0.4)
                    : Colors.orange.shade200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.orange.shade300
                      : Colors.orange.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Demo Mode: Showing sample health data for visualization',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.orange.shade300
                          : Colors.orange.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: IndexedStack(
            index: _currentTabIndex,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Retry Setup'),
            ),
            const SizedBox(height: 16),
            const Text(
              'This feature requires:\n• iOS device with HealthKit\n• Health app with data\n• Permissions granted',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIInsightsCard() {
    if (_cycleInsights == null) return Container();

    return DimensionalTheme.getDimensionalCard(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      gradient: DimensionalTheme.gradients['primary']!,
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with animated icon
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Health Insights',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Powered by FlowSense AI',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Insights Grid
          Row(
            children: [
              Expanded(
                child: _buildInsightMetric(
                  'Current Phase',
                  _cycleInsights!.currentPhase.displayName,
                  Icons.calendar_today,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInsightMetric(
                  'Energy Level',
                  _formatPercentage(_cycleInsights!.energyLevel),
                  Icons.battery_charging_full,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildInsightMetric(
                  'Sleep Quality',
                  _formatPercentage(_cycleInsights!.sleepQuality),
                  Icons.bedtime,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInsightMetric(
                  'Stress Level',
                  _formatPercentage(_cycleInsights!.stressLevel),
                  Icons.favorite,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Predictions Section
          if (_cycleInsights!.ovulationPrediction != null ||
              _cycleInsights!.nextPeriodPrediction != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🔮 Predictions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_cycleInsights!.ovulationPrediction != null)
                    _buildPredictionRow(
                      'Next Ovulation',
                      _formatDate(_cycleInsights!.ovulationPrediction!),
                      Icons.eco,
                    ),
                  if (_cycleInsights!.nextPeriodPrediction != null)
                    _buildPredictionRow(
                      'Next Period',
                      _formatDate(_cycleInsights!.nextPeriodPrediction!),
                      Icons.water_drop,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Confidence Indicator
          DimensionalTheme.getDimensionalProgress(
            label: 'AI Confidence Level',
            value: _cycleInsights!.confidence,
            valueText: '${(_cycleInsights!.confidence * 100).toInt()}%',
            gradient: [Colors.white.withValues(alpha: 0.9), Colors.white],
            height: 8,
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
            style: const TextStyle(color: Colors.white70, fontSize: 14),
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

    final avgSteps =
        _activityData.map((a) => a.steps).reduce((a, b) => a + b) /
        _activityData.length;

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
    final themeService = Provider.of<ThemeService>(context);

    return DimensionalTheme.getDimensionalCard(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: DimensionalTheme.gradients['health']!
                        .take(2)
                        .toList(),
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: DimensionalTheme.getColoredShadow(
                    DimensionalTheme.gradients['health']![0],
                    opacity: 0.3,
                  ),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themeService.getTextColor(context),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: themeService
                            .getTextColor(context)
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Chart Container with dimensional styling
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: themeService.isDarkModeEnabled(context)
                  ? Colors.grey.shade800.withValues(alpha: 0.3)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: themeService.isDarkModeEnabled(context)
                    ? Colors.grey.shade700
                    : Colors.grey.shade200,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: chart,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataMessage(String dataType) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.data_usage_outlined, size: 64, color: Colors.grey),
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
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Advanced chart widgets using fl_chart
  Widget _buildHeartRateChart() {
    return AdvancedHealthCharts.buildHeartRateChart(
      _heartRateData,
      height: 300,
    );
  }

  Widget _buildHRVChart() {
    return AdvancedHealthCharts.buildHRVChart(_hrvData, height: 300);
  }

  Widget _buildSleepChart() {
    return AdvancedHealthCharts.buildSleepChart(_sleepData, height: 300);
  }

  Widget _buildTemperatureChart() {
    return AdvancedHealthCharts.buildTemperatureChart(
      _temperatureData,
      height: 300,
    );
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

  Widget _buildInsightMetric(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
