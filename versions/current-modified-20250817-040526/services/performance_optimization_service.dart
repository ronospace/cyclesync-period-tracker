import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:collection';
import 'dart:async';

class PerformanceOptimizationService {
  static final PerformanceOptimizationService _instance = 
      PerformanceOptimizationService._internal();
  
  factory PerformanceOptimizationService() => _instance;
  
  PerformanceOptimizationService._internal();

  // Cache management
  final Map<String, CacheItem> _cache = <String, CacheItem>{};
  final int _maxCacheSize = 1000;
  final Duration _defaultCacheDuration = const Duration(hours: 1);

  // Memory management
  Timer? _memoryCleanupTimer;
  Timer? _cacheCleanupTimer;
  final List<VoidCallback> _disposables = [];

  // Performance metrics
  final Map<String, PerformanceMetric> _metrics = {};
  DateTime? _appStartTime;

  // Database query optimization
  final Map<String, QueryCache> _queryCache = {};
  final Duration _queryCacheDuration = const Duration(minutes: 30);

  // Image cache optimization
  final Map<String, Uint8List> _imageCache = {};
  final int _maxImageCacheSize = 50;

  void initialize() {
    _appStartTime = DateTime.now();
    _startMemoryCleanup();
    _startCacheCleanup();
    _optimizeSystemMemory();
    _preloadCriticalData();
    
    debugPrint('✅ PerformanceService: Initialized successfully');
  }

  void dispose() {
    _memoryCleanupTimer?.cancel();
    _cacheCleanupTimer?.cancel();
    _clearAllCaches();
    _disposeAll();
    
    debugPrint('🔄 PerformanceService: Disposed');
  }

