import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:survival/features/sensor_connectivity/domain/entities/sensor_entities.dart';

// Base State
abstract class SensorState extends Equatable {
  const SensorState();

  @override
  List<Object?> get props => [];
}

// Initial State
class SensorInitial extends SensorState {}

// Loading States
class SensorLoading extends SensorState {
  final String message;
  const SensorLoading({this.message = 'Loading...'});
  @override
  List<Object?> get props => [message];
}

// Success State with Loaded Devices
class SensorLoaded extends SensorState {
  final List<SensorDevice> sensors;
  const SensorLoaded(this.sensors);
  @override
  List<Object?> get props => [sensors];
}

// MQTT States
class MqttConnectionStatusChanged extends SensorState {
  final MqttConnectionState status;
  const MqttConnectionStatusChanged(this.status);
  @override
  List<Object?> get props => [status];
}

// BLE States
class BlePermissionsGranted extends SensorState {}

class BleScanLoading extends SensorState {}

class BleScanResultsUpdated extends SensorState {
  final List<ScanResult> scanResults;
  const BleScanResultsUpdated(this.scanResults);
  @override
  List<Object?> get props => [scanResults];
}

class BleDeviceConnectionStateChanged extends SensorState {
  final BluetoothDevice device;
  final BluetoothConnectionState connectionState;
  const BleDeviceConnectionStateChanged(this.device, this.connectionState);
  @override
  List<Object?> get props => [device.remoteId, connectionState]; // Use remoteId for comparison
}

// Data State
class SensorDataReceived extends SensorState {
  final DeviceStatus status; // Changed from SensorStatus to DeviceStatus
  final String source; // 'MQTT' or 'BLE'
  const SensorDataReceived(this.status, this.source);
  @override
  List<Object?> get props => [status, source];
}

// Error State
class SensorError extends SensorState {
  final String message;
  const SensorError(this.message);
  @override
  List<Object?> get props => [message];
}
