import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Error types for categorized handling
enum ErrorType {
  network,
  timeout,
  authentication,
  authorization,
  validation,
  serverError,
  rateLimited,
  unknown,
}

/// Retry strategies
enum RetryStrategy {
  fixed,           // Fixed delay between retries
  exponential,     // Exponential backoff
  linear,          // Linear increase in delay
  fibonacci,       // Fibonacci sequence delays
  custom,          // Custom strategy
}

/// Circuit breaker states
enum CircuitBreakerState {
  closed,    // Normal operation
  open,      // Failing fast
  halfOpen,  // Testing if service recovered
}

/// Error classification and metadata
class CycleSyncError {
  final String message;
  final ErrorType type;
  final int? statusCode;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;
  final String? stackTrace;
  final Exception? originalException;

  const CycleSyncError({
    required this.message,
    required this.type,
    this.statusCode,
    this.metadata,
    required this.timestamp,
    this.stackTrace,
    this.originalException,
  });

  bool get isRetryable {
    switch (type) {
      case ErrorType.network:
      case ErrorType.timeout:
      case ErrorType.serverError:
      case ErrorType.rateLimited:
        return true;
      case ErrorType.authentication:
      case ErrorType.authorization:
      case ErrorType.validation:
      case ErrorType.unknown:
        return false;
    }
  }

  factory CycleSyncError.fromException(Exception exception, {Map<String, dynamic>? metadata}) {
    ErrorType type = ErrorType.unknown;
    int? statusCode;
    String message = exception.toString();

    if (exception is SocketException) {
      type = ErrorType.network;
      message = 'Network connection failed';
    } else if (exception is TimeoutException) {
      type = ErrorType.timeout;
      message = 'Request timed out';
    } else if (exception is HttpException) {
      final httpException = exception;
      statusCode = int.tryParse(httpException.message.split(' ').first);
      
      if (statusCode != null) {
        if (statusCode == 401) {
          type = ErrorType.authentication;
          message = 'Authentication required';
        } else if (statusCode == 403) {
          type = ErrorType.authorization;
          message = 'Access forbidden';
        } else if (statusCode >= 400 && statusCode < 500) {
          type = ErrorType.validation;
          message = 'Invalid request';
        } else if (statusCode == 429) {
          type = ErrorType.rateLimited;
          message = 'Too many requests';
        } else if (statusCode >= 500) {
          type = ErrorType.serverError;
          message = 'Server error';
        }
      }
    }

    return CycleSyncError(
      message: message,
      type: type,
      statusCode: statusCode,
      metadata: metadata,
      timestamp: DateTime.now(),
      stackTrace: StackTrace.current.toString(),
      originalException: exception,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'type': type.name,
      'statusCode': statusCode,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
      'stackTrace': stackTrace,
    };
  }
}

/// Retry configuration
class RetryConfig {
  final int maxRetries;
  final Duration initialDelay;
  final Duration maxDelay;
  final RetryStrategy strategy;
  final double backoffMultiplier;
  final double jitter;
  final bool Function(CycleSyncError)? retryIf;

  const RetryConfig({
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 30),
    this.strategy = RetryStrategy.exponential,
    this.backoffMultiplier = 2.0,
    this.jitter = 0.1,
    this.retryIf,
  });

  static const RetryConfig network = RetryConfig(
    maxRetries: 5,
    initialDelay: Duration(milliseconds: 1000),
    strategy: RetryStrategy.exponential,
    backoffMultiplier: 1.5,
  );

  static const RetryConfig api = RetryConfig(
    maxRetries: 3,
    initialDelay: Duration(milliseconds: 500),
    strategy: RetryStrategy.exponential,
  );

  static const RetryConfig database = RetryConfig(
    maxRetries: 2,
    initialDelay: Duration(milliseconds: 100),
    strategy: RetryStrategy.fixed,
  );
}

/// Circuit breaker for failing services
class CircuitBreaker {
  final String name;
  final int failureThreshold;
  final Duration timeout;
  final Duration resetTimeout;

