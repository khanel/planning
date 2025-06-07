/// Circuit breaker implementation for managing failure tolerance.
/// 
/// Implements the circuit breaker pattern to prevent cascading failures
/// by temporarily disabling operations when failure rate exceeds threshold.
class CircuitBreaker {
  final int failureThreshold;
  final int recoveryTimeoutMs;
  
  int _failureCount = 0;
  DateTime? _circuitOpenTime;

  CircuitBreaker({
    required this.failureThreshold,
    required this.recoveryTimeoutMs,
  }) : assert(failureThreshold > 0),
       assert(recoveryTimeoutMs > 0);

  /// Checks if the circuit is currently open (blocking operations).
  bool get isOpen {
    if (_failureCount < failureThreshold) {
      return false;
    }
    
    if (_circuitOpenTime == null) {
      _circuitOpenTime = DateTime.now();
      return true;
    }
    
    final timeSinceOpen = DateTime.now().difference(_circuitOpenTime!).inMilliseconds;
    return timeSinceOpen < recoveryTimeoutMs;
  }

  /// Checks if the circuit is closed (allowing operations).
  bool get isClosed => !isOpen;

  /// Records a failure and potentially opens the circuit.
  void recordFailure() {
    _failureCount++;
    if (_failureCount >= failureThreshold && _circuitOpenTime == null) {
      _circuitOpenTime = DateTime.now();
    }
  }

  /// Records a success and resets the circuit breaker.
  void recordSuccess() {
    reset();
  }

  /// Resets the circuit breaker to its initial state.
  void reset() {
    _failureCount = 0;
    _circuitOpenTime = null;
  }

  /// Gets the current failure count.
  int get failureCount => _failureCount;

  /// Gets the time when the circuit was opened, if applicable.
  DateTime? get circuitOpenTime => _circuitOpenTime;

  /// Calculates the remaining recovery time in milliseconds.
  /// Returns 0 if the circuit is not open or recovery time has passed.
  int get remainingRecoveryTimeMs {
    if (_circuitOpenTime == null) return 0;
    
    final timeSinceOpen = DateTime.now().difference(_circuitOpenTime!).inMilliseconds;
    final remaining = recoveryTimeoutMs - timeSinceOpen;
    return remaining > 0 ? remaining : 0;
  }

  @override
  String toString() {
    return 'CircuitBreaker('
        'isOpen: $isOpen, '
        'failureCount: $_failureCount, '
        'failureThreshold: $failureThreshold, '
        'recoveryTimeoutMs: $recoveryTimeoutMs'
        ')';
  }
}
