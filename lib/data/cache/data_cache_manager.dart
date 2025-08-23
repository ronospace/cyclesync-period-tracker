import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/cycle_models.dart';
import '../../models/daily_log_models.dart';
import '../../services/encryption_service.dart';

/// Advanced data cache manager with encryption and intelligent caching strategies
class DataCacheManager {
  static DataCacheManager? _instance;
  static DataCacheManager get instance => _instance ??= DataCacheManager._();

  DataCacheManager._();

  static const String _cyclesCacheKey = 'cached_cycles_v2';
  static const String _dailyLogsCacheKey = 'cached_daily_logs_v2';
  static const String _metadataCacheKey = 'cache_metadata_v2';
  static const String _analyticsCacheKey = 'cached_analytics_v2';

  SharedPreferences? _prefs;
  final EncryptionService _encryption = EncryptionService.instance;
  final Map<String, dynamic> _memoryCache = {};
  Timer? _cleanupTimer;

  bool _isInitialized = false;
  int _cacheSize = 0;

  /// Initialize the cache manager
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🗂️ Initializing DataCacheManager...');

      _prefs = await SharedPreferences.getInstance();
      await _encryption.initialize();

      // Load cache metadata
      await _loadCacheMetadata();

      // Start cleanup timer
      _startCleanupTimer();