  CircuitBreakerState _state = CircuitBreakerState.closed;
  int _failureCount = 0;
  DateTime? _lastFailureTime;
  DateTime? _nextAttemptTime;

  CircuitBreaker({
    required this.name,
    this.failureThreshold = 5,
    this.timeout = const Duration(seconds: 30),
    this.resetTimeout = const Duration(minutes: 1),
  });

  CircuitBreakerState get state => _state;

  bool get canExecute {
    switch (_state) {
      case CircuitBreakerState.closed:
        return true;
      case CircuitBreakerState.open:
        if (_nextAttemptTime != null && DateTime.now().isAfter(_nextAttemptTime!)) {
          _state = CircuitBreakerState.halfOpen;
          return true;
        }
        return false;
      case CircuitBreakerState.halfOpen:
        return true;
    }
  }

  void recordSuccess() {
    _failureCount = 0;
    _state = CircuitBreakerState.closed;
    _lastFailureTime = null;
    _nextAttemptTime = null;
  }

  void recordFailure() {
    _failureCount++;
    _lastFailureTime = DateTime.now();

    if (_state == CircuitBreakerState.halfOpen) {
      _state = CircuitBreakerState.open;
      _nextAttemptTime = DateTime.now().add(resetTimeout);
    } else if (_failureCount >= failureThreshold) {
      _state = CircuitBreakerState.open;
      _nextAttemptTime = DateTime.now().add(resetTimeout);
    }
  }

  Map<String, dynamic> getStatus() {
    return {
      'name': name,
      'state': _state.name,
      'failureCount': _failureCount,
      'lastFailureTime': _lastFailureTime?.toIso8601String(),
      'nextAttemptTime': _nextAttemptTime?.toIso8601String(),
    };
  }
}

/// Comprehensive retry service with circuit breakers and intelligent error handling
class RetryService {
  static final RetryService _instance = RetryService._internal();
  factory RetryService() => _instance;
  RetryService._internal();

  final Map<String, CircuitBreaker> _circuitBreakers = {};
  final List<CycleSyncError> _errorHistory = [];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  
  bool _isOnline = true;
  static const int _maxErrorHistory = 1000;

