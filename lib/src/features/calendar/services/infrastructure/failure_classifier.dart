import 'package:planning/src/core/errors/failures.dart';

/// Strategy for classifying failures and determining retry eligibility.
abstract class FailureClassifier {
  /// Determines if a failure should trigger a retry attempt.
  bool isRetryable(Failure failure);
  
  /// Determines if a failure should be counted toward circuit breaker threshold.
  bool isCircuitBreakerRelevant(Failure failure) => isRetryable(failure);
}

/// Default implementation for calendar operation failure classification.
/// 
/// Considers network failures, server errors, and specific rate-limiting
/// scenarios as retryable conditions.
class CalendarFailureClassifier implements FailureClassifier {
  /// Set of HTTP status codes that indicate retryable server errors.
  static const Set<String> _retryableStatusCodes = {
    '429', // Too Many Requests
    '500', // Internal Server Error
    '502', // Bad Gateway
    '503', // Service Unavailable
    '504', // Gateway Timeout
  };

  /// Set of keywords in error messages that indicate retryable conditions.
  static const Set<String> _retryableErrorKeywords = {
    'timeout',
    'rate limit',
    'quota exceeded',
    'service unavailable',
    'internal server error',
    'temporarily unavailable',
    'network error',
    'connection failed',
    'connection reset',
    'dns resolution failed',
  };

  @override
  bool isRetryable(Failure failure) {
    // Network failures are generally retryable
    if (failure is NetworkFailure) {
      return _isRetryableNetworkFailure(failure);
    }
    
    // Server failures may be retryable depending on the cause
    if (failure is ServerFailure) {
      return _isRetryableServerFailure(failure);
    }
    
    // Other failure types are generally not retryable
    return false;
  }

  bool _isRetryableNetworkFailure(NetworkFailure failure) {
    final message = failure.message.toLowerCase();
    
    // Check for specific retryable status codes
    for (final statusCode in _retryableStatusCodes) {
      if (message.contains(statusCode)) {
        return true;
      }
    }
    
    // Check for retryable error keywords
    for (final keyword in _retryableErrorKeywords) {
      if (message.contains(keyword)) {
        return true;
      }
    }
    
    // Generic network failures are typically retryable
    return true;
  }

  bool _isRetryableServerFailure(ServerFailure failure) {
    final message = failure.message.toLowerCase();
    
    // Check for specific retryable status codes
    for (final statusCode in _retryableStatusCodes) {
      if (message.contains(statusCode)) {
        return true;
      }
    }
    
    // Check for retryable error keywords
    for (final keyword in _retryableErrorKeywords) {
      if (message.contains(keyword)) {
        return true;
      }
    }
    
    // Authentication and validation errors are not retryable
    if (message.contains('auth') || 
        message.contains('permission') ||
        message.contains('invalid') ||
        message.contains('malformed')) {
      return false;
    }
    
    // Generic server failures may be retryable
    return message.contains('server') || message.contains('internal');
  }

  @override
  bool isCircuitBreakerRelevant(Failure failure) {
    // Circuit breaker should only consider actual service failures,
    // not client-side errors like validation failures
    if (failure is NetworkFailure) {
      final message = failure.message.toLowerCase();
      
      // Don't count authentication/authorization failures
      if (message.contains('auth') || 
          message.contains('permission') ||
          message.contains('unauthorized') ||
          message.contains('forbidden')) {
        return false;
      }
      
      return true;
    }
    
    if (failure is ServerFailure) {
      final message = failure.message.toLowerCase();
      
      // Don't count authentication/authorization failures
      if (message.contains('auth') || 
          message.contains('permission') ||
          message.contains('unauthorized') ||
          message.contains('forbidden')) {
        return false;
      }
      
      return true;
    }
    
    return false;
  }
}

/// Conservative failure classifier that only retries on network timeouts
/// and specific server errors.
class ConservativeFailureClassifier implements FailureClassifier {
  @override
  bool isRetryable(Failure failure) {
    if (failure is NetworkFailure) {
      final message = failure.message.toLowerCase();
      return message.contains('timeout') || 
             message.contains('connection') ||
             message.contains('503') ||
             message.contains('502');
    }
    
    return false;
  }

  @override
  bool isCircuitBreakerRelevant(Failure failure) {
    // Only count network and server failures
    return failure is NetworkFailure || failure is ServerFailure;
  }
}

/// Aggressive failure classifier that retries on most error conditions
/// except for clear client errors.
class AggressiveFailureClassifier implements FailureClassifier {
  @override
  bool isRetryable(Failure failure) {
    // Don't retry on cache or validation failures
    if (failure is CacheFailure || failure is ValidationFailure) {
      return false;
    }
    
    // Don't retry on clear authentication failures
    if (failure is ServerFailure && 
        (failure.message.contains('401') || 
         failure.message.contains('403') ||
         failure.message.toLowerCase().contains('unauthorized'))) {
      return false;
    }
    
    // Retry on all other failures
    return true;
  }

  @override
  bool isCircuitBreakerRelevant(Failure failure) {
    // Count most failures except client-side errors
    return !(failure is CacheFailure || failure is ValidationFailure);
  }
}
