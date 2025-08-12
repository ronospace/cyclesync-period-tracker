import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../data/repositories/health_data_repository.dart';
import '../data/providers/data_change_notifier.dart';
import '../data/sync/data_sync_manager.dart';
import '../models/cycle_models.dart';
import '../models/daily_log_models.dart';
import '../services/firebase_service.dart';

/// Enterprise data provider that bridges the data layer with UI components
/// Manages state, handles loading states, and provides error handling
class EnterpriseDataProvider extends ChangeNotifier {
  static EnterpriseDataProvider? _instance;
  static EnterpriseDataProvider get instance => _instance ??= EnterpriseDataProvider._();

  EnterpriseDataProvider._() {
    _initialize();
  }

  final HealthDataRepository _repository = HealthDataRepository.instance;
  final DataChangeNotifier _changeNotifier = DataChangeNotifier.instance;

  // Loading states
  bool _isInitializing = false;
  bool _isLoadingCycles = false;
  bool _isLoadingDailyLogs = false;
  bool _isSaving = false;
  bool _isSyncing = false;

  // Data states
  List<CycleData> _cycles = [];
  List<DailyLogEntry> _dailyLogs = [];
  CycleAnalytics? _analytics;
  String? _error;
  DateTime? _lastSyncTime;

  // Getters
  bool get isInitializing => _isInitializing;
  bool get isLoadingCycles => _isLoadingCycles;
  bool get isLoadingDailyLogs => _isLoadingDailyLogs;
  bool get isSaving => _isSaving;
  bool get isSyncing => _isSyncing;
  bool get isLoading => _isLoadingCycles || _isLoadingDailyLogs || _isSaving || _isSyncing;

  List<CycleData> get cycles => _cycles;
  List<DailyLogEntry> get dailyLogs => _dailyLogs;
  CycleAnalytics? get analytics => _analytics;
  String? get error => _error;
  DateTime? get lastSyncTime => _lastSyncTime;

  // Computed properties
  CycleData? get currentCycle => _cycles.isNotEmpty ? _cycles.first : null;
  bool get hasCycles => _cycles.isNotEmpty;
  bool get hasDailyLogs => _dailyLogs.isNotEmpty;

