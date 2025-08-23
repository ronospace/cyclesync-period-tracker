import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../models/cycle_models.dart';
import '../../models/daily_log_models.dart';
import '../../services/firebase_service.dart';
import '../../services/advanced_health_kit_service.dart';
import '../cache/data_cache_manager.dart';
import '../providers/data_change_notifier.dart';

// Sync-related enums and classes
enum SyncState {
  idle,
  syncing,
  success,
  error,
  offline,
}

enum SyncOperationType {
  createCycle,
  updateCycle,
  deleteCycle,
  createDailyLog,
  updateDailyLog,
  deleteDailyLog,
  syncHealthKit,
}

/// Data sync status model
class DataSyncStatus {
  final SyncState state;
  final String message;
  final DateTime timestamp;
  final bool hasChanges;
  final Map<String, dynamic> details;

  const DataSyncStatus({
    required this.state,
    required this.message,
    required this.timestamp,
    this.hasChanges = false,
    this.details = const {},
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

/// Sync result for individual operations
class SyncResult {
  final bool success;
  final bool hasChanges;
  final int syncedCount;
  final List<String> errors;
  final Map<String, dynamic> details;

  const SyncResult({
    required this.success,
    this.hasChanges = false,
    this.syncedCount = 0,
    this.errors = const [],
    this.details = const {},
  });

  factory SyncResult.success({
    int syncedCount = 0,
    bool hasChanges = false,
  }) {
    return SyncResult(
      success: true,
      hasChanges: hasChanges,
      syncedCount: syncedCount,
    );
  }

  factory SyncResult.error(String error) {
    return SyncResult(
      success: false,
      errors: [error],
    );
  }
}

/// HealthKit sync result
class HealthKitSyncResult {
  final bool success;
  final bool hasNewData;
  final List<String> syncedDataTypes;
  final Map<String, dynamic> data;
  final String summary;

  const HealthKitSyncResult({
    required this.success,
    this.hasNewData = false,
    this.syncedDataTypes = const [],
    this.data = const {},
    this.summary = '',
  });

  factory HealthKitSyncResult.success({
    bool hasNewData = false,
    List<String> syncedDataTypes = const [],
    Map<String, dynamic> data = const {},
  }) {
    return HealthKitSyncResult(
      success: true,
      hasNewData: hasNewData,
      syncedDataTypes: syncedDataTypes,
      data: data,
      summary: 'HealthKit sync successful',
    );
  }

  factory HealthKitSyncResult.error(String error) {
    return HealthKitSyncResult(
      success: false,
      summary: 'HealthKit sync failed: $error',
    );
  }
}

/// Pending sync operation
class PendingSyncOperation {
  final String id;
  final SyncOperationType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int retryCount;

  const PendingSyncOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'retryCount': retryCount,
    };
  }

  factory PendingSyncOperation.fromJson(Map<String, dynamic> json) {
    return PendingSyncOperation(
      id: json['id'],
      type: SyncOperationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SyncOperationType.createCycle,
      ),
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
      retryCount: json['retryCount'] ?? 0,
    );
  }

  PendingSyncOperation copyWith({
    String? id,
    SyncOperationType? type,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    int? retryCount,
  }) {
    return PendingSyncOperation(
      id: id ?? this.id,
      type: type ?? this.type,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

/// Enterprise-level data synchronization manager
/// Handles multi-source sync, conflict resolution, and offline/online coordination
class DataSyncManager {
  static DataSyncManager? _instance;
  static DataSyncManager get instance => _instance ??= DataSyncManager._();

  DataSyncManager._();

  final DataCacheManager _cacheManager = DataCacheManager.instance;
  final DataChangeNotifier _changeNotifier = DataChangeNotifier.instance;
  final AdvancedHealthKitService _healthKit = AdvancedHealthKitService.instance;

  // Sync state tracking
  bool _isOnline = true;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  Timer? _syncTimer;
  final List<PendingSyncOperation> _pendingOperations = [];
  
  // Sync configuration
  static const Duration _syncInterval = Duration(minutes: 15);
  static const Duration _retryDelay = Duration(seconds: 30);
  static const int _maxRetryAttempts = 3;
  
  bool _isInitialized = false;

  /// Initialize the sync manager
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🔄 Initializing DataSyncManager...');
      
      // Initialize connectivity monitoring
      await _initializeConnectivityMonitoring();
      
      // Load pending sync operations
      await _loadPendingOperations();
      
      // Start periodic sync
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
    // Check initial connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    _isOnline = connectivityResult.isNotEmpty && !connectivityResult.contains(ConnectivityResult.none);
    
    // Listen to connectivity changes
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final wasOnline = _isOnline;
      _isOnline = results.isNotEmpty && !results.contains(ConnectivityResult.none);
      
      if (_isOnline && !wasOnline) {
        debugPrint('📡 Connection restored - starting sync...');
        _processPendingOperations();
        performSync();
      } else if (!_isOnline && wasOnline) {
        debugPrint('📡 Connection lost - entering offline mode');
      }
    });
  }

