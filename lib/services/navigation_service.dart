import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'cache_service.dart';

/// Navigation context data that preserves user state
class NavigationContext {
  final String routeName;
  final Map<String, dynamic> arguments;
  final Map<String, dynamic> formData;
  final Map<String, dynamic> scrollPositions;
  final DateTime timestamp;
  final String? previousRoute;

  const NavigationContext({
    required this.routeName,
    this.arguments = const {},
    this.formData = const {},
    this.scrollPositions = const {},
    required this.timestamp,
    this.previousRoute,
  });

  Map<String, dynamic> toMap() {
    return {
      'routeName': routeName,
      'arguments': arguments,
      'formData': formData,
      'scrollPositions': scrollPositions,
      'timestamp': timestamp.toIso8601String(),
      'previousRoute': previousRoute,
    };
  }

  factory NavigationContext.fromMap(Map<String, dynamic> map) {
    return NavigationContext(
      routeName: map['routeName'] ?? '',
      arguments: Map<String, dynamic>.from(map['arguments'] ?? {}),
      formData: Map<String, dynamic>.from(map['formData'] ?? {}),
      scrollPositions: Map<String, dynamic>.from(map['scrollPositions'] ?? {}),
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      previousRoute: map['previousRoute'],
    );
  }

  NavigationContext copyWith({
    String? routeName,
    Map<String, dynamic>? arguments,
    Map<String, dynamic>? formData,
    Map<String, dynamic>? scrollPositions,
    DateTime? timestamp,
    String? previousRoute,
  }) {
    return NavigationContext(
      routeName: routeName ?? this.routeName,
      arguments: arguments ?? this.arguments,
      formData: formData ?? this.formData,
      scrollPositions: scrollPositions ?? this.scrollPositions,
      timestamp: timestamp ?? this.timestamp,
      previousRoute: previousRoute ?? this.previousRoute,
    );
  }
}

/// Navigation history entry
class NavigationHistoryEntry {
  final String routeName;
  final Map<String, dynamic> arguments;
  final DateTime timestamp;
  final int index;

  const NavigationHistoryEntry({
    required this.routeName,
    required this.arguments,
    required this.timestamp,
    required this.index,
  });

  Map<String, dynamic> toMap() {
    return {
      'routeName': routeName,
      'arguments': arguments,
      'timestamp': timestamp.toIso8601String(),
      'index': index,
    };
  }

  factory NavigationHistoryEntry.fromMap(Map<String, dynamic> map) {
    return NavigationHistoryEntry(
      routeName: map['routeName'] ?? '',
      arguments: Map<String, dynamic>.from(map['arguments'] ?? {}),
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      index: map['index'] ?? 0,
    );
  }
}

/// Navigation analytics for understanding user flow
class NavigationAnalytics {
  final Map<String, int> routeVisitCount;
  final Map<String, Duration> routeTimeSpent;
  final List<String> commonPaths;
  final Map<String, double> exitRates;

  const NavigationAnalytics({
    this.routeVisitCount = const {},
    this.routeTimeSpent = const {},
    this.commonPaths = const [],
    this.exitRates = const {},
  });
}

