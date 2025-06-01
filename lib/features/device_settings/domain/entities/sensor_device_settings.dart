import 'package:equatable/equatable.dart';

class SensorDeviceSettings extends Equatable {
  final int fallDetectionTime; // Example: seconds
  final int noMotionAlertTime; // Example: minutes
  final int installationHeight; // Example: cm
  final bool noMotionDetectionEnabled;
  final bool soundAlertEnabled;
  final bool voiceLearningMode;
  // Add other configurable settings based on documentation

  const SensorDeviceSettings({
    required this.fallDetectionTime,
    required this.noMotionAlertTime,
    required this.installationHeight,
    required this.noMotionDetectionEnabled,
    required this.soundAlertEnabled,
    required this.voiceLearningMode,
  });

  // Default settings
  factory SensorDeviceSettings.defaultSettings() {
    return const SensorDeviceSettings(
      fallDetectionTime: 60,
      noMotionAlertTime: 90,
      installationHeight: 250,
      noMotionDetectionEnabled: true,
      soundAlertEnabled: true,
      voiceLearningMode: false,
    );
  }

  // Convert to Firestore map
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

  // Create from Firestore map
  factory SensorDeviceSettings.fromMap(Map<String, dynamic> map) {
    return SensorDeviceSettings(
      fallDetectionTime: map['fallDetectionTime'] as int? ?? 60,
      noMotionAlertTime: map['noMotionAlertTime'] as int? ?? 90,
      installationHeight: map['installationHeight'] as int? ?? 250,
      noMotionDetectionEnabled: map['noMotionDetectionEnabled'] as bool? ?? true,
      soundAlertEnabled: map['soundAlertEnabled'] as bool? ?? true,
      voiceLearningMode: map['voiceLearningMode'] as bool? ?? false,
    );
  }

   // CopyWith method for immutability
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
      noMotionDetectionEnabled: noMotionDetectionEnabled ?? this.noMotionDetectionEnabled,
      soundAlertEnabled: soundAlertEnabled ?? this.soundAlertEnabled,
      voiceLearningMode: voiceLearningMode ?? this.voiceLearningMode,
    );
  }

  @override
  List<Object?> get props => [
        fallDetectionTime,
        noMotionAlertTime,
        installationHeight,
        noMotionDetectionEnabled,
        soundAlertEnabled,
        voiceLearningMode,
      ];
}

