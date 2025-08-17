import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/social_service.dart';
import '../../models/social_models.dart';
import '../../widgets/loading_overlay.dart';

/// Professional dashboard for healthcare providers to view shared patient data
class ProviderDashboard extends StatefulWidget {
  final String shareToken;

  const ProviderDashboard({
    super.key,
    required this.shareToken,
  });

  @override
  State<ProviderDashboard> createState() => _ProviderDashboardState();
}

class _ProviderDashboardState extends State<ProviderDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  SharedDataResult? _sharedData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSharedData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSharedData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await SocialService.getSharedData(widget.shareToken);
      
      setState(() {
        _sharedData = result;
        _isLoading = false;
        if (!result.success) {
          _error = result.error ?? 'Unknown error occurred';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load shared data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CycleSync - Provider Dashboard'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        bottom: _sharedData?.success == true 
            ? TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
                  Tab(icon: Icon(Icons.timeline), text: 'Patterns'),
                  Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
                  Tab(icon: Icon(Icons.medical_services), text: 'Clinical'),
                ],
              )
            : null,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return _buildErrorState();
    }

    if (_sharedData == null || !_sharedData!.success) {
      return _buildEmptyState();
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildPatternsTab(),
        _buildAnalyticsTab(),
        _buildClinicalTab(),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              'Access Error',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadSharedData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text('No data available'),
    );
  }

  Widget _buildOverviewTab() {
    final shareInfo = _sharedData!.shareInfo!;
    final analytics = _sharedData!.analytics!;
    final summary = _sharedData!.summary!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPatientInfoCard(shareInfo),
          const SizedBox(height: 16),
          _buildSummaryCard(summary),
          const SizedBox(height: 16),
          _buildQuickStatsCard(analytics),
          const SizedBox(height: 16),
          _buildDataPermissionsCard(shareInfo),
        ],
      ),
    );
  }

  Widget _buildPatientInfoCard(ShareInfo shareInfo) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            children: [
              const Icon(Icons.person, color: Colors.teal),
              const SizedBox(width: 8),
              const Text(
                'Patient Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(),
          _buildInfoRow('Patient Email', shareInfo.ownerEmail),
          _buildInfoRow('Data Period', shareInfo.dateRange.toString()),
          _buildInfoRow('Access Level', shareInfo.permission.displayName),
          if (shareInfo.personalMessage != null && shareInfo.personalMessage!.isNotEmpty)
            _buildInfoRow('Message', shareInfo.personalMessage!),
        ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String summary) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            children: [
              Icon(Icons.summarize, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Data Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(summary),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsCard(ProviderAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          const Text(
            'Quick Statistics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(
                analytics.totalCycles.toString(),
                'Total Cycles',
                Icons.calendar_month,
              ),
              _buildStatColumn(
                analytics.averageCycleLength?.toStringAsFixed(1) ?? 'N/A',
                'Avg Length (days)',
                Icons.timeline,
              ),
              _buildStatColumn(
                '${(analytics.cycleRegularity * 100).toStringAsFixed(0)}%',
                'Regularity',
                Icons.show_chart,
              ),
            ],
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataPermissionsCard(ShareInfo shareInfo) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            children: [
              const Icon(Icons.security, color: Colors.green),
              const SizedBox(width: 8),
              const Text(
                'Data Permissions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(shareInfo.permission.description),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: shareInfo.permission.allowedDataTypes
                .map((type) => Chip(
                      label: Text(type.displayName),
                      backgroundColor: Colors.green.shade50,
                    ))
                .toList(),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.teal, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildPatternsTab() {
    final cycles = _sharedData!.cycles!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCycleLengthChart(cycles),
          const SizedBox(height: 16),
          _buildCycleCalendar(cycles),
          const SizedBox(height: 16),
          _buildSymptomFrequencyChart(cycles),
        ],
      ),
    );
  }

  Widget _buildCycleLengthChart(List<Map<String, dynamic>> cycles) {
    final cycleLengths = cycles
        .where((cycle) => cycle['start'] != null && cycle['end'] != null)
        .map((cycle) {
      final start = cycle['start'] is DateTime 
          ? cycle['start'] as DateTime
          : DateTime.parse(cycle['start'].toString());
      final end = cycle['end'] is DateTime 
          ? cycle['end'] as DateTime
          : DateTime.parse(cycle['end'].toString());
      return end.difference(start).inDays + 1;
    }).toList();

    if (cycleLengths.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No cycle length data available'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cycle Length Trends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('C${value.toInt() + 1}');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: cycleLengths.asMap().entries
                          .map((entry) => FlSpot(
                                entry.key.toDouble(),
                                entry.value.toDouble(),
                              ))
                          .toList(),
                      isCurved: true,
                      color: Colors.teal,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleCalendar(List<Map<String, dynamic>> cycles) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Cycles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...cycles.take(5).map((cycle) => _buildCycleItem(cycle)),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleItem(Map<String, dynamic> cycle) {
    final start = cycle['start'] is DateTime 
        ? cycle['start'] as DateTime
        : DateTime.parse(cycle['start'].toString());
    final end = cycle['end'] is DateTime 
        ? cycle['end'] as DateTime
        : DateTime.parse(cycle['end'].toString());
    final length = end.difference(start).inDays + 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  length.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_formatDate(start)} - ${_formatDate(end)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '$length days',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (cycle['symptoms'] != null && (cycle['symptoms'] as List).isNotEmpty)
              Chip(
                label: Text('${(cycle['symptoms'] as List).length} symptoms'),
                backgroundColor: Colors.orange.shade100,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomFrequencyChart(List<Map<String, dynamic>> cycles) {
    final symptomCounts = <String, int>{};
    
    for (final cycle in cycles) {
      if (cycle['symptoms'] != null) {
        for (final symptom in cycle['symptoms'] as List) {
          symptomCounts[symptom.toString()] = 
              (symptomCounts[symptom.toString()] ?? 0) + 1;
        }
      }
    }

    if (symptomCounts.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No symptom data available'),
        ),
      );
    }

    final sortedSymptoms = symptomCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Common Symptoms',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...sortedSymptoms.take(5).map((symptom) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(symptom.key),
                  ),
                  Expanded(
                    flex: 3,
                    child: LinearProgressIndicator(
                      value: symptom.value / cycles.length,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${symptom.value}'),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    final analytics = _sharedData!.analytics!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAnalyticsOverview(analytics),
          const SizedBox(height: 16),
          if (analytics.averageWellbeing != null)
            _buildWellbeingAnalytics(analytics.averageWellbeing!),
          const SizedBox(height: 16),
          _buildClinicalInsights(analytics),
        ],
      ),
    );
  }

  Widget _buildAnalyticsOverview(ProviderAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Clinical Analytics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildAnalyticRow(
              'Data Period',
              analytics.dateRange.toString(),
              Icons.date_range,
            ),
            _buildAnalyticRow(
              'Total Cycles Tracked',
              analytics.totalCycles.toString(),
              Icons.calendar_month,
            ),
            _buildAnalyticRow(
              'Average Cycle Length',
              analytics.averageCycleLength?.toStringAsFixed(1) ?? 'N/A',
              Icons.timeline,
            ),
            _buildAnalyticRow(
              'Cycle Regularity Score',
              '${(analytics.cycleRegularity * 100).toStringAsFixed(0)}%',
              Icons.show_chart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildWellbeingAnalytics(WellbeingAverages wellbeing) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Wellbeing Trends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildWellbeingBar('Mood Level', wellbeing.mood / 10, Colors.blue),
            _buildWellbeingBar('Energy Level', wellbeing.energy / 10, Colors.green),
            _buildWellbeingBar('Pain Level', wellbeing.pain / 10, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildWellbeingBar(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text('${(value * 10).toStringAsFixed(1)}/10'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalInsights(ProviderAnalytics analytics) {
    final insights = <String>[];
    
    if (analytics.averageCycleLength != null) {
      final avgLength = analytics.averageCycleLength!;
      if (avgLength < 21) {
        insights.add('Cycles appear shorter than typical range (21-35 days)');
      } else if (avgLength > 35) {
        insights.add('Cycles appear longer than typical range (21-35 days)');
      }
    }
    
    if (analytics.cycleRegularity < 0.7) {
      insights.add('Cycle regularity may warrant clinical attention');
    }
    
    if (analytics.commonSymptoms.length > 5) {
      insights.add('Patient reports diverse symptom patterns');
    }

    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Text(
                  'Clinical Insights',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (insights.isEmpty)
              const Text('No specific clinical insights detected based on available data.')
            else
              ...insights.map((insight) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: Colors.orange.shade700)),
                    Expanded(child: Text(insight)),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildClinicalSummary(),
          const SizedBox(height: 16),
          _buildRecommendations(),
          const SizedBox(height: 16),
          _buildExportOptions(),
        ],
      ),
    );
  }

  Widget _buildClinicalSummary() {
    final analytics = _sharedData!.analytics!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Clinical Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Based on ${analytics.totalCycles} cycles tracked over ${analytics.dateRange.duration.inDays} days, '
              'the patient demonstrates ${analytics.cycleRegularity > 0.8 ? 'regular' : analytics.cycleRegularity > 0.6 ? 'moderately regular' : 'irregular'} '
              'menstrual patterns with an average cycle length of ${analytics.averageCycleLength?.toStringAsFixed(1) ?? 'N/A'} days.',
            ),
            const SizedBox(height: 12),
            if (analytics.commonSymptoms.isNotEmpty) ...[
              const Text(
                'Most frequently reported symptoms:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: analytics.commonSymptoms
                    .take(5)
                    .map((symptom) => Chip(label: Text(symptom)))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medical_services, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  'Clinical Recommendations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '• Continue regular cycle tracking for ongoing monitoring\n'
              '• Consider lifestyle factors if irregularities persist\n'
              '• Patient education on normal cycle variation\n'
              '• Follow-up appointment if concerning patterns emerge',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOptions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.file_download, color: Colors.indigo),
                const SizedBox(width: 8),
                const Text(
                  'Export Options',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportData('pdf'),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Export PDF'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportData('csv'),
                    icon: const Icon(Icons.table_chart),
                    label: const Text('Export CSV'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _exportData(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting data as $format...'),
      ),
    );
    // Implementation would generate and download the file
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