      _isInitialized = true;
      debugPrint('✅ DataCacheManager initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize DataCacheManager: $e');
      rethrow;
    }
  }

  /// Load cache metadata for size tracking
  Future<void> _loadCacheMetadata() async {
    try {
      final metadataJson = _prefs?.getString(_metadataCacheKey);
      if (metadataJson != null) {
        final metadata = json.decode(metadataJson);
        _cacheSize = metadata['size'] ?? 0;
      }
    } catch (e) {
      debugPrint('⚠️ Error loading cache metadata: $e');
      _cacheSize = 0;
    }
  }

  /// Save cache metadata
  Future<void> _saveCacheMetadata() async {
    try {
      final metadata = {
        'size': _cacheSize,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      await _prefs?.setString(_metadataCacheKey, json.encode(metadata));
    } catch (e) {
      debugPrint('⚠️ Error saving cache metadata: $e');
    }
  }

  /// Start cleanup timer for expired cache entries
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(hours: 1), (_) {
      _cleanupExpiredEntries();
    });
  }

  /// Clean up expired cache entries
  Future<void> _cleanupExpiredEntries() async {
    try {
      // Implement cache expiration logic here
      // For now, just clean memory cache of old entries
      final now = DateTime.now();
      _memoryCache.removeWhere((key, value) {
        if (value is Map && value.containsKey('timestamp')) {
          final timestamp = DateTime.parse(value['timestamp']);
          return now.difference(timestamp).inHours > 24;
        }
        return false;
      });

      debugPrint('🧹 Cleaned up expired cache entries');
    } catch (e) {
      debugPrint('⚠️ Error during cache cleanup: $e');
    }
  }

  /// Cache cycles data
  Future<void> cacheCycles(List<CycleData> cycles) async {
    try {
      // Convert to serializable format
      final cyclesJson = cycles.map((cycle) => cycle.toFirestore()).toList();
      final jsonString = json.encode(cyclesJson);

      // Encrypt and store
      final encryptedData = await _encryption.encrypt(jsonString);
      await _prefs?.setString(_cyclesCacheKey, encryptedData);

      // Update memory cache
      _memoryCache[_cyclesCacheKey] = {
        'data': cycles,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Update cache size
      _cacheSize += jsonString.length;
      await _saveCacheMetadata();

      debugPrint(
        '💾 Cached ${cycles.length} cycles (${jsonString.length} bytes)',
      );
    } catch (e) {
      debugPrint('❌ Error caching cycles: $e');
    }
  }

  /// Get cached cycles
  Future<List<CycleData>> getCachedCycles() async {
    try {
      // Check memory cache first
      if (_memoryCache.containsKey(_cyclesCacheKey)) {
        final cachedData = _memoryCache[_cyclesCacheKey];
        if (cachedData is Map && cachedData.containsKey('data')) {
          final timestamp = DateTime.parse(cachedData['timestamp']);
          if (DateTime.now().difference(timestamp).inMinutes < 30) {
            return List<CycleData>.from(cachedData['data']);
          }
        }
      }

      // Check persistent cache
      final encryptedData = _prefs?.getString(_cyclesCacheKey);
      if (encryptedData == null) return [];

      // Decrypt and deserialize
      final jsonString = await _encryption.decrypt(encryptedData);
      final cyclesJson = json.decode(jsonString) as List;

      final cycles = cyclesJson
          .map((json) => CycleData.fromFirestore(json as Map<String, dynamic>))
          .toList();

      // Update memory cache
      _memoryCache[_cyclesCacheKey] = {
        'data': cycles,
        'timestamp': DateTime.now().toIso8601String(),
      };

      debugPrint('📦 Retrieved ${cycles.length} cycles from cache');
      return cycles;
    } catch (e) {
      debugPrint('⚠️ Error getting cached cycles: $e');
      return [];
    }
  }

  /// Cache daily logs data
  Future<void> cacheDailyLogs(List<DailyLogEntry> dailyLogs) async {
    try {
      // Convert to serializable format
      final logsJson = dailyLogs.map((log) => log.toFirestore()).toList();
      final jsonString = json.encode(logsJson);

      // Encrypt and store
      final encryptedData = await _encryption.encrypt(jsonString);
      await _prefs?.setString(_dailyLogsCacheKey, encryptedData);

      // Update memory cache
      _memoryCache[_dailyLogsCacheKey] = {
        'data': dailyLogs,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Update cache size
      _cacheSize += jsonString.length;
      await _saveCacheMetadata();

      debugPrint(
        '💾 Cached ${dailyLogs.length} daily logs (${jsonString.length} bytes)',
      );
    } catch (e) {
      debugPrint('❌ Error caching daily logs: $e');
    }
  }

  /// Get cached daily logs
  Future<List<DailyLogEntry>> getCachedDailyLogs() async {
    try {
      // Check memory cache first
      if (_memoryCache.containsKey(_dailyLogsCacheKey)) {
        final cachedData = _memoryCache[_dailyLogsCacheKey];
        if (cachedData is Map && cachedData.containsKey('data')) {
          final timestamp = DateTime.parse(cachedData['timestamp']);
          if (DateTime.now().difference(timestamp).inMinutes < 30) {
            return List<DailyLogEntry>.from(cachedData['data']);
          }
        }
      }

      // Check persistent cache
      final encryptedData = _prefs?.getString(_dailyLogsCacheKey);
      if (encryptedData == null) return [];

      // Decrypt and deserialize
      final jsonString = await _encryption.decrypt(encryptedData);
      final logsJson = json.decode(jsonString) as List;

      final dailyLogs = logsJson
          .map(
            (json) => DailyLogEntry.fromFirestore(
              json as Map<String, dynamic>,
              json['id'] ?? '',
            ),
          )
          .toList();

      // Update memory cache
      _memoryCache[_dailyLogsCacheKey] = {
        'data': dailyLogs,
        'timestamp': DateTime.now().toIso8601String(),
      };

      debugPrint('📦 Retrieved ${dailyLogs.length} daily logs from cache');
      return dailyLogs;
    } catch (e) {
      debugPrint('⚠️ Error getting cached daily logs: $e');
      return [];
    }
  }

  /// Cache analytics data
  Future<void> cacheAnalytics(
    String key,
    Map<String, dynamic> analytics,
  ) async {
    try {
      final cacheKey = '$_analyticsCacheKey-$key';
      final jsonString = json.encode(analytics);

      // Encrypt and store
      final encryptedData = await _encryption.encrypt(jsonString);
      await _prefs?.setString(cacheKey, encryptedData);

      // Update memory cache with expiration
      _memoryCache[cacheKey] = {
        'data': analytics,
        'timestamp': DateTime.now().toIso8601String(),
        'expiry': DateTime.now()
            .add(const Duration(hours: 6))
            .toIso8601String(),
      };

      debugPrint('💾 Cached analytics: $key');
    } catch (e) {
      debugPrint('❌ Error caching analytics: $e');
    }
  }

  /// Get cached analytics
  Future<Map<String, dynamic>?> getCachedAnalytics(String key) async {
    try {
      final cacheKey = '$_analyticsCacheKey-$key';

      // Check memory cache first
      if (_memoryCache.containsKey(cacheKey)) {
        final cachedData = _memoryCache[cacheKey];
        if (cachedData is Map && cachedData.containsKey('data')) {
          final expiry = DateTime.parse(cachedData['expiry']);
          if (DateTime.now().isBefore(expiry)) {
            return Map<String, dynamic>.from(cachedData['data']);
          }
        }
      }

      // Check persistent cache
      final encryptedData = _prefs?.getString(cacheKey);
      if (encryptedData == null) return null;

      // Decrypt and deserialize
      final jsonString = await _encryption.decrypt(encryptedData);
      final analytics = json.decode(jsonString) as Map<String, dynamic>;

      debugPrint('📊 Retrieved analytics from cache: $key');
      return analytics;
    } catch (e) {
      debugPrint('⚠️ Error getting cached analytics: $e');
      return null;
    }
  }

  /// Cache arbitrary data with TTL
  Future<void> cacheData(String key, dynamic data, {Duration? ttl}) async {
    try {
      final expiryTime = DateTime.now().add(ttl ?? const Duration(hours: 24));
      final cacheData = {
        'data': data,
        'expiry': expiryTime.toIso8601String(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      final jsonString = json.encode(cacheData);
      final encryptedData = await _encryption.encrypt(jsonString);

      await _prefs?.setString('cache_$key', encryptedData);
      _memoryCache['cache_$key'] = cacheData;

      debugPrint('💾 Cached data: $key (TTL: ${ttl?.toString() ?? '24h'})');
    } catch (e) {
      debugPrint('❌ Error caching data: $e');
    }
  }

  /// Get cached data with TTL check
  Future<T?> getCachedData<T>(String key) async {
    try {
      final cacheKey = 'cache_$key';

      // Check memory cache first
      if (_memoryCache.containsKey(cacheKey)) {
        final cachedData = _memoryCache[cacheKey];
        if (cachedData is Map && cachedData.containsKey('data')) {
          final expiry = DateTime.parse(cachedData['expiry']);
          if (DateTime.now().isBefore(expiry)) {
            return cachedData['data'] as T?;
          }
        }
      }

      // Check persistent cache
      final encryptedData = _prefs?.getString(cacheKey);
      if (encryptedData == null) return null;

      // Decrypt and deserialize
      final jsonString = await _encryption.decrypt(encryptedData);
      final cacheData = json.decode(jsonString) as Map<String, dynamic>;

      // Check expiry
      final expiry = DateTime.parse(cacheData['expiry']);
      if (DateTime.now().isAfter(expiry)) {
        // Remove expired data
        await _prefs?.remove(cacheKey);
        _memoryCache.remove(cacheKey);
        return null;
      }

      debugPrint('📦 Retrieved cached data: $key');
      return cacheData['data'] as T?;
    } catch (e) {
      debugPrint('⚠️ Error getting cached data: $e');
      return null;
    }
  }

  /// Get cache statistics
  CacheStats getCacheStats() {
    final keys = _prefs?.getKeys() ?? {};
    final cyclesCacheSize = _prefs?.getString(_cyclesCacheKey)?.length ?? 0;
    final dailyLogsCacheSize =
        _prefs?.getString(_dailyLogsCacheKey)?.length ?? 0;

    return CacheStats(
      totalKeys: keys.length,
      totalSize: _cacheSize,
      memoryEntries: _memoryCache.length,
      cyclesCacheSize: cyclesCacheSize,
      dailyLogsCacheSize: dailyLogsCacheSize,
      lastUpdated: DateTime.now(),
    );
  }

  /// Get total cache size
  int getCacheSize() => _cacheSize;

  /// Clear specific cache
  Future<void> clearCache([String? specificKey]) async {
    try {
      if (specificKey != null) {
        await _prefs?.remove(specificKey);
        _memoryCache.remove(specificKey);
        debugPrint('🗑️ Cleared cache for key: $specificKey');
      } else {
        // Clear all cache
        final keys = _prefs?.getKeys() ?? {};
        for (final key in keys) {
          if (key.startsWith('cached_') || key.startsWith('cache_')) {
            await _prefs?.remove(key);
          }
        }

        _memoryCache.clear();
        _cacheSize = 0;
        await _saveCacheMetadata();

        debugPrint('🗑️ Cleared all cache data');
      }
    } catch (e) {
      debugPrint('❌ Error clearing cache: $e');
    }
  }

  /// Optimize cache by removing old entries
  Future<void> optimizeCache() async {
    try {
      debugPrint('🔧 Starting cache optimization...');

      final keys = _prefs?.getKeys() ?? {};
      int removedCount = 0;
      int freedBytes = 0;

      for (final key in keys) {
        if (key.startsWith('cache_') || key.startsWith('cached_')) {
          try {
            final data = _prefs?.getString(key);
            if (data != null) {
              // Try to decrypt and check expiry
              final decrypted = await _encryption.decrypt(data);
              final parsed = json.decode(decrypted);

              if (parsed is Map && parsed.containsKey('expiry')) {
                final expiry = DateTime.parse(parsed['expiry']);
                if (DateTime.now().isAfter(expiry)) {
                  await _prefs?.remove(key);
                  _memoryCache.remove(key);
                  removedCount++;
                  freedBytes += data.length;
                }
              }
            }
          } catch (e) {
            // Remove corrupted cache entries
            await _prefs?.remove(key);
            _memoryCache.remove(key);
            removedCount++;
          }
        }
      }

      _cacheSize = _cacheSize - freedBytes;
      await _saveCacheMetadata();

      debugPrint(
        '✅ Cache optimization completed: removed $removedCount entries, freed $freedBytes bytes',
      );
    } catch (e) {
      debugPrint('❌ Error optimizing cache: $e');
    }
  }

  /// Check if cache is healthy
  bool isCacheHealthy() {
    return _isInitialized &&
        _prefs != null &&
        _cacheSize < (50 * 1024 * 1024); // Less than 50MB
  }

  /// Get cache health report
  CacheHealthReport getCacheHealthReport() {
    final stats = getCacheStats();
    final isHealthy = isCacheHealthy();

    return CacheHealthReport(
      isHealthy: isHealthy,
      totalSize: stats.totalSize,
      memoryUsage: _memoryCache.length * 1024, // Rough estimate
      fragmentationLevel: _calculateFragmentation(),
      lastOptimized: DateTime.now(),
      recommendations: _getOptimizationRecommendations(stats),
    );
  }

  /// Calculate cache fragmentation level
  double _calculateFragmentation() {
    final keys = _prefs?.getKeys() ?? {};
    final cacheKeys = keys.where(
      (k) => k.startsWith('cache_') || k.startsWith('cached_'),
    );

    if (cacheKeys.isEmpty) return 0.0;

    // Simple fragmentation calculation based on key count vs total size
    return (cacheKeys.length / (_cacheSize / 1024)).clamp(0.0, 1.0);
  }

  /// Get optimization recommendations
  List<String> _getOptimizationRecommendations(CacheStats stats) {
    final recommendations = <String>[];

    if (stats.totalSize > 30 * 1024 * 1024) {
      recommendations.add('Consider clearing old cache entries');
    }

    if (stats.memoryEntries > 100) {
      recommendations.add('Memory cache is growing large');
    }

    if (_calculateFragmentation() > 0.7) {
      recommendations.add('Cache fragmentation is high - run optimization');
    }

    return recommendations;
  }

  /// Dispose resources
  void dispose() {
    _cleanupTimer?.cancel();
    _memoryCache.clear();
  }
}

/// Cache statistics
class CacheStats {
  final int totalKeys;
  final int totalSize;
  final int memoryEntries;
  final int cyclesCacheSize;
  final int dailyLogsCacheSize;
  final DateTime lastUpdated;

  CacheStats({
    required this.totalKeys,
    required this.totalSize,
    required this.memoryEntries,
    required this.cyclesCacheSize,
    required this.dailyLogsCacheSize,
    required this.lastUpdated,
  });
}

/// Cache health report
class CacheHealthReport {
  final bool isHealthy;
  final int totalSize;
  final int memoryUsage;
  final double fragmentationLevel;
  final DateTime lastOptimized;
  final List<String> recommendations;

  CacheHealthReport({
    required this.isHealthy,
    required this.totalSize,
    required this.memoryUsage,
    required this.fragmentationLevel,
    required this.lastOptimized,
    required this.recommendations,
  });
}
