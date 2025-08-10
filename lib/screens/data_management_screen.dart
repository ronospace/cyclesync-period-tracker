import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/data_export_service.dart';

class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  bool _isExporting = false;
  bool _isImporting = false;

  Future<void> _exportAsJson() async {
    setState(() => _isExporting = true);
    
    try {
      await DataExportService.exportAsJsonFile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Data exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Export failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _exportAsCsv() async {
    setState(() => _isExporting = true);
    
    try {
      await DataExportService.exportAsCsvFile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ CSV data exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ CSV export failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _importData() async {
    setState(() => _isImporting = true);
    
    try {
      final importData = await DataExportService.importFromJsonFile();
      
      if (mounted) {
        final result = await _showImportConfirmDialog(importData);
        if (result == true) {
          final importedCount = await DataExportService.restoreFromImport(importData);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ Successfully imported $importedCount cycles!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Import failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  Future<bool?> _showImportConfirmDialog(Map<String, dynamic> importData) {
    final cycles = importData['data']['cycles'] as List<dynamic>;
    final statistics = importData['statistics'] as Map<String, dynamic>;
    
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Import'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Import ${cycles.length} cycles?'),
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Import Details:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('• Total cycles: ${cycles.length}'),
                    if (statistics['average_length'] != null)
                      Text('• Average length: ${statistics['average_length'].toStringAsFixed(1)} days'),
                    if (statistics['date_range'] != null)
                      Text('• Date range: ${statistics['date_range']}'),
                    Text('• Export date: ${importData['export_date']?.substring(0, 10)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '⚠️ This will add new cycles to your existing data. Duplicates will be automatically skipped.',
              style: TextStyle(fontSize: 12, color: Colors.orange),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  Widget _buildExportSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.backup, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  'Export Your Data',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Create a backup of all your cycle data. Choose the format that works best for you.',
            ),
            const SizedBox(height: 16),
            
            // JSON Export
            ListTile(
              leading: const Icon(Icons.code, color: Colors.green),
              title: const Text('JSON Backup'),
              subtitle: const Text('Complete backup with all data - recommended for backup'),
              trailing: _isExporting 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _isExporting ? null : _exportAsJson,
            ),
            
            const Divider(),
            
            // CSV Export
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.orange),
              title: const Text('CSV Export'),
              subtitle: const Text('Spreadsheet format - great for analysis'),
              trailing: _isExporting 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _isExporting ? null : _exportAsCsv,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restore, color: Colors.purple),
                const SizedBox(width: 12),
                Text(
                  'Import Data',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Restore your data from a previous backup. Only JSON backups from CycleSync are supported.',
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.folder_open, color: Colors.purple),
              title: const Text('Import from File'),
              subtitle: const Text('Select a CycleSync JSON backup file'),
              trailing: _isImporting 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _isImporting ? null : _importData,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  'Data Management Tips',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTip('💾', 'Regular Backups', 'Export your data regularly to avoid data loss'),
            const SizedBox(height: 8),
            _buildTip('📱', 'Device Transfer', 'Use JSON backups to transfer data between devices'),
            const SizedBox(height: 8),
            _buildTip('📊', 'External Analysis', 'Use CSV exports for analysis in spreadsheet apps'),
            const SizedBox(height: 8),
            _buildTip('🔒', 'Privacy', 'Your data stays private - backups are stored locally on your device'),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📤 Data Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backup & Restore',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Keep your cycle data safe with regular backups. Export to share with healthcare providers or for your own analysis.',
            ),
            const SizedBox(height: 24),
            
            _buildExportSection(),
            const SizedBox(height: 16),
            
            _buildImportSection(),
            const SizedBox(height: 16),
            
            _buildInfoSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
