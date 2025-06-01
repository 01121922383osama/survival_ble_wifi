import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:survival/core/error/failures.dart';
import 'package:survival/core/usecases/usecase.dart';
import 'package:survival/features/sensor_connectivity/domain/repositories/sensor_repository.dart';

// --- BLE Use Cases ---

class RequestBlePermissionsUseCase implements UseCase<void, NoParams> {
  final SensorRepository repository;
  RequestBlePermissionsUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.requestBlePermissions();
  }
}

class StartBleScanUseCase implements UseCase<void, NoParams> {
  final SensorRepository repository;
  StartBleScanUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.startBleScan();
  }
}

class StopBleScanUseCase implements UseCase<void, NoParams> {
  final SensorRepository repository;
  StopBleScanUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.stopBleScan();
  }
}

class ConnectBleDeviceUseCase implements UseCase<void, BluetoothDevice> {
  final SensorRepository repository;
  ConnectBleDeviceUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(BluetoothDevice device) async {
    return await repository.connectBleDevice(device);
  }
}

class DisconnectBleDeviceUseCase implements UseCase<void, BluetoothDevice> {
  final SensorRepository repository;
  DisconnectBleDeviceUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(BluetoothDevice device) async {
    return await repository.disconnectBleDevice(device);
  }
}

class WriteBleCharacteristicUseCase implements UseCase<void, WriteBleParams> {
  final SensorRepository repository;
  WriteBleCharacteristicUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(WriteBleParams params) async {
    return await repository.writeBleCharacteristic(
      params.device,
      params.serviceUuid,
      params.characteristicUuid,
      params.value,
      withoutResponse: params.withoutResponse,
    );
  }
}

class WriteBleParams extends Equatable {
  final BluetoothDevice device;
  final Guid serviceUuid;
  final Guid characteristicUuid;
  final List<int> value;
  final bool withoutResponse;

  const WriteBleParams({
    required this.device,
    required this.serviceUuid,
    required this.characteristicUuid,
    required this.value,
    this.withoutResponse = false,
  });

  @override
  List<Object?> get props => [device, serviceUuid, characteristicUuid, value, withoutResponse];
}

class SetBleNotificationUseCase implements UseCase<void, SetBleNotificationParams> {
  final SensorRepository repository;
  SetBleNotificationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SetBleNotificationParams params) async {
    return await repository.setBleNotification(
      params.device,
      params.serviceUuid,
      params.characteristicUuid,
      params.enable,
    );
  }
}

class SetBleNotificationParams extends Equatable {
  final BluetoothDevice device;
  final Guid serviceUuid;
  final Guid characteristicUuid;
  final bool enable;

  const SetBleNotificationParams({
    required this.device,
    required this.serviceUuid,
    required this.characteristicUuid,
    required this.enable,
  });

  @override
  List<Object?> get props => [device, serviceUuid, characteristicUuid, enable];
}

// Add ReadBleCharacteristicUseCase if needed

