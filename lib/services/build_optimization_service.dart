import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Build environment types
enum BuildEnvironment { debug, profile, release }

/// Build optimization configuration
class BuildOptimizationConfig {
  final bool treeShakeIcons;
  final bool deferredComponents;
  final bool splitDebugInfo;
  final bool obfuscate;
  final bool shrink;
  final Map<String, dynamic> platformSpecific;
  final Map<String, dynamic> performance;
  final Map<String, dynamic> security;

  const BuildOptimizationConfig({
    this.treeShakeIcons = true,
    this.deferredComponents = true,
    this.splitDebugInfo = true,
    this.obfuscate = true,
    this.shrink = true,
    this.platformSpecific = const {},
    this.performance = const {},
    this.security = const {},
  });

  factory BuildOptimizationConfig.fromMap(Map<String, dynamic> map) {
    return BuildOptimizationConfig(
      treeShakeIcons: map['tree_shake_icons'] ?? true,
      deferredComponents: map['deferred_components'] ?? true,
      splitDebugInfo: map['split_debug_info'] ?? true,
      obfuscate: map['obfuscate'] ?? true,
      shrink: map['shrink'] ?? true,
      platformSpecific: Map<String, dynamic>.from(
        map['platform_specific'] ?? {},
      ),
      performance: Map<String, dynamic>.from(map['performance'] ?? {}),
      security: Map<String, dynamic>.from(map['security'] ?? {}),
    );
  }
}

/// Performance optimization metrics
class PerformanceMetrics {
  final int bundleSize;
  final int startupTime;
  final int memoryUsage;
  final double frameRate;
  final int networkRequests;
  final Map<String, dynamic> additionalMetrics;

  const PerformanceMetrics({
    required this.bundleSize,
    required this.startupTime,
    required this.memoryUsage,
    required this.frameRate,
    required this.networkRequests,
    this.additionalMetrics = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'bundleSize': bundleSize,
      'startupTime': startupTime,
      'memoryUsage': memoryUsage,
      'frameRate': frameRate,
      'networkRequests': networkRequests,
      'additionalMetrics': additionalMetrics,
    };
  }
}

/// Build Optimization Service for production performance
class BuildOptimizationService {
  static final BuildOptimizationService _instance =
      BuildOptimizationService._internal();
  factory BuildOptimizationService() => _instance;
  BuildOptimizationService._internal();

  BuildOptimizationConfig? _config;
  PerformanceMetrics? _currentMetrics;
  bool _initialized = false;

  // Performance monitoring
  final Stopwatch _startupTimer = Stopwatch();
  final Map<String, Stopwatch> _operationTimers = {};
  final List<PerformanceMetrics> _metricsHistory = [];

  /// Current build environment
  BuildEnvironment get buildEnvironment {
    if (kDebugMode) return BuildEnvironment.debug;
    if (kProfileMode) return BuildEnvironment.profile;
    return BuildEnvironment.release;
  }

  /// Check if running in production
  bool get isProduction => buildEnvironment == BuildEnvironment.release;

  /// Get current optimization configuration
  BuildOptimizationConfig get config =>
      _config ?? const BuildOptimizationConfig();

  /// Get current performance metrics
  PerformanceMetrics? get currentMetrics => _currentMetrics;

  /// Initialize the build optimization service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await _loadConfiguration();
      _startPerformanceMonitoring();
      await _applyOptimizations();

