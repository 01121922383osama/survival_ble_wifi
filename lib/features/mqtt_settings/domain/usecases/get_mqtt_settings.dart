import 'package:dartz/dartz.dart';
import 'package:survival/core/error/failures.dart';
import 'package:survival/core/usecases/usecase.dart';
import 'package:survival/features/mqtt_settings/domain/repositories/mqtt_settings_repository.dart';

class GetMqttSettings implements UseCase<MqttSettings, NoParams> {
  final MqttSettingsRepository repository;

  GetMqttSettings(this.repository);

  @override
  Future<Either<Failure, MqttSettings>> call(NoParams params) async {
    return await repository.getMqttSettings();
  }
}

