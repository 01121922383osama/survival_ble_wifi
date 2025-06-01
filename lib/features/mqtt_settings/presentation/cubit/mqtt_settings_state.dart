part of 'mqtt_settings_cubit.dart';

abstract class MqttSettingsState extends Equatable {
  const MqttSettingsState();

  @override
  List<Object> get props => [];
}

class MqttSettingsInitial extends MqttSettingsState {}

class MqttSettingsLoading extends MqttSettingsState {}

class MqttSettingsLoaded extends MqttSettingsState {
  final MqttSettings settings;

  const MqttSettingsLoaded(this.settings);

  @override
  List<Object> get props => [settings];
}

class MqttSettingsSaved extends MqttSettingsState {
  final MqttSettings settings;

  const MqttSettingsSaved(this.settings);

  @override
  List<Object> get props => [settings];
}

class MqttSettingsError extends MqttSettingsState {
  final String message;

  const MqttSettingsError(this.message);

  @override
  List<Object> get props => [message];
}
