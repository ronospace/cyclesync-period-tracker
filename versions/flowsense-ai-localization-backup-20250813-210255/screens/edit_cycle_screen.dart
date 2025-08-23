import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';

class EditCycleScreen extends StatefulWidget {
  final Map<String, dynamic> cycle;
  
  const EditCycleScreen({
    super.key,
    required this.cycle,
  });

  @override
  State<EditCycleScreen> createState() => _EditCycleScreenState();
}

class _EditCycleScreenState extends State<EditCycleScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCycleDates();
  }

  void _loadCycleDates() {
    try {
      // Parse existing start date
      if (widget.cycle['start'] != null) {
        if (widget.cycle['start'] is DateTime) {
          _startDate = widget.cycle['start'];
        } else if (widget.cycle['start'].toString().contains('Timestamp')) {
          _startDate = (widget.cycle['start'] as dynamic).toDate();
        } else {
          _startDate = DateTime.parse(widget.cycle['start'].toString());
        }
      }
      
      // Parse existing end date
      if (widget.cycle['end'] != null) {
        if (widget.cycle['end'] is DateTime) {
          _endDate = widget.cycle['end'];
        } else if (widget.cycle['end'].toString().contains('Timestamp')) {
          _endDate = (widget.cycle['end'] as dynamic).toDate();
        } else {
          _endDate = DateTime.parse(widget.cycle['end'].toString());
        }
      }
    } catch (e) {
      print('Error parsing cycle dates: $e');
      // Set today as fallback
      _startDate = DateTime.now().subtract(const Duration(days: 7));
      _endDate = DateTime.now();
    }
    
    setState(() {});
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: isStartDate ? 'Select start date' : 'Select end date',
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // If end date is before start date, adjust it
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = picked;
          }
        } else {
          _endDate = picked;
          // If start date is after end date, adjust it
          if (_startDate != null && _startDate!.isAfter(picked)) {
            _startDate = picked;
          }
        }
      });
    }
  }

  Future<void> _updateCycle() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both start and end dates'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date cannot be before start date'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      print('🟡 Starting update operation...');
      
      await FirebaseService.updateCycle(
        cycleId: widget.cycle['id'],
        startDate: _startDate!,
        endDate: _endDate!,
      );

      print('✅ Update successful!');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cycle updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Return to previous screen
        Navigator.of(context).pop(true); // true indicates success
      }
    } catch (e) {
      print('❌ Update failed: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update cycle: ${e.toString().split(':').last.trim()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        print('🔁 Cleaning up update operation...');
      }
    }
  }

  Widget _buildDateCard({
    required String title,
    required DateTime? date,
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date != null
                          ? DateFormat.yMMMEd().format(date)
                          : 'Tap to select',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: date != null ? Colors.black87 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    if (_startDate == null || _endDate == null) {
      return const SizedBox.shrink();
    }

    final duration = _endDate!.difference(_startDate!).inDays + 1;
    
    return Card(
      color: Colors.pink.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.pink.shade100,
              child: Icon(Icons.timeline, color: Colors.pink.shade700),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cycle Duration',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$duration day${duration == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink.shade700,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('✏️ Edit Cycle'),
        backgroundColor: Colors.blue.shade50,
        actions: [
          if (!_isSaving)
            TextButton.icon(
              onPressed: _updateCycle,
              icon: const Icon(Icons.check),
              label: const Text('Update'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue.shade700,
              ),
            ),
        ],
      ),
      body: _isSaving
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Updating cycle...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Update Cycle Dates',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Modify the start and end dates for this cycle entry.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildDateCard(
                    title: 'Start Date',
                    date: _startDate,
                    onTap: () => _selectDate(context, true),
                    icon: Icons.play_arrow,
                    color: Colors.green,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildDateCard(
                    title: 'End Date',
                    date: _endDate,
                    onTap: () => _selectDate(context, false),
                    icon: Icons.stop,
                    color: Colors.red,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildSummaryCard(),
                  
                  const SizedBox(height: 32),
                  
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _updateCycle,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: Text(_isSaving ? 'Updating...' : 'Update Cycle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  OutlinedButton(
                    onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
    );
  }
}
