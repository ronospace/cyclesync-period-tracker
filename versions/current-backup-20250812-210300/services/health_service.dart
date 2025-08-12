import 'package:flutter/foundation.dart';
import '../models/cycle_models.dart';
import '../config/platform_config.dart';
import 'firebase_service.dart';

class HealthService {
  static bool _isInitialized = false;

  /// Initialize the Health service
  static Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
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
      if (!_isInitialized) {
        await initialize();
      }

      // Mock permission request - always returns true for testing
      debugPrint('🔐 HealthService: Permission request result: true');
      return true;
    } catch (e) {
      debugPrint('❌ HealthService: Permission request failed: $e');
      return false;
    }
  }

  /// Check if health data access is available
  static Future<bool> isAvailable() async {
    return PlatformConfig.supportsHealthIntegration;
  }

  /// Get health integration status
  static Future<HealthIntegrationStatus> getIntegrationStatus() async {
    try {
      final isSupported = PlatformConfig.supportsHealthIntegration;
      
      if (!isSupported) {
        return HealthIntegrationStatus(
          isSupported: false,
          hasPermissions: false,
          message: 'Health data is not supported on this device',
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
      if (!_isInitialized) {
        await initialize();
      }

      // Mock sync - always successful for testing
      return HealthSyncResult(
        success: true,
        syncedDataTypes: ['menstruation_flow', 'symptoms'],
        failedDataTypes: [],
        errors: [],
        summary: 'Successfully synced cycle data to health platform',
        syncedCount: 1,
        exportedData: {
          'cycle_id': cycle.id,
          'flow_intensity': cycle.flowIntensity.name,
          'symptoms_count': cycle.symptoms.length,
        },
      );
    } catch (e) {
      return HealthSyncResult(
        success: false,
        syncedDataTypes: [],
        failedDataTypes: ['all'],
        errors: ['General sync error: ${e.toString()}'],
        summary: 'Sync failed due to an unexpected error',
        syncedCount: 0,
        exportedData: {},
      );
    }
  }

  /// Import health data from platform
  static Future<HealthImportResult> importHealthData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Mock import - return empty for testing
      return HealthImportResult(
        success: true,
        importedCount: 0,
        summary: 'No health data available to import',
        cycles: [],
      );
    } catch (e) {
      return HealthImportResult(
        success: false,
        importedCount: 0,
        summary: 'Import failed: ${e.toString()}',
        cycles: [],
      );
    }
  }

  /// Bulk sync all cycles to health platform
  static Future<HealthSyncResult> bulkSyncToHealth() async {
    try {
      final cycleData = await FirebaseService.getCycles();
      int successCount = 0;
      int failureCount = 0;

      // Convert Map<String, dynamic> to CycleData objects
      final cycles = cycleData.map((data) {
        try {
          return CycleData.fromFirestore(data);
        } catch (e) {
          // Skip invalid cycle data
          debugPrint('Warning: Skipping invalid cycle data: $e');
          return null;
        }
      }).where((cycle) => cycle != null).cast<CycleData>().toList();

      for (final cycle in cycles) {
        final result = await syncCycleToHealth(cycle);
        if (result.success) {
          successCount++;
        } else {
          failureCount++;
        }
      }

      return HealthSyncResult(
        success: successCount > 0 || cycles.isEmpty,
        syncedDataTypes: ['bulk_sync'],
        failedDataTypes: failureCount > 0 ? ['some_cycles'] : [],
        errors: [],
        summary: cycles.isEmpty 
            ? 'No cycles to sync' 
            : 'Bulk sync completed: $successCount successful, $failureCount failed',
        syncedCount: successCount,
        exportedData: {
          'total_cycles': cycles.length,
          'successful_syncs': successCount,
          'failed_syncs': failureCount,
        },
      );
    } catch (e) {
      return HealthSyncResult(
        success: false,
        syncedDataTypes: [],
        failedDataTypes: ['bulk_sync'],
        errors: ['Bulk sync error: ${e.toString()}'],
        summary: 'Bulk sync failed',
        syncedCount: 0,
        exportedData: {},
      );
    }
  }
}

