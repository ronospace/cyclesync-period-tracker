import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Cache levels for different types of data
enum CacheLevel {
  memory, // In-memory cache (fastest, limited)
  persistent, // Disk cache (fast, larger capacity)
  database, // SQLite cache (structured, queryable)
}

/// Cache expiry policies
enum CacheExpiryPolicy { never, session, hourly, daily, weekly, custom }

/// Cache entry metadata
class CacheEntry<T> {
  final String key;
  final T data;
  final DateTime createdAt;
  final DateTime expiresAt;
  final CacheLevel level;
  final int accessCount;
  final DateTime lastAccessed;
  final int size;

  const CacheEntry({
    required this.key,
    required this.data,
    required this.createdAt,
    required this.expiresAt,
    required this.level,
    this.accessCount = 0,
    required this.lastAccessed,
    this.size = 0,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  CacheEntry<T> copyWith({int? accessCount, DateTime? lastAccessed}) {
    return CacheEntry<T>(
      key: key,
      data: data,
      createdAt: createdAt,
      expiresAt: expiresAt,
      level: level,
      accessCount: accessCount ?? this.accessCount,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      size: size,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'data': jsonEncode(data),
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'level': level.name,
      'accessCount': accessCount,
      'lastAccessed': lastAccessed.toIso8601String(),
      'size': size,
    };
  }

  factory CacheEntry.fromMap(Map<String, dynamic> map) {
    return CacheEntry<T>(
      key: map['key'],
      data: jsonDecode(map['data']) as T,
      createdAt: DateTime.parse(map['createdAt']),
      expiresAt: DateTime.parse(map['expiresAt']),
      level: CacheLevel.values.firstWhere((l) => l.name == map['level']),
      accessCount: map['accessCount'] ?? 0,
      lastAccessed: DateTime.parse(map['lastAccessed']),
      size: map['size'] ?? 0,
    );
  }
}

/// Performance metrics for cache monitoring
class CacheMetrics {
  int hits = 0;
  int misses = 0;
  int evictions = 0;
  int totalSize = 0;
  int totalEntries = 0;
  double averageAccessTime = 0.0;

  double get hitRatio => hits + misses > 0 ? hits / (hits + misses) : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'hits': hits,
      'misses': misses,
      'evictions': evictions,
      'totalSize': totalSize,
      'totalEntries': totalEntries,
      'hitRatio': hitRatio,
      'averageAccessTime': averageAccessTime,
    };
  }
}

