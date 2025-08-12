import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../models/cycle_models.dart';
import '../../models/daily_log_models.dart';
import '../../services/firebase_service.dart';
import '../../services/advanced_health_kit_service.dart';
import '../cache/data_cache_manager.dart';
import '../sync/data_sync_manager.dart';
import '../providers/data_change_notifier.dart';

/// Enterprise-level data repository for health data management
/// Implements advanced caching, synchronization, and real-time updates
class HealthDataRepository extends ChangeNotifier {
  static HealthDataRepository? _instance;
  static HealthDataRepository get instance => _instance ??= HealthDataRepository._();

  HealthDataRepository._();

  final DataCacheManager _cacheManager = DataCacheManager.instance;
  final DataSyncManager _syncManager = DataSyncManager.instance;
  final DataChangeNotifier _changeNotifier = DataChangeNotifier.instance;
  final AdvancedHealthKitService _healthKit = AdvancedHealthKitService.instance;

  // Data streams for real-time updates
  final StreamController<List<CycleData>> _cyclesStreamController = 
      StreamController<List<CycleData>>.broadcast();
  final StreamController<List<DailyLogEntry>> _dailyLogsStreamController = 
      StreamController<List<DailyLogEntry>>.broadcast();
  final StreamController<DataSyncStatus> _syncStatusStreamController = 
      StreamController<DataSyncStatus>.broadcast();

  // Public streams
  Stream<List<CycleData>> get cyclesStream => _cyclesStreamController.stream;
  Stream<List<DailyLogEntry>> get dailyLogsStream => _dailyLogsStreamController.stream;
  Stream<DataSyncStatus> get syncStatusStream => _syncStatusStreamController.stream;

  // Internal data stores
  List<CycleData>? _cachedCycles;
  List<DailyLogEntry>? _cachedDailyLogs;
  DateTime? _lastSyncTime;
  bool _isInitialized = false;

  /// Initialize the repository with background sync
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🏗️ Initializing HealthDataRepository...');
      
      // Initialize cache manager
      await _cacheManager.initialize();
      
      // Initialize sync manager
      await _syncManager.initialize();
      
      // Load cached data
      await _loadCachedData();
      
      // Set up real-time listeners
      _setupRealtimeListeners();
      
      // Start background sync
      _startBackgroundSync();
      
