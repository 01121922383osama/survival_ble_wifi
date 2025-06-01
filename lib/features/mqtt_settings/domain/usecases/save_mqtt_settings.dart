import 'package:dartz/dartz.dart';
import 'package:survival/core/error/failures.dart';
import 'package:survival/core/usecases/usecase.dart';
import 'package:survival/features/mqtt_settings/domain/repositories/mqtt_settings_repository.dart';

class SaveMqttSettings implements UseCase<void, MqttSettings> {
  final MqttSettingsRepository repository;

  SaveMqttSettings(this.repository);

  @override
  Future<Either<Failure, void>> call(MqttSettings settings) async {
    return await repository.saveMqttSettings(settings);
  }
}

