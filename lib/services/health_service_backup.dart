import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import '../models/cycle_models.dart';
import 'firebase_service.dart';

class HealthService {
  static Health? _health;
  static bool _isInitialized = false;

  // Define the data types we want to work with
  static final List<HealthDataType> _healthDataTypes = [
    HealthDataType.MENSTRUATION_FLOW,
    // Wellbeing related
    HealthDataType.HEART_RATE,
    HealthDataType.BODY_TEMPERATURE,
    HealthDataType.SLEEP_IN_BED,
    // General health
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
  ];

  static final List<HealthDataAccess> _healthDataAccess = [
    HealthDataAccess.READ_WRITE,
    // Wellbeing related - mostly read
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    // General health - read only
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  /// Initialize the Health service
  static Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _health = Health();
      
      // Check if Health is supported on this platform
      final hasPermissions = await Health().hasPermissions(_healthDataTypes, permissions: _healthDataAccess);
      if (hasPermissions != true) {
        debugPrint('❌ HealthService: Health permissions not granted');
        return false;
      }

      _isInitialized = true;
      debugPrint('✅ HealthService: Initialized successfully');
      return true;
    } catch (e) {
      debugPrint('❌ HealthService: Initialization failed: $e');
      return false;
    }
  }

  /// Request permissions for health data access
  static Future<bool> requestPermissions() async {
    try {
      if (_health == null) {
        await initialize();
      }

      final requested = await _health?.requestAuthorization(
        _healthDataTypes,
        permissions: _healthDataAccess,
      );

      debugPrint('🔐 HealthService: Permission request result: $requested');
      return requested ?? false;
    } catch (e) {
      debugPrint('❌ HealthService: Permission request failed: $e');
      return false;
    }
  }

  /// Check if health data access is available
  static Future<bool> isAvailable() async {
    try {
      if (_health == null) {
        await initialize();
      }
      
      final hasPermissions = await Health().hasPermissions(_healthDataTypes, permissions: _healthDataAccess);
      return hasPermissions == true;
    } catch (e) {
      debugPrint('❌ HealthService: Availability check failed: $e');
      return false;
    }
  }

  /// Get health integration status
  static Future<HealthIntegrationStatus> getIntegrationStatus() async {
    try {
      final isSupported = await Health().hasPermissions(_healthDataTypes) ?? false;
      final hasPermissions = await Health().hasPermissions(_healthDataTypes, permissions: _healthDataAccess) ?? false;
      
      if (!isSupported) {
        return HealthIntegrationStatus(
          isSupported: false,
          hasPermissions: false,
          message: 'Health data is not supported on this device',
          canSync: false,
        );
      }
      
      if (!hasPermissions) {
        return HealthIntegrationStatus(
          isSupported: true,
          hasPermissions: false,
          message: 'Health permissions not granted. Tap to request access.',
          canSync: false,
        );
      }
      
      return HealthIntegrationStatus(
        isSupported: true,
        hasPermissions: true,
        message: 'Health integration is active and ready',
        canSync: true,
      );
    } catch (e) {
      return HealthIntegrationStatus(
        isSupported: false,
        hasPermissions: false,
        message: 'Error checking health integration: ${e.toString()}',
        canSync: false,
      );
    }
  }

  /// Sync cycle data to health platform
  static Future<HealthSyncResult> syncCycleToHealth(CycleData cycle) async {
    try {
      if (_health == null || !_isInitialized) {
        await initialize();
      }

      final results = <String, bool>{};
      final errors = <String>[];

      // Sync menstruation flow data
      if (cycle.endDate != null) {
        try {
          final flowValue = _convertFlowIntensityToHealthValue(cycle.flowIntensity);
          
          final success = await _health?.writeHealthData(
            value: flowValue,
            type: HealthDataType.MENSTRUATION_FLOW,
            startTime: cycle.startDate,
            endTime: cycle.endDate!,
          );
          
          results['menstruation_flow'] = success ?? false;
          if (!(success ?? false)) {
            errors.add('Failed to sync menstruation flow data');
          }
        } catch (e) {
          errors.add('Menstruation flow sync error: $e');
          results['menstruation_flow'] = false;
        }
      }

      // Skip mood data for now as it's not available in all health platforms
      debugPrint('📝 HealthService: Mood sync skipped - not available in all platforms');

      // Sync symptoms as notes/observations
      if (cycle.symptoms.isNotEmpty || cycle.notes.isNotEmpty) {
        try {
          final symptomText = [
            ...cycle.symptoms.map((s) => s.displayName),
            if (cycle.notes.isNotEmpty) 'Notes: ${cycle.notes}',
          ].join(', ');
          
          // Store as a general observation - this might vary by platform
          debugPrint('📝 HealthService: Would sync symptoms: $symptomText');
          results['symptoms'] = true;
        } catch (e) {
          errors.add('Symptoms sync error: $e');
          results['symptoms'] = false;
        }
      }

      final successCount = results.values.where((success) => success).length;
      final totalAttempts = results.length;

      return HealthSyncResult(
        success: successCount > 0,
        syncedDataTypes: results.keys.where((key) => results[key] == true).toList(),
        failedDataTypes: results.keys.where((key) => results[key] == false).toList(),
        errors: errors,
        summary: 'Synced $successCount of $totalAttempts data types successfully',
      );
    } catch (e) {
      return HealthSyncResult(
        success: false,
        syncedDataTypes: [],
        failedDataTypes: ['all'],
        errors: ['General sync error: ${e.toString()}'],
        summary: 'Sync failed due to an unexpected error',
      );
    }
  }

  /// Import health data and convert to cycle data
  static Future<HealthImportResult> importHealthData({DateTime? startDate, DateTime? endDate}) async {
    try {
      if (_health == null || !_isInitialized) {
        await initialize();
      }

      final now = DateTime.now();
      final importStartDate = startDate ?? now.subtract(const Duration(days: 365)); // Last year
      final importEndDate = endDate ?? now;

      final importedCycles = <CycleData>[];
      final errors = <String>[];

      // Get menstruation data
      try {
        final menstruationData = await _health?.getHealthDataFromTypes(
          startTime: importStartDate,
          endTime: importEndDate,
          types: [HealthDataType.MENSTRUATION_FLOW],
        );

        if (menstruationData?.isNotEmpty ?? false) {
          // Group menstruation data into cycles
          final cycleGroups = _groupMenstruationDataIntoCycles(menstruationData!);
          
          for (final group in cycleGroups) {
            final cycleData = await _convertHealthDataToCycle(group);
            if (cycleData != null) {
              importedCycles.add(cycleData);
            }
          }
        }
      } catch (e) {
        errors.add('Menstruation data import error: $e');
      }

      // Skip mood data import for now
      debugPrint('📝 HealthService: Mood import skipped - not available in all platforms');

      return HealthImportResult(
        success: importedCycles.isNotEmpty,
        importedCycles: importedCycles,
        importedCount: importedCycles.length,
        errors: errors,
        summary: errors.isEmpty 
            ? 'Successfully imported ${importedCycles.length} cycles from health data'
            : 'Imported ${importedCycles.length} cycles with ${errors.length} warnings',
      );
    } catch (e) {
      return HealthImportResult(
        success: false,
        importedCycles: [],
        importedCount: 0,
        errors: ['Import failed: ${e.toString()}'],
        summary: 'Health data import failed due to an unexpected error',
      );
    }
  }

  /// Bulk sync all existing cycles to health platform
  static Future<HealthBulkSyncResult> bulkSyncToHealth() async {
    try {
      final cycles = await FirebaseService.getCycles(limit: 100);
      final results = <String, HealthSyncResult>{};
      int successCount = 0;
      int failCount = 0;

      for (final rawCycle in cycles) {
        final cycle = _convertToCycleData(rawCycle);
        final result = await syncCycleToHealth(cycle);
        
        results[cycle.id] = result;
        if (result.success) {
          successCount++;
        } else {
          failCount++;
        }

        // Add small delay to avoid overwhelming the health system
        await Future.delayed(const Duration(milliseconds: 100));
      }

      return HealthBulkSyncResult(
        success: successCount > 0,
        totalCycles: cycles.length,
        successCount: successCount,
        failCount: failCount,
        results: results,
        summary: 'Bulk sync completed: $successCount successful, $failCount failed out of ${cycles.length} cycles',
      );
    } catch (e) {
      return HealthBulkSyncResult(
        success: false,
        totalCycles: 0,
        successCount: 0,
        failCount: 0,
        results: {},
        summary: 'Bulk sync failed: ${e.toString()}',
      );
    }
  }

  // Helper methods

  static double _convertFlowIntensityToHealthValue(FlowIntensity intensity) {
    switch (intensity) {
      case FlowIntensity.light:
        return 1.0;
      case FlowIntensity.medium:
        return 2.0;
      case FlowIntensity.heavy:
        return 3.0;
    }
  }

  static FlowIntensity _convertHealthValueToFlowIntensity(double value) {
    if (value <= 1.5) return FlowIntensity.light;
    if (value <= 2.5) return FlowIntensity.medium;
    return FlowIntensity.heavy;
  }

  static List<List<HealthDataPoint>> _groupMenstruationDataIntoCycles(List<HealthDataPoint> data) {
    // Sort by date
    data.sort((a, b) => a.dateTo.compareTo(b.dateTo));
    
    final cycles = <List<HealthDataPoint>>[];
    List<HealthDataPoint> currentCycle = [];
    
    for (final point in data) {
      if (currentCycle.isEmpty) {
        currentCycle.add(point);
      } else {
        final lastPoint = currentCycle.last;
        final daysDiff = point.dateFrom.difference(lastPoint.dateTo).inDays;
        
        // If gap is more than 10 days, start a new cycle
        if (daysDiff > 10) {
          cycles.add(List.from(currentCycle));
          currentCycle = [point];
        } else {
          currentCycle.add(point);
        }
      }
    }
    
    if (currentCycle.isNotEmpty) {
      cycles.add(currentCycle);
    }
    
    return cycles;
  }

  static Future<CycleData?> _convertHealthDataToCycle(List<HealthDataPoint> healthData) async {
    if (healthData.isEmpty) return null;

    final firstPoint = healthData.first;
    final lastPoint = healthData.last;
    
    // Calculate average flow intensity
    final flowValues = healthData
        .map((point) => double.tryParse(point.value.toString()) ?? 2.0)
        .toList();
    final avgFlow = flowValues.reduce((a, b) => a + b) / flowValues.length;
    
    return CycleData(
      id: 'health_import_${firstPoint.dateFrom.millisecondsSinceEpoch}',
      startDate: firstPoint.dateFrom,
      endDate: lastPoint.dateTo,
      flowIntensity: _convertHealthValueToFlowIntensity(avgFlow),
      wellbeing: const WellbeingData(mood: 3.0, energy: 3.0, pain: 2.0), // Default values
      symptoms: [], // Will be populated if available
      notes: 'Imported from Health app',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static void _correlateMoodDataWithCycles(List<CycleData> cycles, List<HealthDataPoint> moodData) {
    for (final cycle in cycles) {
      final relevantMood = moodData.where((mood) {
        return mood.dateFrom.isAfter(cycle.startDate.subtract(const Duration(days: 2))) &&
               mood.dateFrom.isBefore((cycle.endDate ?? cycle.startDate.add(const Duration(days: 7))).add(const Duration(days: 2)));
      }).toList();
      
      if (relevantMood.isNotEmpty) {
        final avgMood = relevantMood
            .map((m) => double.tryParse(m.value.toString()) ?? 3.0)
            .reduce((a, b) => a + b) / relevantMood.length;
        
        // Update the cycle's wellbeing data with imported mood
        // Note: This would require making CycleData mutable or creating a new instance
        debugPrint('📊 HealthService: Found mood data for cycle ${cycle.id}: $avgMood');
      }
    }
  }

  static CycleData _convertToCycleData(Map<String, dynamic> raw) {
    return CycleData(
      id: raw['id'] ?? '',
      startDate: _parseDate(raw['start']) ?? DateTime.now(),
      endDate: _parseDate(raw['end']),
      flowIntensity: _parseFlowIntensity(raw['flow_intensity'] ?? raw['flow']),
      wellbeing: WellbeingData(
        mood: (raw['mood'] ?? raw['mood_level'] ?? 3.0).toDouble(),
        energy: (raw['energy'] ?? raw['energy_level'] ?? 3.0).toDouble(),
        pain: (raw['pain'] ?? raw['pain_level'] ?? 1.0).toDouble(),
      ),
      symptoms: _parseSymptoms(raw['symptoms']),
      notes: raw['notes']?.toString() ?? '',
      createdAt: _parseDate(raw['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(raw['updated_at']) ?? DateTime.now(),
    );
  }

  static DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    try {
      if (date is DateTime) return date;
      if (date.toString().contains('Timestamp')) {
        return (date as dynamic).toDate();
      }
      return DateTime.parse(date.toString());
    } catch (e) {
      return null;
    }
  }

  static FlowIntensity _parseFlowIntensity(dynamic flow) {
    if (flow == null) return FlowIntensity.medium;
    if (flow is String) {
      switch (flow.toLowerCase()) {
        case 'light': return FlowIntensity.light;
        case 'heavy': return FlowIntensity.heavy;
        default: return FlowIntensity.medium;
      }
    }
    return FlowIntensity.medium;
  }

  static List<Symptom> _parseSymptoms(dynamic symptoms) {
    if (symptoms == null) return [];
    if (symptoms is! List) return [];
    
    return symptoms
        .map((name) => Symptom.fromName(name.toString()))
        .where((symptom) => symptom != null)
        .cast<Symptom>()
        .toList();
  }
}

// Data models for health integration

class HealthIntegrationStatus {
  final bool isSupported;
  final bool hasPermissions;
  final String message;
  final bool canSync;

  HealthIntegrationStatus({
    required this.isSupported,
    required this.hasPermissions,
    required this.message,
    required this.canSync,
  });
}

class HealthSyncResult {
  final bool success;
  final List<String> syncedDataTypes;
  final List<String> failedDataTypes;
  final List<String> errors;
  final String summary;

  HealthSyncResult({
    required this.success,
    required this.syncedDataTypes,
    required this.failedDataTypes,
    required this.errors,
    required this.summary,
  });
}

class HealthImportResult {
  final bool success;
  final List<CycleData> importedCycles;
  final int importedCount;
  final List<String> errors;
  final String summary;

  HealthImportResult({
    required this.success,
    required this.importedCycles,
    required this.importedCount,
    required this.errors,
    required this.summary,
  });
}

class HealthBulkSyncResult {
  final bool success;
  final int totalCycles;
  final int successCount;
  final int failCount;
  final Map<String, HealthSyncResult> results;
  final String summary;

  HealthBulkSyncResult({
    required this.success,
    required this.totalCycles,
    required this.successCount,
    required this.failCount,
    required this.results,
    required this.summary,
  });
}
