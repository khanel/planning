/// Calendar services
/// 
/// This module provides a unified interface to all calendar services,
/// organized into logical modules for better maintainability.
library services;

// Core business logic services
export 'core/core.dart';

// Infrastructure services (retry, circuit breaker, etc.)
export 'infrastructure/infrastructure.dart';

// Synchronization services
export 'sync/sync.dart';
