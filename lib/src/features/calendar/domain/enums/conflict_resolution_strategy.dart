enum ConflictResolutionStrategy {
  /// Use the last modified event (timestamp-based)
  lastWriteWins,
  
  /// Always prefer local version
  localWins,
  
  /// Always prefer remote version  
  remoteWins,
  
  /// Require manual resolution by user
  manual,
}
