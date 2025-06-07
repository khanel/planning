import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/features/calendar/services/sync/calendar_sync_service.dart';
import 'package:planning/src/features/calendar/services/infrastructure/retry_config.dart';
import 'package:planning/src/features/calendar/services/infrastructure/circuit_breaker.dart';
import 'package:planning/src/features/calendar/services/infrastructure/delay_calculator.dart';
import 'package:planning/src/features/calendar/services/infrastructure/failure_classifier.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event.dart';

/// Service that provides advanced retry mechanisms and circuit breaker pattern
/// for calendar synchronization operations.
/// 
/// Implements exponential backoff with jitter, circuit breaker pattern,
/// and configurable retry policies for enhanced reliability.
/// 
/// This refactored version uses dependency injection and strategy patterns
/// for better testability and maintainability.
class CalendarRetryService {
  // REFACTOR: Configuration constants for better maintainability
  static const int _defaultFailureThreshold = 5;
  static const int _defaultRecoveryTimeoutMs = 30000;
  static const int _defaultBaseDelayMs = 1000;
  static const int _defaultMaxDelayMs = 30000;
  static const double _defaultJitterPercentage = 0.25;
  
  // REFACTOR: Error message constants for consistency
  static const String _circuitBreakerOpenMessage = 
      'Circuit breaker is open. Remaining recovery time:';
  static const String _maxRetriesExceededMessage = 'Max retries exceeded';
  static const String _unexpectedErrorMessage = 'Unexpected error during sync:';

  final CalendarSyncService syncService;
  final RetryConfig config;
  final CircuitBreaker circuitBreaker;
  final DelayCalculator delayCalculator;
  final FailureClassifier failureClassifier;

  CalendarRetryService({
    required this.syncService,
    RetryConfig? config,
    CircuitBreaker? circuitBreaker,
    DelayCalculator? delayCalculator,
    FailureClassifier? failureClassifier,
  }) : config = config ?? const RetryConfig(),
       circuitBreaker = circuitBreaker ?? CircuitBreaker(
         failureThreshold: config?.circuitBreakerThreshold ?? _defaultFailureThreshold,
         recoveryTimeoutMs: config?.circuitRecoveryTimeoutMs ?? _defaultRecoveryTimeoutMs,
       ),
       delayCalculator = delayCalculator ?? ExponentialBackoffCalculator(
         baseDelayMs: config?.baseDelayMs ?? _defaultBaseDelayMs,
         maxDelayMs: config?.maxDelayMs ?? _defaultMaxDelayMs,
         jitterPercentage: config?.jitterPercentage ?? _defaultJitterPercentage,
       ),
       failureClassifier = failureClassifier ?? CalendarFailureClassifier();

  /// Factory constructor for aggressive retry configuration.
  /// 
  /// Creates a service with aggressive retry settings for scenarios where
  /// high availability is critical and network conditions may be unstable.
  factory CalendarRetryService.aggressive({
    required CalendarSyncService syncService,
  }) {
    final config = RetryConfig.aggressive();
    return CalendarRetryService(
      syncService: syncService,
      config: config,
      circuitBreaker: CircuitBreaker(
        failureThreshold: config.circuitBreakerThreshold,
        recoveryTimeoutMs: config.circuitRecoveryTimeoutMs,
      ),
      delayCalculator: ExponentialBackoffCalculator(
        baseDelayMs: config.baseDelayMs,
        maxDelayMs: config.maxDelayMs,
        jitterPercentage: config.jitterPercentage,
      ),
      failureClassifier: AggressiveFailureClassifier(),
    );
  }

  /// Factory constructor for conservative retry configuration.
  /// 
  /// Creates a service with conservative retry settings for scenarios where
  /// network reliability is more important than immediate availability.
  factory CalendarRetryService.conservative({
    required CalendarSyncService syncService,
  }) {
    final config = RetryConfig.conservative();
    return CalendarRetryService(
      syncService: syncService,
      config: config,
      circuitBreaker: CircuitBreaker(
        failureThreshold: config.circuitBreakerThreshold,
        recoveryTimeoutMs: config.circuitRecoveryTimeoutMs,
      ),
      delayCalculator: ExponentialBackoffCalculator(
        baseDelayMs: config.baseDelayMs,
        maxDelayMs: config.maxDelayMs,
        jitterPercentage: config.jitterPercentage,
      ),
      failureClassifier: ConservativeFailureClassifier(),
    );
  }

  /// Factory constructor with no retry logic (immediate failure).
  /// 
  /// Creates a service that fails immediately without retries, useful for
  /// testing scenarios or when retry logic needs to be disabled.
  factory CalendarRetryService.noRetry({
    required CalendarSyncService syncService,
  }) {
    final config = RetryConfig.noRetry();
    return CalendarRetryService(
      syncService: syncService,
      config: config,
      circuitBreaker: CircuitBreaker(
        failureThreshold: config.circuitBreakerThreshold,
        recoveryTimeoutMs: config.circuitRecoveryTimeoutMs,
      ),
      delayCalculator: FixedDelayCalculator(delayMs: config.baseDelayMs),
      failureClassifier: ConservativeFailureClassifier(),
    );
  }

