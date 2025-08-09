import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';

class CycleAnalyticsScreen extends StatefulWidget {
  const CycleAnalyticsScreen({super.key});

  @override
  State<CycleAnalyticsScreen> createState() => _CycleAnalyticsScreenState();
}

class _CycleAnalyticsScreenState extends State<CycleAnalyticsScreen> {
  List<Map<String, dynamic>> _cycles = [];
  bool _isLoading = true;
  String? _error;
  
  // Analytics data
  double? _averageCycleLength;
  int _totalCycles = 0;
  DateTime? _lastCycleDate;
  DateTime? _nextPredictedDate;
  List<int> _cycleLengths = [];
  String _regularityStatus = 'Unknown';

  @override
  void initState() {
    super.initState();
    _loadAndAnalyzeCycles();
  }

  Future<void> _loadAndAnalyzeCycles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final cycles = await FirebaseService.getCycles();
      setState(() {
        _cycles = cycles;
        _isLoading = false;
      });
      
      _calculateAnalytics();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _calculateAnalytics() {
    if (_cycles.isEmpty) return;

    _totalCycles = _cycles.length;
    _cycleLengths = [];

    // Parse and sort cycles by date
    List<Map<String, dynamic>> validCycles = [];
    
    for (var cycle in _cycles) {
      DateTime? startDate;
      DateTime? endDate;
      
      try {
        // Parse start date
        if (cycle['start'] != null) {
          if (cycle['start'] is DateTime) {
            startDate = cycle['start'];
          } else if (cycle['start'].toString().contains('Timestamp')) {
            startDate = (cycle['start'] as dynamic).toDate();
          } else {
            startDate = DateTime.parse(cycle['start'].toString());
          }
        }
        
        // Parse end date
        if (cycle['end'] != null) {
          if (cycle['end'] is DateTime) {
            endDate = cycle['end'];
          } else if (cycle['end'].toString().contains('Timestamp')) {
            endDate = (cycle['end'] as dynamic).toDate();
          } else {
            endDate = DateTime.parse(cycle['end'].toString());
          }
        }
        
        if (startDate != null && endDate != null) {
          cycle['parsed_start'] = startDate;
          cycle['parsed_end'] = endDate;
          validCycles.add(cycle);
          
          // Calculate cycle length
          int cycleLength = endDate.difference(startDate).inDays + 1;
          _cycleLengths.add(cycleLength);
        }
      } catch (e) {
        print('Error parsing cycle dates: $e');
      }
    }

    if (validCycles.isEmpty) return;

    // Sort by start date (most recent first)
    validCycles.sort((a, b) => 
      (b['parsed_start'] as DateTime).compareTo(a['parsed_start'] as DateTime));

    // Calculate average cycle length
    if (_cycleLengths.isNotEmpty) {
      _averageCycleLength = _cycleLengths.reduce((a, b) => a + b) / _cycleLengths.length;
    }

    // Get last cycle date
    _lastCycleDate = validCycles.first['parsed_end'] as DateTime;

    // Predict next cycle (rough estimate)
    if (_averageCycleLength != null && _lastCycleDate != null) {
      // Assume average cycle interval is 28 days (can be made more sophisticated)
      _nextPredictedDate = _lastCycleDate!.add(Duration(days: 28));
    }

    // Calculate regularity
    _calculateRegularity();

    setState(() {});
  }

  void _calculateRegularity() {
    if (_cycleLengths.length < 2) {
      _regularityStatus = 'Need more data';
      return;
    }

    // Calculate standard deviation of cycle lengths
    double mean = _averageCycleLength ?? 0;
    double variance = _cycleLengths
        .map((length) => (length - mean) * (length - mean))
        .reduce((a, b) => a + b) / _cycleLengths.length;
    double stdDev = variance.sqrt();

    if (stdDev <= 1.5) {
      _regularityStatus = 'Very Regular';
    } else if (stdDev <= 3.0) {
      _regularityStatus = 'Regular';
    } else if (stdDev <= 5.0) {
      _regularityStatus = 'Somewhat Irregular';
    } else {
      _regularityStatus = 'Irregular';
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
            onPressed: _loadAndAnalyzeCycles,
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
                                icon: Icons.predictions,
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
                                    onPressed: () => Navigator.of(context).pushReplacementNamed('/cycle-history'),
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
