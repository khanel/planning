import 'dart:async';
import 'dart:math';
import 'package:dartz/dartz.dart';
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/features/calendar/services/calendar_sync_service.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event.dart';

/// Service that provides advanced retry mechanisms and circuit breaker pattern
/// for calendar synchronization operations.
/// 
/// Implements exponential backoff with jitter, circuit breaker pattern,
/// and configurable retry policies for enhanced reliability.
class CalendarRetryService {
  final CalendarSyncService syncService;
  final int maxRetries;
  final int baseDelayMs;
  final int maxDelayMs;
  
  // Circuit breaker state
  int _failureCount = 0;
  DateTime? _circuitOpenTime;
  static const int _circuitBreakerThreshold = 5;
  static const int _circuitRecoveryTimeoutMs = 30000;
  
  CalendarRetryService({
    required this.syncService,
    this.maxRetries = 3,
    this.baseDelayMs = 1000,
    this.maxDelayMs = 30000,
  });

  /// Performs calendar sync with advanced retry mechanisms.
  /// 
  /// Implements exponential backoff with jitter, respects circuit breaker state,
  /// and handles specific error types appropriately.
  /// 
  /// Total attempts = 1 initial + maxRetries retries
  Future<Either<Failure, List<CalendarEvent>>> performSyncWithRetry({
    int? rateLimitDelayMs,
  }) async {
    // Check circuit breaker state
    if (_isCircuitOpen()) {
      return Left(ServerFailure('Circuit breaker is open'));
    }

    int attempt = 0;
    Either<Failure, List<CalendarEvent>>? lastResult;

    // Initial attempt + retry attempts (maxRetries)
    while (attempt <= maxRetries) {
      try {
        final result = await syncService.performFullSync();
        
        if (result.isRight()) {
          // Success - reset circuit breaker
          _resetCircuitBreaker();
          return result;
        }
        
        lastResult = result;
        final failure = result.fold((l) => l, (r) => null)!;
        
        // Record failure for circuit breaker tracking
        _recordFailure();
        
        // Check if this is a retryable failure or if we've exhausted retries
        if (!_isRetryableFailure(failure) || attempt >= maxRetries) {
          return result;
        }
        
        // Calculate delay with exponential backoff and jitter
        final delay = _calculateDelay(attempt, rateLimitDelayMs);
        await Future.delayed(Duration(milliseconds: delay));
        
        attempt++;
      } catch (e) {
        _recordFailure();
        return Left(ServerFailure('Unexpected error: $e'));
      }
    }
    
    return lastResult ?? Left(ServerFailure('Max retries exceeded'));
  }

  /// Determines if a failure type should trigger retries.
  bool _isRetryableFailure(Failure failure) {
    return failure is NetworkFailure || 
           failure is ServerFailure ||
           (failure is NetworkFailure && 
            (failure.message.contains('429') || 
             failure.message.contains('503') ||
             failure.message.contains('timeout') ||
             failure.message.contains('Rate limit')));
  }

  /// Calculates delay with exponential backoff and jitter.
  int _calculateDelay(int attempt, int? rateLimitDelayMs) {
    if (rateLimitDelayMs != null) {
      return rateLimitDelayMs;
    }
    
    // Exponential backoff: base * 2^attempt
    final exponentialDelay = baseDelayMs * (1 << attempt);
    
    // Cap at max delay
    final cappedDelay = exponentialDelay.clamp(baseDelayMs, maxDelayMs);
    
    // Add jitter (±25% randomization)
    final jitterRange = (cappedDelay * 0.25).round();
    final jitter = Random().nextInt(jitterRange * 2) - jitterRange;
    
    return (cappedDelay + jitter).clamp(baseDelayMs ~/ 2, maxDelayMs);
  }

  /// Checks if circuit breaker is open.
  bool _isCircuitOpen() {
    if (_failureCount < _circuitBreakerThreshold) {
      return false;
    }
    
    if (_circuitOpenTime == null) {
      _circuitOpenTime = DateTime.now();
      return true;
    }
    
    final timeSinceOpen = DateTime.now().difference(_circuitOpenTime!).inMilliseconds;
    return timeSinceOpen < _circuitRecoveryTimeoutMs;
  }

  /// Records a failure for circuit breaker tracking.
  void _recordFailure() {
    _failureCount++;
    if (_failureCount >= _circuitBreakerThreshold && _circuitOpenTime == null) {
      _circuitOpenTime = DateTime.now();
    }
  }

  /// Resets circuit breaker state on successful operation.
  void _resetCircuitBreaker() {
    _failureCount = 0;
    _circuitOpenTime = null;
  }

  /// Resets circuit breaker for testing purposes.
  Future<void> resetCircuitBreakerForTesting() async {
    _resetCircuitBreaker();
  }
}
