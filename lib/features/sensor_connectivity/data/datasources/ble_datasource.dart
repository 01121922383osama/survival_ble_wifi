import 'dart:async';
import 'dart:developer';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// Define BLE-related data structures if needed
class BleDevice {
  final String id;
  final String name;
  // Add other relevant properties like RSSI, services, etc.

  BleDevice({required this.id, required this.name});
}

abstract class BleDatasource {
  Future<void> startScan();
  Future<void> stopScan();
  Stream<List<BleDevice>> get scanResults;
  Future<bool> connectToDevice(String deviceId);
  Future<void> disconnectFromDevice(String deviceId);

  // Add methods for reading/writing characteristics, subscribing to notifications, etc.
  Future<void> setBleNotification(
    BluetoothDevice device,
    Guid serviceUuid,
    Guid characteristicUuid,
    bool enable,
  );
  Future<void> writeBleCharacteristic(
    BluetoothDevice device,
    Guid serviceUuid,
    Guid characteristicUuid,
    List<int> value, {
    bool withoutResponse = false,
  });

  // Stream for notifications
  Stream<Map<Guid, List<int>>> get characteristicValueStream;

  // Additional methods for sensor data
  Stream<List<int>> subscribeToSensorData(String deviceId);
  Future<void> sendCommandToDevice(String deviceId, String command);
  Future<List<String>> discoverWifiNetworks(String deviceId);
  Future<bool> pairWifiNetwork(String deviceId, String ssid, String password);
}

// Implementation using a BLE package like flutter_blue_plus
class BleDatasourceImpl implements BleDatasource {
  final Map<String, BluetoothDevice> _connectedDevices = {};
  final StreamController<Map<Guid, List<int>>> _characteristicValueController =
      StreamController<Map<Guid, List<int>>>.broadcast();

  @override
  Stream<Map<Guid, List<int>>> get characteristicValueStream =>
      _characteristicValueController.stream;

  @override
  Future<void> startScan() async {
    log('BLE Datasource: Starting scan');
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
  }

  @override
  Future<void> stopScan() async {
    log('BLE Datasource: Stopping scan');
    await FlutterBluePlus.stopScan();
  }

  @override
  Stream<List<BleDevice>> get scanResults {
    return FlutterBluePlus.scanResults.map((results) {
      return results
          .map(
            (result) => BleDevice(
              id: result.device.remoteId.toString(),
              name: result.device.platformName.isNotEmpty
                  ? result.device.platformName
                  : 'Unknown Device',
            ),
          )
          .toList();
    });
  }

  @override
  Future<bool> connectToDevice(String deviceId) async {
    log('BLE Datasource: Connecting to $deviceId');
    try {
      // Find device from scan results
      final scanResults = await FlutterBluePlus.scanResults.first;
      final device = scanResults
          .firstWhere(
            (result) => result.device.remoteId.toString() == deviceId,
            orElse: () => throw Exception('Device not found'),
          )
          .device;

      await device.connect();
      _connectedDevices[deviceId] = device;
      return true;
    } catch (e) {
      log('BLE Datasource: Error connecting to device: $e');
      return false;
    }
  }

  @override
  Future<void> disconnectFromDevice(String deviceId) async {
    log('BLE Datasource: Disconnecting from $deviceId');
    try {
      if (_connectedDevices.containsKey(deviceId)) {
        await _connectedDevices[deviceId]!.disconnect();
        _connectedDevices.remove(deviceId);
      }
    } catch (e) {
      log('BLE Datasource: Error disconnecting from device: $e');
    }
  }

