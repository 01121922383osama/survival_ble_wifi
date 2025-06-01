import 'dart:convert'; // For JSON encoding/decoding if storing complex object

import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:survival/core/error/failures.dart';
import 'package:survival/features/mqtt_settings/domain/repositories/mqtt_settings_repository.dart';

// Define keys for SharedPreferences
const String CACHED_MQTT_SETTINGS = 'CACHED_MQTT_SETTINGS';

class MqttSettingsRepositoryImpl implements MqttSettingsRepository {
  final SharedPreferences sharedPreferences;

  MqttSettingsRepositoryImpl({required this.sharedPreferences});

  @override
  Future<Either<Failure, MqttSettings>> getMqttSettings() async {
    final jsonString = sharedPreferences.getString(CACHED_MQTT_SETTINGS);
    if (jsonString != null) {
      try {
        final settingsMap = json.decode(jsonString) as Map<String, dynamic>;
        return Right(MqttSettings.fromMap(settingsMap));
      } catch (e) {
        return Left(
          DatabaseFailure('Failed to decode cached MQTT settings: $e'),
        );
      }
    } else {
      // Return default settings if nothing is cached
      return Right(MqttSettings.defaultSettings());
    }
  }

  @override
  Future<Either<Failure, void>> saveMqttSettings(MqttSettings settings) async {
    try {
      final settingsMap = settings.toMap();
      await sharedPreferences.setString(
        CACHED_MQTT_SETTINGS,
        json.encode(settingsMap),
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to cache MQTT settings: $e'));
    }
  }
}
