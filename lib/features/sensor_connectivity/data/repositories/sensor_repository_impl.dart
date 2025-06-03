import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:survival/core/error/failures.dart';
import 'package:survival/features/sensor_connectivity/data/datasources/ble_datasource.dart';
import 'package:survival/features/sensor_connectivity/data/datasources/firestore_datasource.dart';
import 'package:survival/features/sensor_connectivity/data/datasources/mqtt_datasource.dart';
import 'package:survival/features/sensor_connectivity/domain/entities/sensor_entities.dart';
import 'package:survival/features/sensor_connectivity/domain/repositories/sensor_repository.dart';

class SensorRepositoryImpl implements SensorRepository {
  final BleDatasource bleDatasource;
  final MqttDatasource mqttDatasource;
  final FirestoreDatasource firestoreDatasource;

  SensorRepositoryImpl({
    required this.bleDatasource,
    required this.mqttDatasource,
    required this.firestoreDatasource,
  });

  // --- BLE Methods ---
  @override
  Stream<List<SensorDevice>> scanForDevices() {
    bleDatasource.startScan();
    bleDatasource.scanResults.listen((results) {
      log('scan results: ${results.map((r) => r.name).join(', ')}');
    });
    // For now, might rely primarily on Firestore for device list
    // return bleDatasource.scanForDevices();
    return Stream.value([]); // Placeholder
  }

