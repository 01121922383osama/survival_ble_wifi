import 'package:equatable/equatable.dart';

abstract class DeviceSettingsState extends Equatable {
  const DeviceSettingsState();

  @override
  List<Object?> get props => [];
}

class DeviceSettingsInitial extends DeviceSettingsState {
  const DeviceSettingsInitial();
}

class DeviceSettingsLoading extends DeviceSettingsState {
  const DeviceSettingsLoading();
}

class DeviceSettingsLoaded extends DeviceSettingsState {
  final int fallDetectionTime;
  final int noMotionAlertTime;
  final int installationHeight;
  final bool noMotionDetectionEnabled;
  final bool soundAlertEnabled;
  final bool voiceLearningMode;

  const DeviceSettingsLoaded({
    required this.fallDetectionTime,
    required this.noMotionAlertTime,
    required this.installationHeight,
    required this.noMotionDetectionEnabled,
    required this.soundAlertEnabled,
    required this.voiceLearningMode,
  });

  @override
  List<Object> get props => [
        fallDetectionTime,
        noMotionAlertTime,
        installationHeight,
        noMotionDetectionEnabled,
        soundAlertEnabled,
        voiceLearningMode,
      ];

  DeviceSettingsLoaded copyWith({
    int? fallDetectionTime,
    int? noMotionAlertTime,
    int? installationHeight,
    bool? noMotionDetectionEnabled,
    bool? soundAlertEnabled,
    bool? voiceLearningMode,
  }) {
    return DeviceSettingsLoaded(
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

class DeviceSettingsError extends DeviceSettingsState {
  final String message;

  const DeviceSettingsError(this.message);

  @override
  List<Object> get props => [message];
}

class DeviceSettingsSaved extends DeviceSettingsState {
  const DeviceSettingsSaved();
}