  /// Performs calendar sync with advanced retry mechanisms.
  /// 
  /// Implements exponential backoff with jitter, respects circuit breaker state,
  /// and handles specific error types appropriately.
  /// 
  /// The [rateLimitDelayMs] parameter allows overriding delay calculation
  /// when rate limiting is detected from server responses.
  /// 
  /// Returns either a [Failure] or a list of [CalendarEvent]s on success.
  /// Total attempts = 1 initial + maxRetries retries.
  Future<Either<Failure, List<CalendarEvent>>> performSyncWithRetry({
    int? rateLimitDelayMs,
  }) async {
    if (circuitBreaker.isOpen) {
      return Left(ServerFailure(
        '$_circuitBreakerOpenMessage ${circuitBreaker.remainingRecoveryTimeMs}ms'
      ));
    }

    return _executeWithRetry(rateLimitDelayMs: rateLimitDelayMs);
  }

  /// Executes the sync operation with retry logic.
  /// 
  /// This method implements the core retry algorithm:
  /// 1. Attempts the sync operation
  /// 2. Records success/failure for circuit breaker
  /// 3. Determines if retry should be attempted
  /// 4. Applies appropriate delay
  /// 5. Repeats until success or max retries exceeded
  Future<Either<Failure, List<CalendarEvent>>> _executeWithRetry({
    int? rateLimitDelayMs,
  }) async {
    int attemptNumber = 0;
    Either<Failure, List<CalendarEvent>>? lastResult;

    // Initial attempt + retry attempts (maxRetries)
    while (attemptNumber <= config.maxRetries) {
      try {
        final result = await _performSyncAttempt();
        
        if (result.isRight()) {
          circuitBreaker.recordSuccess();
          return result;
        }
        
        lastResult = result;
        final failure = result.getLeft();
        
        // Record failure for circuit breaker if relevant
        if (failureClassifier.isCircuitBreakerRelevant(failure)) {
          circuitBreaker.recordFailure();
        }
        
        // Check if this failure should trigger a retry
        if (!_shouldRetry(failure, attemptNumber)) {
          return result;
        }
        
        // Calculate and apply delay before retry
        await _applyRetryDelay(attemptNumber, rateLimitDelayMs);
        
        attemptNumber++;
      } catch (exception) {
        circuitBreaker.recordFailure();
        return Left(ServerFailure('$_unexpectedErrorMessage $exception'));
      }
    }
    
    return lastResult ?? Left(ServerFailure(_maxRetriesExceededMessage));
  }

  /// Performs a single sync attempt.
  /// 
  /// Extracted for better testability and separation of concerns.
  Future<Either<Failure, List<CalendarEvent>>> _performSyncAttempt() async {
    return syncService.performFullSync();
  }

  /// Determines if a retry should be attempted for the given failure and attempt.
  /// 
  /// Takes into account:
  /// - Current attempt number vs maximum retries
  /// - Failure type and classification
  /// - Circuit breaker state
  bool _shouldRetry(Failure failure, int attemptNumber) {
    // Don't retry if we've reached the maximum number of attempts
    if (attemptNumber >= config.maxRetries) {
      return false;
    }
    
    // Check if the failure type is retryable
    return failureClassifier.isRetryable(failure);
  }

  /// Applies the calculated delay before the next retry attempt.
  /// 
  /// Uses the configured delay calculator to determine appropriate delay,
  /// respecting rate limit overrides when provided.
  Future<void> _applyRetryDelay(int attemptNumber, int? rateLimitDelayMs) async {
    final delayMs = delayCalculator.calculateDelay(
      attemptNumber,
      rateLimitDelayMs: rateLimitDelayMs,
    );
    
    if (delayMs > 0) {
      await Future.delayed(Duration(milliseconds: delayMs));
    }
  }

  /// Resets circuit breaker for testing purposes.
  /// 
  /// This method should only be used in testing scenarios.
  /// In production, circuit breaker recovery is handled automatically.
  Future<void> resetCircuitBreakerForTesting() async {
    circuitBreaker.reset();
  }

  /// Gets the current state of the circuit breaker.
  /// 
  /// Useful for monitoring and debugging purposes.
  bool get isCircuitBreakerOpen => circuitBreaker.isOpen;

  /// Gets the current failure count in the circuit breaker.
  /// 
  /// Useful for monitoring circuit breaker health.
  int get circuitBreakerFailureCount => circuitBreaker.failureCount;

  /// Gets comprehensive information about the current configuration.
  /// 
  /// Returns a map containing all relevant configuration parameters
  /// for debugging, monitoring, and logging purposes.
  Map<String, dynamic> get configInfo => {
    'maxRetries': config.maxRetries,
    'baseDelayMs': config.baseDelayMs,
    'maxDelayMs': config.maxDelayMs,
    'circuitBreakerThreshold': config.circuitBreakerThreshold,
    'circuitRecoveryTimeoutMs': config.circuitRecoveryTimeoutMs,
    'jitterPercentage': config.jitterPercentage,
    'delayCalculator': delayCalculator.toString(),
    'failureClassifier': failureClassifier.toString(),
    'circuitBreakerState': isCircuitBreakerOpen ? 'OPEN' : 'CLOSED',
    'currentFailureCount': circuitBreakerFailureCount,
  };
}

// REFACTOR: Add extension for better readability
extension _EitherExtension<L, R> on Either<L, R> {
  L getLeft() => fold((l) => l, (r) => throw StateError('Called getLeft on Right'));
}
