class PermissionFailure extends Failure {
  final String message;

  const PermissionFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  final String message;

  const ServerFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ConnectionFailure extends Failure {
  final String message;

  const ConnectionFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class CommunicationFailure extends Failure {
  final String message;

  const CommunicationFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class DatabaseFailure extends Failure {
  final String message;

  const DatabaseFailure(this.message);

  @override
  List<Object?> get props => [message];
}

abstract class Failure {
  const Failure();

  List<Object?> get props;
}
