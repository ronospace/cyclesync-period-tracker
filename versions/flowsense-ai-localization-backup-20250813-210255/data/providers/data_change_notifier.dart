import 'dart:async';
import 'package:flutter/foundation.dart';

/// Central data change notification system
/// Provides real-time updates to UI components when data changes
class DataChangeNotifier extends ChangeNotifier {
  static DataChangeNotifier? _instance;
  static DataChangeNotifier get instance => _instance ??= DataChangeNotifier._();

  DataChangeNotifier._();

  // Stream controllers for different data types
  final StreamController<DataChange> _dataChangeController = 
      StreamController<DataChange>.broadcast();
  final StreamController<CycleDataChange> _cycleChangeController = 
      StreamController<CycleDataChange>.broadcast();
  final StreamController<DailyLogChange> _dailyLogChangeController = 
      StreamController<DailyLogChange>.broadcast();
  final StreamController<SyncStatusChange> _syncStatusController = 
      StreamController<SyncStatusChange>.broadcast();

  // Public streams
  Stream<DataChange> get dataChangeStream => _dataChangeController.stream;
  Stream<CycleDataChange> get cycleChangeStream => _cycleChangeController.stream;
  Stream<DailyLogChange> get dailyLogChangeStream => _dailyLogChangeController.stream;
  Stream<SyncStatusChange> get syncStatusStream => _syncStatusController.stream;

  // Change tracking
  final List<DataChange> _recentChanges = [];
  static const int _maxRecentChanges = 100;

  /// Notify of a general data change
  void notifyDataChange(DataChange change) {
    _addToRecentChanges(change);
    _dataChangeController.add(change);
    
    // Route to specific change streams
    switch (change.entityType) {
      case EntityType.cycle:
        _cycleChangeController.add(CycleDataChange.fromDataChange(change));
        break;
      case EntityType.dailyLog:
        _dailyLogChangeController.add(DailyLogChange.fromDataChange(change));
        break;
      default:
        break;
    }
    
    notifyListeners();
    debugPrint('📡 Data change notification: ${change.type} - ${change.entityType} - ${change.entityId}');
  }

  /// Notify of cycle-specific changes
  void notifyCycleChange(CycleDataChange change) {
    _addToRecentChanges(change.toDataChange());
    _cycleChangeController.add(change);
    _dataChangeController.add(change.toDataChange());
    
    notifyListeners();
    debugPrint('🔄 Cycle change notification: ${change.type} - ${change.cycleId}');
  }

  /// Notify of daily log changes
  void notifyDailyLogChange(DailyLogChange change) {
    _addToRecentChanges(change.toDataChange());
    _dailyLogChangeController.add(change);
    _dataChangeController.add(change.toDataChange());
    
    notifyListeners();
    debugPrint('📝 Daily log change notification: ${change.type} - ${change.logId}');
  }

  /// Notify of sync status changes
  void notifySyncStatusChange(SyncStatusChange change) {
    _syncStatusController.add(change);
    notifyListeners();
    debugPrint('🔄 Sync status change: ${change.status} - ${change.message}');
  }

  /// Add change to recent changes list
  void _addToRecentChanges(DataChange change) {
    _recentChanges.insert(0, change);
    
    // Maintain max size
    if (_recentChanges.length > _maxRecentChanges) {
      _recentChanges.removeRange(_maxRecentChanges, _recentChanges.length);
    }
  }

  /// Get recent changes for debugging/audit
  List<DataChange> getRecentChanges({int? limit}) {
    final limitValue = limit ?? _recentChanges.length;
    return _recentChanges.take(limitValue).toList();
  }

  /// Clear recent changes history
  void clearRecentChanges() {
    _recentChanges.clear();
  }

