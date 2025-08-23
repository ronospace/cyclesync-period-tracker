import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../models/cycle_models.dart';
import '../../services/firebase_service.dart';
import '../../services/advanced_health_kit_service.dart';
import '../cache/data_cache_manager.dart';
import '../providers/data_change_notifier.dart';
import 'data_sync_manager.dart';

/// Backup data synchronization manager
/// Simplified version for backup functionality
class DataSyncManagerBackup {
  static DataSyncManagerBackup? _instance;
  static DataSyncManagerBackup get instance =>
      _instance ??= DataSyncManagerBackup._();

  DataSyncManagerBackup._();

  final DataCacheManager _cacheManager = DataCacheManager.instance;
  final DataChangeNotifier _changeNotifier = DataChangeNotifier.instance;
  final AdvancedHealthKitService _healthKit = AdvancedHealthKitService.instance;

  // Sync state tracking
  bool _isOnline = true;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  Timer? _syncTimer;

  // Sync configuration
  static const Duration _syncInterval = Duration(minutes: 15);

  bool _isInitialized = false;

  /// Initialize the sync manager
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🔄 Initializing DataSyncManager...');

      // Initialize connectivity monitoring
      await _initializeConnectivityMonitoring();

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
    _isOnline =
        connectivityResult.isNotEmpty &&
        !connectivityResult.contains(ConnectivityResult.none);

    // Listen to connectivity changes
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final wasOnline = _isOnline;
      _isOnline =
          results.isNotEmpty && !results.contains(ConnectivityResult.none);

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

      // Skip pending operations for now since they need additional classes

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
      final resolvedCycles = await _resolveCycleConflicts(
        localCycles,
        remoteCycles,
      );

      // Update cache with resolved data
      await _cacheManager.cacheCycles(resolvedCycles);

      // Notify of changes
      _changeNotifier.notifyDataChange(
        DataChange(
          type: DataChangeType.updated,
          entityType: EntityType.cycle,
          entityId: 'bulk_sync',
          timestamp: DateTime.now(),
        ),
      );

      return SyncResult(
        success: true,
        hasChanges: localCycles.length != resolvedCycles.length,
        syncedCount: resolvedCycles.length,
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

      // For now, return empty result since daily logs sync is not implemented
      // This will be implemented when daily logs Firebase integration is ready

      return SyncResult(
        success: true,
        hasChanges: false,
        syncedCount: localLogs.length,
      );
    } catch (e) {
      debugPrint('❌ Error syncing daily logs: $e');
      return SyncResult.error('Daily logs sync failed: $e');
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
    int conflictCount = 0;

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
          conflictCount++;
        }
      }
    }

    // Log conflicts if any
    if (conflictCount > 0) {
      debugPrint('⚠️ Resolved $conflictCount cycle conflicts');
    }

    return resolved;
  }

  /// Resolve individual cycle conflict
  Future<CycleData> _resolveCycleConflict(
    CycleData local,
    CycleData remote,
  ) async {
    // Conflict resolution strategy: latest modified wins, but merge non-conflicting fields

    if (local.updatedAt.isAfter(remote.updatedAt)) {
      // Local is newer - merge in remote data that doesn't conflict
      return _mergeCycles(local, remote, preferLocal: true);
    } else {
      // Remote is newer - merge in local data that doesn't conflict
      return _mergeCycles(remote, local, preferLocal: false);
    }
  }

  /// Merge two cycles intelligently
  CycleData _mergeCycles(
    CycleData primary,
    CycleData secondary, {
    required bool preferLocal,
  }) {
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

    // Merge wellbeing data (prefer primary, but use secondary if primary has defaults)
    final mergedWellbeing = WellbeingData(
      mood: primary.wellbeing.mood != 3.0
          ? primary.wellbeing.mood
          : secondary.wellbeing.mood,
      energy: primary.wellbeing.energy != 3.0
          ? primary.wellbeing.energy
          : secondary.wellbeing.energy,
      pain: primary.wellbeing.pain != 1.0
          ? primary.wellbeing.pain
          : secondary.wellbeing.pain,
    );

    // Create merged cycle using the actual CycleData constructor
    return CycleData(
      id: primary.id,
      startDate: primary.startDate,
      endDate: primary.endDate ?? secondary.endDate,
      flowIntensity: primary.flowIntensity,
      wellbeing: mergedWellbeing,
      symptoms: combinedSymptoms,
      notes: mergedNotes,
      createdAt: primary.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Sync with HealthKit specifically
  Future<HealthKitSyncResult> syncWithHealthKit() async {
    return await _syncHealthKitData();
  }

  /// Get basic sync information
  Map<String, dynamic> getSyncInfo() {
    return {
      'lastSyncTime': _lastSyncTime?.toIso8601String(),
      'isOnline': _isOnline,
      'isSyncing': _isSyncing,
      'syncInterval': _syncInterval.inMinutes,
    };
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
  }
}

/// Additional data conflict types specific to backup manager
enum BackupConflictType { merge, overwrite, skip }

/// Additional helper classes for backup sync manager
class BackupSyncResult {
  final String entityType;
  final int localCount;
  final int remoteCount;
  final int resolvedCount;
  final bool hasChanges;
  final List<String> conflicts;

  BackupSyncResult({
    required this.entityType,
    required this.localCount,
    required this.remoteCount,
    required this.resolvedCount,
    required this.hasChanges,
    required this.conflicts,
  });
}
