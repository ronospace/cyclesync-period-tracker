import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';

class CycleLoggingScreen extends StatefulWidget {
  const CycleLoggingScreen({super.key});

  @override
  State<CycleLoggingScreen> createState() => _CycleLoggingScreenState();
}

class _CycleLoggingScreenState extends State<CycleLoggingScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSaving = false;
  
  // Symptom tracking
  String _flow = 'Medium';
  double _moodLevel = 3.0; // 1-5 scale
  double _energyLevel = 3.0; // 1-5 scale
  double _painLevel = 1.0; // 1-5 scale
  Set<String> _symptoms = <String>{};
  String _notes = '';

  Future<void> _saveCycle() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick both start and end dates')),
      );
      return;
    }

    // Prevent double-saving
    if (_isSaving) {
      print('⚠️ Save already in progress, ignoring duplicate request');
      return;
    }

    setState(() => _isSaving = true);
    print('🟡 Starting save operation...');

    try {
      // Use the robust FirebaseService with shorter timeout for better UX
      await FirebaseService.saveCycle(
        startDate: _startDate!,
        endDate: _endDate!,
        timeout: const Duration(seconds: 15), // Shorter timeout for quicker feedback
      );

      print('✅ Save successful!');

      if (!mounted) {
        print('⚠️ Widget unmounted, skipping UI updates');
        return;
      }

      // Update notifications with latest cycle data
      try {
        final cycles = await FirebaseService.getCycles();
        await NotificationService.updateCycleNotifications(cycles);
        print('✅ Notifications updated successfully');
      } catch (e) {
        print('⚠️ Failed to update notifications: $e');
      }

      // Clear the form after successful save
      _startDate = null;
      _endDate = null;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cycle logged successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('❌ Error saving cycle: $e');
      print('❌ Error type: ${e.runtimeType}');

      if (mounted) {
        String userMessage;
        if (e.toString().contains('timeout')) {
          userMessage = 'Save timed out. Please check your internet connection and try again.';
        } else if (e.toString().contains('permission-denied')) {
          userMessage = 'Permission denied. Please check your account settings.';
        } else if (e.toString().contains('network')) {
          userMessage = 'Network error. Please check your internet connection.';
        } else {
          userMessage = 'Failed to save: ${e.toString().split(':').last.trim()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _saveCycle(),
            ),
          ),
        );
      }
    } finally {
      print('🔁 Cleaning up save operation...');
      if (mounted) {
        setState(() => _isSaving = false);
        print('🔁 UI reset complete - isSaving: $_isSaving');
      } else {
        print('⚠️ Widget unmounted during cleanup');
      }
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMMd();

    return Scaffold(
      appBar: AppBar(title: const Text('🩸 Log Your Cycle')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _pickDate(true),
              child: Text(
                _startDate == null
                    ? 'Pick Start Date'
                    : 'Start: ${dateFormat.format(_startDate!)}',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _pickDate(false),
              child: Text(
                _endDate == null
                    ? 'Pick End Date'
                    : 'End: ${dateFormat.format(_endDate!)}',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveCycle,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save),
              label: _isSaving
                  ? const Text('Saving...')
                  : const Text('Save Cycle'),
            ),
          ],
        ),
      ),
    );
  }
}
