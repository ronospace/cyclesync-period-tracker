import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/health_service.dart';
import '../services/health_kit_service.dart';
import '../models/cycle_models.dart';

class HealthIntegrationScreen extends StatefulWidget {
  const HealthIntegrationScreen({super.key});

  @override
  State<HealthIntegrationScreen> createState() => _HealthIntegrationScreenState();
}

class _HealthIntegrationScreenState extends State<HealthIntegrationScreen> {
  final HealthKitService _healthKitService = HealthKitService();
  
  HealthIntegrationStatus? _status;
  bool _isLoading = false;
  String? _lastSyncResult;
  DateTime? _lastSyncTime;
  bool _autoSyncEnabled = true;
  bool _importOnSetup = false;
  
  // HealthKit specific state
  final bool _healthKitInitialized = false;
  final bool _healthKitHasPermissions = false;
  final Map<String, dynamic> _healthKitSummary = {};

  @override
  void initState() {
    super.initState();
    _checkHealthStatus();
  }

  Future<void> _checkHealthStatus() async {
    setState(() => _isLoading = true);
    
    try {
      final status = await HealthService.getIntegrationStatus();
      setState(() {
        _status = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = HealthIntegrationStatus(
          isSupported: false,
          hasPermissions: false,
          message: 'Error checking health integration: ${e.toString()}',
          canSync: false,
        );
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermissions() async {
    setState(() => _isLoading = true);
    
    try {
      final granted = await HealthService.requestPermissions();
      
      if (granted) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Health permissions granted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        await _checkHealthStatus();
        
        if (_importOnSetup) {
          await _importHealthData();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Health permissions were not granted'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error requesting permissions: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _importHealthData() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await HealthService.importHealthData();
      
      setState(() {
        _lastSyncResult = result.summary;
        _lastSyncTime = DateTime.now();
        _isLoading = false;
      });
      
      if (result.success) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📥 ${result.summary}'),
            backgroundColor: Colors.green,
            action: result.importedCount > 0 ? SnackBarAction(
              label: 'View Cycles',
              onPressed: () => Navigator.of(context).pushReplacementNamed('/cycles'),
            ) : null,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ ${result.summary}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _lastSyncResult = 'Import failed: ${e.toString()}';
        _lastSyncTime = DateTime.now();
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Import failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _bulkSyncToHealth() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await HealthService.bulkSyncToHealth();
      
      setState(() {
        _lastSyncResult = result.summary;
        _lastSyncTime = DateTime.now();
        _isLoading = false;
      });
      
      if (result.success) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📤 ${result.summary}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ ${result.summary}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _lastSyncResult = 'Sync failed: ${e.toString()}';
        _lastSyncTime = DateTime.now();
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Sync failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showImportDialog() async {
    final DateTimeRange? dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 365)),
        end: DateTime.now(),
      ),
    );

    if (dateRange != null) {
      setState(() => _isLoading = true);
      
      try {
        final result = await HealthService.importHealthData(
          startDate: dateRange.start,
          endDate: dateRange.end,
        );
        
        setState(() {
          _lastSyncResult = result.summary;
          _lastSyncTime = DateTime.now();
          _isLoading = false;
        });
        
        if (result.success) {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📥 ${result.summary}'),
              backgroundColor: Colors.green,
              action: result.importedCount > 0 ? SnackBarAction(
                label: 'View Cycles',
                onPressed: () => Navigator.of(context).pushReplacementNamed('/cycles'),
              ) : null,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⚠️ ${result.summary}'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _lastSyncResult = 'Import failed: ${e.toString()}';
          _lastSyncTime = DateTime.now();
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Import failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStatusCard() {
    if (_status == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _status!.canSync
                      ? Icons.health_and_safety
                      : _status!.isSupported
                          ? Icons.warning_amber
                          : Icons.error_outline,
                  color: _status!.canSync
                      ? Colors.green
                      : _status!.isSupported
                          ? Colors.orange
                          : Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Health Integration',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _status!.canSync
                            ? 'Active & Ready'
                            : _status!.isSupported
                                ? 'Setup Required'
                                : 'Not Available',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _status!.canSync
                              ? Colors.green
                              : _status!.isSupported
                                  ? Colors.orange
                                  : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _status!.message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (!_status!.canSync && _status!.isSupported) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _importOnSetup,
                    onChanged: (value) => setState(() => _importOnSetup = value ?? false),
                  ),
                  Expanded(
                    child: Text(
                      'Import existing health data after granting permissions',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _requestPermissions,
                  icon: const Icon(Icons.security),
                  label: const Text('Grant Health Permissions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSyncControls() {
    if (_status?.canSync != true) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sync Controls',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Auto-sync toggle
            SwitchListTile(
              title: const Text('Auto-sync new cycles'),
              subtitle: const Text('Automatically sync new cycle data to Health app'),
              value: _autoSyncEnabled,
              onChanged: (value) => setState(() => _autoSyncEnabled = value),
              secondary: const Icon(Icons.sync),
            ),
            
            const Divider(),
            
            // Import data button
            ListTile(
              leading: const Icon(Icons.download, color: Colors.green),
              title: const Text('Import from Health'),
              subtitle: const Text('Import existing health data to CycleSync'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _isLoading ? null : _showImportDialog,
            ),
            
            const Divider(),
            
            // Export data button
            ListTile(
              leading: const Icon(Icons.upload, color: Colors.blue),
              title: const Text('Export to Health'),
              subtitle: const Text('Sync all CycleSync data to Health app'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _isLoading ? null : _bulkSyncToHealth,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastSyncInfo() {
    if (_lastSyncTime == null || _lastSyncResult == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Last Sync',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _lastSyncResult!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'At ${_lastSyncTime!.hour.toString().padLeft(2, '0')}:${_lastSyncTime!.minute.toString().padLeft(2, '0')} on ${_lastSyncTime!.day}/${_lastSyncTime!.month}/${_lastSyncTime!.year}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTypesInfo() {
    if (_status?.canSync != true) {
      return const SizedBox.shrink();
    }

    const supportedTypes = [
      {'icon': Icons.water_drop, 'name': 'Menstrual Flow', 'desc': 'Flow intensity and dates'},
      {'icon': Icons.mood, 'name': 'Mood Tracking', 'desc': 'Daily mood levels'},
      {'icon': Icons.notes, 'name': 'Symptoms & Notes', 'desc': 'Symptom observations'},
      {'icon': Icons.favorite, 'name': 'General Wellbeing', 'desc': 'Energy and pain levels'},
    ];

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Synced Data Types',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...supportedTypes.map((type) { return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Icon(
                    type['icon'] as IconData,
                    color: Colors.purple,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type['name'] as String,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          type['desc'] as String,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );}),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        foregroundColor: Colors.grey.shade700,
        iconTheme: IconThemeData(color: Colors.grey.shade700),
        title: const Text('Health Integration'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _checkHealthStatus,
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _checkHealthStatus,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildStatusCard(),
                const SizedBox(height: 16),
                _buildSyncControls(),
                const SizedBox(height: 16),
                _buildLastSyncInfo(),
                const SizedBox(height: 16),
                _buildDataTypesInfo(),
                const SizedBox(height: 32),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
