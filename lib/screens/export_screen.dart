import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../services/export_service.dart';
import '../services/firebase_service.dart';
import '../services/enhanced_analytics_service.dart';
import '../models/cycle_models.dart';
import '../models/daily_log_models.dart';

/// 🚀 Mission Beta: Export & Data Management Screen
/// Comprehensive interface for exporting, backing up, and managing user data
class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  String? _statusMessage;
  List<CycleData> _cycles = [];
  List<DailyLogEntry> _dailyLogs = [];
  late TabController _tabController;

  // Export options
  bool _includeCharts = true;
  bool _includeInsights = true;
  bool _includeRawData = false;
  bool _includeDailyLogs = true;

  // Date range for filtering
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 365));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Loading your data...';
    });

    try {
      // Load cycles and daily logs
      final cycleData = await FirebaseService.getCycles(limit: 1000);
      // Convert to models (simplified for now)
      final cycles = cycleData
          .map(
            (cycleMap) => CycleData(
              id: cycleMap['id'] ?? '',
              startDate:
                  (cycleMap['start_date'] as DateTime?) ?? DateTime.now(),
              endDate: cycleMap['end_date'] as DateTime?,
              symptoms:
                  (cycleMap['symptoms'] as List<dynamic>?)
                      ?.map(
                        (s) =>
                            Symptom.fromName(s['name'] ?? '') ??
                            Symptom.allSymptoms.first,
                      )
                      .toList() ??
                  [],
              wellbeing: WellbeingData(
                mood: (cycleMap['mood'] as num?)?.toDouble() ?? 3.0,
                energy: (cycleMap['energy'] as num?)?.toDouble() ?? 3.0,
                pain: (cycleMap['pain'] as num?)?.toDouble() ?? 1.0,
              ),
              notes: cycleMap['notes'] as String? ?? '',
              createdAt:
                  (cycleMap['created_at'] as DateTime?) ?? DateTime.now(),
              updatedAt:
                  (cycleMap['updated_at'] as DateTime?) ?? DateTime.now(),
            ),
          )
          .toList();

      // For now, daily logs will be empty but the structure is ready
      final dailyLogs = <DailyLogEntry>[];

      setState(() {
        _cycles = cycles;
        _dailyLogs = dailyLogs;
        _isLoading = false;
        _statusMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error loading data: ${e.toString()}';
      });
    }
  }

  Future<void> _exportPDF() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Generating PDF report...';
    });

    try {
      final filteredCycles = _getFilteredCycles();
      final filteredLogs = _getFilteredDailyLogs();

      final filePath = await ExportService.exportPDFReport(
        cycles: filteredCycles,
        dailyLogs: filteredLogs,
        dateRange: DateRange(start: _startDate, end: _endDate),
        includeCharts: _includeCharts,
        includeInsights: _includeInsights,
        includeRawData: _includeRawData,
      );

      await ExportService.shareFile(filePath, 'CycleSync Health Report');

      setState(() {
        _isLoading = false;
        _statusMessage = 'PDF report generated successfully!';
      });

      _showSuccessSnackBar('PDF report generated and ready to share!');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error generating PDF: ${e.toString()}';
      });
      _showErrorSnackBar('Failed to generate PDF: ${e.toString()}');
    }
  }

  Future<void> _exportCSV() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Generating CSV file...';
    });

    try {
      final filteredCycles = _getFilteredCycles();
      final filteredLogs = _getFilteredDailyLogs();

      final filePath = await ExportService.exportCSV(
        cycles: filteredCycles,
        dailyLogs: filteredLogs,
        includeDailyLogs: _includeDailyLogs,
      );

      await ExportService.shareFile(filePath, 'CycleSync Data Export');

      setState(() {
        _isLoading = false;
        _statusMessage = 'CSV file generated successfully!';
      });

      _showSuccessSnackBar('CSV data exported and ready to share!');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error generating CSV: ${e.toString()}';
      });
      _showErrorSnackBar('Failed to generate CSV: ${e.toString()}');
    }
  }

  Future<void> _exportJSON() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Creating backup file...';
    });

    try {
      final filteredCycles = _getFilteredCycles();
      final filteredLogs = _getFilteredDailyLogs();

      final filePath = await ExportService.exportJSONBackup(
        cycles: filteredCycles,
        dailyLogs: filteredLogs,
        metadata: {
          'export_type': 'full_backup',
          'date_range_start': _startDate.toIso8601String(),
          'date_range_end': _endDate.toIso8601String(),
          'cycles_count': filteredCycles.length,
          'daily_logs_count': filteredLogs.length,
        },
      );

      await ExportService.shareFile(filePath, 'CycleSync Data Backup');

      setState(() {
        _isLoading = false;
        _statusMessage = 'Backup created successfully!';
      });

      _showSuccessSnackBar('Complete backup created and ready to share!');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error creating backup: ${e.toString()}';
      });
      _showErrorSnackBar('Failed to create backup: ${e.toString()}');
    }
  }

  List<CycleData> _getFilteredCycles() {
    return _cycles
        .where(
          (cycle) =>
              cycle.startDate.isAfter(
                _startDate.subtract(const Duration(days: 1)),
              ) &&
              cycle.startDate.isBefore(_endDate.add(const Duration(days: 1))),
        )
        .toList();
  }

  List<DailyLogEntry> _getFilteredDailyLogs() {
    return _dailyLogs
        .where(
          (log) =>
              log.date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
              log.date.isBefore(_endDate.add(const Duration(days: 1))),
        )
        .toList();
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
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
      appBar: AppBar(
        title: const Text('📤 Export & Backup'),
        backgroundColor: Colors.indigo.shade50,
        foregroundColor: Colors.indigo.shade700,
        iconTheme: IconThemeData(color: Colors.indigo.shade700),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.indigo.shade700),
          onPressed: () => context.go('/home'),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.indigo.shade700,
          unselectedLabelColor: Colors.indigo.shade400,
          tabs: const [
            Tab(text: 'Reports', icon: Icon(Icons.description, size: 16)),
            Tab(text: 'Data Export', icon: Icon(Icons.download, size: 16)),
            Tab(
              text: 'Backup & Sync',
              icon: Icon(Icons.cloud_upload, size: 16),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_statusMessage ?? 'Processing...'),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildReportsTab(),
                _buildDataExportTab(),
                _buildBackupTab(),
              ],
            ),
    );
  }

  Widget _buildReportsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Reports',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate comprehensive PDF reports with insights and visualizations',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // Date Range Selection
          _buildDateRangeCard(),
          const SizedBox(height: 20),

          // Report Options
          _buildReportOptionsCard(),
          const SizedBox(height: 20),

          // Data Summary
          _buildDataSummaryCard(),
          const SizedBox(height: 24),

          // Generate Report Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _cycles.isEmpty ? null : _exportPDF,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Generate PDF Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataExportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data Export',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Export your data in various formats for analysis or migration',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // Export Format Cards
          _buildExportFormatCard(
            title: 'CSV Spreadsheet',
            description:
                'Export data in CSV format for Excel, Google Sheets, or other spreadsheet applications',
            icon: Icons.table_chart,
            color: Colors.green,
            onTap: _exportCSV,
          ),
          const SizedBox(height: 16),

          _buildExportFormatCard(
            title: 'JSON Data',
            description:
                'Export complete data structure for developers or advanced analysis',
            icon: Icons.code,
            color: Colors.orange,
            onTap: _exportJSON,
          ),
          const SizedBox(height: 24),

          // Export Options
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export Options',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Include Daily Logs'),
                    subtitle: const Text(
                      'Include daily mood, energy, and symptom logs',
                    ),
                    value: _includeDailyLogs,
                    onChanged: (value) =>
                        setState(() => _includeDailyLogs = value),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Backup & Sync',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Create backups and sync your data across devices',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // Backup Options
          _buildBackupCard(
            title: 'Complete Backup',
            description:
                'Create a full backup of all your cycle data, settings, and analytics',
            icon: Icons.backup,
            color: Colors.blue,
            onTap: _exportJSON,
          ),
          const SizedBox(height: 16),

          _buildBackupCard(
            title: 'Cloud Sync',
            description: 'Sync your data to cloud storage (coming soon)',
            icon: Icons.cloud_sync,
            color: Colors.purple,
            onTap: () => _showComingSoonDialog('Cloud Sync'),
          ),
          const SizedBox(height: 16),

          _buildBackupCard(
            title: 'Auto Backup',
            description: 'Schedule automatic backups (coming soon)',
            icon: Icons.schedule,
            color: Colors.teal,
            onTap: () => _showComingSoonDialog('Auto Backup'),
          ),
          const SizedBox(height: 24),

          // Import Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.file_upload, color: Colors.indigo.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Import Data',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Import data from other cycle tracking apps or restore from backup',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showComingSoonDialog('Import Data'),
                      icon: const Icon(Icons.file_upload),
                      label: const Text('Import from File'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date Range',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'From Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(DateFormat.yMMMd().format(_startDate)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'To Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(DateFormat.yMMMd().format(_endDate)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _buildQuickDateButton('Last Month', () {
                  setState(() {
                    _endDate = DateTime.now();
                    _startDate = DateTime(
                      _endDate.year,
                      _endDate.month - 1,
                      _endDate.day,
                    );
                  });
                }),
                _buildQuickDateButton('Last 3 Months', () {
                  setState(() {
                    _endDate = DateTime.now();
                    _startDate = DateTime(
                      _endDate.year,
                      _endDate.month - 3,
                      _endDate.day,
                    );
                  });
                }),
                _buildQuickDateButton('Last Year', () {
                  setState(() {
                    _endDate = DateTime.now();
                    _startDate = DateTime(
                      _endDate.year - 1,
                      _endDate.month,
                      _endDate.day,
                    );
                  });
                }),
                _buildQuickDateButton('All Time', () {
                  setState(() {
                    _endDate = DateTime.now();
                    _startDate = DateTime(2020, 1, 1); // Reasonable start date
                  });
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDateButton(String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12),
      ),
      child: Text(label),
    );
  }

  Widget _buildReportOptionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Content',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Include Charts'),
              subtitle: const Text('Visual charts and graphs'),
              value: _includeCharts,
              onChanged: (value) => setState(() => _includeCharts = value),
            ),
            SwitchListTile(
              title: const Text('Include Health Insights'),
              subtitle: const Text('AI-powered health recommendations'),
              value: _includeInsights,
              onChanged: (value) => setState(() => _includeInsights = value),
            ),
            SwitchListTile(
              title: const Text('Include Raw Data'),
              subtitle: const Text('Detailed cycle and symptom data tables'),
              value: _includeRawData,
              onChanged: (value) => setState(() => _includeRawData = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSummaryCard() {
    final filteredCycles = _getFilteredCycles();
    final filteredLogs = _getFilteredDailyLogs();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Summary',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  label: 'Cycles',
                  value: filteredCycles.length.toString(),
                  icon: Icons.calendar_today,
                  color: Colors.blue,
                ),
                _buildSummaryItem(
                  label: 'Daily Logs',
                  value: filteredLogs.length.toString(),
                  icon: Icons.event_note,
                  color: Colors.green,
                ),
                _buildSummaryItem(
                  label: 'Time Span',
                  value: '${(_endDate.difference(_startDate).inDays)} days',
                  icon: Icons.timeline,
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildExportFormatCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: _cycles.isEmpty ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackupCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$feature Coming Soon'),
        content: Text(
          '$feature is currently in development and will be available in a future update.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
