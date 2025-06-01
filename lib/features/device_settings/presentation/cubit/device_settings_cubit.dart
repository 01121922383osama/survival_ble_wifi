import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:survival/core/error/failures.dart';
import 'package:survival/features/device_settings/domain/usecases/get_device_settings.dart';
import 'package:survival/features/device_settings/domain/usecases/save_device_settings.dart';
import 'package:survival/features/device_settings/presentation/cubit/device_settings_state.dart';

class DeviceSettingsCubit extends Cubit<DeviceSettingsState> {
  final GetDeviceSettings _getDeviceSettings;
  final SaveDeviceSettings _saveDeviceSettings;

  DeviceSettingsCubit({
    required GetDeviceSettings getDeviceSettings,
    required SaveDeviceSettings saveDeviceSettings,
  }) : _getDeviceSettings = getDeviceSettings,
       _saveDeviceSettings = saveDeviceSettings,
       super(DeviceSettingsInitial());

  Future<void> loadDeviceSettings(String deviceId) async {
    emit(DeviceSettingsLoading());
    final result = await _getDeviceSettings(deviceId);
    result.fold(
      (failure) => emit(DeviceSettingsError(_mapFailureToMessage(failure))),
      (settings) {
        // Provide default values if settings are missing from Firestore
        emit(
          DeviceSettingsLoaded(
            fallDetectionTime: settings.fallDetectionTime,
            noMotionAlertTime: settings.noMotionAlertTime,
            installationHeight: settings.installationHeight,
            noMotionDetectionEnabled: settings.noMotionDetectionEnabled,
            soundAlertEnabled: settings.soundAlertEnabled,
            voiceLearningMode: settings.voiceLearningMode,
          ),
        );
      },
    );
  }

  Future<void> saveDeviceSettings({
    required String deviceId,
    required int fallDetectionTime,
    required int noMotionAlertTime,
    required int installationHeight,
    required bool noMotionDetectionEnabled,
    required bool soundAlertEnabled,
    required bool voiceLearningMode,
  }) async {
    // Optionally emit loading state
    // emit(DeviceSettingsLoading());

    final settingsMap = {
      'fallDetectionTime': fallDetectionTime,
      'noMotionAlertTime': noMotionAlertTime,
      'installationHeight': installationHeight,
      'noMotionDetectionEnabled': noMotionDetectionEnabled,
      'soundAlertEnabled': soundAlertEnabled,
      'voiceLearningMode': voiceLearningMode,
    };

    final result = await _saveDeviceSettings(
      SaveDeviceSettingsParams(
        deviceId: deviceId,
        settings: SensorDeviceSettings.fromJson(settingsMap),
      ),
    );

    result.fold(
      (failure) => emit(DeviceSettingsError(_mapFailureToMessage(failure))),
      (_) {
        // Re-emit loaded state with the saved values to update UI immediately
        // Or rely on Firestore stream if settings page listens to it
        emit(
          DeviceSettingsLoaded(
            fallDetectionTime: fallDetectionTime,
            noMotionAlertTime: noMotionAlertTime,
            installationHeight: installationHeight,
            noMotionDetectionEnabled: noMotionDetectionEnabled,
            soundAlertEnabled: soundAlertEnabled,
            voiceLearningMode: voiceLearningMode,
          ),
        );
        // Optionally emit a specific saved state
        emit(DeviceSettingsSaved());
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (ServerFailure):
      case const (DatabaseFailure):
        return (failure as dynamic).message;
      default:
        return 'An unexpected error occurred';
    }
  }
}