  /// Initialize the retry service
  Future<void> initialize() async {
    // Monitor connectivity
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      _isOnline = result != ConnectivityResult.none;
      debugPrint('🌐 Connectivity changed: ${_isOnline ? "Online" : "Offline"}');
    });

    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    _isOnline = result != ConnectivityResult.none;
  }

  /// Execute a function with retry logic and error handling
  Future<T> execute<T>(
    String operationName,
    Future<T> Function() operation, {
    RetryConfig config = const RetryConfig(),
    bool useCircuitBreaker = true,
  }) async {
    final circuitBreaker = useCircuitBreaker ? _getOrCreateCircuitBreaker(operationName) : null;

    // Check circuit breaker
    if (circuitBreaker != null && !circuitBreaker.canExecute) {
      throw CycleSyncError(
        message: 'Circuit breaker is open for $operationName',
        type: ErrorType.serverError,
        timestamp: DateTime.now(),
      );
    }

    CycleSyncError? lastError;
    final random = Random();

    for (int attempt = 0; attempt <= config.maxRetries; attempt++) {
      try {
        // Check if we should retry based on connectivity
        if (!_isOnline && _requiresNetwork(operationName)) {
          await _waitForConnectivity();
        }

        final result = await operation();
        
        // Record success
        circuitBreaker?.recordSuccess();
        
        if (attempt > 0) {
          debugPrint('✅ $operationName succeeded after $attempt retries');
        }
        
        return result;
      } catch (e) {
        final error = e is CycleSyncError ? e : CycleSyncError.fromException(e as Exception);
        lastError = error;
        
        // Log error
        _logError(error, operationName, attempt);
        
        // Check if error is retryable
        final shouldRetry = _shouldRetry(error, attempt, config.maxRetries);
        
        if (!shouldRetry) {
          circuitBreaker?.recordFailure();
          break;
        }

        // Calculate delay for next retry
        if (attempt < config.maxRetries) {
          final delay = _calculateDelay(config, attempt, random);
          debugPrint('⏳ Retrying $operationName in ${delay.inMilliseconds}ms (attempt ${attempt + 1}/${config.maxRetries})');
          await Future.delayed(delay);
        }
      }
    }

    circuitBreaker?.recordFailure();
    throw lastError!;
  }

  /// Execute with timeout and automatic retry
  Future<T> executeWithTimeout<T>(
    String operationName,
    Future<T> Function() operation,
    Duration timeout, {
    RetryConfig config = const RetryConfig(),
  }) async {
    return execute(
      operationName,
      () => operation().timeout(timeout),
      config: config,
    );
  }

  /// Batch execute multiple operations with individual error handling
  Future<List<T?>> executeBatch<T>(
    List<String> operationNames,
    List<Future<T> Function()> operations, {
    RetryConfig config = const RetryConfig(),
    bool continueOnError = true,
  }) async {
    final results = <T?>[];
    
    for (int i = 0; i < operations.length; i++) {
      try {
        final result = await execute(
          operationNames[i],
          operations[i],
          config: config,
        );
        results.add(result);
      } catch (e) {
        if (!continueOnError) rethrow;
        results.add(null);
      }
    }
    
    return results;
  }

  /// Execute with automatic fallback
  Future<T> executeWithFallback<T>(
    String operationName,
    Future<T> Function() primaryOperation,
    Future<T> Function() fallbackOperation, {
    RetryConfig config = const RetryConfig(),
  }) async {
    try {
      return await execute(operationName, primaryOperation, config: config);
    } catch (primaryError) {
      debugPrint('🔄 Primary operation failed, trying fallback for $operationName');
      
      try {
        return await execute('${operationName}_fallback', fallbackOperation);
      } catch (fallbackError) {
        debugPrint('❌ Both primary and fallback operations failed for $operationName');
        rethrow;
      }
    }
  }

  /// Get circuit breaker status
  Map<String, dynamic> getCircuitBreakerStatus(String operationName) {
    final breaker = _circuitBreakers[operationName];
    return breaker?.getStatus() ?? {'name': operationName, 'state': 'not_exists'};
  }

  /// Get all circuit breaker statuses
  Map<String, Map<String, dynamic>> getAllCircuitBreakersStatus() {
    return _circuitBreakers.map((key, breaker) => MapEntry(key, breaker.getStatus()));
  }

  /// Get error history
  List<CycleSyncError> getErrorHistory({int? limit, ErrorType? type}) {
    var errors = _errorHistory.reversed.toList();
    
    if (type != null) {
      errors = errors.where((e) => e.type == type).toList();
    }
    
    if (limit != null && errors.length > limit) {
      errors = errors.take(limit).toList();
    }
    
    return errors;
  }

  /// Clear error history
  void clearErrorHistory() {
    _errorHistory.clear();
  }

  /// Reset circuit breaker
  void resetCircuitBreaker(String operationName) {
    final breaker = _circuitBreakers[operationName];
    if (breaker != null) {
      breaker.recordSuccess();
      debugPrint('🔄 Reset circuit breaker for $operationName');
    }
  }

  /// Reset all circuit breakers
  void resetAllCircuitBreakers() {
    for (final breaker in _circuitBreakers.values) {
      breaker.recordSuccess();
    }
    debugPrint('🔄 Reset all circuit breakers');
  }

  // Private helper methods

  CircuitBreaker _getOrCreateCircuitBreaker(String operationName) {
    return _circuitBreakers.putIfAbsent(
      operationName,
      () => CircuitBreaker(name: operationName),
    );
  }

  bool _shouldRetry(CycleSyncError error, int attempt, int maxRetries) {
    if (attempt >= maxRetries) return false;
    if (!error.isRetryable) return false;
    
    // Don't retry auth errors immediately
    if (error.type == ErrorType.authentication || error.type == ErrorType.authorization) {
      return false;
    }
    
    // Special handling for rate limiting
    if (error.type == ErrorType.rateLimited) {
      return attempt < 2; // Only retry rate limited requests twice
    }
    
    return true;
  }

  Duration _calculateDelay(RetryConfig config, int attempt, Random random) {
    Duration delay;
    
    switch (config.strategy) {
      case RetryStrategy.fixed:
        delay = config.initialDelay;
        break;
      
      case RetryStrategy.linear:
        delay = Duration(
          milliseconds: config.initialDelay.inMilliseconds * (attempt + 1),
        );
        break;
      
      case RetryStrategy.exponential:
        delay = Duration(
          milliseconds: (config.initialDelay.inMilliseconds * 
                        pow(config.backoffMultiplier, attempt)).round(),
        );
        break;
      
      case RetryStrategy.fibonacci:
        delay = Duration(
          milliseconds: config.initialDelay.inMilliseconds * _fibonacci(attempt + 1),
        );
        break;
      
      case RetryStrategy.custom:
        // For custom strategies, use exponential as default
        delay = Duration(
          milliseconds: (config.initialDelay.inMilliseconds * 
                        pow(config.backoffMultiplier, attempt)).round(),
        );
        break;
    }

    // Apply maximum delay limit
    if (delay > config.maxDelay) {
      delay = config.maxDelay;
    }

    // Apply jitter to avoid thundering herd
    if (config.jitter > 0) {
      final jitterMs = (delay.inMilliseconds * config.jitter * random.nextDouble()).round();
      delay = Duration(milliseconds: delay.inMilliseconds + jitterMs);
    }

    return delay;
  }

  int _fibonacci(int n) {
    if (n <= 1) return n;
    int a = 0, b = 1;
    for (int i = 2; i <= n; i++) {
      int temp = a + b;
      a = b;
      b = temp;
    }
    return b;
  }

  bool _requiresNetwork(String operationName) {
    // Operations that require network connectivity
    final networkOperations = [
      'api_call',
      'upload',
      'download',
      'sync',
      'authenticate',
      'fetch',
    ];
    
    return networkOperations.any((op) => operationName.toLowerCase().contains(op));
  }

  Future<void> _waitForConnectivity() async {
    if (_isOnline) return;
    
    final completer = Completer<void>();
    late StreamSubscription<ConnectivityResult> subscription;
    
    subscription = _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        _isOnline = true;
        subscription.cancel();
        completer.complete();
      }
    });
    
    // Timeout after 30 seconds
    Timer(const Duration(seconds: 30), () {
      if (!completer.isCompleted) {
        subscription.cancel();
        completer.completeError(
          CycleSyncError(
            message: 'Network connectivity timeout',
            type: ErrorType.timeout,
            timestamp: DateTime.now(),
          ),
        );
      }
    });
    
    return completer.future;
  }

  void _logError(CycleSyncError error, String operationName, int attempt) {
    // Add to error history
    _errorHistory.add(error);
    
    // Keep history size manageable
    if (_errorHistory.length > _maxErrorHistory) {
      _errorHistory.removeAt(0);
    }
    
    // Log error details
    debugPrint('''
❌ Error in $operationName (attempt ${attempt + 1}):
   Type: ${error.type.name}
   Message: ${error.message}
   Status: ${error.statusCode}
   Time: ${error.timestamp}
''');
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription.cancel();
  }
}

/// Convenience extensions for common retry patterns
extension RetryExtensions on Future<T> Function() {
  /// Execute with default retry configuration
  Future<T> withRetry<T>(String operationName) {
    return RetryService().execute(operationName, this);
  }

  /// Execute with network retry configuration
  Future<T> withNetworkRetry<T>(String operationName) {
    return RetryService().execute(operationName, this, config: RetryConfig.network);
  }

  /// Execute with API retry configuration
  Future<T> withApiRetry<T>(String operationName) {
    return RetryService().execute(operationName, this, config: RetryConfig.api);
  }

  /// Execute with timeout and retry
  Future<T> withTimeoutAndRetry<T>(String operationName, Duration timeout) {
    return RetryService().executeWithTimeout(operationName, this, timeout);
  }
}
