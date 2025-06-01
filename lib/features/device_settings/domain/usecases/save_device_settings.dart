import 'package:dartz/dartz.dart';
import 'package:survival/core/error/failures.dart';
import 'package:survival/core/usecases/usecase.dart';
import 'package:survival/features/device_settings/domain/repositories/device_settings_repository.dart';
import 'package:survival/features/device_settings/domain/usecases/get_device_settings.dart';

class SaveDeviceSettings implements UseCase<void, SaveDeviceSettingsParams> {
  final DeviceSettingsRepository repository;

  SaveDeviceSettings(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveDeviceSettingsParams params) async {
    return await repository.saveDeviceSettings(
      params.deviceId,
      params.settings.toJson(),
    );
  }
}

class SaveDeviceSettingsParams {
  final String deviceId;
  final SensorDeviceSettings settings;

  SaveDeviceSettingsParams({required this.deviceId, required this.settings});
}

// Ensure SensorDeviceSettings entity is defined (e.g., in sensor_entities.dart or its own file)
// Example definition (if not already present):
/*
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

  // Add fromJson, toJson, copyWith, toMap etc. if needed
  Map<String, dynamic> toMap() {
    return {
      'fallDetectionTime': fallDetectionTime,
      'noMotionAlertTime': noMotionAlertTime,
      'installationHeight': installationHeight,
      'noMotionDetectionEnabled': noMotionDetectionEnabled,
      'soundAlertEnabled': soundAlertEnabled,
      'voiceLearningMode': voiceLearningMode,
    };
  }

  factory SensorDeviceSettings.fromMap(Map<String, dynamic> map) {
    return SensorDeviceSettings(
      fallDetectionTime: map['fallDetectionTime'] ?? 60,
      noMotionAlertTime: map['noMotionAlertTime'] ?? 90,
      installationHeight: map['installationHeight'] ?? 250,
      noMotionDetectionEnabled: map['noMotionDetectionEnabled'] ?? true,
      soundAlertEnabled: map['soundAlertEnabled'] ?? true,
      voiceLearningMode: map['voiceLearningMode'] ?? false,
    );
  }

  // Default settings
  factory SensorDeviceSettings.defaultSettings() {
    return SensorDeviceSettings(
      fallDetectionTime: 60,
      noMotionAlertTime: 90,
      installationHeight: 250,
      noMotionDetectionEnabled: true,
      soundAlertEnabled: true,
      voiceLearningMode: false,
    );
  }
}
*/
