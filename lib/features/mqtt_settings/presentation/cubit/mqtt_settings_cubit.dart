import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:survival/core/error/failures.dart';
import 'package:survival/core/usecases/usecase.dart';
import 'package:survival/features/mqtt_settings/domain/repositories/mqtt_settings_repository.dart'; // Import MqttSettings entity
import 'package:survival/features/mqtt_settings/domain/usecases/get_mqtt_settings.dart';
import 'package:survival/features/mqtt_settings/domain/usecases/save_mqtt_settings.dart';

part 'mqtt_settings_state.dart';

class MqttSettingsCubit extends Cubit<MqttSettingsState> {
  final GetMqttSettings getMqttSettings;
  final SaveMqttSettings saveMqttSettings;

  MqttSettingsCubit({
    required this.getMqttSettings,
    required this.saveMqttSettings,
  }) : super(MqttSettingsInitial());

  Future<void> loadSettings() async {
    emit(MqttSettingsLoading());
    final result = await getMqttSettings(NoParams());
    result.fold(
      (failure) => emit(MqttSettingsError(_mapFailureToMessage(failure))),
      (settings) => emit(MqttSettingsLoaded(settings)),
    );
  }

  Future<void> saveSettings(MqttSettings settings) async {
    emit(MqttSettingsLoading());
    final result = await saveMqttSettings(settings);
    result.fold(
      (failure) => emit(MqttSettingsError(_mapFailureToMessage(failure))),
      (_) => emit(
        MqttSettingsSaved(settings),
      ), // Emit saved state with the settings
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (DatabaseFailure):
        return (failure as DatabaseFailure).message;
      default:
        return 'An unexpected error occurred while handling MQTT settings';
    }
  }
}
