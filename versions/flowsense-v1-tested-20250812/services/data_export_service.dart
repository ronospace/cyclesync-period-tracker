import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';

class DataExportService {
  static final _auth = FirebaseAuth.instance;

  /// Export user data to JSON format
  static Future<Map<String, dynamic>> exportToJson() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get all cycles
      final cycles = await FirebaseService.getCycles(limit: 1000);
      
      // Create export data structure
      final exportData = {
        'app_name': 'CycleSync',
        'version': '1.0.0',
        'export_date': DateTime.now().toIso8601String(),
        'user_id': user.uid,
        'user_email': user.email,
        'data': {
          'cycles': cycles.map((cycle) => {
            'id': cycle['id'],
            'start': _formatDateForExport(cycle['start']),
            'end': _formatDateForExport(cycle['end']),
            'flow': cycle['flow'],
            'symptoms': cycle['symptoms'] ?? [],
            'notes': cycle['notes'] ?? '',
            'created_at': _formatDateForExport(cycle['timestamp']),
            'updated_at': _formatDateForExport(cycle['updated_at']),
          }).toList(),
        },
        'statistics': await _calculateExportStatistics(cycles),
      };

      return exportData;
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  /// Export data as JSON file and share
  static Future<void> exportAsJsonFile() async {
    try {
      final exportData = await exportToJson();
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'cyclesync_backup_$timestamp.json';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(jsonString);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'CycleSync Data Export',
        text: 'Your CycleSync data backup - ${exportData['data']['cycles'].length} cycles exported',
      );
    } catch (e) {
      throw Exception('Failed to export JSON file: $e');
    }
  }

  /// Export data as CSV file and share
  static Future<void> exportAsCsvFile() async {
    try {
      final cycles = await FirebaseService.getCycles(limit: 1000);
      
      // Create CSV data
      final List<List<String>> csvData = [
        // Header row
        ['Date', 'Start Date', 'End Date', 'Duration (days)', 'Flow', 'Symptoms', 'Notes'],
      ];

      for (final cycle in cycles) {
        final startDate = _parseDateFromCycle(cycle['start']);
        final endDate = _parseDateFromCycle(cycle['end']);
        final duration = endDate != null && startDate != null 
            ? endDate.difference(startDate).inDays + 1 
            : 0;

        csvData.add([
          startDate != null ? _formatDateForCsv(startDate) : '',
          startDate != null ? _formatDateForCsv(startDate) : '',
          endDate != null ? _formatDateForCsv(endDate) : '',
          duration.toString(),
          cycle['flow'] ?? '',
          (cycle['symptoms'] as List<dynamic>?)?.join(', ') ?? '',
          cycle['notes'] ?? '',
        ]);
      }

      final csvString = const ListToCsvConverter().convert(csvData);
      
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'cyclesync_data_$timestamp.csv';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(csvString);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'CycleSync Data Export (CSV)',
        text: 'Your CycleSync data in CSV format - ${cycles.length} cycles',
      );
    } catch (e) {
      throw Exception('Failed to export CSV file: $e');
    }
  }

  /// Import data from JSON file
  static Future<Map<String, dynamic>> importFromJsonFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        throw Exception('No file selected');
      }

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final importData = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate import data
      if (!_validateImportData(importData)) {
        throw Exception('Invalid backup file format');
      }

      return importData;
    } catch (e) {
      throw Exception('Failed to import file: $e');
    }
  }

  /// Restore data from import
  static Future<int> restoreFromImport(Map<String, dynamic> importData, {bool overwrite = false}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final cycles = importData['data']['cycles'] as List<dynamic>;
      int importedCount = 0;
      int skippedCount = 0;

      // Get existing cycles if not overwriting
      List<Map<String, dynamic>> existingCycles = [];
      if (!overwrite) {
        existingCycles = await FirebaseService.getCycles(limit: 1000);
      }

      for (final cycleData in cycles) {
        try {
          final startDate = DateTime.parse(cycleData['start']);
          final endDate = DateTime.parse(cycleData['end']);

          // Check for duplicates if not overwriting
          if (!overwrite && _isDuplicate(cycleData, existingCycles)) {
            skippedCount++;
            continue;
          }

          // Import the cycle (this will create a new cycle since we can't restore IDs)
          await FirebaseService.saveCycle(
            startDate: startDate,
            endDate: endDate,
            timeout: const Duration(seconds: 10),
          );

          // TODO: Add support for flow, symptoms, notes in saveCycle method
          importedCount++;
        } catch (e) {
          print('Failed to import cycle: $e');
          skippedCount++;
        }
      }

      return importedCount;
    } catch (e) {
      throw Exception('Failed to restore data: $e');
    }
  }

  // Helper methods
  static String? _formatDateForExport(dynamic date) {
    if (date == null) return null;
    
    try {
      DateTime dateTime;
      if (date is DateTime) {
        dateTime = date;
      } else if (date.toString().contains('Timestamp')) {
        dateTime = (date as dynamic).toDate();
      } else {
        dateTime = DateTime.parse(date.toString());
      }
      return dateTime.toIso8601String();
    } catch (e) {
      return null;
    }
  }

  static String _formatDateForCsv(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static DateTime? _parseDateFromCycle(dynamic date) {
    if (date == null) return null;
    
    try {
      if (date is DateTime) {
        return date;
      } else if (date.toString().contains('Timestamp')) {
        return (date as dynamic).toDate();
      } else {
        return DateTime.parse(date.toString());
      }
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> _calculateExportStatistics(List<Map<String, dynamic>> cycles) async {
    if (cycles.isEmpty) {
      return {
        'total_cycles': 0,
        'average_length': 0.0,
        'date_range': null,
      };
    }

    int totalDays = 0;
    int validCycles = 0;
    DateTime? earliest;
    DateTime? latest;

    for (final cycle in cycles) {
      final startDate = _parseDateFromCycle(cycle['start']);
      final endDate = _parseDateFromCycle(cycle['end']);

      if (startDate != null && endDate != null) {
        totalDays += endDate.difference(startDate).inDays + 1;
        validCycles++;

        if (earliest == null || startDate.isBefore(earliest)) {
          earliest = startDate;
        }
        if (latest == null || endDate.isAfter(latest)) {
          latest = endDate;
        }
      }
    }

    return {
      'total_cycles': cycles.length,
      'valid_cycles': validCycles,
      'average_length': validCycles > 0 ? totalDays / validCycles : 0.0,
      'date_range': earliest != null && latest != null
          ? '${_formatDateForCsv(earliest)} - ${_formatDateForCsv(latest)}'
          : null,
    };
  }

  static bool _validateImportData(Map<String, dynamic> data) {
    try {
      // Check required fields
      if (!data.containsKey('app_name') || data['app_name'] != 'CycleSync') {
        return false;
      }
      
      if (!data.containsKey('data') || !data['data'].containsKey('cycles')) {
        return false;
      }

      final cycles = data['data']['cycles'] as List<dynamic>;
      
      // Validate at least one cycle has required fields
      if (cycles.isNotEmpty) {
        final firstCycle = cycles.first as Map<String, dynamic>;
        if (!firstCycle.containsKey('start') || !firstCycle.containsKey('end')) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  static bool _isDuplicate(Map<String, dynamic> newCycle, List<Map<String, dynamic>> existingCycles) {
    final newStart = _parseDateFromCycle(newCycle['start']);
    final newEnd = _parseDateFromCycle(newCycle['end']);
    
    if (newStart == null || newEnd == null) return false;

    for (final existing in existingCycles) {
      final existingStart = _parseDateFromCycle(existing['start']);
      final existingEnd = _parseDateFromCycle(existing['end']);
      
      if (existingStart != null && existingEnd != null) {
        // Consider duplicates if dates are within 1 day of each other
        if ((newStart.difference(existingStart).inDays.abs() <= 1) &&
            (newEnd.difference(existingEnd).inDays.abs() <= 1)) {
          return true;
        }
      }
    }

    return false;
  }
}
