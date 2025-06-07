/// Configuration class for retry mechanisms in calendar operations.
/// 
/// Encapsulates all retry-related parameters and provides factory methods
/// for common configurations.
class RetryConfig {
  /// Maximum number of retry attempts after the initial try.
  final int maxRetries;
  
  /// Base delay in milliseconds for exponential backoff.
  final int baseDelayMs;
  
  /// Maximum delay in milliseconds to prevent excessive wait times.
  final int maxDelayMs;
  
  /// Number of failures required to open the circuit breaker.
  final int circuitBreakerThreshold;
  
  /// Time in milliseconds before attempting to close an open circuit.
  final int circuitRecoveryTimeoutMs;
  
  /// Percentage of jitter to add to delay calculations (0.0 to 1.0).
  final double jitterPercentage;

  const RetryConfig({
    this.maxRetries = 3,
    this.baseDelayMs = 1000,
    this.maxDelayMs = 30000,
    this.circuitBreakerThreshold = 5,
    this.circuitRecoveryTimeoutMs = 30000,
    this.jitterPercentage = 0.25,
  }) : assert(maxRetries >= 0),
       assert(baseDelayMs > 0),
       assert(maxDelayMs >= baseDelayMs),
       assert(circuitBreakerThreshold > 0),
       assert(circuitRecoveryTimeoutMs > 0),
       assert(jitterPercentage >= 0.0 && jitterPercentage <= 1.0);

  /// Creates a configuration optimized for high-frequency operations.
  factory RetryConfig.aggressive() => const RetryConfig(
    maxRetries: 5,
    baseDelayMs: 500,
    maxDelayMs: 15000,
    circuitBreakerThreshold: 3,
    circuitRecoveryTimeoutMs: 15000,
    jitterPercentage: 0.3,
  );

  /// Creates a configuration optimized for low-frequency, critical operations.
  factory RetryConfig.conservative() => const RetryConfig(
    maxRetries: 2,
    baseDelayMs: 2000,
    maxDelayMs: 60000,
    circuitBreakerThreshold: 10,
    circuitRecoveryTimeoutMs: 60000,
    jitterPercentage: 0.2,
  );

  /// Creates a configuration with no retries (immediate failure).
  factory RetryConfig.noRetry() => const RetryConfig(
    maxRetries: 0,
    baseDelayMs: 1000,
    maxDelayMs: 1000,
    circuitBreakerThreshold: 1,
    circuitRecoveryTimeoutMs: 1000,
    jitterPercentage: 0.0,
  );

  /// Creates a copy of this configuration with optional parameter overrides.
  RetryConfig copyWith({
    int? maxRetries,
    int? baseDelayMs,
    int? maxDelayMs,
    int? circuitBreakerThreshold,
    int? circuitRecoveryTimeoutMs,
    double? jitterPercentage,
  }) {
    return RetryConfig(
      maxRetries: maxRetries ?? this.maxRetries,
      baseDelayMs: baseDelayMs ?? this.baseDelayMs,
      maxDelayMs: maxDelayMs ?? this.maxDelayMs,
      circuitBreakerThreshold: circuitBreakerThreshold ?? this.circuitBreakerThreshold,
      circuitRecoveryTimeoutMs: circuitRecoveryTimeoutMs ?? this.circuitRecoveryTimeoutMs,
      jitterPercentage: jitterPercentage ?? this.jitterPercentage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RetryConfig &&
        other.maxRetries == maxRetries &&
        other.baseDelayMs == baseDelayMs &&
        other.maxDelayMs == maxDelayMs &&
        other.circuitBreakerThreshold == circuitBreakerThreshold &&
        other.circuitRecoveryTimeoutMs == circuitRecoveryTimeoutMs &&
        other.jitterPercentage == jitterPercentage;
  }

  @override
  int get hashCode {
    return Object.hash(
      maxRetries,
      baseDelayMs,
      maxDelayMs,
      circuitBreakerThreshold,
      circuitRecoveryTimeoutMs,
      jitterPercentage,
    );
  }

  @override
  String toString() {
    return 'RetryConfig('
        'maxRetries: $maxRetries, '
        'baseDelayMs: $baseDelayMs, '
        'maxDelayMs: $maxDelayMs, '
        'circuitBreakerThreshold: $circuitBreakerThreshold, '
        'circuitRecoveryTimeoutMs: $circuitRecoveryTimeoutMs, '
        'jitterPercentage: $jitterPercentage'
        ')';
  }
}
