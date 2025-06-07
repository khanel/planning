import 'dart:math';

/// Strategy for calculating retry delays with various backoff algorithms.
abstract class DelayCalculator {
  /// Calculates the delay for a given retry attempt.
  /// 
  /// [attempt] is the retry attempt number (0-based).
  /// [rateLimitDelayMs] overrides the calculated delay if provided.
  int calculateDelay(int attempt, {int? rateLimitDelayMs});
}

/// Implements exponential backoff with jitter for retry delays.
/// 
/// Uses the formula: delay = min(baseDelay * 2^attempt, maxDelay) + jitter
/// where jitter is a random value within ±(jitterPercentage * delay).
class ExponentialBackoffCalculator implements DelayCalculator {
  final int baseDelayMs;
  final int maxDelayMs;
  final double jitterPercentage;
  final Random _random;

  ExponentialBackoffCalculator({
    required this.baseDelayMs,
    required this.maxDelayMs,
    required this.jitterPercentage,
    Random? random,
  }) : assert(baseDelayMs > 0),
       assert(maxDelayMs >= baseDelayMs),
       assert(jitterPercentage >= 0.0 && jitterPercentage <= 1.0),
       _random = random ?? Random();

  @override
  int calculateDelay(int attempt, {int? rateLimitDelayMs}) {
    if (rateLimitDelayMs != null) {
      return rateLimitDelayMs;
    }
    
    // Calculate exponential backoff: base * 2^attempt
    final exponentialDelay = baseDelayMs * (1 << attempt);
    
    // Cap at maximum delay
    final cappedDelay = exponentialDelay.clamp(baseDelayMs, maxDelayMs);
    
    // Add jitter to prevent thundering herd effect
    final jitter = _calculateJitter(cappedDelay);
    
    // Ensure minimum delay is reasonable (at least half of base delay)
    final finalDelay = (cappedDelay + jitter).clamp(baseDelayMs ~/ 2, maxDelayMs);
    
    return finalDelay;
  }

  /// Calculates jitter as a random value within ±(jitterPercentage * delay).
  int _calculateJitter(int delay) {
    if (jitterPercentage == 0.0) return 0;
    
    final jitterRange = (delay * jitterPercentage).round();
    return _random.nextInt(jitterRange * 2) - jitterRange;
  }

  @override
  String toString() {
    return 'ExponentialBackoffCalculator('
        'baseDelayMs: $baseDelayMs, '
        'maxDelayMs: $maxDelayMs, '
        'jitterPercentage: $jitterPercentage'
        ')';
  }
}

/// Implements linear backoff for retry delays.
/// 
/// Uses the formula: delay = min(baseDelay + (increment * attempt), maxDelay) + jitter
class LinearBackoffCalculator implements DelayCalculator {
  final int baseDelayMs;
  final int maxDelayMs;
  final int incrementMs;
  final double jitterPercentage;
  final Random _random;

  LinearBackoffCalculator({
    required this.baseDelayMs,
    required this.maxDelayMs,
    required this.incrementMs,
    required this.jitterPercentage,
    Random? random,
  }) : assert(baseDelayMs > 0),
       assert(maxDelayMs >= baseDelayMs),
       assert(incrementMs >= 0),
       assert(jitterPercentage >= 0.0 && jitterPercentage <= 1.0),
       _random = random ?? Random();

  @override
  int calculateDelay(int attempt, {int? rateLimitDelayMs}) {
    if (rateLimitDelayMs != null) {
      return rateLimitDelayMs;
    }
    
    // Calculate linear backoff: base + (increment * attempt)
    final linearDelay = baseDelayMs + (incrementMs * attempt);
    
    // Cap at maximum delay
    final cappedDelay = linearDelay.clamp(baseDelayMs, maxDelayMs);
    
    // Add jitter
    final jitter = _calculateJitter(cappedDelay);
    
    return (cappedDelay + jitter).clamp(baseDelayMs ~/ 2, maxDelayMs);
  }

  int _calculateJitter(int delay) {
    if (jitterPercentage == 0.0) return 0;
    
    final jitterRange = (delay * jitterPercentage).round();
    return _random.nextInt(jitterRange * 2) - jitterRange;
  }

  @override
  String toString() {
    return 'LinearBackoffCalculator('
        'baseDelayMs: $baseDelayMs, '
        'maxDelayMs: $maxDelayMs, '
        'incrementMs: $incrementMs, '
        'jitterPercentage: $jitterPercentage'
        ')';
  }
}

/// Implements fixed delay for retry operations.
class FixedDelayCalculator implements DelayCalculator {
  final int delayMs;

  const FixedDelayCalculator({required this.delayMs}) : assert(delayMs > 0);

  @override
  int calculateDelay(int attempt, {int? rateLimitDelayMs}) {
    return rateLimitDelayMs ?? delayMs;
  }

  @override
  String toString() {
    return 'FixedDelayCalculator(delayMs: $delayMs)';
  }
}