  /// Get change statistics
  ChangeStatistics getChangeStatistics() {
    final now = DateTime.now();
    final last24Hours = _recentChanges
        .where((change) => now.difference(change.timestamp).inHours < 24)
        .toList();
    
    final lastHour = _recentChanges
        .where((change) => now.difference(change.timestamp).inMinutes < 60)
        .toList();

    return ChangeStatistics(
      totalChanges: _recentChanges.length,
      changesLast24Hours: last24Hours.length,
      changesLastHour: lastHour.length,
      changesByType: _groupChangesByType(_recentChanges),
      changesByEntity: _groupChangesByEntity(_recentChanges),
    );
  }

  /// Group changes by type
  Map<DataChangeType, int> _groupChangesByType(List<DataChange> changes) {
    final Map<DataChangeType, int> grouped = {};
    for (final change in changes) {
      grouped[change.type] = (grouped[change.type] ?? 0) + 1;
    }
    return grouped;
  }

  /// Group changes by entity type
  Map<EntityType, int> _groupChangesByEntity(List<DataChange> changes) {
    final Map<EntityType, int> grouped = {};
    for (final change in changes) {
      grouped[change.entityType] = (grouped[change.entityType] ?? 0) + 1;
    }
    return grouped;
  }

  @override
  void dispose() {
    _dataChangeController.close();
    _cycleChangeController.close();
    _dailyLogChangeController.close();
    _syncStatusController.close();
    super.dispose();
  }
}

/// Base data change class
class DataChange {
  final DataChangeType type;
  final EntityType entityType;
  final String entityId;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  DataChange({
    required this.type,
    required this.entityType,
    required this.entityId,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'type': type.toString(),
    'entityType': entityType.toString(),
    'entityId': entityId,
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata,
  };

  factory DataChange.fromJson(Map<String, dynamic> json) {
    return DataChange(
      type: DataChangeType.values.firstWhere(
        (e) => e.toString() == json['type']
      ),
      entityType: EntityType.values.firstWhere(
        (e) => e.toString() == json['entityType']
      ),
      entityId: json['entityId'],
      timestamp: DateTime.parse(json['timestamp']),
      metadata: json['metadata'],
    );
  }
}

/// Cycle-specific data change
class CycleDataChange {
  final DataChangeType type;
  final String cycleId;
  final DateTime timestamp;
  final Map<String, dynamic>? cycleData;
  final List<String>? affectedFields;

  CycleDataChange({
    required this.type,
    required this.cycleId,
    required this.timestamp,
    this.cycleData,
    this.affectedFields,
  });

  factory CycleDataChange.fromDataChange(DataChange change) {
    return CycleDataChange(
      type: change.type,
      cycleId: change.entityId,
      timestamp: change.timestamp,
      cycleData: change.metadata,
    );
  }

  DataChange toDataChange() {
    return DataChange(
      type: type,
      entityType: EntityType.cycle,
      entityId: cycleId,
      timestamp: timestamp,
      metadata: cycleData,
    );
  }

  factory CycleDataChange.created(String cycleId, Map<String, dynamic> cycleData) {
    return CycleDataChange(
      type: DataChangeType.created,
      cycleId: cycleId,
      timestamp: DateTime.now(),
      cycleData: cycleData,
    );
  }

  factory CycleDataChange.updated(
    String cycleId, 
    Map<String, dynamic> cycleData, 
    List<String> affectedFields
  ) {
    return CycleDataChange(
      type: DataChangeType.updated,
      cycleId: cycleId,
      timestamp: DateTime.now(),
      cycleData: cycleData,
      affectedFields: affectedFields,
    );
  }

  factory CycleDataChange.deleted(String cycleId) {
    return CycleDataChange(
      type: DataChangeType.deleted,
      cycleId: cycleId,
      timestamp: DateTime.now(),
    );
  }
}

/// Daily log specific data change
class DailyLogChange {
  final DataChangeType type;
  final String logId;
  final DateTime timestamp;
  final DateTime logDate;
  final Map<String, dynamic>? logData;

