import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:survival/core/error/failures.dart';
import 'package:survival/core/usecases/usecase.dart';
import 'package:survival/features/sensor_connectivity/domain/repositories/sensor_repository.dart';

class ConnectMqttUseCase implements UseCase<bool, ConnectMqttParams> {
  final SensorRepository repository;

  ConnectMqttUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(ConnectMqttParams params) async {
    return await repository.connectMqtt(
      params.broker,
      params.port,
      params.clientId,
      params.username,
      params.password,
    );
  }
}

class ConnectMqttParams extends Equatable {
  final String broker;
  final int port;
  final String clientId;
  final String? username;
  final String? password;

  const ConnectMqttParams({
    required this.broker,
    required this.port,
    required this.clientId,
    this.username,
    this.password,
  });

  @override
  List<Object?> get props => [broker, port, clientId, username, password];
}

class DisconnectMqttUseCase implements UseCase<void, NoParams> {
  final SensorRepository repository;

  DisconnectMqttUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.disconnectMqtt();
  }
}

class SubscribeToMqttTopicUseCase {
  final SensorRepository repository;

  SubscribeToMqttTopicUseCase(this.repository);

  Stream<String> call(String topic) {
    return repository.subscribeToMqttTopic(topic);
  }
}

class PublishToMqttTopicUseCase implements UseCase<void, PublishMqttParams> {
  final SensorRepository repository;

  PublishToMqttTopicUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(PublishMqttParams params) async {
    return await repository.publishToMqttTopic(params.topic, params.message);
  }
}

class PublishMqttParams extends Equatable {
  final String topic;
  final String message;

  const PublishMqttParams({
    required this.topic,
    required this.message,
  });

  @override
  List<Object?> get props => [topic, message];
}