  /// Load pending sync operations from cache
  Future<void> _loadPendingOperations() async {
    try {
      final pendingData = await _cacheManager.getCachedData<List<dynamic>>('pending_sync_operations');
      if (pendingData != null) {
        _pendingOperations.clear();
        _pendingOperations.addAll(
          pendingData.map((data) => PendingSyncOperation.fromJson(data)).toList()
        );
        debugPrint('📋 Loaded ${_pendingOperations.length} pending sync operations');
      }
    } catch (e) {
      debugPrint('⚠️ Error loading pending sync operations: $e');
    }
  }

  /// Save pending sync operations to cache
  Future<void> _savePendingOperations() async {
    try {
      final pendingData = _pendingOperations.map((op) => op.toJson()).toList();
      await _cacheManager.cacheData('pending_sync_operations', pendingData);
    } catch (e) {
      debugPrint('⚠️ Error saving pending sync operations: $e');
    }
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
    if (_isSyncing) {
      return DataSyncStatus.syncing();
    }

    _isSyncing = true;
    
    try {
      debugPrint('🔄 Starting comprehensive data sync...');
      
      final syncResults = <String, dynamic>{};
      bool hasChanges = false;
      final errors = <String>[];

      // 1. Sync cycles data
      try {
        final cyclesSyncResult = await _syncCycles();
        syncResults['cycles'] = cyclesSyncResult;
        if (cyclesSyncResult.hasChanges) hasChanges = true;
      } catch (e) {
        errors.add('Cycles sync failed: $e');
      }

      // 2. Sync daily logs
      try {
        final logsSyncResult = await _syncDailyLogs();
        syncResults['daily_logs'] = logsSyncResult;
        if (logsSyncResult.hasChanges) hasChanges = true;
      } catch (e) {
        errors.add('Daily logs sync failed: $e');
      }

      // 3. Sync HealthKit data
      try {
        final healthKitResult = await _syncHealthKitData();
        syncResults['healthkit'] = healthKitResult;
        if (healthKitResult.hasNewData) hasChanges = true;
      } catch (e) {
        errors.add('HealthKit sync failed: $e');
      }

      // 4. Process pending operations
      try {
        await _processPendingOperations();
      } catch (e) {
        errors.add('Pending operations failed: $e');
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
        final successMessage = 'Sync completed successfully';
        debugPrint('✅ $successMessage');
        return DataSyncStatus.success(successMessage);
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
      
      // Get remote cycles
      final remoteCyclesData = await FirebaseService.getCycles();
      final remoteCycles = remoteCyclesData
          .map((data) => CycleData.fromFirestore(data))
          .toList();

      // Perform conflict resolution
      final resolvedCycles = await _resolveCycleConflicts(localCycles, remoteCycles);
      
      // Update cache with resolved data
      await _cacheManager.cacheCycles(resolvedCycles);
      
      // Notify of changes
      _changeNotifier.notifyDataChange(DataChange(
        type: DataChangeType.updated,
        entityType: EntityType.cycle,
        entityId: 'bulk_sync',
        timestamp: DateTime.now(),
      ));

      return SyncResult(
        entityType: 'cycles',
        localCount: localCycles.length,
        remoteCount: remoteCycles.length,
        resolvedCount: resolvedCycles.length,
        hasChanges: localCycles.length != resolvedCycles.length,
        conflicts: [],
      );

    } catch (e) {
      debugPrint('❌ Error syncing cycles: $e');
      rethrow;
    }
  }

  /// Sync daily logs data
  Future<SyncResult> _syncDailyLogs() async {
    try {
      debugPrint('🔄 Syncing daily logs...');
      
      // Get local daily logs
      final localLogs = await _cacheManager.getCachedDailyLogs();
      
      // For now, return empty result since daily logs sync is not implemented
      // This will be implemented when daily logs Firebase integration is ready
      
      return SyncResult(
        entityType: 'daily_logs',
        localCount: localLogs.length,
        remoteCount: 0,
        resolvedCount: localLogs.length,
        hasChanges: false,
        conflicts: [],
      );

    } catch (e) {
      debugPrint('❌ Error syncing daily logs: $e');
      rethrow;
    }
  }

  /// Sync HealthKit data
  Future<HealthKitSyncResult> _syncHealthKitData() async {
    try {
      debugPrint('🏥 Syncing HealthKit data...');
      
      // Get recent health data
      final healthData = await _healthKit.getRecentHealthData();
      
      if (healthData.isEmpty) {
        return HealthKitSyncResult(
          success: true,
          summary: 'No new HealthKit data',
          newRecords: 0,
          errors: [],
          hasNewData: false,
        );
      }

      // Process and integrate health data
      int processedRecords = 0;
      final errors = <String>[];

      for (final data in healthData) {
        try {
          await _processHealthKitData(data);
          processedRecords++;
        } catch (e) {
          errors.add('Failed to process health data: $e');
        }
      }

      return HealthKitSyncResult(
        success: errors.isEmpty,
        summary: 'Processed $processedRecords HealthKit records',
        newRecords: processedRecords,
        errors: errors,
        hasNewData: processedRecords > 0,
      );

    } catch (e) {
      debugPrint('❌ Error syncing HealthKit data: $e');
      return HealthKitSyncResult.error(e.toString());
    }
  }

  /// Process individual HealthKit data entry
  Future<void> _processHealthKitData(Map<String, dynamic> healthData) async {
    // Implementation depends on the health data format
    // This is a placeholder for health data processing logic
    debugPrint('🔄 Processing HealthKit data: ${healthData['type']}');
  }

  /// Resolve conflicts between local and remote cycles
  Future<List<CycleData>> _resolveCycleConflicts(
    List<CycleData> localCycles,
    List<CycleData> remoteCycles,
  ) async {
    final resolved = <CycleData>[];
    final conflicts = <DataConflict>[];

    // Create maps for efficient lookup
    final localMap = {for (var cycle in localCycles) cycle.id: cycle};
    final remoteMap = {for (var cycle in remoteCycles) cycle.id: cycle};
    
    // Get all unique IDs
    final allIds = {...localMap.keys, ...remoteMap.keys};

    for (final id in allIds) {
      final local = localMap[id];
      final remote = remoteMap[id];

      if (local == null) {
        // Only remote - add remote version
        resolved.add(remote!);
      } else if (remote == null) {
        // Only local - keep local version
        resolved.add(local);
      } else {
        // Both exist - resolve conflict
        final resolvedCycle = await _resolveCycleConflict(local, remote);
        resolved.add(resolvedCycle);
        
        if (resolvedCycle != local && resolvedCycle != remote) {
          conflicts.add(DataConflict(
            entityId: id,
            entityType: EntityType.cycle,
            conflictType: ConflictType.merge,
            localVersion: local.toFirestore(),
            remoteVersion: remote.toFirestore(),
            resolvedVersion: resolvedCycle.toFirestore(),
            timestamp: DateTime.now(),
          ));
        }
      }
    }

    // Log conflicts if any
    if (conflicts.isNotEmpty) {
      debugPrint('⚠️ Resolved ${conflicts.length} cycle conflicts');
    }

    return resolved;
  }

  /// Resolve individual cycle conflict
  Future<CycleData> _resolveCycleConflict(CycleData local, CycleData remote) async {
    // Conflict resolution strategy: latest modified wins, but merge non-conflicting fields
    
    if (local.lastUpdated != null && remote.lastUpdated != null) {
      if (local.lastUpdated!.isAfter(remote.lastUpdated!)) {
        // Local is newer - merge in remote data that doesn't conflict
        return _mergeCycles(local, remote, preferLocal: true);
      } else {
        // Remote is newer - merge in local data that doesn't conflict
        return _mergeCycles(remote, local, preferLocal: false);
      }
    }

    // If no timestamps, prefer remote (server-side)
    return _mergeCycles(remote, local, preferLocal: false);
  }

  /// Merge two cycles intelligently
  CycleData _mergeCycles(CycleData primary, CycleData secondary, {required bool preferLocal}) {
    // Start with primary cycle
    var merged = primary;

    // Merge symptoms (combine unique symptoms)
    final combinedSymptoms = <Symptom>[];
    final symptomNames = <String>{};
    
    for (final symptom in primary.symptoms) {
      if (!symptomNames.contains(symptom.name)) {
        combinedSymptoms.add(symptom);
        symptomNames.add(symptom.name);
      }
    }
    
    for (final symptom in secondary.symptoms) {
      if (!symptomNames.contains(symptom.name)) {
        combinedSymptoms.add(symptom);
        symptomNames.add(symptom.name);
      }
    }

    // Merge notes (combine if different)
    String mergedNotes = primary.notes;
    if (secondary.notes.isNotEmpty && secondary.notes != primary.notes) {
      if (mergedNotes.isNotEmpty) {
        mergedNotes += '\n---\n${secondary.notes}';
      } else {
        mergedNotes = secondary.notes;
      }
    }

    // Create merged cycle
    merged = CycleData(
      id: primary.id,
      startDate: primary.startDate,
      endDate: primary.endDate ?? secondary.endDate,
      flowIntensity: primary.flowIntensity,
      symptoms: combinedSymptoms,
      notes: mergedNotes,
      ovulationDate: primary.ovulationDate ?? secondary.ovulationDate,
      predictedNextPeriod: primary.predictedNextPeriod ?? secondary.predictedNextPeriod,
      mood: primary.mood ?? secondary.mood,
      energyLevel: primary.energyLevel ?? secondary.energyLevel,
      sleepQuality: primary.sleepQuality ?? secondary.sleepQuality,
      tags: <dynamic>{...primary.tags, ...secondary.tags}.toList(),
      lastUpdated: DateTime.now(),
    );

    return merged;
  }

  /// Process pending sync operations
  Future<void> _processPendingOperations() async {
    if (_pendingOperations.isEmpty) return;

    debugPrint('🔄 Processing ${_pendingOperations.length} pending operations...');

    final completedOperations = <PendingSyncOperation>[];

    for (final operation in _pendingOperations) {
      try {
        await _processSyncOperation(operation);
        completedOperations.add(operation);
        debugPrint('✅ Completed pending operation: ${operation.type}');
      } catch (e) {
        operation.retryCount++;
        if (operation.retryCount >= _maxRetryAttempts) {
          completedOperations.add(operation);
          debugPrint('❌ Max retries exceeded for operation: ${operation.type}');
        } else {
          debugPrint('⚠️ Retry ${operation.retryCount} for operation: ${operation.type}');
        }
      }
    }

    // Remove completed operations
    _pendingOperations.removeWhere((op) => completedOperations.contains(op));
    await _savePendingOperations();
  }

  /// Process individual sync operation
  Future<void> _processSyncOperation(PendingSyncOperation operation) async {
    switch (operation.type) {
      case SyncOperationType.createCycle:
        final cycleData = CycleData.fromFirestore(operation.data);
        await FirebaseService.saveCycleWithSymptoms(cycleData: cycleData.toFirestore());
        break;
        
      case SyncOperationType.updateCycle:
        final cycleData = CycleData.fromFirestore(operation.data);
        await FirebaseService.saveCycleWithSymptoms(cycleData: cycleData.toFirestore());
        break;
        
      case SyncOperationType.deleteCycle:
        await FirebaseService.deleteCycle(operation.entityId);
        break;
        
      case SyncOperationType.createDailyLog:
        // Implement when daily logs Firebase integration is ready
        break;
        
      case SyncOperationType.updateDailyLog:
        // Implement when daily logs Firebase integration is ready
        break;
    }
  }

  /// Add operation to pending sync queue
  Future<void> addPendingOperation(PendingSyncOperation operation) async {
    _pendingOperations.add(operation);
    await _savePendingOperations();
    
    // Try to process immediately if online
    if (_isOnline && !_isSyncing) {
      _processPendingOperations();
    }
  }

  /// Sync with HealthKit specifically
  Future<HealthKitSyncResult> syncWithHealthKit() async {
    return await _syncHealthKitData();
  }

  /// Get sync statistics
  SyncStats getSyncStats() {
    return SyncStats(
      lastSyncTime: _lastSyncTime,
      isOnline: _isOnline,
      isSyncing: _isSyncing,
      pendingOperationsCount: _pendingOperations.length,
      syncInterval: _syncInterval,
    );
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

  /// Dispose resources
  void dispose() {
    _syncTimer?.cancel();
    _pendingOperations.clear();
  }
}

/// Sync result for individual entity types
class SyncResult {
  final String entityType;
  final int localCount;
  final int remoteCount;
  final int resolvedCount;
  final bool hasChanges;
  final List<DataConflict> conflicts;

  SyncResult({
    required this.entityType,
    required this.localCount,
    required this.remoteCount,
    required this.resolvedCount,
    required this.hasChanges,
    required this.conflicts,
  });
}

/// Pending sync operation
class PendingSyncOperation {
  final String id;
  final SyncOperationType type;
  final String entityId;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  int retryCount;

  PendingSyncOperation({
    required this.id,
    required this.type,
    required this.entityId,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'entityId': entityId,
    'data': data,
    'createdAt': createdAt.toIso8601String(),
    'retryCount': retryCount,
  };

  factory PendingSyncOperation.fromJson(Map<String, dynamic> json) {
    return PendingSyncOperation(
      id: json['id'],
      type: SyncOperationType.values.firstWhere(
        (e) => e.toString() == json['type']
      ),
      entityId: json['entityId'],
      data: Map<String, dynamic>.from(json['data']),
      createdAt: DateTime.parse(json['createdAt']),
      retryCount: json['retryCount'] ?? 0,
    );
  }
}

/// Sync operation types
enum SyncOperationType {
  createCycle,
  updateCycle,
  deleteCycle,
  createDailyLog,
  updateDailyLog,
  deleteDailyLog,
}

/// Data conflict representation
class DataConflict {
  final String entityId;
  final EntityType entityType;
  final ConflictType conflictType;
  final Map<String, dynamic> localVersion;
  final Map<String, dynamic> remoteVersion;
  final Map<String, dynamic> resolvedVersion;
  final DateTime timestamp;

  DataConflict({
    required this.entityId,
    required this.entityType,
    required this.conflictType,
    required this.localVersion,
    required this.remoteVersion,
    required this.resolvedVersion,
    required this.timestamp,
  });
}

/// Conflict types
enum ConflictType {
  merge,
  overwrite,
  skip,
}

/// Sync statistics
class SyncStats {
  final DateTime? lastSyncTime;
  final bool isOnline;
  final bool isSyncing;
  final int pendingOperationsCount;
  final Duration syncInterval;

  SyncStats({
    required this.lastSyncTime,
    required this.isOnline,
    required this.isSyncing,
    required this.pendingOperationsCount,
    required this.syncInterval,
  });
}

/// Import required enums and classes from other modules
enum EntityType { cycle, dailyLog, symptom }
enum DataChangeType { created, updated, deleted }

class DataChange {
  final DataChangeType type;
  final EntityType entityType;
  final String entityId;
  final DateTime timestamp;

  DataChange({
    required this.type,
    required this.entityType,
    required this.entityId,
    required this.timestamp,
  });
}
