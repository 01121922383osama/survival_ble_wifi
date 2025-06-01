import 'package:dartz/dartz.dart';
import 'package:survival/core/error/failures.dart';

// Define MqttSettings entity if needed, or use a simple Map
class MqttSettings {
  final String broker;
  final int port;
  final String username;
  // Password might be handled separately for security

  MqttSettings({
    required this.broker,
    required this.port,
    required this.username,
  });

  // Add fromJson, toJson, copyWith etc. if needed
  Map<String, dynamic> toMap() {
    return {'broker': broker, 'port': port, 'username': username};
  }

  factory MqttSettings.fromMap(Map<String, dynamic> map) {
    return MqttSettings(
      broker: map['broker'] ?? '167.71.52.138', // Default broker
      port: map['port'] ?? 1883, // Default port
      username: map['username'] ?? '', // Default username
    );
  }

  factory MqttSettings.defaultSettings() {
    return MqttSettings(broker: '167.71.52.138', port: 1883, username: '');
  }
}

abstract class MqttSettingsRepository {
  Future<Either<Failure, MqttSettings>> getMqttSettings();
  Future<Either<Failure, void>> saveMqttSettings(MqttSettings settings);
}