/// Intelligent Navigation Service with context preservation and smart back navigation
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  SharedPreferences? _prefs;
  final List<NavigationContext> _navigationStack = [];
  final List<NavigationHistoryEntry> _history = [];
  final Map<String, Timer> _routeTimers = {};
  final Map<String, DateTime> _routeStartTimes = {};
  
  // Form data preservation
  final Map<String, Map<String, dynamic>> _preservedFormData = {};
  final Map<String, Map<String, double>> _preservedScrollPositions = {};
  
  // Navigation analytics
  final Map<String, int> _routeVisitCount = {};
  final Map<String, Duration> _routeTimeSpent = {};
  
  bool _initialized = false;
  int _navigationIndex = 0;
  
  // Cache keys
  static const String _navigationStackKey = 'navigation_stack';
  static const String _navigationHistoryKey = 'navigation_history';
  static const String _formDataKey = 'preserved_form_data';
  static const String _analyticsKey = 'navigation_analytics';

  /// Initialize the navigation service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadNavigationState();
      _setupSystemBackHandler();
      
      _initialized = true;
      debugPrint('✅ NavigationService initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize NavigationService: $e');
    }
  }

  /// Get the current navigator context
  BuildContext? get currentContext => navigatorKey.currentContext;

  /// Get current route name
  String? get currentRouteName {
    final context = currentContext;
    if (context != null) {
      return ModalRoute.of(context)?.settings.name;
    }
    return _navigationStack.isNotEmpty ? _navigationStack.last.routeName : null;
  }

  /// Check if we can go back
  bool get canGoBack => _navigationStack.length > 1;

  /// Get navigation history
  List<NavigationHistoryEntry> get history => List.unmodifiable(_history);

  /// Navigate to a route with context preservation
  Future<T?> navigateTo<T>(
    String routeName, {
    Map<String, dynamic> arguments = const {},
    bool preserveContext = true,
    bool clearStack = false,
  }) async {
    if (!_initialized) await initialize();

    try {
      _recordRouteVisit(routeName);
      
      if (preserveContext && currentRouteName != null) {
        await _preserveCurrentContext();
      }

      if (clearStack) {
        _navigationStack.clear();
        _history.clear();
      }

      // Add to navigation stack
      final context = NavigationContext(
        routeName: routeName,
        arguments: arguments,
        timestamp: DateTime.now(),
        previousRoute: currentRouteName,
      );
      
      _navigationStack.add(context);
      _addToHistory(routeName, arguments);

      // Start timer for this route
      _startRouteTimer(routeName);

      // Navigate using Flutter's navigator
      final result = await navigatorKey.currentState?.pushNamed<T>(
        routeName,
        arguments: arguments,
      );

      await _saveNavigationState();
      return result;
    } catch (e) {
      debugPrint('Navigation error: $e');
      return null;
    }
  }

  /// Replace current route
  Future<T?> navigateToReplacement<T>(
    String routeName, {
    Map<String, dynamic> arguments = const {},
    bool preserveContext = true,
  }) async {
    if (!_initialized) await initialize();

    try {
      if (preserveContext && currentRouteName != null) {
        await _preserveCurrentContext();
      }

      // Replace last entry in stack
      if (_navigationStack.isNotEmpty) {
        _navigationStack.removeLast();
      }

      final context = NavigationContext(
        routeName: routeName,
        arguments: arguments,
        timestamp: DateTime.now(),
        previousRoute: _navigationStack.isNotEmpty ? _navigationStack.last.routeName : null,
      );
      
      _navigationStack.add(context);
      _addToHistory(routeName, arguments);
      _startRouteTimer(routeName);

      final result = await navigatorKey.currentState?.pushReplacementNamed<T, dynamic>(
        routeName,
        arguments: arguments,
      );

      await _saveNavigationState();
      return result;
    } catch (e) {
      debugPrint('Navigation replacement error: $e');
      return null;
    }
  }

  /// Smart back navigation that preserves context
  Future<bool> goBack({bool restoreContext = true}) async {
    if (!canGoBack) {
      return _handleSystemBack();
    }

    try {
      // Stop timer for current route
      if (currentRouteName != null) {
        _stopRouteTimer(currentRouteName!);
      }

      // Remove current context from stack
      if (_navigationStack.isNotEmpty) {
        _navigationStack.removeLast();
      }

      if (_navigationStack.isEmpty) {
        return _handleSystemBack();
      }

      final previousContext = _navigationStack.last;
      
      // Restore previous context if requested
      if (restoreContext) {
        await _restoreContext(previousContext.routeName);
      }

      // Use Flutter's navigator to go back
      final canPop = navigatorKey.currentState?.canPop() ?? false;
      if (canPop) {
        navigatorKey.currentState?.pop();
      } else {
        // Navigate to previous route if we can't pop
        await navigatorKey.currentState?.pushNamedAndRemoveUntil(
          previousContext.routeName,
          (route) => false,
          arguments: previousContext.arguments,
        );
      }

      await _saveNavigationState();
      return true;
    } catch (e) {
      debugPrint('Smart back navigation error: $e');
      return _handleSystemBack();
    }
  }

  /// Navigate to a specific point in history
  Future<void> navigateToHistoryIndex(int index) async {
    if (index < 0 || index >= _history.length) return;

    try {
      final targetEntry = _history[index];
      
      // Clear stack and navigate to target
      await navigateTo(
        targetEntry.routeName,
        arguments: targetEntry.arguments,
        clearStack: true,
      );
    } catch (e) {
      debugPrint('Navigate to history index error: $e');
    }
  }

  /// Preserve form data for a route
  Future<void> preserveFormData(String routeName, Map<String, dynamic> formData) async {
    _preservedFormData[routeName] = Map<String, dynamic>.from(formData);
    await _saveFormData();
  }

  /// Restore form data for a route
  Map<String, dynamic>? getPreservedFormData(String routeName) {
    return _preservedFormData[routeName];
  }

  /// Preserve scroll position for a route
  Future<void> preserveScrollPosition(String routeName, String scrollKey, double position) async {
    _preservedScrollPositions[routeName] ??= {};
    _preservedScrollPositions[routeName]![scrollKey] = position;
    await _saveScrollPositions();
  }

  /// Get preserved scroll position
  double? getPreservedScrollPosition(String routeName, String scrollKey) {
    return _preservedScrollPositions[routeName]?[scrollKey];
  }

  /// Clear preserved data for a route
  Future<void> clearPreservedData(String routeName) async {
    _preservedFormData.remove(routeName);
    _preservedScrollPositions.remove(routeName);
    await _saveFormData();
    await _saveScrollPositions();
  }

  /// Get navigation analytics
  NavigationAnalytics getAnalytics() {
    final commonPaths = _calculateCommonPaths();
    final exitRates = _calculateExitRates();
    
    return NavigationAnalytics(
      routeVisitCount: Map.unmodifiable(_routeVisitCount),
      routeTimeSpent: Map.unmodifiable(_routeTimeSpent),
      commonPaths: commonPaths,
      exitRates: exitRates,
    );
  }

  /// Clear navigation history
  Future<void> clearHistory() async {
    _navigationStack.clear();
    _history.clear();
    _preservedFormData.clear();
    _preservedScrollPositions.clear();
    _routeVisitCount.clear();
    _routeTimeSpent.clear();
    
    await _saveNavigationState();
    await _saveFormData();
    await _saveScrollPositions();
  }

  /// Export navigation data for debugging
  Future<Map<String, dynamic>> exportNavigationData() async {
    return {
      'navigationStack': _navigationStack.map((c) => c.toMap()).toList(),
      'history': _history.map((h) => h.toMap()).toList(),
      'preservedFormData': _preservedFormData,
      'preservedScrollPositions': _preservedScrollPositions,
      'analytics': getAnalytics().toMap(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  // Private helper methods

  Future<void> _setupSystemBackHandler() async {
    SystemChannels.platform.setMethodCallHandler((call) async {
      if (call.method == 'SystemNavigator.pop') {
        final handled = await goBack();
        if (!handled) {
          SystemNavigator.pop();
        }
      }
    });
  }

  Future<bool> _handleSystemBack() async {
    // Let the system handle it (exit app or go to previous app)
    return false;
  }

  Future<void> _preserveCurrentContext() async {
    final routeName = currentRouteName;
    if (routeName == null) return;

    // This would be implemented with route-specific context preservation
    // For now, we save the current state
    await CacheService().set(
      'context:$routeName',
      {
        'timestamp': DateTime.now().toIso8601String(),
        'preserved': true,
      },
      policy: CacheExpiryPolicy.session,
    );
  }

  Future<void> _restoreContext(String routeName) async {
    try {
      final context = await CacheService().get<Map<String, dynamic>>('context:$routeName');
      if (context != null) {
        debugPrint('Restoring context for $routeName');
        // Context restoration would be handled by individual route widgets
      }
    } catch (e) {
      debugPrint('Error restoring context for $routeName: $e');
    }
  }

  void _addToHistory(String routeName, Map<String, dynamic> arguments) {
    final entry = NavigationHistoryEntry(
      routeName: routeName,
      arguments: arguments,
      timestamp: DateTime.now(),
      index: _navigationIndex++,
    );
    
    _history.add(entry);
    
    // Keep history size manageable
    if (_history.length > 100) {
      _history.removeAt(0);
    }
  }

  void _recordRouteVisit(String routeName) {
    _routeVisitCount[routeName] = (_routeVisitCount[routeName] ?? 0) + 1;
  }

  void _startRouteTimer(String routeName) {
    _routeStartTimes[routeName] = DateTime.now();
  }

  void _stopRouteTimer(String routeName) {
    final startTime = _routeStartTimes[routeName];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _routeTimeSpent[routeName] = (_routeTimeSpent[routeName] ?? Duration.zero) + duration;
      _routeStartTimes.remove(routeName);
    }
  }

  List<String> _calculateCommonPaths() {
    final pathCounts = <String, int>{};
    
    for (int i = 0; i < _history.length - 1; i++) {
      final current = _history[i].routeName;
      final next = _history[i + 1].routeName;
      final path = '$current->$next';
      pathCounts[path] = (pathCounts[path] ?? 0) + 1;
    }
    
    final sortedPaths = pathCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedPaths.take(10).map((e) => e.key).toList();
  }

  Map<String, double> _calculateExitRates() {
    final exitRates = <String, double>{};
    final routeExits = <String, int>{};
    
    for (final route in _routeVisitCount.keys) {
      final visits = _routeVisitCount[route] ?? 0;
      final exits = routeExits[route] ?? 0;
      if (visits > 0) {
        exitRates[route] = exits / visits;
      }
    }
    
    return exitRates;
  }

  Future<void> _loadNavigationState() async {
    try {
      // Load navigation stack
      final stackJson = _prefs?.getString(_navigationStackKey);
      if (stackJson != null) {
        final List<dynamic> stackData = jsonDecode(stackJson);
        _navigationStack.clear();
        _navigationStack.addAll(
          stackData.map((data) => NavigationContext.fromMap(data)),
        );
      }

      // Load navigation history
      final historyJson = _prefs?.getString(_navigationHistoryKey);
      if (historyJson != null) {
        final List<dynamic> historyData = jsonDecode(historyJson);
        _history.clear();
        _history.addAll(
          historyData.map((data) => NavigationHistoryEntry.fromMap(data)),
        );
      }

      // Load form data
      await _loadFormData();
      await _loadScrollPositions();
      await _loadAnalytics();

    } catch (e) {
      debugPrint('Error loading navigation state: $e');
    }
  }

  Future<void> _saveNavigationState() async {
    try {
      // Save navigation stack (keep only recent entries)
      final recentStack = _navigationStack.length > 20 
          ? _navigationStack.sublist(_navigationStack.length - 20)
          : _navigationStack;
      
      await _prefs?.setString(
        _navigationStackKey,
        jsonEncode(recentStack.map((c) => c.toMap()).toList()),
      );

      // Save navigation history (keep only recent entries)
      final recentHistory = _history.length > 50
          ? _history.sublist(_history.length - 50)
          : _history;
      
      await _prefs?.setString(
        _navigationHistoryKey,
        jsonEncode(recentHistory.map((h) => h.toMap()).toList()),
      );
    } catch (e) {
      debugPrint('Error saving navigation state: $e');
    }
  }

  Future<void> _loadFormData() async {
    try {
      final formDataJson = _prefs?.getString(_formDataKey);
      if (formDataJson != null) {
        final Map<String, dynamic> data = jsonDecode(formDataJson);
        _preservedFormData.clear();
        data.forEach((key, value) {
          _preservedFormData[key] = Map<String, dynamic>.from(value);
        });
      }
    } catch (e) {
      debugPrint('Error loading form data: $e');
    }
  }

  Future<void> _saveFormData() async {
    try {
      await _prefs?.setString(_formDataKey, jsonEncode(_preservedFormData));
    } catch (e) {
      debugPrint('Error saving form data: $e');
    }
  }

  Future<void> _loadScrollPositions() async {
    try {
      final scrollJson = _prefs?.getString('scroll_positions');
      if (scrollJson != null) {
        final Map<String, dynamic> data = jsonDecode(scrollJson);
        _preservedScrollPositions.clear();
        data.forEach((key, value) {
          _preservedScrollPositions[key] = Map<String, double>.from(value);
        });
      }
    } catch (e) {
      debugPrint('Error loading scroll positions: $e');
    }
  }

  Future<void> _saveScrollPositions() async {
    try {
      await _prefs?.setString('scroll_positions', jsonEncode(_preservedScrollPositions));
    } catch (e) {
      debugPrint('Error saving scroll positions: $e');
    }
  }

  Future<void> _loadAnalytics() async {
    try {
      final analyticsJson = _prefs?.getString(_analyticsKey);
      if (analyticsJson != null) {
        final Map<String, dynamic> data = jsonDecode(analyticsJson);
        
        // Load visit counts
        if (data['routeVisitCount'] != null) {
          _routeVisitCount.clear();
          final Map<String, dynamic> visitData = data['routeVisitCount'];
          visitData.forEach((key, value) {
            _routeVisitCount[key] = value as int;
          });
        }

        // Load time spent (simplified - would need duration parsing)
        if (data['routeTimeSpent'] != null) {
          _routeTimeSpent.clear();
          final Map<String, dynamic> timeData = data['routeTimeSpent'];
          timeData.forEach((key, value) {
            _routeTimeSpent[key] = Duration(milliseconds: value as int);
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading analytics: $e');
    }
  }

  Future<void> _saveAnalytics() async {
    try {
      final analyticsData = {
        'routeVisitCount': _routeVisitCount,
        'routeTimeSpent': _routeTimeSpent.map((key, value) => 
            MapEntry(key, value.inMilliseconds)),
      };
      
      await _prefs?.setString(_analyticsKey, jsonEncode(analyticsData));
    } catch (e) {
      debugPrint('Error saving analytics: $e');
    }
  }
}

/// Extension methods for NavigationAnalytics
extension NavigationAnalyticsExtension on NavigationAnalytics {
  Map<String, dynamic> toMap() {
    return {
      'routeVisitCount': routeVisitCount,
      'routeTimeSpent': routeTimeSpent.map((key, value) => 
          MapEntry(key, value.inMilliseconds)),
      'commonPaths': commonPaths,
      'exitRates': exitRates,
    };
  }
}

/// Mixin for widgets that want to preserve their state
mixin NavigationStateMixin<T extends StatefulWidget> on State<T> {
  String get routeName => widget.runtimeType.toString();

  @override
  void dispose() {
    // Preserve any form data or scroll positions before disposing
    _preserveWidgetState();
    super.dispose();
  }

  Future<void> _preserveWidgetState() async {
    // Subclasses can override this to preserve specific state
  }

  /// Preserve form data
  Future<void> preserveFormData(Map<String, dynamic> formData) async {
    await NavigationService().preserveFormData(routeName, formData);
  }

  /// Get preserved form data
  Map<String, dynamic>? getPreservedFormData() {
    return NavigationService().getPreservedFormData(routeName);
  }

  /// Preserve scroll position
  Future<void> preserveScrollPosition(String scrollKey, double position) async {
    await NavigationService().preserveScrollPosition(routeName, scrollKey, position);
  }

  /// Get preserved scroll position
  double? getPreservedScrollPosition(String scrollKey) {
    return NavigationService().getPreservedScrollPosition(routeName, scrollKey);
  }
}