  @override
  Future<void> setBleNotification(
    BluetoothDevice device,
    Guid serviceUuid,
    Guid characteristicUuid,
    bool enable,
  ) async {
    log(
      'BLE Datasource: Setting notification for $characteristicUuid to $enable',
    );
    try {
      // Discover services
      List<BluetoothService> services = await device.discoverServices();

      // Find the target service and characteristic
      for (var service in services) {
        if (service.uuid == serviceUuid) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid == characteristicUuid) {
              // Set notification
              if (enable) {
                await characteristic.setNotifyValue(true);
                // Listen to notifications
                characteristic.lastValueStream.listen((value) {
                  _characteristicValueController.add({
                    characteristicUuid: value,
                  });
                });
              } else {
                await characteristic.setNotifyValue(false);
              }
              return;
            }
          }
        }
      }
      throw Exception('Service or characteristic not found');
    } catch (e) {
      log('BLE Datasource: Error setting notification: $e');
      rethrow;
    }
  }

  @override
  Future<void> writeBleCharacteristic(
    BluetoothDevice device,
    Guid serviceUuid,
    Guid characteristicUuid,
    List<int> value, {
    bool withoutResponse = false,
  }) async {
    log('BLE Datasource: Writing to characteristic $characteristicUuid in service $serviceUuid');
    log('Value to write (hex): ${value.map((b) => b.toRadixString(16).padLeft(2, '0')).join(':')}');
    
    try {
      // Log connection state
      log('Device connection state: ${device.connectionState}');
      
      // Discover services
      log('Discovering services...');
      List<BluetoothService> services = await device.discoverServices();
      log('Discovered ${services.length} service(s) on device');
      
      // Log all services and their characteristics for debugging
      for (var service in services) {
        log('Service: ${service.uuid}');
        for (var char in service.characteristics) {
          log('  Characteristic: ${char.uuid} (props: ${char.properties})');
          // Log if this is the characteristic we're looking for
          if (char.uuid == characteristicUuid) {
            log('    ^^^ MATCHES TARGET CHARACTERISTIC ^^^');
          }
        }
      }

      // Find the target service and characteristic
      for (var service in services) {
        if (service.uuid == serviceUuid) {
          log('Found target service: ${service.uuid}');
          
          for (var characteristic in service.characteristics) {
            log('  Checking characteristic: ${characteristic.uuid} (props: ${characteristic.properties})');
            
            if (characteristic.uuid == characteristicUuid) {
              log('  Found target characteristic. Writing value...');
              
              // Check if characteristic is writable
              if (withoutResponse) {
                if (!characteristic.properties.writeWithoutResponse) {
                  log('  Error: Characteristic does not support writeWithoutResponse');
                  throw Exception('Characteristic does not support writeWithoutResponse');
                }
              } else {
                if (!characteristic.properties.write) {
                  log('  Error: Characteristic does not support write with response');
                  throw Exception('Characteristic does not support write with response');
                }
              }
              
              // Write to characteristic
              await characteristic.write(
                value,
                withoutResponse: withoutResponse,
              );
              log('  Write successful');
              return;
            }
          }
          log('  Error: Characteristic $characteristicUuid not found in service');
        }
      }
      
      log('Error: Service $serviceUuid or characteristic $characteristicUuid not found');
      throw Exception('Service or characteristic not found');
    } catch (e) {
      log('BLE Datasource: Error writing to characteristic: $e');
      log('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  @override
  Stream<List<int>> subscribeToSensorData(String deviceId) {
    // Placeholder implementation
    return Stream.empty();
  }

  @override
  Future<void> sendCommandToDevice(String deviceId, String command) async {
    // Placeholder implementation
    log('BLE Datasource: Sending command $command to $deviceId (STUB)');
  }

  @override
  Future<List<String>> discoverWifiNetworks(String deviceId) async {
    // Placeholder implementation
    log('BLE Datasource: Discovering WiFi networks via $deviceId (STUB)');
    return ['WiFi_Network_1', 'WiFi_Network_2'];
  }

  @override
  Future<bool> pairWifiNetwork(
    String deviceId,
    String ssid,
    String password,
  ) async {
    // Placeholder implementation
    log('BLE Datasource: Pairing $deviceId to WiFi network $ssid (STUB)');
    return true;
  }
}