  @override
  Future<Either<Failure, bool>> connectToDevice(String deviceId) async {
    try {
      final result = await bleDatasource.connectToDevice(deviceId);
      return Right(result);
    } catch (e) {
      return Left(
        ConnectionFailure('Failed to connect via BLE: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> disconnectFromDevice(String deviceId) async {
    try {
      await bleDatasource.disconnectFromDevice(deviceId);
      return const Right(null);
    } catch (e) {
      return Left(
        ConnectionFailure('Failed to disconnect via BLE: ${e.toString()}'),
      );
    }
  }

  @override
  Stream<SensorData> subscribeToSensorData(String deviceId) {
    return bleDatasource
        .subscribeToSensorData(deviceId)
        .map(
          (data) => SensorData(
            deviceId: deviceId,
            data: {'rawData': data},
            timestamp: DateTime.now(),
          ),
        );
  }

  @override
  Future<Either<Failure, void>> sendCommandToDevice(
    String deviceId,
    String command,
  ) async {
    try {
      await bleDatasource.sendCommandToDevice(deviceId, command);
      return const Right(null);
    } catch (e) {
      return Left(
        CommunicationFailure('Failed to send command via BLE: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<String>>> discoverWifiNetworks(
    String deviceId,
  ) async {
    try {
      final networks = await bleDatasource.discoverWifiNetworks(deviceId);
      return Right(networks);
    } catch (e) {
      return Left(
        CommunicationFailure(
          'Failed to discover Wi-Fi networks: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> pairWifiNetwork(
    String deviceId,
    String ssid,
    String password,
  ) async {
    try {
      final result = await bleDatasource.pairWifiNetwork(
        deviceId,
        ssid,
        password,
      );
      return Right(result);
    } catch (e) {
      return Left(
        CommunicationFailure('Failed to pair Wi-Fi network: ${e.toString()}'),
      );
    }
  }

  // Added BLE Characteristic methods for WiFi pairing
  @override
  Future<Either<Failure, void>> setBleNotification(
    BluetoothDevice device,
    Guid serviceUuid,
    Guid characteristicUuid,
    bool enable,
  ) async {
    try {
      await bleDatasource.setBleNotification(
        device,
        serviceUuid,
        characteristicUuid,
        enable,
      );
      return const Right(null);
    } catch (e) {
      return Left(
        CommunicationFailure('Failed to set BLE notification: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> writeBleCharacteristic(
    BluetoothDevice device,
    Guid serviceUuid,
    Guid characteristicUuid,
    List<int> value, {
    bool withoutResponse = false,
  }) async {
    try {
      await bleDatasource.writeBleCharacteristic(
        device,
        serviceUuid,
        characteristicUuid,
        value,
        withoutResponse: withoutResponse,
      );
      return const Right(null);
    } catch (e) {
      return Left(
        CommunicationFailure(
          'Failed to write to BLE characteristic: ${e.toString()}',
        ),
      );
    }
  }

  // Additional BLE methods for usecases
  @override
  Future<Either<Failure, void>> requestBlePermissions() async {
    try {
      // Assuming BleDatasource has a method to request permissions
      // If not, implement the logic here or add to BleDatasource
      // await bleDatasource.requestPermissions();
      // For now, just return success
      return const Right(null);
    } catch (e) {
      return Left(
        PermissionFailure('Failed to request BLE permissions: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> startBleScan() async {
    try {
      await bleDatasource.startScan();
      return const Right(null);
    } catch (e) {
      return Left(
        CommunicationFailure('Failed to start BLE scan: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> stopBleScan() async {
    try {
      await bleDatasource.stopScan();
      return const Right(null);
    } catch (e) {
      return Left(
        CommunicationFailure('Failed to stop BLE scan: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> connectBleDevice(BluetoothDevice device) async {
    try {
      final result = await bleDatasource.connectToDevice(device.remoteId.toString());
      return result
          ? const Right(null)
          : Left(ConnectionFailure('Failed to connect to BLE device'));
    } catch (e) {
      return Left(
        ConnectionFailure('Failed to connect to BLE device: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> disconnectBleDevice(
    BluetoothDevice device,
  ) async {
    try {
      await bleDatasource.disconnectFromDevice(device.remoteId.toString());
      return const Right(null);
    } catch (e) {
      return Left(
        ConnectionFailure('Failed to disconnect BLE device: ${e.toString()}'),
      );
    }
  }

  // --- MQTT Methods ---
  @override
  Future<Either<Failure, bool>> connectToMqttBroker(
    String broker,
    int port,
    String clientId,
    String? username,
    String? password,
  ) async {
    try {
      final result = await mqttDatasource.connect(
        broker,
        port,
        clientId,
        username,
        password,
      );
      return Right(result);
    } catch (e) {
      return Left(
        ConnectionFailure('Failed to connect to MQTT: ${e.toString()}'),
      );
    }
  }

  // MQTT methods for usecases - aliases to existing methods
  @override
  Future<Either<Failure, bool>> connectMqtt(
    String broker,
    int port,
    String clientId,
    String? username,
    String? password,
  ) async {
    return connectToMqttBroker(broker, port, clientId, username, password);
  }

  @override
  Future<Either<Failure, void>> disconnectFromMqttBroker() async {
    try {
      mqttDatasource.disconnect();
      return const Right(null);
    } catch (e) {
      return Left(
        ConnectionFailure('Failed to disconnect from MQTT: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> disconnectMqtt() async {
    return disconnectFromMqttBroker();
  }

  @override
  Stream<String> subscribeToMqttTopic(String topic) {
    return mqttDatasource.subscribeToTopic(topic);
  }

  @override
  Future<Either<Failure, void>> publishToMqttTopic(
    String topic,
    String message,
  ) async {
    try {
      mqttDatasource.publish(topic, message);
      return const Right(null);
    } catch (e) {
      return Left(
        CommunicationFailure('Failed to publish to MQTT: ${e.toString()}'),
      );
    }
  }

  // --- Firestore Methods ---
  @override
  Stream<List<SensorDevice>> streamFirestoreDevices() {
    try {
      return firestoreDatasource.streamDevices();
    } catch (e) {
      // Convert exceptions to a stream error
      return Stream.error(
        DatabaseFailure('Failed to stream devices: ${e.toString()}'),
      );
    }
  }

  @override
  Stream<List<DeviceLog>> streamFirestoreDeviceLogs(String deviceId) {
    try {
      return firestoreDatasource.streamDeviceLogs(deviceId);
    } catch (e) {
      return Stream.error(
        DatabaseFailure(
          'Failed to stream logs for device $deviceId: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> addDeviceToFirestore(
    SensorDevice device,
  ) async {
    try {
      await firestoreDatasource.addDevice(device);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add device: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateDeviceStatusInFirestore(
    String deviceId,
    Map<String, dynamic> statusData,
  ) async {
    try {
      await firestoreDatasource.updateDeviceStatus(deviceId, statusData);
      return const Right(null);
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to update device status: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> addDeviceLogToFirestore(
    String deviceId,
    DeviceLog log,
  ) async {
    try {
      await firestoreDatasource.addDeviceLog(deviceId, log);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add device log: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateDeviceSettingsInFirestore(
    String deviceId,
    Map<String, dynamic> settings,
  ) async {
    try {
      await firestoreDatasource.updateDeviceSettings(deviceId, settings);
      return const Right(null);
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to update device settings: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>?>> getDeviceSettingsFromFirestore(
    String deviceId,
  ) async {
    try {
      final settings = await firestoreDatasource.getDeviceSettings(deviceId);
      return Right(settings);
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to get device settings: ${e.toString()}'),
      );
    }
  }
}
