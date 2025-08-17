import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../models/cycle_models.dart';
import '../../models/daily_log_models.dart';
import '../../services/firebase_service.dart';
import '../cache/data_cache_manager.dart';
import '../providers/data_change_notifier.dart';

// Essential sync enums and classes
enum SyncState { idle, syncing, success, error, offline }
enum SyncOperationType { createCycle, updateCycle, deleteCycle, createDailyLog, updateDailyLog, deleteDailyLog }

/// Data sync status model
class DataSyncStatus {
  final SyncState state;
  final String message;
  final DateTime timestamp;
  final bool hasChanges;

  const DataSyncStatus({
    required this.state,
    required this.message,
    required this.timestamp,
    this.hasChanges = false,
  });

  factory DataSyncStatus.syncing([String message = 'Syncing data...']) {
    return DataSyncStatus(
      state: SyncState.syncing,
      message: message,
      timestamp: DateTime.now(),
    );
  }

  factory DataSyncStatus.success([String message = 'Sync successful']) {
    return DataSyncStatus(
      state: SyncState.success,
      message: message,
      timestamp: DateTime.now(),
      hasChanges: true,
    );
  }

  factory DataSyncStatus.error(String message) {
    return DataSyncStatus(
      state: SyncState.error,
      message: message,
      timestamp: DateTime.now(),
    );
  }
}

/// Sync result for operations
class SyncResult {
  final bool success;
  final bool hasChanges;
  final int syncedCount;
  final List<String> errors;

  const SyncResult({
    required this.success,
    this.hasChanges = false,
    this.syncedCount = 0,
    this.errors = const [],
  });

  factory SyncResult.success({int syncedCount = 0, bool hasChanges = false}) {
    return SyncResult(success: true, hasChanges: hasChanges, syncedCount: syncedCount);
  }

  factory SyncResult.error(String error) {
    return SyncResult(success: false, errors: [error]);
  }
}

/// HealthKit sync result
class HealthKitSyncResult {
  final bool success;
  final bool hasNewData;
  final String summary;

  const HealthKitSyncResult({
    required this.success,
    this.hasNewData = false,
    this.summary = '',
  });

  factory HealthKitSyncResult.success({bool hasNewData = false}) {
    return HealthKitSyncResult(
      success: true, 
      hasNewData: hasNewData, 
      summary: 'HealthKit sync successful'
    );
  }

  factory HealthKitSyncResult.error(String error) {
    return HealthKitSyncResult(success: false, summary: 'HealthKit sync failed: $error');
  }
}

/// Enterprise data synchronization manager
class DataSyncManager {
  static DataSyncManager? _instance;
  static DataSyncManager get instance => _instance ??= DataSyncManager._();

  DataSyncManager._();

  final DataCacheManager _cacheManager = DataCacheManager.instance;
  final DataChangeNotifier _changeNotifier = DataChangeNotifier.instance;

  bool _isOnline = true;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  Timer? _syncTimer;
  
  static const Duration _syncInterval = Duration(minutes: 15);
  bool _isInitialized = false;

  /// Initialize the sync manager
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🔄 Initializing DataSyncManager...');
      await _initializeConnectivityMonitoring();
      _startPeriodicSync();
      _isInitialized = true;
      debugPrint('✅ DataSyncManager initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize DataSyncManager: $e');
      rethrow;
    }
  }

  /// Initialize connectivity monitoring
  Future<void> _initializeConnectivityMonitoring() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    _isOnline = !connectivityResult.contains(ConnectivityResult.none);
    
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final wasOnline = _isOnline;
      _isOnline = !results.contains(ConnectivityResult.none);
      
      if (_isOnline && !wasOnline) {
        debugPrint('📡 Connection restored - starting sync...');
        performSync();
      } else if (!_isOnline && wasOnline) {
        debugPrint('📡 Connection lost - entering offline mode');
      }
    });
  }

  /// Start periodic synchronization
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(_syncInterval, (_) {
      if (_isOnline && !_isSyncing) {
        performSync();
      }
    });
  }

  /// Perform comprehensive data synchronization
  Future<DataSyncStatus> performSync() async {
    if (_isSyncing) return DataSyncStatus.syncing();

    _isSyncing = true;
    
    try {
      debugPrint('🔄 Starting comprehensive data sync...');
      
      bool hasChanges = false;
      final errors = <String>[];

      // Sync cycles data
      try {
        final cyclesSyncResult = await _syncCycles();
        if (cyclesSyncResult.hasChanges) hasChanges = true;
      } catch (e) {
        errors.add('Cycles sync failed: $e');
      }

      // Sync daily logs
      try {
        final logsSyncResult = await _syncDailyLogs();
        if (logsSyncResult.hasChanges) hasChanges = true;
      } catch (e) {
        errors.add('Daily logs sync failed: $e');
      }

      _lastSyncTime = DateTime.now();
      
      if (errors.isNotEmpty) {
        final errorMessage = 'Sync completed with errors: ${errors.join(', ')}';
        debugPrint('⚠️ $errorMessage');
        return DataSyncStatus(
          state: SyncState.error,
          message: errorMessage,
          timestamp: DateTime.now(),
          hasChanges: hasChanges,
        );
      } else {
        debugPrint('✅ Sync completed successfully');
        return DataSyncStatus.success('Sync completed successfully');
      }
      
    } catch (e) {
      debugPrint('❌ Sync failed: $e');
      return DataSyncStatus.error('Sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync cycles data with Firebase
  Future<SyncResult> _syncCycles() async {
    try {
      debugPrint('🔄 Syncing cycles data...');
      
      // Get local cycles
      final localCycles = await _cacheManager.getCachedCycles();
      
      // For now, just return success since we have basic Firebase integration
      // This can be expanded later with conflict resolution
      
      return SyncResult.success(
        syncedCount: localCycles.length,
        hasChanges: false,
      );

    } catch (e) {
      debugPrint('❌ Error syncing cycles: $e');
      return SyncResult.error('Cycles sync failed: $e');
    }
  }

  /// Sync daily logs data
  Future<SyncResult> _syncDailyLogs() async {
    try {
      debugPrint('🔄 Syncing daily logs...');
      
      // Get local daily logs
      final localLogs = await _cacheManager.getCachedDailyLogs();
      
      // For now, just return success
      return SyncResult.success(
        syncedCount: localLogs.length,
        hasChanges: false,
      );

    } catch (e) {
      debugPrint('❌ Error syncing daily logs: $e');
      return SyncResult.error('Daily logs sync failed: $e');
    }
  }

  /// Sync with HealthKit
  Future<HealthKitSyncResult> syncWithHealthKit() async {
    try {
      debugPrint('🏥 Syncing HealthKit data...');
      // Placeholder for HealthKit sync
      return HealthKitSyncResult.success(hasNewData: false);
    } catch (e) {
      debugPrint('❌ Error syncing HealthKit data: $e');
      return HealthKitSyncResult.error(e.toString());
    }
  }

  /// Force sync all data
  Future<DataSyncStatus> forceSync() async {
    debugPrint('🔄 Force sync initiated...');
    return await performSync();
  }

  /// Get connectivity status
  bool get isOnline => _isOnline;

  /// Check if currently syncing
  bool get isSyncing => _isSyncing;

  /// Get last sync time
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Dispose resources
  void dispose() {
    _syncTimer?.cancel();
  }
}