  DailyLogChange({
    required this.type,
    required this.logId,
    required this.timestamp,
    required this.logDate,
    this.logData,
  });

  factory DailyLogChange.fromDataChange(DataChange change) {
    final logDate = change.metadata?['date'] != null 
        ? DateTime.parse(change.metadata!['date']) 
        : DateTime.now();
        
    return DailyLogChange(
      type: change.type,
      logId: change.entityId,
      timestamp: change.timestamp,
      logDate: logDate,
      logData: change.metadata,
    );
  }

  DataChange toDataChange() {
    return DataChange(
      type: type,
      entityType: EntityType.dailyLog,
      entityId: logId,
      timestamp: timestamp,
      metadata: logData,
    );
  }

  factory DailyLogChange.created(String logId, DateTime logDate, Map<String, dynamic> logData) {
    return DailyLogChange(
      type: DataChangeType.created,
      logId: logId,
      timestamp: DateTime.now(),
      logDate: logDate,
      logData: logData,
    );
  }

  factory DailyLogChange.updated(String logId, DateTime logDate, Map<String, dynamic> logData) {
    return DailyLogChange(
      type: DataChangeType.updated,
      logId: logId,
      timestamp: DateTime.now(),
      logDate: logDate,
      logData: logData,
    );
  }

  factory DailyLogChange.deleted(String logId, DateTime logDate) {
    return DailyLogChange(
      type: DataChangeType.deleted,
      logId: logId,
      timestamp: DateTime.now(),
      logDate: logDate,
    );
  }
}

/// Sync status change notification
class SyncStatusChange {
  final SyncStatus status;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? details;

  SyncStatusChange({
    required this.status,
    required this.message,
    required this.timestamp,
    this.details,
  });

  factory SyncStatusChange.started() {
    return SyncStatusChange(
      status: SyncStatus.syncing,
      message: 'Synchronization started',
      timestamp: DateTime.now(),
    );
  }

  factory SyncStatusChange.completed(String message, {Map<String, dynamic>? details}) {
    return SyncStatusChange(
      status: SyncStatus.completed,
      message: message,
      timestamp: DateTime.now(),
      details: details,
    );
  }

  factory SyncStatusChange.failed(String message, {Map<String, dynamic>? details}) {
    return SyncStatusChange(
      status: SyncStatus.failed,
      message: message,
      timestamp: DateTime.now(),
      details: details,
    );
  }

  factory SyncStatusChange.offline() {
    return SyncStatusChange(
      status: SyncStatus.offline,
      message: 'Device is offline',
      timestamp: DateTime.now(),
    );
  }

  factory SyncStatusChange.online() {
    return SyncStatusChange(
      status: SyncStatus.online,
      message: 'Device is online',
      timestamp: DateTime.now(),
    );
  }
}

/// Change statistics
class ChangeStatistics {
  final int totalChanges;
  final int changesLast24Hours;
  final int changesLastHour;
  final Map<DataChangeType, int> changesByType;
  final Map<EntityType, int> changesByEntity;

  ChangeStatistics({
    required this.totalChanges,
    required this.changesLast24Hours,
    required this.changesLastHour,
    required this.changesByType,
    required this.changesByEntity,
  });

  Map<String, dynamic> toJson() => {
    'totalChanges': totalChanges,
    'changesLast24Hours': changesLast24Hours,
    'changesLastHour': changesLastHour,
    'changesByType': changesByType.map((k, v) => MapEntry(k.toString(), v)),
    'changesByEntity': changesByEntity.map((k, v) => MapEntry(k.toString(), v)),
  };
}

/// Data change types
enum DataChangeType {
  created,
  updated,
  deleted,
  synced,
  conflict,
}

/// Entity types
enum EntityType {
  cycle,
  dailyLog,
  symptom,
  analytics,
  user,
}

/// Sync status
enum SyncStatus {
  idle,
  syncing,
  completed,
  failed,
  offline,
  online,
}
