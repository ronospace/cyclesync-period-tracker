import 'package:flutter/material.dart';
import '../services/firebase_diagnostic.dart';

class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({super.key});

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  bool _isRunning = false;
  Map<String, dynamic>? _results;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 Firebase Diagnostics'),
        backgroundColor: Colors.blue.shade50,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Firebase Connection Tester',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This tool will test your Firebase configuration and help identify connection issues.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: _isRunning ? null : _runDiagnostics,
                icon: _isRunning
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(
                  _isRunning ? 'Running Tests...' : 'Run Diagnostics',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_results != null) ...[
              Text(
                'Test Results',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildResultsView()),
            ] else if (!_isRunning) ...[
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.science, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Ready to run diagnostics',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isRunning = true;
      _results = null;
    });

    try {
      final results = await FirebaseDiagnostic.runDiagnostics();
      setState(() {
        _results = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Diagnostic failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  Widget _buildResultsView() {
    if (_results == null) return const SizedBox.shrink();

    final tests = _results!['tests'] as Map<String, dynamic>;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSummaryCard(tests),
          const SizedBox(height: 16),
          ...tests.entries.map(
            (entry) => _buildTestCard(entry.key, entry.value),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> tests) {
    final passed = tests.values.where((test) => test['success'] == true).length;
    final total = tests.length;
    final allPassed = passed == total;

    return Card(
      color: allPassed ? Colors.green.shade50 : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              allPassed ? Icons.check_circle : Icons.warning,
              color: allPassed ? Colors.green : Colors.orange,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Status',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$passed/$total tests passed',
                    style: TextStyle(
                      color: allPassed
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard(String testName, Map<String, dynamic> testResult) {
    final success = testResult['success'] as bool;
    final status = testResult['status'];
    final error = testResult['error'];

    return Card(
      child: ExpansionTile(
        leading: Icon(
          success ? Icons.check_circle : Icons.error,
          color: success ? Colors.green : Colors.red,
        ),
        title: Text(
          _formatTestName(testName),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          status?.toString() ?? 'Unknown',
          style: TextStyle(
            color: success ? Colors.green.shade700 : Colors.red.shade700,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (error != null) ...[
                  const Text(
                    'Error Details:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      error.toString(),
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                const Text(
                  'Raw Data:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    testResult.toString(),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTestName(String testName) {
    switch (testName) {
      case 'auth':
        return '🔐 Authentication Status';
      case 'connectivity':
        return '🌐 Basic Connectivity';
      case 'read_permissions':
        return '📖 Read Permissions';
      case 'write_permissions':
        return '✍️ Write Permissions';
      case 'network_config':
        return '⚙️ Network Configuration';
      default:
        return testName.replaceAll('_', ' ').toUpperCase();
    }
  }
}
