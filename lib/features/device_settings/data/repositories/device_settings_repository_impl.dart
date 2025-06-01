import 'package:dartz/dartz.dart';
import 'package:survival/core/error/failures.dart'; // Import the Failure classes
import 'package:survival/features/device_settings/domain/repositories/device_settings_repository.dart';
import 'package:survival/features/sensor_connectivity/data/datasources/firestore_datasource.dart';

class DeviceSettingsRepositoryImpl implements DeviceSettingsRepository {
  final FirestoreDatasource firestoreDatasource;

  DeviceSettingsRepositoryImpl(this.firestoreDatasource);

  @override
  Future<Either<Failure, Map<String, dynamic>?>> getDeviceSettings(String deviceId) async {
    try {
      final settings = await firestoreDatasource.getDeviceSettings(deviceId);
      // Extract only the relevant settings fields if needed, or return the whole doc data
      // For now, returning the whole data map which might include non-setting fields
      return Right(settings);
    } catch (e) {
      // Now DatabaseFailure should be recognized
      return Left(DatabaseFailure('Failed to get device settings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveDeviceSettings(String deviceId, Map<String, dynamic> settings) async {
    try {
      // Ensure only valid settings fields are passed
      // Consider defining a Settings entity/model for better type safety
      final validSettings = {
        'fallDetectionTime': settings['fallDetectionTime'],
        'noMotionAlertTime': settings['noMotionAlertTime'],
        'installationHeight': settings['installationHeight'],
        'noMotionDetectionEnabled': settings['noMotionDetectionEnabled'],
        'soundAlertEnabled': settings['soundAlertEnabled'],
        'voiceLearningMode': settings['voiceLearningMode'],
        // Add any other configurable settings here
      };
      // Remove null values before saving to Firestore if necessary
      validSettings.removeWhere((key, value) => value == null);
      
      await firestoreDatasource.updateDeviceSettings(deviceId, validSettings);
      return const Right(null);
    } catch (e) {
      // Now DatabaseFailure should be recognized
      return Left(DatabaseFailure('Failed to save device settings: ${e.toString()}'));
    }
  }
}

