import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CycleLoggingScreen extends StatefulWidget {
  const CycleLoggingScreen({super.key});

  @override
  State<CycleLoggingScreen> createState() => _CycleLoggingScreenState();
}

class _CycleLoggingScreenState extends State<CycleLoggingScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSaving = false;

  Future<void> _saveCycle() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick both start and end dates')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not authenticated");
      }

      print('✅ Saving for user: ${user.uid}');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cycles')
          .add({
            'start': _startDate,
            'end': _endDate,
            'timestamp': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cycle logged successfully!')),
      );
    } catch (e) {
      print('❌ Error saving cycle: $e');

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
        print('🔁 UI reset complete');
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
              icon: const Icon(Icons.save),
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