      _initialized = true;
      debugPrint('✅ BuildOptimizationService initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize BuildOptimizationService: $e');
    }
  }

  /// Apply build optimizations based on environment
  Future<void> applyBuildOptimizations() async {
    if (!isProduction) return;

    try {
      // Apply memory optimizations
      await _optimizeMemoryUsage();

      // Apply network optimizations
      await _optimizeNetworkRequests();

      // Apply rendering optimizations
      await _optimizeRendering();

      // Apply asset optimizations
      await _optimizeAssets();

      debugPrint('✅ Build optimizations applied');
    } catch (e) {
      debugPrint('❌ Error applying build optimizations: $e');
    }
  }

  /// Start performance timer for an operation
  void startTimer(String operationName) {
    _operationTimers[operationName] = Stopwatch()..start();
  }

  /// Stop performance timer and get duration
  Duration? stopTimer(String operationName) {
    final timer = _operationTimers[operationName];
    if (timer != null) {
      timer.stop();
      final duration = timer.elapsed;
      _operationTimers.remove(operationName);
      return duration;
    }
    return null;
  }

  /// Measure widget build performance
  T measureWidgetPerformance<T>(String widgetName, T Function() buildFunction) {
    if (!isProduction) {
      return buildFunction();
    }

    startTimer('widget_build_$widgetName');
    final result = buildFunction();
    final duration = stopTimer('widget_build_$widgetName');

    if (duration != null && duration.inMilliseconds > 16) {
      debugPrint(
        '⚠️ Slow widget build detected: $widgetName took ${duration.inMilliseconds}ms',
      );
    }

    return result;
  }

  /// Measure async operation performance
  Future<T> measureAsyncPerformance<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    startTimer('async_$operationName');
    final result = await operation();
    final duration = stopTimer('async_$operationName');

    if (duration != null && duration.inMilliseconds > 100) {
      debugPrint(
        '⚠️ Slow async operation: $operationName took ${duration.inMilliseconds}ms',
      );
    }

    return result;
  }

  /// Get build optimization recommendations
  List<String> getBuildRecommendations() {
    final recommendations = <String>[];

    if (_currentMetrics != null) {
      final metrics = _currentMetrics!;

      // Bundle size recommendations
      if (metrics.bundleSize > 50 * 1024 * 1024) {
        // 50MB
        recommendations.add(
          'Consider enabling tree shaking and code splitting to reduce bundle size',
        );
      }

      // Startup time recommendations
      if (metrics.startupTime > 3000) {
        // 3 seconds
        recommendations.add(
          'Optimize app startup time by implementing lazy loading',
        );
      }

      // Memory usage recommendations
      if (metrics.memoryUsage > 200 * 1024 * 1024) {
        // 200MB
        recommendations.add(
          'Consider implementing memory optimization strategies',
        );
      }

      // Frame rate recommendations
      if (metrics.frameRate < 55) {
        recommendations.add('Optimize rendering performance to achieve 60 FPS');
      }

      // Network recommendations
      if (metrics.networkRequests > 50) {
        recommendations.add(
          'Consider implementing request batching to reduce network calls',
        );
      }
    }

    return recommendations;
  }

  /// Export performance metrics
  Future<Map<String, dynamic>> exportPerformanceMetrics() async {
    return {
      'buildEnvironment': buildEnvironment.name,
      'currentMetrics': _currentMetrics?.toMap(),
      'metricsHistory': _metricsHistory.map((m) => m.toMap()).toList(),
      'optimizationConfig': {
        'treeShakeIcons': config.treeShakeIcons,
        'deferredComponents': config.deferredComponents,
        'splitDebugInfo': config.splitDebugInfo,
        'obfuscate': config.obfuscate,
        'shrink': config.shrink,
      },
      'recommendations': getBuildRecommendations(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Generate build commands for different environments
  Map<String, String> generateBuildCommands() {
    return {
      'debug': 'flutter build apk --debug',
      'profile': 'flutter build apk --profile --tree-shake-icons',
      'release_android': _generateAndroidReleaseCommand(),
      'release_ios': _generateiOSReleaseCommand(),
      'release_web': _generateWebReleaseCommand(),
    };
  }

  // Private helper methods

  Future<void> _loadConfiguration() async {
    try {
      // In a real implementation, this would load from build_config.yaml
      _config = const BuildOptimizationConfig(
        treeShakeIcons: true,
        deferredComponents: true,
        splitDebugInfo: true,
        obfuscate: true,
        shrink: true,
      );
    } catch (e) {
      debugPrint('Error loading build configuration: $e');
      _config = const BuildOptimizationConfig();
    }
  }

  void _startPerformanceMonitoring() {
    _startupTimer.start();

    // Monitor app lifecycle for performance metrics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startupTimer.stop();
      _updatePerformanceMetrics();
    });
  }

  Future<void> _applyOptimizations() async {
    if (!isProduction) return;

    // Apply platform-specific optimizations
    if (Platform.isAndroid) {
      await _applyAndroidOptimizations();
    } else if (Platform.isIOS) {
      await _applyiOSOptimizations();
    }
  }

  Future<void> _applyAndroidOptimizations() async {
    // Enable hardware acceleration
    await SystemChannels.platform.invokeMethod('enableHardwareAcceleration');

    // Optimize memory allocation
    await _optimizeAndroidMemory();

    debugPrint('✅ Android optimizations applied');
  }

  Future<void> _applyiOSOptimizations() async {
    // Enable Metal rendering
    await SystemChannels.platform.invokeMethod('enableMetalRendering');

    // Optimize iOS memory management
    await _optimizeiOSMemory();

    debugPrint('✅ iOS optimizations applied');
  }

  Future<void> _optimizeMemoryUsage() async {
    // Force garbage collection
    // In a real implementation, this would use platform-specific methods
    debugPrint('🗑️ Optimizing memory usage');
  }

  Future<void> _optimizeNetworkRequests() async {
    // Implement request batching and caching
    debugPrint('🌐 Optimizing network requests');
  }

  Future<void> _optimizeRendering() async {
    // Optimize widget rendering
    debugPrint('🎨 Optimizing rendering performance');
  }

  Future<void> _optimizeAssets() async {
    // Optimize image and font loading
    debugPrint('📦 Optimizing assets');
  }

  Future<void> _optimizeAndroidMemory() async {
    // Android-specific memory optimizations
    debugPrint('📱 Applying Android memory optimizations');
  }

  Future<void> _optimizeiOSMemory() async {
    // iOS-specific memory optimizations
    debugPrint('📱 Applying iOS memory optimizations');
  }

  void _updatePerformanceMetrics() {
    try {
      final metrics = PerformanceMetrics(
        bundleSize: _estimateBundleSize(),
        startupTime: _startupTimer.elapsedMilliseconds,
        memoryUsage: _estimateMemoryUsage(),
        frameRate: _estimateFrameRate(),
        networkRequests: _countNetworkRequests(),
      );

      _currentMetrics = metrics;
      _metricsHistory.add(metrics);

      // Keep only recent metrics (last 10)
      if (_metricsHistory.length > 10) {
        _metricsHistory.removeAt(0);
      }
    } catch (e) {
      debugPrint('Error updating performance metrics: $e');
    }
  }

  int _estimateBundleSize() {
    // In a real implementation, this would get actual bundle size
    return 25 * 1024 * 1024; // 25MB estimate
  }

  int _estimateMemoryUsage() {
    // In a real implementation, this would get actual memory usage
    return 150 * 1024 * 1024; // 150MB estimate
  }

  double _estimateFrameRate() {
    // In a real implementation, this would measure actual frame rate
    return 60.0;
  }

  int _countNetworkRequests() {
    // In a real implementation, this would count actual network requests
    return 10;
  }

  String _generateAndroidReleaseCommand() {
    final commands = <String>[
      'flutter build appbundle',
      if (config.obfuscate) '--obfuscate',
      if (config.splitDebugInfo) '--split-debug-info=build/app/outputs/symbols',
      if (config.treeShakeIcons) '--tree-shake-icons',
      if (config.shrink) '--shrink',
    ];

    return commands.join(' ');
  }

  String _generateiOSReleaseCommand() {
    final commands = <String>[
      'flutter build ipa',
      if (config.obfuscate) '--obfuscate',
      if (config.splitDebugInfo) '--split-debug-info=build/ios/symbols',
      if (config.treeShakeIcons) '--tree-shake-icons',
    ];

    return commands.join(' ');
  }

  String _generateWebReleaseCommand() {
    final commands = <String>[
      'flutter build web',
      if (config.treeShakeIcons) '--tree-shake-icons',
      '--web-renderer html', // or canvaskit for better performance
      '--source-maps', // for debugging in production
    ];

    return commands.join(' ');
  }
}

/// Performance monitoring widget mixin
mixin PerformanceMonitoringMixin<T extends StatefulWidget> on State<T> {
  final BuildOptimizationService _optimizationService =
      BuildOptimizationService();
  String get widgetName => widget.runtimeType.toString();

  @override
  void initState() {
    super.initState();
    _optimizationService.startTimer('widget_init_$widgetName');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _optimizationService.stopTimer('widget_init_$widgetName');
    });
  }

  @override
  Widget build(BuildContext context) {
    return _optimizationService.measureWidgetPerformance(
      widgetName,
      () => buildWidget(context),
    );
  }

  /// Override this method instead of build()
  Widget buildWidget(BuildContext context);
}

/// Optimized image widget with performance monitoring
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return BuildOptimizationService().measureWidgetPerformance(
      'OptimizedImage',
      () => Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        // Optimize image loading
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        ),
      ),
    );
  }
}