/// Advanced caching service with multi-level cache and performance optimization
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  // Cache storage layers
  final Map<String, CacheEntry> _memoryCache = {};
  SharedPreferences? _prefs;
  Database? _database;

  // Configuration
  static const int _maxMemorySize = 50 * 1024 * 1024; // 50MB
  static const int _maxMemoryEntries = 1000;
  static const int _maxDiskSize = 200 * 1024 * 1024; // 200MB

  // Performance tracking
  final CacheMetrics _metrics = CacheMetrics();
  final Connectivity _connectivity = Connectivity();

  // Timers for cleanup
  Timer? _cleanupTimer;
  Timer? _metricsTimer;

  bool _initialized = false;

  /// Initialize the cache service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize shared preferences
      _prefs = await SharedPreferences.getInstance();

      // Initialize SQLite database
      await _initializeDatabase();

      // Start periodic cleanup
      _startCleanupTimer();

      // Start metrics collection
      _startMetricsTimer();

      _initialized = true;
      debugPrint('✅ CacheService initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize CacheService: $e');
      rethrow;
    }
  }

  /// Initialize SQLite database for structured caching
  Future<void> _initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cache.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cache_entries (
            key TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            expiresAt TEXT NOT NULL,
            level TEXT NOT NULL,
            accessCount INTEGER DEFAULT 0,
            lastAccessed TEXT NOT NULL,
            size INTEGER DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE INDEX idx_expires_at ON cache_entries(expiresAt)
        ''');

        await db.execute('''
          CREATE INDEX idx_last_accessed ON cache_entries(lastAccessed)
        ''');
      },
    );
  }

  /// Store data in cache with automatic level selection
  Future<void> set<T>(
    String key,
    T data, {
    Duration? expiry,
    CacheExpiryPolicy policy = CacheExpiryPolicy.daily,
    CacheLevel? preferredLevel,
  }) async {
    if (!_initialized) await initialize();

    final now = DateTime.now();
    final expiresAt = _calculateExpiryDate(now, expiry, policy);
    final dataSize = _calculateSize(data);
    final level = preferredLevel ?? _selectOptimalLevel(dataSize);

    final entry = CacheEntry<T>(
      key: key,
      data: data,
      createdAt: now,
      expiresAt: expiresAt,
      level: level,
      lastAccessed: now,
      size: dataSize,
    );

    try {
      await _storeEntry(entry);
      debugPrint('🔄 Cached $key at level ${level.name} ($dataSize bytes)');
    } catch (e) {
      debugPrint('❌ Failed to cache $key: $e');
    }
  }

  /// Retrieve data from cache
  Future<T?> get<T>(String key) async {
    if (!_initialized) await initialize();

    final stopwatch = Stopwatch()..start();

    try {
      // Check memory cache first
      if (_memoryCache.containsKey(key)) {
        final entry = _memoryCache[key] as CacheEntry<T>?;
        if (entry != null && !entry.isExpired) {
          _updateAccessCount(entry);
          _metrics.hits++;
          stopwatch.stop();
          _metrics.averageAccessTime =
              (_metrics.averageAccessTime + stopwatch.elapsedMicroseconds) / 2;
          return entry.data;
        } else {
          _memoryCache.remove(key);
        }
      }

      // Check persistent cache
      final prefData = _prefs?.getString('cache_$key');
      if (prefData != null) {
        try {
          final entry = CacheEntry<T>.fromMap(jsonDecode(prefData));
          if (!entry.isExpired) {
            // Promote to memory cache if frequently accessed
            if (entry.accessCount > 5) {
              _memoryCache[key] = entry;
            }
            _updateAccessCount(entry);
            _metrics.hits++;
            stopwatch.stop();
            _metrics.averageAccessTime =
                (_metrics.averageAccessTime + stopwatch.elapsedMicroseconds) /
                2;
            return entry.data;
          } else {
            _prefs?.remove('cache_$key');
          }
        } catch (e) {
          debugPrint('Error parsing cached data for $key: $e');
        }
      }

      // Check database cache
      if (_database != null) {
        final result = await _database!.query(
          'cache_entries',
          where: 'key = ?',
          whereArgs: [key],
        );

        if (result.isNotEmpty) {
          try {
            final entry = CacheEntry<T>.fromMap(result.first);
            if (!entry.isExpired) {
              // Promote to higher level cache
              if (entry.accessCount > 10) {
                _memoryCache[key] = entry;
              } else if (entry.accessCount > 3) {
                _prefs?.setString('cache_$key', jsonEncode(entry.toMap()));
              }

              _updateAccessCount(entry);
              _metrics.hits++;
              stopwatch.stop();
              _metrics.averageAccessTime =
                  (_metrics.averageAccessTime + stopwatch.elapsedMicroseconds) /
                  2;
              return entry.data;
            } else {
              await _database!.delete(
                'cache_entries',
                where: 'key = ?',
                whereArgs: [key],
              );
            }
          } catch (e) {
            debugPrint('Error parsing database cached data for $key: $e');
          }
        }
      }

      _metrics.misses++;
      stopwatch.stop();
      _metrics.averageAccessTime =
          (_metrics.averageAccessTime + stopwatch.elapsedMicroseconds) / 2;
      return null;
    } catch (e) {
      debugPrint('❌ Error retrieving cached data for $key: $e');
      _metrics.misses++;
      return null;
    }
  }

  /// Remove specific key from cache
  Future<void> remove(String key) async {
    if (!_initialized) await initialize();

    // Remove from all cache levels
    _memoryCache.remove(key);
    _prefs?.remove('cache_$key');
    if (_database != null) {
      await _database!.delete(
        'cache_entries',
        where: 'key = ?',
        whereArgs: [key],
      );
    }
  }

  /// Clear cache by pattern
  Future<void> removePattern(String pattern) async {
    if (!_initialized) await initialize();

    final regex = RegExp(pattern);

    // Clear memory cache
    _memoryCache.removeWhere((key, value) => regex.hasMatch(key));

    // Clear shared preferences
    if (_prefs != null) {
      final keys = _prefs!.getKeys().where(
        (key) => key.startsWith('cache_') && regex.hasMatch(key.substring(6)),
      );
      for (final key in keys) {
        _prefs!.remove(key);
      }
    }

    // Clear database
    if (_database != null) {
      final result = await _database!.query('cache_entries', columns: ['key']);
      final keysToDelete = result
          .where((row) => regex.hasMatch(row['key'] as String))
          .map((row) => row['key'] as String)
          .toList();

      for (final key in keysToDelete) {
        await _database!.delete(
          'cache_entries',
          where: 'key = ?',
          whereArgs: [key],
        );
      }
    }
  }

  /// Clear entire cache
  Future<void> clear() async {
    if (!_initialized) await initialize();

    _memoryCache.clear();

    if (_prefs != null) {
      final cacheKeys = _prefs!.getKeys().where(
        (key) => key.startsWith('cache_'),
      );
      for (final key in cacheKeys) {
        _prefs!.remove(key);
      }
    }

    if (_database != null) {
      await _database!.delete('cache_entries');
    }

    _metrics.evictions += _metrics.totalEntries;
    _metrics.totalEntries = 0;
    _metrics.totalSize = 0;
  }

  /// Get cache statistics
  CacheMetrics getMetrics() {
    _metrics.totalEntries = _memoryCache.length;
    _metrics.totalSize = _memoryCache.values.fold(
      0,
      (sum, entry) => sum + entry.size,
    );
    return _metrics;
  }

  /// Check if data is cached and fresh
  Future<bool> has(String key) async {
    final data = await get<dynamic>(key);
    return data != null;
  }

  /// Get cached data or compute if missing
  Future<T> getOrSet<T>(
    String key,
    Future<T> Function() compute, {
    Duration? expiry,
    CacheExpiryPolicy policy = CacheExpiryPolicy.daily,
    CacheLevel? preferredLevel,
  }) async {
    final cached = await get<T>(key);
    if (cached != null) {
      return cached;
    }

    final computed = await compute();
    await set(
      key,
      computed,
      expiry: expiry,
      policy: policy,
      preferredLevel: preferredLevel,
    );
    return computed;
  }

  /// Preload frequently accessed data
  Future<void> preload(Map<String, Future<dynamic> Function()> loaders) async {
    final connectivity = await _connectivity.checkConnectivity();
    if (connectivity == ConnectivityResult.none) return;

    for (final entry in loaders.entries) {
      try {
        if (!await has(entry.key)) {
          final data = await entry.value();
          await set(entry.key, data, policy: CacheExpiryPolicy.daily);
        }
      } catch (e) {
        debugPrint('Failed to preload ${entry.key}: $e');
      }
    }
  }

  /// Invalidate cache based on conditions
  Future<void> invalidate({
    List<String>? keys,
    String? pattern,
    CacheLevel? level,
    DateTime? olderThan,
  }) async {
    if (keys != null) {
      for (final key in keys) {
        await remove(key);
      }
    }

    if (pattern != null) {
      await removePattern(pattern);
    }

    if (olderThan != null || level != null) {
      await _conditionalCleanup(olderThan: olderThan, level: level);
    }
  }

  // Private helper methods

  DateTime _calculateExpiryDate(
    DateTime now,
    Duration? expiry,
    CacheExpiryPolicy policy,
  ) {
    if (expiry != null) return now.add(expiry);

    switch (policy) {
      case CacheExpiryPolicy.never:
        return DateTime(2099, 12, 31);
      case CacheExpiryPolicy.session:
        return now.add(const Duration(hours: 24));
      case CacheExpiryPolicy.hourly:
        return now.add(const Duration(hours: 1));
      case CacheExpiryPolicy.daily:
        return now.add(const Duration(days: 1));
      case CacheExpiryPolicy.weekly:
        return now.add(const Duration(days: 7));
      case CacheExpiryPolicy.custom:
        return now.add(const Duration(hours: 6));
    }
  }

  int _calculateSize(dynamic data) {
    try {
      return utf8.encode(jsonEncode(data)).length;
    } catch (e) {
      return 1024; // Default size estimate
    }
  }

  CacheLevel _selectOptimalLevel(int size) {
    if (size < 10 * 1024) {
      // < 10KB
      return CacheLevel.memory;
    } else if (size < 100 * 1024) {
      // < 100KB
      return CacheLevel.persistent;
    } else {
      return CacheLevel.database;
    }
  }

  Future<void> _storeEntry<T>(CacheEntry<T> entry) async {
    switch (entry.level) {
      case CacheLevel.memory:
        _ensureMemoryCapacity();
        _memoryCache[entry.key] = entry;
        break;

      case CacheLevel.persistent:
        if (_prefs != null) {
          await _prefs!.setString(
            'cache_${entry.key}',
            jsonEncode(entry.toMap()),
          );
        }
        break;

      case CacheLevel.database:
        if (_database != null) {
          await _database!.insert(
            'cache_entries',
            entry.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        break;
    }
  }

  void _ensureMemoryCapacity() {
    while (_memoryCache.length >= _maxMemoryEntries) {
      final oldestKey = _memoryCache.entries
          .reduce(
            (a, b) =>
                a.value.lastAccessed.isBefore(b.value.lastAccessed) ? a : b,
          )
          .key;
      _memoryCache.remove(oldestKey);
      _metrics.evictions++;
    }
  }

  void _updateAccessCount(CacheEntry entry) {
    final updatedEntry = entry.copyWith(
      accessCount: entry.accessCount + 1,
      lastAccessed: DateTime.now(),
    );

    // Update in appropriate cache level
    switch (entry.level) {
      case CacheLevel.memory:
        _memoryCache[entry.key] = updatedEntry;
        break;
      case CacheLevel.persistent:
        _prefs?.setString(
          'cache_${entry.key}',
          jsonEncode(updatedEntry.toMap()),
        );
        break;
      case CacheLevel.database:
        _database?.update(
          'cache_entries',
          {
            'accessCount': updatedEntry.accessCount,
            'lastAccessed': updatedEntry.lastAccessed.toIso8601String(),
          },
          where: 'key = ?',
          whereArgs: [entry.key],
        );
        break;
    }
  }

  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(hours: 1), (_) async {
      await _performCleanup();
    });
  }

  void _startMetricsTimer() {
    _metricsTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _logMetrics();
    });
  }

  Future<void> _performCleanup() async {
    final now = DateTime.now();

    // Clean expired memory entries
    _memoryCache.removeWhere((key, entry) {
      final expired = entry.isExpired;
      if (expired) _metrics.evictions++;
      return expired;
    });

    // Clean expired persistent entries
    if (_prefs != null) {
      final cacheKeys = _prefs!.getKeys().where(
        (key) => key.startsWith('cache_'),
      );
      for (final key in cacheKeys) {
        try {
          final data = _prefs!.getString(key);
          if (data != null) {
            final entry = CacheEntry.fromMap(jsonDecode(data));
            if (entry.isExpired) {
              _prefs!.remove(key);
              _metrics.evictions++;
            }
          }
        } catch (e) {
          _prefs!.remove(key); // Remove corrupted entries
        }
      }
    }

    // Clean expired database entries
    if (_database != null) {
      final deletedCount = await _database!.delete(
        'cache_entries',
        where: 'expiresAt < ?',
        whereArgs: [now.toIso8601String()],
      );
      _metrics.evictions += deletedCount;
    }
  }

  Future<void> _conditionalCleanup({
    DateTime? olderThan,
    CacheLevel? level,
  }) async {
    if (level != null && level == CacheLevel.memory) {
      if (olderThan != null) {
        _memoryCache.removeWhere(
          (key, entry) => entry.lastAccessed.isBefore(olderThan),
        );
      }
    }

    if (_database != null && (level == null || level == CacheLevel.database)) {
      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (olderThan != null) {
        whereClause = 'lastAccessed < ?';
        whereArgs.add(olderThan.toIso8601String());
      }

      if (whereClause.isNotEmpty) {
        await _database!.delete(
          'cache_entries',
          where: whereClause,
          whereArgs: whereArgs,
        );
      }
    }
  }

  void _logMetrics() {
    final metrics = getMetrics();
    debugPrint('''
📊 Cache Metrics:
   Hit Ratio: ${(metrics.hitRatio * 100).toStringAsFixed(1)}%
   Total Entries: ${metrics.totalEntries}
   Total Size: ${(metrics.totalSize / 1024).toStringAsFixed(1)} KB
   Average Access Time: ${metrics.averageAccessTime.toStringAsFixed(2)}μs
''');
  }

  /// Dispose of resources
  Future<void> dispose() async {
    _cleanupTimer?.cancel();
    _metricsTimer?.cancel();
    await _database?.close();
    _initialized = false;
  }
}
