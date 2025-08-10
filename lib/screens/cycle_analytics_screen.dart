import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../services/firebase_service.dart';
import '../services/analytics_service.dart';

class CycleAnalyticsScreen extends StatefulWidget {
  const CycleAnalyticsScreen({super.key});

  @override
  State<CycleAnalyticsScreen> createState() => _CycleAnalyticsScreenState();
}

class _CycleAnalyticsScreenState extends State<CycleAnalyticsScreen> with TickerProviderStateMixin {
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Cycle Analytics'),
        backgroundColor: Colors.purple.shade50,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
        onPressed: _loadCycles,
          ),
        ],
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
                        onPressed: _loadAndAnalyzeCycles,
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
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Log Your Cycles'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadAndAnalyzeCycles,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Overview Stats
                            Text(
                              'Overview',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              childAspectRatio: 1.2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              children: [
                                _buildStatCard(
                                  title: 'Total Cycles',
                                  value: '$_totalCycles',
                                  icon: Icons.calendar_today,
                                  color: Colors.blue,
                                ),
                                _buildStatCard(
                                  title: 'Average Length',
                                  value: _averageCycleLength != null 
                                      ? '${_averageCycleLength!.toStringAsFixed(1)} days'
                                      : 'N/A',
                                  icon: Icons.timeline,
                                  color: Colors.green,
                                ),
                                _buildStatCard(
                                  title: 'Regularity',
                                  value: _regularityStatus,
                                  icon: Icons.track_changes,
                                  color: _regularityStatus.contains('Regular') 
                                      ? Colors.green : Colors.orange,
                                ),
                                _buildStatCard(
                                  title: 'Last Cycle',
                                  value: _lastCycleDate != null
                                      ? DateFormat.MMMMd().format(_lastCycleDate!)
                                      : 'N/A',
                                  icon: Icons.event,
                                  color: Colors.purple,
                                  subtitle: _lastCycleDate != null
                                      ? '${DateTime.now().difference(_lastCycleDate!).inDays} days ago'
                                      : null,
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Insights Section
                            Text(
                              'Insights',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            if (_nextPredictedDate != null)
                              _buildInsightCard(
                                title: 'Next Cycle Prediction',
                                description: 'Estimated around ${DateFormat.MMMMd().format(_nextPredictedDate!)} '
                                    '(${_nextPredictedDate!.difference(DateTime.now()).inDays} days from now)',
                                icon: Icons.calendar_month,
                                color: Colors.blue,
                              ),
                            
                            if (_averageCycleLength != null)
                              _buildInsightCard(
                                title: 'Cycle Length Analysis',
                                description: _averageCycleLength! >= 3 && _averageCycleLength! <= 7
                                    ? 'Your average cycle length is within the typical range.'
                                    : _averageCycleLength! < 3
                                    ? 'Your cycles appear shorter than typical. Consider consulting a healthcare provider.'
                                    : 'Your cycles appear longer than typical. This can be normal, but consider tracking more data.',
                                icon: Icons.insights,
                                color: _averageCycleLength! >= 3 && _averageCycleLength! <= 7
                                    ? Colors.green : Colors.orange,
                              ),
                            
                            _buildInsightCard(
                              title: 'Data Quality',
                              description: _totalCycles >= 6
                                  ? 'You have enough data for reliable insights!'
                                  : 'Log more cycles for better predictions and insights.',
                              icon: Icons.data_usage,
                              color: _totalCycles >= 6 ? Colors.green : Colors.orange,
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Action Buttons
                            Text(
                              'Actions',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => Navigator.of(context).pop(),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Log New Cycle'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.pink,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => context.pushReplacement('/cycle-history'),
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
                        ),
                      ),
                    ),
    );
  }
}
