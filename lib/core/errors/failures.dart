import 'package:equatable/equatable.dart';

/// Base class for failures in the app.
abstract class Failure extends Equatable {
  const Failure([this.message]);

  final String? message;

  @override
  List<Object?> get props => [message];
}

/// Server/API error (4xx, 5xx, etc.).
class ServerFailure extends Failure {
  const ServerFailure([super.message]);

  @override
  String toString() => 'ServerFailure: ${message ?? 'Unknown server error'}';
}

/// Network connectivity or timeout error.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message]);

  @override
  String toString() => 'NetworkFailure: ${message ?? 'Network error'}';
}