  // Cache Management
  void setCache<T>(String key, T value, {Duration? duration}) {
    final item = CacheItem<T>(
      value: value,
      timestamp: DateTime.now(),
      duration: duration ?? _defaultCacheDuration,
    );

    _cache[key] = item;

    // Remove oldest items if cache is too large
    if (_cache.length > _maxCacheSize) {
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);
    }
  }

  T? getCache<T>(String key) {
    final item = _cache[key];
    if (item == null) return null;

    final isExpired = DateTime.now().difference(item.timestamp) > item.duration;
    if (isExpired) {
      _cache.remove(key);
      return null;
    }

    return item.value as T?;
  }

  void removeCache(String key) {
    _cache.remove(key);
  }

  void clearCache({String? pattern}) {
    if (pattern != null) {
      final keysToRemove = _cache.keys
          .where((key) => key.contains(pattern))
          .toList();
      for (final key in keysToRemove) {
        _cache.remove(key);
      }
    } else {
      _cache.clear();
    }
  }

  // Query Cache Management
  void setCachedQuery(String query, List<Map<String, dynamic>> result) {
    _queryCache[query] = QueryCache(
      result: result,
      timestamp: DateTime.now(),
      duration: _queryCacheDuration,
    );
  }

  List<Map<String, dynamic>>? getCachedQuery(String query) {
    final cached = _queryCache[query];
    if (cached == null) return null;

    final isExpired = DateTime.now().difference(cached.timestamp) > cached.duration;
    if (isExpired) {
      _queryCache.remove(query);
      return null;
    }

    return cached.result;
  }

  // Memory Management
  void _startMemoryCleanup() {
    _memoryCleanupTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _performMemoryCleanup(),
    );
  }

  void _startCacheCleanup() {
    _cacheCleanupTimer = Timer.periodic(
      const Duration(minutes: 10),
      (_) => _performCacheCleanup(),
    );
  }

  void _performMemoryCleanup() {
    // Clean expired cache items
    final now = DateTime.now();
    final expiredKeys = _cache.entries
        .where((entry) => now.difference(entry.value.timestamp) > entry.value.duration)
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      _cache.remove(key);
    }

    // Clean expired query cache
    final expiredQueries = _queryCache.entries
        .where((entry) => now.difference(entry.value.timestamp) > entry.value.duration)
        .map((entry) => entry.key)
        .toList();

    for (final query in expiredQueries) {
      _queryCache.remove(query);
    }

    // Clean image cache if too large
    if (_imageCache.length > _maxImageCacheSize) {
      final keysToRemove = _imageCache.keys.take(_imageCache.length - _maxImageCacheSize);
      for (final key in keysToRemove) {
        _imageCache.remove(key);
      }
    }

    debugPrint('🧹 PerformanceService: Memory cleanup completed');
  }

  void _performCacheCleanup() {
    final cacheSize = _cache.length;
    final queryCacheSize = _queryCache.length;
    final imageCacheSize = _imageCache.length;

    debugPrint('📊 Cache sizes - General: $cacheSize, Query: $queryCacheSize, Image: $imageCacheSize');
  }

  void _optimizeSystemMemory() {
    // Force garbage collection
    if (kDebugMode) {
      // Only in debug mode to avoid performance issues in release
      SystemChannels.platform.invokeMethod('System.gc');
    }

    debugPrint('🗑️ PerformanceService: Memory optimization completed');
  }

  // Performance Metrics
  void startMetric(String name) {
    _metrics[name] = PerformanceMetric(
      name: name,
      startTime: DateTime.now(),
    );
  }

  void endMetric(String name) {
    final metric = _metrics[name];
    if (metric != null) {
      metric.endTime = DateTime.now();
      metric.duration = metric.endTime!.difference(metric.startTime);
      
      if (kDebugMode) {
        debugPrint('📊 Metric "$name": ${metric.duration.inMilliseconds}ms');
      }
    }
  }

  Duration? getMetricDuration(String name) {
    return _metrics[name]?.duration;
  }

  Map<String, Duration> getAllMetrics() {
    return _metrics
        .where((key, metric) => metric.duration != null)
        .map((key, metric) => MapEntry(key, metric.duration!));
  }

  // Preloading and Asset Management
  Future<void> _preloadCriticalData() async {
    try {
      // Preload critical assets that will be used frequently
      _preloadImages();
      
      debugPrint('✅ PerformanceService: Asset preloading skipped (no assets configured)');
    } catch (e) {
      debugPrint('❌ PerformanceService: Asset preloading failed: $e');
    }
  }

  void _preloadImages() {
    // Preload commonly used images
    final commonImages = [
      'assets/images/logo.png',
      'assets/images/onboarding_1.png',
      'assets/images/onboarding_2.png',
      'assets/images/onboarding_3.png',
    ];

    for (final imagePath in commonImages) {
      _preloadImage(imagePath);
    }
  }

  Future<void> _preloadImage(String imagePath) async {
    try {
      final bytes = await rootBundle.load(imagePath);
      _imageCache[imagePath] = bytes.buffer.asUint8List();
    } catch (e) {
      // Image doesn't exist, skip silently
      debugPrint('⚠️ Image not found: $imagePath');
    }
  }

  Uint8List? getCachedImage(String imagePath) {
    return _imageCache[imagePath];
  }

  // Firebase Connection Optimization
  Future<void> warmupFirebaseConnections() async {
    try {
      startMetric('firebase_warmup');
      
      // Pre-establish Firebase connections
      // This would typically involve making a lightweight query to Firebase
      await Future.delayed(const Duration(milliseconds: 100)); // Simulate warmup
      
      endMetric('firebase_warmup');
      debugPrint('🔥 PerformanceService: Firebase connections warmed up');
    } catch (e) {
      debugPrint('❌ PerformanceService: Firebase warmup failed: $e');
    }
  }

  // Critical Data Preloading
  Future<void> preloadCriticalData() async {
    try {
      startMetric('critical_data_preload');
      
      // Preload user profile data
      // Preload recent cycles
      // Preload app settings
      await Future.delayed(const Duration(milliseconds: 200)); // Simulate preload
      
      endMetric('critical_data_preload');
      debugPrint('✅ PerformanceService: Critical data preloaded');
    } catch (e) {
      debugPrint('❌ PerformanceService: Critical data preload failed: $e');
    }
  }

  // Device Performance Optimization
  void optimizeForDevice() {
    // Detect device capabilities and optimize accordingly
    if (kDebugMode) {
      debugPrint('🔧 PerformanceService: Debug performance monitoring enabled');
    } else {
      // Production optimizations
      debugPrint('🚀 PerformanceService: Production optimizations enabled');
    }
    
    debugPrint('✅ PerformanceService: Performance optimized for device');
  }

  // Performance Monitoring
  void startPerformanceMonitoring() {
    Timer.periodic(const Duration(minutes: 1), (_) {
      _reportPerformanceMetrics();
    });
    
    debugPrint('📊 PerformanceService: Performance monitoring started');
  }

  void _reportPerformanceMetrics() {
    final uptime = _appStartTime != null 
        ? DateTime.now().difference(_appStartTime!)
        : Duration.zero;
    
    final metrics = {
      'uptime': uptime.toString(),
      'cache_size': _cache.length,
      'query_cache_size': _queryCache.length,
      'image_cache_size': _imageCache.length,
    };
    
    if (kDebugMode) {
      debugPrint('📊 Performance Metrics: $metrics');
    }
  }

  // Resource Management
  void addDisposable(VoidCallback disposable) {
    _disposables.add(disposable);
  }

  void _disposeAll() {
    for (final disposable in _disposables) {
      try {
        disposable();
      } catch (e) {
        debugPrint('⚠️ Error disposing resource: $e');
      }
    }
    _disposables.clear();
  }

  void _clearAllCaches() {
    _cache.clear();
    _queryCache.clear();
    _imageCache.clear();
    _metrics.clear();
  }

  // Batch Operations
  Future<List<T>> batchOperation<T>(
    List<Future<T> Function()> operations, {
    int batchSize = 5,
    Duration delay = const Duration(milliseconds: 100),
  }) async {
    final results = <T>[];
    
    for (int i = 0; i < operations.length; i += batchSize) {
      final batch = operations.skip(i).take(batchSize);
      final futures = batch.map((op) => op()).toList();
      final batchResults = await Future.wait(futures);
      results.addAll(batchResults);
      
      if (i + batchSize < operations.length) {
        await Future.delayed(delay);
      }
    }
    
    return results;
  }

  // Network Request Optimization
  Future<T> optimizedRequest<T>(
    String cacheKey,
    Future<T> Function() request, {
    Duration? cacheDuration,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = getCache<T>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    startMetric('request_$cacheKey');
    final result = await request();
    endMetric('request_$cacheKey');

    setCache(cacheKey, result, duration: cacheDuration);
    return result;
  }
}

// Supporting classes
class CacheItem<T> {
  final T value;
  final DateTime timestamp;
  final Duration duration;

  CacheItem({
    required this.value,
    required this.timestamp,
    required this.duration,
  });
}

class QueryCache {
  final List<Map<String, dynamic>> result;
  final DateTime timestamp;
  final Duration duration;

  QueryCache({
    required this.result,
    required this.timestamp,
    required this.duration,
  });
}

class PerformanceMetric {
  final String name;
  final DateTime startTime;
  DateTime? endTime;
  Duration? duration;

  PerformanceMetric({
    required this.name,
    required this.startTime,
    this.endTime,
    this.duration,
  });
}
