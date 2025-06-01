import 'package:dartz/dartz.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:survival/core/error/failures.dart';
import 'package:survival/features/sensor_connectivity/domain/entities/sensor_entities.dart';

abstract class SensorRepository {
  // BLE related methods
  Stream<List<SensorDevice>> scanForDevices();
  Future<Either<Failure, bool>> connectToDevice(String deviceId);
  Future<Either<Failure, void>> disconnectFromDevice(String deviceId);
  Stream<SensorData> subscribeToSensorData(String deviceId);
  Future<Either<Failure, void>> sendCommandToDevice(String deviceId, String command);
  Future<Either<Failure, List<String>>> discoverWifiNetworks(String deviceId);
  Future<Either<Failure, bool>> pairWifiNetwork(String deviceId, String ssid, String password);
  
  // BLE Characteristic methods (added for WiFi pairing)
  Future<Either<Failure, void>> setBleNotification(
      BluetoothDevice device, Guid serviceUuid, Guid characteristicUuid, bool enable);
  Future<Either<Failure, void>> writeBleCharacteristic(
      BluetoothDevice device, Guid serviceUuid, Guid characteristicUuid, List<int> value, 
      {bool withoutResponse = false});
      
  // Additional BLE methods for usecases
  Future<Either<Failure, void>> requestBlePermissions();
  Future<Either<Failure, void>> startBleScan();
  Future<Either<Failure, void>> stopBleScan();
  Future<Either<Failure, void>> connectBleDevice(BluetoothDevice device);
  Future<Either<Failure, void>> disconnectBleDevice(BluetoothDevice device);

  // MQTT related methods
  Future<Either<Failure, bool>> connectToMqttBroker(
      String broker, int port, String clientId, String? username, String? password);
  Future<Either<Failure, void>> disconnectFromMqttBroker();
  Stream<String> subscribeToMqttTopic(String topic);
  Future<Either<Failure, void>> publishToMqttTopic(String topic, String message);
  
  // MQTT methods for usecases
  Future<Either<Failure, bool>> connectMqtt(String broker, int port, String clientId, String? username, String? password);
  Future<Either<Failure, void>> disconnectMqtt();

  // Firestore related methods
  Stream<List<SensorDevice>> streamFirestoreDevices();
  Stream<List<DeviceLog>> streamFirestoreDeviceLogs(String deviceId);
  Future<Either<Failure, void>> addDeviceToFirestore(SensorDevice device);
  Future<Either<Failure, void>> updateDeviceStatusInFirestore(String deviceId, Map<String, dynamic> statusData);
  Future<Either<Failure, void>> addDeviceLogToFirestore(String deviceId, DeviceLog log);
  Future<Either<Failure, void>> updateDeviceSettingsInFirestore(String deviceId, Map<String, dynamic> settings);
  Future<Either<Failure, Map<String, dynamic>?>> getDeviceSettingsFromFirestore(String deviceId);
}
