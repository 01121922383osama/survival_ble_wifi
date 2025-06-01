import 'package:dartz/dartz.dart';
import 'package:survival/core/error/failures.dart';
import 'package:survival/core/usecases/usecase.dart';
import 'package:survival/features/device_settings/domain/repositories/device_settings_repository.dart';

class GetDeviceSettings implements UseCase<SensorDeviceSettings, String> {
  final DeviceSettingsRepository repository;

  GetDeviceSettings(this.repository);

  @override
  Future<Either<Failure, SensorDeviceSettings>> call(String deviceId) async {
    final result = await repository.getDeviceSettings(deviceId);
    return result.fold((failure) => Left(failure), (settingsMap) {
      if (settingsMap == null) {
        return Left(ServerFailure('Device settings not found'));
      }
      try {
        final settings = SensorDeviceSettings.fromJson(settingsMap);
        return Right(settings);
      } catch (e) {
        return Left(ServerFailure('Failed to parse device settings'));
      }
    });
  }
}

class SensorDeviceSettings {
  final int fallDetectionTime;
  final int noMotionAlertTime;
  final int installationHeight;
  final bool noMotionDetectionEnabled;
  final bool soundAlertEnabled;
  final bool voiceLearningMode;

  SensorDeviceSettings({
    required this.fallDetectionTime,
    required this.noMotionAlertTime,
    required this.installationHeight,
    required this.noMotionDetectionEnabled,
    required this.soundAlertEnabled,
    required this.voiceLearningMode,
  });

  factory SensorDeviceSettings.fromJson(Map<String, dynamic> json) {
    return SensorDeviceSettings(
      fallDetectionTime: json['fallDetectionTime'] as int,
      noMotionAlertTime: json['noMotionAlertTime'] as int,
      installationHeight: json['installationHeight'] as int,
      noMotionDetectionEnabled: json['noMotionDetectionEnabled'] as bool,
      soundAlertEnabled: json['soundAlertEnabled'] as bool,
      voiceLearningMode: json['voiceLearningMode'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fallDetectionTime': fallDetectionTime,
      'noMotionAlertTime': noMotionAlertTime,
      'installationHeight': installationHeight,
      'noMotionDetectionEnabled': noMotionDetectionEnabled,
      'soundAlertEnabled': soundAlertEnabled,
      'voiceLearningMode': voiceLearningMode,
    };
  }

  SensorDeviceSettings copyWith({
    int? fallDetectionTime,
    int? noMotionAlertTime,
    int? installationHeight,
    bool? noMotionDetectionEnabled,
    bool? soundAlertEnabled,
    bool? voiceLearningMode,
  }) {
    return SensorDeviceSettings(
      fallDetectionTime: fallDetectionTime ?? this.fallDetectionTime,
      noMotionAlertTime: noMotionAlertTime ?? this.noMotionAlertTime,
      installationHeight: installationHeight ?? this.installationHeight,
      noMotionDetectionEnabled:
          noMotionDetectionEnabled ?? this.noMotionDetectionEnabled,
      soundAlertEnabled: soundAlertEnabled ?? this.soundAlertEnabled,
      voiceLearningMode: voiceLearningMode ?? this.voiceLearningMode,
    );
  }
}