      _isInitialized = true;
      debugPrint('✅ HealthDataRepository initialized successfully');
      
    } catch (e) {
      debugPrint('❌ Failed to initialize HealthDataRepository: $e');
      rethrow;
    }
  }

  /// Load cached data on startup
  Future<void> _loadCachedData() async {
    try {
      // Load cycles from cache
      final cachedCycles = await _cacheManager.getCachedCycles();
      if (cachedCycles.isNotEmpty) {
        _cachedCycles = cachedCycles;
        _cyclesStreamController.add(cachedCycles);
      }

      // Load daily logs from cache
      final cachedLogs = await _cacheManager.getCachedDailyLogs();
      if (cachedLogs.isNotEmpty) {
        _cachedDailyLogs = cachedLogs;
        _dailyLogsStreamController.add(cachedLogs);
      }

      debugPrint('📦 Loaded cached data: ${cachedCycles.length} cycles, ${cachedLogs.length} logs');
    } catch (e) {
      debugPrint('⚠️ Error loading cached data: $e');
    }
  }

  /// Set up real-time data listeners
  void _setupRealtimeListeners() {
    // For now, we'll implement periodic refresh instead of real-time Firebase streams
    // This can be enhanced later with Firebase real-time listeners
    
    // Listen to cache changes
    _changeNotifier.dataChangeStream.listen(
      (change) => _handleDataChange(change),
      onError: (error) => debugPrint('❌ Data change stream error: $error'),
    );
  }

  /// Handle cycles data update
  void _handleCyclesUpdate(List<Map<String, dynamic>> rawCycles) {
    try {
      final cycles = rawCycles
          .map((raw) => CycleData.fromFirestore(raw))
          .toList();

      _cachedCycles = cycles;
      _cyclesStreamController.add(cycles);
      
      // Update cache
      _cacheManager.cacheCycles(cycles);
      
      debugPrint('🔄 Updated cycles data: ${cycles.length} cycles');
    } catch (e) {
      debugPrint('❌ Error handling cycles update: $e');
    }
  }

  /// Handle data change notifications
  void _handleDataChange(DataChange change) {
    debugPrint('📡 Data change detected: ${change.type} - ${change.entityType}');
    
    switch (change.type) {
      case DataChangeType.created:
      case DataChangeType.updated:
      case DataChangeType.deleted:
        _refreshData();
        break;
      case DataChangeType.synced:
      case DataChangeType.conflict:
        // These cases don't require data refresh
        break;
    }
  }

  /// Start background synchronization
  void _startBackgroundSync() {
    Timer.periodic(const Duration(minutes: 5), (_) {
      if (_isInitialized) {
        _performBackgroundSync();
      }
    });
  }

  /// Perform background data synchronization
  Future<void> _performBackgroundSync() async {
    try {
      final syncResult = await _syncManager.performSync();
      _syncStatusStreamController.add(syncResult);
      
      if (syncResult.hasChanges) {
        await _refreshData();
      }
      
      _lastSyncTime = DateTime.now();
    } catch (e) {
      debugPrint('⚠️ Background sync failed: $e');
      _syncStatusStreamController.add(DataSyncStatus.error(e.toString()));
    }
  }

  /// Refresh all data from sources
  Future<void> _refreshData() async {
    try {
      // Refresh cycles
      final cycles = await getCycles(forceRefresh: true);
      _cyclesStreamController.add(cycles);
      
      // Refresh daily logs
      final logs = await getDailyLogs(forceRefresh: true);
      _dailyLogsStreamController.add(logs);
      
    } catch (e) {
      debugPrint('❌ Error refreshing data: $e');
    }
  }

  /// Get cycles with intelligent caching
  Future<List<CycleData>> getCycles({
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache first
      if (!forceRefresh && _cachedCycles != null && _cachedCycles!.isNotEmpty) {
        var cycles = List<CycleData>.from(_cachedCycles!);
        
        // Apply filters
        if (startDate != null) {
          cycles = cycles.where((c) => c.startDate.isAfter(startDate.subtract(const Duration(days: 1)))).toList();
        }
        if (endDate != null) {
          cycles = cycles.where((c) => c.startDate.isBefore(endDate.add(const Duration(days: 1)))).toList();
        }
        if (limit != null) {
          cycles = cycles.take(limit).toList();
        }
        
        return cycles;
      }

      // Fetch from Firebase
      debugPrint('🔄 Fetching cycles from Firebase...');
      final rawCycles = await FirebaseService.getCycles(limit: limit ?? 100);
      final cycles = rawCycles
          .map((raw) => CycleData.fromFirestore(raw))
          .toList();

      // Update cache
      _cachedCycles = cycles;
      await _cacheManager.cacheCycles(cycles);
      
      debugPrint('✅ Fetched ${cycles.length} cycles');
      return cycles;
      
    } catch (e) {
      debugPrint('❌ Error getting cycles: $e');
      
      // Fallback to cache
      if (_cachedCycles != null) {
        debugPrint('📦 Falling back to cached cycles');
        return _cachedCycles!;
      }
      
      rethrow;
    }
  }

  /// Save cycle with optimistic updates
  Future<void> saveCycle(CycleData cycle) async {
    try {
      // Optimistic update
      if (_cachedCycles != null) {
        final updatedCycles = List<CycleData>.from(_cachedCycles!);
        final existingIndex = updatedCycles.indexWhere((c) => c.id == cycle.id);
        
        if (existingIndex != -1) {
          updatedCycles[existingIndex] = cycle;
        } else {
          updatedCycles.insert(0, cycle);
        }
        
        _cachedCycles = updatedCycles;
        _cyclesStreamController.add(updatedCycles);
      }

      // Save to Firebase
      await FirebaseService.saveCycleWithSymptoms(cycleData: cycle.toFirestore());
      
      // Update cache
      await _cacheManager.cacheCycles(_cachedCycles ?? []);
      
      // Notify change
      _changeNotifier.notifyDataChange(DataChange(
        type: DataChangeType.updated,
        entityType: EntityType.cycle,
        entityId: cycle.id,
        timestamp: DateTime.now(),
      ));
      
      debugPrint('✅ Cycle saved successfully: ${cycle.id}');
      
    } catch (e) {
      debugPrint('❌ Error saving cycle: $e');
      
      // Revert optimistic update
      await _refreshData();
      rethrow;
    }
  }

  /// Delete cycle with optimistic updates
  Future<void> deleteCycle(String cycleId) async {
    try {
      // Optimistic update
      if (_cachedCycles != null) {
        final updatedCycles = _cachedCycles!.where((c) => c.id != cycleId).toList();
        _cachedCycles = updatedCycles;
        _cyclesStreamController.add(updatedCycles);
      }

      // Delete from Firebase
      await FirebaseService.deleteCycle(cycleId: cycleId);
      
      // Update cache
      await _cacheManager.cacheCycles(_cachedCycles ?? []);
      
      // Notify change
      _changeNotifier.notifyDataChange(DataChange(
        type: DataChangeType.deleted,
        entityType: EntityType.cycle,
        entityId: cycleId,
        timestamp: DateTime.now(),
      ));
      
      debugPrint('✅ Cycle deleted successfully: $cycleId');
      
    } catch (e) {
      debugPrint('❌ Error deleting cycle: $e');
      
      // Revert optimistic update
      await _refreshData();
      rethrow;
    }
  }

  /// Get daily logs with caching
  Future<List<DailyLogEntry>> getDailyLogs({
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache first
      if (!forceRefresh && _cachedDailyLogs != null && _cachedDailyLogs!.isNotEmpty) {
        var logs = List<DailyLogEntry>.from(_cachedDailyLogs!);
        
        // Apply date filters
        if (startDate != null || endDate != null) {
          logs = logs.where((log) {
            if (startDate != null && log.date.isBefore(startDate)) return false;
            if (endDate != null && log.date.isAfter(endDate)) return false;
            return true;
          }).toList();
        }
        
        return logs;
      }

      // Fetch from Firebase (implement when available)
      // For now, return cached data or empty list
      return _cachedDailyLogs ?? [];
      
    } catch (e) {
      debugPrint('❌ Error getting daily logs: $e');
      return _cachedDailyLogs ?? [];
    }
  }

  /// Sync with HealthKit data
  Future<HealthKitSyncResult> syncWithHealthKit() async {
    try {
      debugPrint('🏥 Starting HealthKit synchronization...');
      
      final syncResult = await _syncManager.syncWithHealthKit();
      _syncStatusStreamController.add(DataSyncStatus.success(syncResult.summary));
      
      if (syncResult.hasNewData) {
        await _refreshData();
      }
      
      return syncResult;
      
    } catch (e) {
      debugPrint('❌ HealthKit sync failed: $e');
      final errorResult = HealthKitSyncResult.error(e.toString());
      _syncStatusStreamController.add(DataSyncStatus.error(e.toString()));
      return errorResult;
    }
  }

  /// Get analytics data
  Future<CycleAnalytics> getAnalytics({DateTime? startDate, DateTime? endDate}) async {
    try {
      final cycles = await getCycles(startDate: startDate, endDate: endDate);
      return CycleAnalytics.fromCycles(cycles);
    } catch (e) {
      debugPrint('❌ Error generating analytics: $e');
      rethrow;
    }
  }

  /// Search cycles by criteria
  Future<List<CycleData>> searchCycles({
    String? query,
    List<String>? symptoms,
    FlowIntensity? flowIntensity,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var cycles = await getCycles();
      
      // Apply filters
      if (query != null && query.isNotEmpty) {
        cycles = cycles.where((c) => 
          c.notes.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
      
      if (symptoms != null && symptoms.isNotEmpty) {
        cycles = cycles.where((c) => 
          symptoms.any((symptom) => c.symptoms.any((s) => s.name == symptom))
        ).toList();
      }
      
      if (flowIntensity != null) {
        cycles = cycles.where((c) => c.flowIntensity == flowIntensity).toList();
      }
      
      if (startDate != null) {
        cycles = cycles.where((c) => c.startDate.isAfter(startDate.subtract(const Duration(days: 1)))).toList();
      }
      
      if (endDate != null) {
        cycles = cycles.where((c) => c.startDate.isBefore(endDate.add(const Duration(days: 1)))).toList();
      }
      
      return cycles;
    } catch (e) {
      debugPrint('❌ Error searching cycles: $e');
      return [];
    }
  }

  /// Get data statistics
  RepositoryStats getStats() {
    return RepositoryStats(
      totalCycles: _cachedCycles?.length ?? 0,
      totalDailyLogs: _cachedDailyLogs?.length ?? 0,
      lastSyncTime: _lastSyncTime,
      cacheSize: _cacheManager.getCacheSize(),
      isOnline: _syncManager.isOnline,
    );
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    try {
      await _cacheManager.clearCache();
      _cachedCycles = null;
      _cachedDailyLogs = null;
      
      _cyclesStreamController.add([]);
      _dailyLogsStreamController.add([]);
      
      debugPrint('🗑️ Cache cleared successfully');
    } catch (e) {
      debugPrint('❌ Error clearing cache: $e');
      rethrow;
    }
  }

  /// Force data refresh from all sources
  Future<void> forceRefresh() async {
    try {
      debugPrint('🔄 Force refreshing all data...');
      
      await clearCache();
      await _refreshData();
      await _performBackgroundSync();
      
      debugPrint('✅ Force refresh completed');
    } catch (e) {
      debugPrint('❌ Error during force refresh: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _cyclesStreamController.close();
    _dailyLogsStreamController.close();
    _syncStatusStreamController.close();
    super.dispose();
  }
}

/// Repository statistics
class RepositoryStats {
  final int totalCycles;
  final int totalDailyLogs;
  final DateTime? lastSyncTime;
  final int cacheSize;
  final bool isOnline;

  RepositoryStats({
    required this.totalCycles,
    required this.totalDailyLogs,
    this.lastSyncTime,
    required this.cacheSize,
    required this.isOnline,
  });
}