  /// Initialize the enterprise data provider
  Future<void> _initialize() async {
    if (_isInitializing) return;

    _isInitializing = true;
    notifyListeners();

    try {
      debugPrint('🚀 Initializing EnterpriseDataProvider...');

      // Initialize the repository
      await _repository.initialize();

      // Set up real-time listeners
      _setupDataStreams();

      // Load initial data
      await _loadInitialData();

      debugPrint('✅ EnterpriseDataProvider initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize EnterpriseDataProvider: $e');
      _setError('Failed to initialize data provider: $e');
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  /// Set up real-time data streams
  void _setupDataStreams() {
    // Listen to cycles changes
    _repository.cyclesStream.listen(
      (cycles) {
        _cycles = cycles;
        _clearError();
        notifyListeners();
        debugPrint('📊 Received ${cycles.length} cycles from stream');
      },
      onError: (error) {
        debugPrint('❌ Cycles stream error: $error');
        _setError('Cycles stream error: $error');
      },
    );

    // Listen to daily logs changes
    _repository.dailyLogsStream.listen(
      (logs) {
        _dailyLogs = logs;
        _clearError();
        notifyListeners();
        debugPrint('📝 Received ${logs.length} daily logs from stream');
      },
      onError: (error) {
        debugPrint('❌ Daily logs stream error: $error');
        _setError('Daily logs stream error: $error');
      },
    );

    // Listen to sync status changes
    _repository.syncStatusStream.listen(
      (status) {
        _isSyncing = status.state == SyncState.syncing;
        if (status.state == SyncState.success || status.state == SyncState.error) {
          _lastSyncTime = status.timestamp;
        }
        if (status.state == SyncState.error) {
          _setError('Sync error: ${status.message}');
        } else {
          _clearError();
        }
        notifyListeners();
        debugPrint('🔄 Sync status update: ${status.state} - ${status.message}');
      },
      onError: (error) {
        debugPrint('❌ Sync status stream error: $error');
      },
    );

    // Listen to general data changes
    _changeNotifier.dataChangeStream.listen(
      (change) {
        debugPrint('📡 Data change detected: ${change.type} - ${change.entityType}');
        
        // Refresh analytics when data changes
        if (change.entityType == EntityType.cycle) {
          _refreshAnalytics();
        }
      },
      onError: (error) {
        debugPrint('❌ Data change stream error: $error');
      },
    );
  }

  /// Load initial data from repository
  Future<void> _loadInitialData() async {
    try {
      // Load cycles and daily logs in parallel
      await Future.wait([
        _loadCycles(),
        _loadDailyLogs(),
      ]);

      // Generate initial analytics
      await _refreshAnalytics();
    } catch (e) {
      debugPrint('❌ Error loading initial data: $e');
      _setError('Failed to load initial data: $e');
    }
  }

  /// Load cycles from repository
  Future<void> loadCycles({
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  }) async {
    await _loadCycles(
      limit: limit,
      startDate: startDate,
      endDate: endDate,
      forceRefresh: forceRefresh,
    );
  }

  Future<void> _loadCycles({
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  }) async {
    if (_isLoadingCycles) return;

    _isLoadingCycles = true;
    _clearError();
    notifyListeners();

    try {
      final cycles = await _repository.getCycles(
        limit: limit,
        startDate: startDate,
        endDate: endDate,
        forceRefresh: forceRefresh,
      );

      _cycles = cycles;
      debugPrint('📊 Loaded ${cycles.length} cycles');
    } catch (e) {
      debugPrint('❌ Error loading cycles: $e');
      _setError('Failed to load cycles: $e');
    } finally {
      _isLoadingCycles = false;
      notifyListeners();
    }
  }

  /// Load daily logs from repository
  Future<void> loadDailyLogs({
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  }) async {
    await _loadDailyLogs(
      startDate: startDate,
      endDate: endDate,
      forceRefresh: forceRefresh,
    );
  }

  Future<void> _loadDailyLogs({
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  }) async {
    if (_isLoadingDailyLogs) return;

    _isLoadingDailyLogs = true;
    _clearError();
    notifyListeners();

    try {
      final logs = await _repository.getDailyLogs(
        startDate: startDate,
        endDate: endDate,
        forceRefresh: forceRefresh,
      );

      _dailyLogs = logs;
      debugPrint('📝 Loaded ${logs.length} daily logs');
    } catch (e) {
      debugPrint('❌ Error loading daily logs: $e');
      _setError('Failed to load daily logs: $e');
    } finally {
      _isLoadingDailyLogs = false;
      notifyListeners();
    }
  }

  /// Save cycle data
  Future<bool> saveCycle(CycleData cycle) async {
    if (_isSaving) return false;

    _isSaving = true;
    _clearError();
    notifyListeners();

    try {
      await _repository.saveCycle(cycle);
      debugPrint('✅ Cycle saved successfully: ${cycle.id}');
      
      // Refresh analytics
      await _refreshAnalytics();
      
      return true;
    } catch (e) {
      debugPrint('❌ Error saving cycle: $e');
      _setError('Failed to save cycle: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Delete cycle
  Future<bool> deleteCycle(String cycleId) async {
    if (_isSaving) return false;

    _isSaving = true;
    _clearError();
    notifyListeners();

    try {
      await _repository.deleteCycle(cycleId);
      debugPrint('✅ Cycle deleted successfully: $cycleId');
      
      // Refresh analytics
      await _refreshAnalytics();
      
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting cycle: $e');
      _setError('Failed to delete cycle: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Search cycles with filters
  Future<List<CycleData>> searchCycles({
    String? query,
    List<String>? symptoms,
    FlowIntensity? flowIntensity,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final results = await _repository.searchCycles(
        query: query,
        symptoms: symptoms,
        flowIntensity: flowIntensity,
        startDate: startDate,
        endDate: endDate,
      );
      
      debugPrint('🔍 Search returned ${results.length} cycles');
      return results;
    } catch (e) {
      debugPrint('❌ Error searching cycles: $e');
      _setError('Search failed: $e');
      return [];
    }
  }

  /// Refresh analytics data
  Future<void> _refreshAnalytics() async {
    try {
      final analytics = await _repository.getAnalytics();
      _analytics = analytics;
      debugPrint('📈 Analytics refreshed');
      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ Error refreshing analytics: $e');
      // Don't set error for analytics failure as it's non-critical
    }
  }

  /// Force refresh all data
  Future<void> forceRefresh() async {
    try {
      debugPrint('🔄 Force refreshing all data...');
      
      await _repository.forceRefresh();
      
      // Reload data
      await _loadInitialData();
      
      debugPrint('✅ Force refresh completed');
    } catch (e) {
      debugPrint('❌ Error during force refresh: $e');
      _setError('Failed to refresh data: $e');
    }
  }

  /// Sync with HealthKit
  Future<void> syncWithHealthKit() async {
    if (_isSyncing) return;

    _isSyncing = true;
    _clearError();
    notifyListeners();

    try {
      final result = await _repository.syncWithHealthKit();
      
      if (result.success) {
        debugPrint('✅ HealthKit sync successful: ${result.summary}');
        
        // Refresh data after successful sync
        await _loadInitialData();
      } else {
        throw Exception(result.summary);
      }
    } catch (e) {
      debugPrint('❌ HealthKit sync failed: $e');
      _setError('HealthKit sync failed: $e');
    } finally {
      _isSyncing = false;
      _lastSyncTime = DateTime.now();
      notifyListeners();
    }
  }

  /// Get cycle by ID
  CycleData? getCycleById(String cycleId) {
    try {
      return _cycles.firstWhere((cycle) => cycle.id == cycleId);
    } catch (e) {
      return null;
    }
  }

  /// Get cycles for date range
  List<CycleData> getCyclesForDateRange(DateTime start, DateTime end) {
    return _cycles.where((cycle) {
      return cycle.startDate.isAfter(start.subtract(const Duration(days: 1))) &&
             cycle.startDate.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  /// Get current cycle phase
  CyclePhase? getCurrentCyclePhase() {
    if (currentCycle == null) return null;
    
    final now = DateTime.now();
    final cycle = currentCycle!;
    final daysSinceStart = now.difference(cycle.startDate).inDays;
    
    if (cycle.endDate != null && now.isAfter(cycle.endDate!)) {
      return null; // Cycle has ended
    }
    
    // Estimate phases based on typical 28-day cycle
    if (daysSinceStart <= 5) {
      return CyclePhase.menstrual;
    } else if (daysSinceStart <= 9) {
      return CyclePhase.follicular;
    } else if (daysSinceStart <= 16) {
      return CyclePhase.ovulation;
    } else {
      return CyclePhase.luteal;
    }
  }

  /// Get repository statistics
  RepositoryStats getRepositoryStats() {
    return _repository.getStats();
  }

  /// Clear cache
  Future<void> clearCache() async {
    try {
      await _repository.clearCache();
      
      // Reload data
      await _loadInitialData();
      
      debugPrint('🗑️ Cache cleared and data reloaded');
    } catch (e) {
      debugPrint('❌ Error clearing cache: $e');
      _setError('Failed to clear cache: $e');
    }
  }

  /// Set error state
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error state
  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  /// Clear error manually
  void clearError() {
    _clearError();
  }

  @override
  void dispose() {
    // Clean up resources
    super.dispose();
  }
}

/// Cycle phases for cycle tracking
enum CyclePhase {
  menstrual,
  follicular,
  ovulation,
  luteal,
}

/// Extension for cycle phase display
extension CyclePhaseExtension on CyclePhase {
  String get displayName {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Menstrual';
      case CyclePhase.follicular:
        return 'Follicular';
      case CyclePhase.ovulation:
        return 'Ovulation';
      case CyclePhase.luteal:
        return 'Luteal';
    }
  }

  String get description {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Days 1-5: Menstruation period';
      case CyclePhase.follicular:
        return 'Days 6-9: Follicle development';
      case CyclePhase.ovulation:
        return 'Days 10-16: Ovulation window';
      case CyclePhase.luteal:
        return 'Days 17-28: Post-ovulation';
    }
  }
}
