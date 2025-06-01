/// Abstract base class for all exceptions
abstract class AppException implements Exception {
  const AppException([this.message]);
  
  final String? message;
  
  @override
  String toString() {
    return message ?? runtimeType.toString();
  }
}

/// Exception thrown when a cache operation fails
class CacheException extends AppException {
  const CacheException([String? message]) : super(message);
}

/// Exception thrown when a network operation fails
class NetworkException extends AppException {
  const NetworkException([String? message]) : super(message);
}

/// Exception thrown when a server operation fails
class ServerException extends AppException {
  const ServerException([String? message]) : super(message);
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  const ValidationException([String? message]) : super(message);
}

/// Exception thrown when authentication fails
class AuthException extends AppException {
  const AuthException([String? message]) : super(message);
}