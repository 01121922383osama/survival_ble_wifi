import 'package:dartz/dartz.dart';
import 'package:survival/core/error/failures.dart';

abstract class DeviceSettingsRepository {
  Future<Either<Failure, Map<String, dynamic>?>> getDeviceSettings(
    String deviceId,
  );
  Future<Either<Failure, void>> saveDeviceSettings(
    String deviceId,
    Map<String, dynamic> settings,
  );
}
