import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../services/firebase_service.dart';

class CycleHistoryScreen extends StatefulWidget {
  const CycleHistoryScreen({super.key});

  @override
  State<CycleHistoryScreen> createState() => _CycleHistoryScreenState();
}

class _CycleHistoryScreenState extends State<CycleHistoryScreen> {
  List<Map<String, dynamic>> _cycles = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCycles();
  }

  Future<void> _loadCycles() async {
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
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildCycleCard(Map<String, dynamic> cycle) {
    final dateFormat = DateFormat.yMMMd();

    // Handle different date formats
    DateTime? startDate;
    DateTime? endDate;

    try {
      if (cycle['start'] != null) {
        if (cycle['start'] is DateTime) {
          startDate = cycle['start'] as DateTime;
        } else if (cycle['start'].toString().contains('Timestamp')) {
          // Handle Firestore Timestamp
          startDate = (cycle['start'] as dynamic).toDate();
        } else if (cycle['start']?.toString().isNotEmpty == true) {
          startDate = DateTime.parse(cycle['start'].toString());
        }
      }

      if (cycle['end'] != null) {
        if (cycle['end'] is DateTime) {
          endDate = cycle['end'] as DateTime;
        } else if (cycle['end'].toString().contains('Timestamp')) {
          // Handle Firestore Timestamp
          endDate = (cycle['end'] as dynamic).toDate();
        } else if (cycle['end']?.toString().isNotEmpty == true) {
          endDate = DateTime.parse(cycle['end'].toString());
        }
      }
    } catch (e) {
      debugPrint('Error parsing dates: $e');
    }

    // Calculate cycle length
    int? cycleDays;
    if (startDate != null && endDate != null) {
      cycleDays = endDate.difference(startDate).inDays + 1;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.pink.shade100,
          child: Icon(Icons.calendar_today, color: Colors.pink.shade700),
        ),
        title: Text(
          startDate != null && endDate != null
              ? '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}'
              : 'Invalid dates',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (cycleDays != null) Text('Duration: $cycleDays days'),
            if (cycle['created_at'] != null)
              Text(
                'Logged: ${DateFormat.yMMMd().add_jm().format(DateTime.parse(cycle['created_at']))}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              _confirmDelete(cycle);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> cycle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Cycle'),
        content: const Text(
          'Are you sure you want to delete this cycle entry?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteCycle(cycle['id']);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCycle(String cycleId) async {
    try {
      // Show loading state
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Deleting cycle...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Delete the cycle using FirebaseService
      await FirebaseService.deleteCycle(cycleId: cycleId);

      // Remove from local list for immediate UI update
      setState(() {
        _cycles.removeWhere((cycle) => cycle['id'] == cycleId);
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cycle deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error deleting cycle: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete: ${e.toString().split(':').last.trim()}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🩸 Cycle History'),
        backgroundColor: Colors.blue.shade50,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadCycles),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading your cycles...'),
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
                    'Failed to load cycles',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadCycles,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            )
          : _cycles.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_note, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No cycles logged yet',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text('Start tracking your cycles to see them here'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Log Your First Cycle'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadCycles,
              child: ListView.builder(
                itemCount: _cycles.length,
                itemBuilder: (context, index) =>
                    _buildCycleCard(_cycles[index]),
              ),
            ),
    );
  }
}
