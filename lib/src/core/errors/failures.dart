import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]) : super();
}

// General failures
class ServerFailure extends Failure {
  final String message;
  
  const ServerFailure([this.message = 'Server operation failed']);
  
  @override
  List<Object?> get props => [message];
}

class CacheFailure extends Failure {
  final String message;
  
  const CacheFailure([this.message = 'Cache operation failed']) : super();
  
  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  final String message;
  
  const NetworkFailure([this.message = 'Network operation failed']);
  
  @override
  List<Object?> get props => [message];
}

class ValidationFailure extends Failure {
  final String message;
  
  const ValidationFailure([this.message = 'Validation failed']);
  
  @override
  List<Object?> get props => [message];
}

class AuthFailure extends Failure {
  final String message;
  
  const AuthFailure([this.message = 'Authentication failed']);
  
  @override
  List<Object?> get props => [message];
}

class UnknownFailure extends Failure {
  final String message;
  
  const UnknownFailure([this.message = 'Unknown error occurred']);
  
  @override
  List<Object?> get props => [message];
}

class SyncFailure extends Failure {
  final String message;
  
  const SyncFailure([this.message = 'Synchronization failed']);
  
  @override
  List<Object?> get props => [message];
}