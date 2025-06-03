import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:developer';
import 'dart:io' show Platform;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:survival/features/sensor_connectivity/domain/entities/sensor_entities.dart';
import 'package:survival/features/sensor_connectivity/domain/repositories/sensor_repository.dart';
import 'package:survival/features/wifi_pairing/presentation/cubit/wifi_pairing_state.dart';
import 'package:wifi_scan/wifi_scan.dart';

// Updated UUIDs for Radar_BLE device
final Guid wifiPairingServiceUuid = Guid(
  "0000FFFF-0000-1000-8000-00805F9B34FB",
);
final Guid wifiPairingWriteCharUuid = Guid(
  "0000FF01-0000-1000-8000-00805F9B34FB",
); // Write characteristic
final Guid wifiPairingReadCharUuid = Guid(
  "0000FF02-0000-1000-8000-00805F9B34FB",
); // Notify characteristic

class WifiPairingCubit extends Cubit<WifiPairingState> {
  final WiFiScan _wifiScan = WiFiScan.instance;
  final SensorRepository sensorRepository;
  StreamSubscription<List<WiFiAccessPoint>>? _scanSubscription;
  StreamSubscription<Map<Guid, List<int>>>? _bleNotificationSubscription;
  BluetoothDevice? _targetDevice;
  String _ssidToPair = "";
  String _passwordToPair = "";

  WifiPairingCubit({required this.sensorRepository})
    : super(WifiPairingInitial());

  Future<void> startWifiScan({bool forceManual = false}) async {
    if (isClosed) return;

    // If forcing manual entry, just show the manual entry UI
    if (forceManual) {
      if (!isClosed) {
        emit(
          const WifiPairingIosManualEntryRequired(
            currentSsid: null,
            showManualOption: true,
            message: 'Please enter your Wi-Fi network details',
          ),
        );
      }
      return;
    }

    if (Platform.isAndroid) {
      await _handleAndroidWifiScan();
    } else if (Platform.isIOS) {
      await _handleIosWifiScan();
    } else {
      if (!isClosed) {
        emit(const WifiPairingFailure('Unsupported platform'));
      }
    }
  }

  Future<void> _handleAndroidWifiScan() async {
    if (isClosed) return;

    emit(const WifiPairingLoading(message: 'Checking permissions...'));

    // Request necessary permissions for Android
    final locationStatus = await Permission.locationWhenInUse.request();
    if (!locationStatus.isGranted) {
      if (!isClosed) {
        emit(
          const WifiPairingFailure(
            'Location permission is required for Wi-Fi scanning. Please enable it in app settings.',
          ),
        );
      }
      return;
    }

    try {
      // First, check if we're already connected to a Wi-Fi network
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.wifi)) {
        String? wifiName = await NetworkInfo().getWifiName();
        String? bssid = await NetworkInfo().getWifiBSSID();

        if (wifiName != null && wifiName.isNotEmpty && wifiName != 'null') {
          // Remove any surrounding quotes from the SSID and BSSID
          wifiName = wifiName.replaceAll('"', '');
          bssid = bssid?.replaceAll('"', '') ?? 'unknown';

          // Create a WiFiNetwork with the current network info
          final currentNetwork = WiFiNetwork(
            ssid: wifiName,
            bssid: bssid,
            level:
                -50, // Default signal strength since we can't get the actual value
            frequency: 2400, // Default 2.4GHz
            capabilities: 'WPA2', // Default security
          );

          if (!isClosed) {
            emit(CurrentWifiNetworkDetected(currentNetwork));
            emit(
              WifiPairingIosManualEntryRequired(
                currentSsid: wifiName,
                showManualOption: false,
              ),
            );
            return; // Exit after handling connected network
          }
        }
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          WifiPairingFailure('Error checking current network: ${e.toString()}'),
        );
      }
      return;
    }

    // If we get here, either we're not connected to Wi-Fi or couldn't get current network info
    // Proceed with Wi-Fi scanning
    emit(
      const WifiPairingLoading(
        message: 'Scanning for available Wi-Fi networks...',
      ),
    );

    try {
      final canScan = await _wifiScan.canStartScan(askPermissions: true);
      if (canScan != CanStartScan.yes) {
        if (!isClosed) {
          emit(WifiPairingFailure('Cannot start Wi-Fi scan: $canScan'));
        }
        return;
      }

      if (!isClosed) emit(const WifiScanResultsReady([]));
      final isScanning = await _wifiScan.startScan();

      if (!isScanning) {
        if (!isClosed) {
          emit(const WifiPairingFailure('Failed to start Wi-Fi scan.'));
        }
        return;
      }

      await _scanSubscription?.cancel();
      _scanSubscription = _wifiScan.onScannedResultsAvailable.listen(
        (List<WiFiAccessPoint> results) {
          // Convert WiFiAccessPoint to WiFiNetwork
          final validResults = results
              .where((ap) => ap.ssid.isNotEmpty)
              .map(
                (ap) => WiFiNetwork(
                  ssid: ap.ssid,
                  bssid: ap.bssid,
                  level: ap.level,
                  frequency: ap.frequency,
                  capabilities: ap.capabilities,
                ),
              )
              .toList();

          // Sort by signal strength (strongest first)
          validResults.sort((a, b) => b.level.compareTo(a.level));

          if (!isClosed) {
            emit(WifiScanResultsReady(validResults));
          }
        },
        onError: (e) {
          if (!isClosed) {
            emit(WifiPairingFailure('Wi-Fi scan error: $e'));
          }
        },
        cancelOnError: true,
      );
    } catch (e) {
      if (!isClosed) {
        emit(WifiPairingFailure('Error during Wi-Fi scan: ${e.toString()}'));
      }
    }
  }

  Future<void> _handleIosWifiScan() async {
    if (isClosed) return;

    // On iOS, we can only get the currently connected network
    emit(const WifiPairingLoading(message: 'Checking Wi-Fi status...'));

    try {
      // Check location permission status first
      var status = await Permission.locationWhenInUse.status;

      // If we don't have location permission, request it
      if (status.isDenied) {
        status = await Permission.locationWhenInUse.request();
      }

      if (status.isPermanentlyDenied) {
        if (!isClosed) {
          emit(
            const WifiPairingIosManualEntryRequired(
              currentSsid: null,
              showManualOption: true,
              message:
                  'Location permission is required to detect Wi-Fi network. Please enable it in Settings or enter network details manually.',
            ),
          );
        }
        return;
      }

      // Check if connected to WiFi
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (!connectivityResult.contains(ConnectivityResult.wifi)) {
        if (!isClosed) {
          emit(
            const WifiPairingIosManualEntryRequired(
              currentSsid: null,
              showManualOption: true,
              message: 'Please connect to a Wi-Fi network to continue.',
            ),
          );
        }
        return;
      }

      // Try to get WiFi info
      try {
        final wifiName = await NetworkInfo().getWifiName();

        if (wifiName == null || wifiName.isEmpty) {
          throw Exception('Could not detect Wi-Fi network');
        }

        if (!isClosed) {
          emit(
            WifiPairingIosManualEntryRequired(
              currentSsid: wifiName,
              showManualOption: true,
              message: 'Detected network: $wifiName',
            ),
          );
        }
      } catch (e) {
        if (!isClosed) {
          emit(
            const WifiPairingIosManualEntryRequired(
              currentSsid: null,
              showManualOption: true,
              message:
                  'Could not detect Wi-Fi network. Please enter network details manually.',
            ),
          );
        }
      }

      // If we don't have location permission, just go to manual entry
      if (!status.isGranted) {
        if (!isClosed) {
          emit(
            const WifiPairingIosManualEntryRequired(
              currentSsid: null,
              showManualOption: true,
              message:
                  'Location permission is required to detect Wi-Fi network. Please enable it in Settings or enter network details manually.',
            ),
          );
        }
        return;
      }

      // If permission is denied, request it
      if (status.isDenied) {
        developer.log('Location permission not granted, requesting...');
        status = await Permission.locationWhenInUse.request();

        // If user denied, show appropriate message
        if (status.isDenied || status.isPermanentlyDenied) {
          if (!isClosed) {
            emit(
              WifiPairingFailure(
                'Location permission is required to scan for Wi-Fi networks.\n\nPlease enable location access in Settings to continue.',
                action: WifiPairingAction(
                  label: 'Open Settings',
                  onAction: () async {
                    await openAppSettings();
                    // After returning from settings, check again
                    if (!isClosed) {
                      await Future.delayed(const Duration(seconds: 1));
                      startWifiScan();
                    }
                  },
                ),
              ),
            );
          }
          return;
        }
      }

      // Check if location services are enabled
      final isLocationEnabled =
          await Permission.locationWhenInUse.serviceStatus.isEnabled;
      if (!isLocationEnabled) {
        if (!isClosed) {
          emit(
            WifiPairingFailure(
              'Location Services are disabled.\n\nPlease enable Location Services in Settings > Privacy & Security > Location Services to continue.',
              action: WifiPairingAction(
                label: 'Open Settings',
                onAction: () async {
                  await openAppSettings();
                  // After returning from settings, check again
                  if (!isClosed) {
                    await Future.delayed(const Duration(seconds: 1));
                    startWifiScan();
                  }
                },
              ),
            ),
          );
        }
        return;
      }

      // At this point, we should have location permission and services enabled
      if (!status.isGranted) {
        if (!isClosed) {
          emit(
            const WifiPairingFailure(
              'Unable to access location services. Please try again.',
            ),
          );
        }
        return;
      }

      // Now check network connectivity
      developer.log('Checking network connectivity...');
      try {
        final connectivityResults = await Connectivity().checkConnectivity();
        developer.log('Connectivity results: $connectivityResults');
        final isWifi = connectivityResults.contains(ConnectivityResult.wifi);
        developer.log('Is connected to WiFi: $isWifi');

        // Get the current Wi-Fi network info if available
        developer.log('Getting Wi-Fi network info...');
        String? wifiName;
        String? bssid;

        try {
          wifiName = await NetworkInfo().getWifiName();
          bssid = await NetworkInfo().getWifiBSSID();
        } catch (e) {
          developer.log('Error getting WiFi info: $e');
        }

        developer.log('Wi-Fi Name: $wifiName, BSSID: $bssid');

        // Clean up the Wi-Fi name and BSSID if they exist
        final cleanWifiName = (wifiName?.isNotEmpty == true)
            ? wifiName!.replaceAll('"', '')
            : null;
        final cleanBssid = (bssid?.isNotEmpty == true)
            ? bssid!.replaceAll('"', '')
            : null;
        final hasNetworkInfo = cleanWifiName != null && cleanBssid != null;

        // If we have valid network info, use it
        if (isWifi && hasNetworkInfo) {
          // Create a WiFiNetwork with the current network info
          final currentNetwork = WiFiNetwork(
            ssid: cleanWifiName,
            bssid: cleanBssid,
            level:
                -50, // Default signal strength since we can't get the actual value on iOS
            frequency: 2400, // Default 2.4GHz
            capabilities: 'WPA2', // Default security
          );

          developer.log(
            'Using network: ${currentNetwork.ssid} (${currentNetwork.bssid})',
          );

          if (!isClosed) {
            emit(CurrentWifiNetworkDetected(currentNetwork));
            // Show manual entry option with current network pre-filled
            emit(
              WifiPairingIosManualEntryRequired(
                currentSsid: cleanWifiName,
                showManualOption: true,
              ),
            );
          }
        } else {
          // Not connected to WiFi or couldn't get network info, allow manual entry
          if (!isClosed) {
            emit(
              WifiPairingIosManualEntryRequired(
                currentSsid: cleanWifiName,
                showManualOption: true,
              ),
            );
          }
        }
      } catch (e) {
        developer.log('Error checking connectivity: $e');
        if (!isClosed) {
          emit(
            WifiPairingFailure(
              'Network error detected. Please check your connection and try again.\n\nError: $e',
              action: WifiPairingAction(
                label: 'Retry',
                onAction: startWifiScan,
              ),
            ),
          );
        }
        return;
      }

      final connectivityResults = await Connectivity().checkConnectivity();
      if (!connectivityResults.contains(ConnectivityResult.wifi)) {
        if (!isClosed) {
          emit(
            WifiPairingFailure(
              'No internet connection detected.\n\nPlease connect to a Wi-Fi network to continue.',
              action: WifiPairingAction(
                label: 'Open Wi-Fi Settings',
                onAction: () async {
                  try {
                    await openAppSettings();
                    // Wait a bit for the user to change settings
                    await Future.delayed(const Duration(seconds: 2));
                    if (!isClosed) {
                      // Force a fresh connectivity check
                      await Future.delayed(const Duration(seconds: 1));
                      startWifiScan();
                    }
                  } catch (e) {
                    developer.log('Error opening settings: $e');
                  }
                },
              ),
            ),
          );
        }
      } else {
        // For mobile data or other connection types
        if (!isClosed) {
          emit(
            WifiPairingFailure(
              'Wi-Fi connection required.\n\nPlease connect to a Wi-Fi network to continue.\n\nNote: Mobile data cannot be used for device setup.',
              action: WifiPairingAction(
                label: 'Open Wi-Fi Settings',
                onAction: () async {
                  try {
                    await openAppSettings();
                    // Wait a bit for the user to change settings
                    await Future.delayed(const Duration(seconds: 2));
                    if (!isClosed) {
                      // Force a fresh connectivity check
                      await Future.delayed(const Duration(seconds: 1));
                      startWifiScan();
                    }
                  } catch (e) {
                    developer.log('Error opening settings: $e');
                  }
                },
              ),
            ),
          );
        }
      }
    } on PlatformException catch (e) {
      developer.log('PlatformException in _handleIosWifiScan: ${e.toString()}');
      developer.log('Error code: ${e.code}, message: ${e.message}');

      if (!isClosed) {
        if (e.code == 'location_services_disabled' ||
            e.code == 'SERVICE_STATUS_ERROR') {
          emit(
            WifiPairingFailure(
              'Location services are disabled.\n\nPlease enable Location Services in Settings > Privacy & Security > Location Services to continue.',
              action: WifiPairingAction(
                label: 'Open Settings',
                onAction: () async {
                  await openAppSettings();
                  // After returning from settings, check again
                  if (!isClosed) {
                    await Future.delayed(const Duration(seconds: 1));
                    startWifiScan();
                  }
                },
              ),
            ),
          );
        } else if (e.code == 'location_permission_denied') {
          emit(
            const WifiPairingFailure(
              'Location permission is required to detect Wi-Fi networks.\n\nPlease grant location access to continue.',
            ),
          );
        } else {
          emit(
            WifiPairingFailure(
              'Unable to access network information: ${e.message ?? 'Please check your settings and try again.'}',
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error in _handleIosWifiScan: $e\n$stackTrace',
        error: e,
        stackTrace: stackTrace,
      );
      if (!isClosed) {
        emit(
          const WifiPairingFailure(
            'An unexpected error occurred while checking Wi-Fi status.\n\nPlease try again or restart the app.',
          ),
        );
      }
    }
  }

  Future<void> stopWifiScan() async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    if (!isClosed &&
        (state is WifiScanResultsReady ||
            (state is WifiPairingLoading &&
                (state as WifiPairingLoading).message.contains("Wi-Fi")))) {
      emit(WifiPairingInitial());
    }
  }

  Future<void> startPairingProcess(
    BluetoothDevice device,
    String ssid,
    String password,
  ) async {
    if (isClosed) return;
    _targetDevice = device;
    _ssidToPair = ssid;
    _passwordToPair = password;
    emit(const WifiPairingLoading(message: 'Starting pairing...'));

    await sensorRepository.connectBleDevice(device);

    final subscribed = await _subscribeToPairingNotifications(device);
    if (!subscribed) return;

    await _sendBleCommand(device, _buildCommand(0x01, []));
  }

  Future<void> _sendSsid() async {
    if (isClosed || _targetDevice == null || _ssidToPair.isEmpty) return;
    emit(const WifiPairingInProgress(message: 'Sending SSID...'));
    List<int> ssidBytes = utf8.encode(_ssidToPair);
    await _sendBleCommand(_targetDevice!, _buildCommand(0x02, ssidBytes));
  }

  Future<void> _sendPassword() async {
    if (isClosed || _targetDevice == null) {
      return; // Allow empty password for open networks
    }
    emit(const WifiPairingInProgress(message: 'Sending Password...'));
    List<int> passwordBytes = utf8.encode(_passwordToPair);
    await _sendBleCommand(_targetDevice!, _buildCommand(0x03, passwordBytes));
  }

  Future<bool> _subscribeToPairingNotifications(BluetoothDevice device) async {
    if (isClosed) return false;
    await _bleNotificationSubscription?.cancel();

    // Get the stream for the characteristic's value updates
    // This assumes SensorRepository provides a way to get the stream, which it currently doesn't.
    // We need to adapt this part based on the actual implementation of SensorRepository.
    // For now, we'll simulate success and handle notifications manually if possible.

    // Placeholder: Assume subscription setup is successful
    // In a real scenario, this would involve interacting with the repository/datasource
    // to get the notification stream.
    log("Attempting to listen to notifications (simulation)...");
    // Simulate listening - replace with actual stream subscription
    // Example: _bleNotificationSubscription = sensorRepository.getNotificationStream(device, serviceUuid, charUuid).listen(...);
    _setupSimulatedNotificationListener(
      device,
    ); // Call a temporary simulation method

    return true; // Simulate success for now
  }

  // --- SIMULATION: Replace with actual BLE notification handling ---
  // This is a temporary workaround because SensorRepository doesn't expose the stream directly.
  void _setupSimulatedNotificationListener(BluetoothDevice device) {
    // In a real app, you'd get the characteristic and listen to its `onValueReceived` stream.
    // Example (conceptual - requires characteristic object):
    /*
     try {
       BluetoothCharacteristic? readChar = await _findCharacteristic(device, wifiPairingServiceUuid, wifiPairingReadCharUuid);
       if (readChar != null) {
         await readChar.setNotifyValue(true);
         _bleNotificationSubscription = readChar.onValueReceived.listen((value) {
            print("Simulated BLE Notification Received: $value");
            _handlePairingNotification({wifiPairingReadCharUuid: value});
         }, onError: (e) {
            if (!isClosed) emit(WifiPairingFailure('BLE notification error: $e'));
         });
       } else {
         if (!isClosed) emit(WifiPairingFailure('Could not find pairing read characteristic.'));
       }
     } catch (e) {
        if (!isClosed) emit(WifiPairingFailure('Error setting up BLE listener: $e'));
     }
     */
    log(
      "Simulated listener setup complete. Waiting for simulated notifications...",
    );
    log("Simulating responses...");
    _simulateResponses();
  }

  // --- SIMULATION HELPER ---
  Future<void> _simulateResponses() async {
    await Future.delayed(
      const Duration(seconds: 2),
    ); // Simulate delay for CMD 0x05
    if (!isClosed) {
      _handlePairingNotification({
        wifiPairingReadCharUuid: [0xAA, 0x55, 0x05, 0x00, 0xFE],
      }); // Simulate ACK for pairing request
    }
    await Future.delayed(
      const Duration(seconds: 2),
    ); // Simulate delay for CMD 0x06
    if (!isClosed) {
      _handlePairingNotification({
        wifiPairingReadCharUuid: [0xAA, 0x55, 0x06, 0x00, 0xFF],
      }); // Simulate ACK for SSID
    }
    await Future.delayed(
      const Duration(seconds: 2),
    ); // Simulate delay for CMD 0x07
    if (!isClosed) {
      _handlePairingNotification({
        wifiPairingReadCharUuid: [0xAA, 0x55, 0x07, 0x00, 0x00],
      }); // Simulate ACK for Password
    }
    await Future.delayed(
      const Duration(seconds: 5),
    ); // Simulate delay for CMD 0x08 (connection success)
    if (!isClosed) {
      _handlePairingNotification({
        wifiPairingReadCharUuid: [0xAA, 0x55, 0x08, 0x00, 0x01],
      }); // Simulate Connection Success
    }
  }
  // --- END SIMULATION ---

  void _handlePairingNotification(Map<Guid, List<int>> dataMap) {
    if (isClosed || _targetDevice == null) return;

    if (dataMap.containsKey(wifiPairingReadCharUuid)) {
      List<int> data = dataMap[wifiPairingReadCharUuid]!;
      log("Handling Pairing Notification: $data");

      if (data.length >= 4 && data[0] == 0xAA && data[1] == 0x55) {
        int cmd = data[2];
        log("Pairing Step: Received Command $cmd");

        switch (cmd) {
          case 0x05: // ACK: Pairing request received
            log("Pairing Step: Device ACK Request. Sending SSID...");
            _sendSsid();
            break;
          case 0x06: // ACK: SSID received
            log("Pairing Step: Device ACK SSID. Sending Password...");
            _sendPassword();
            break;
          case 0x07: // ACK: Password received, device connecting...
            log("Pairing Step: Device ACK Password. Connecting to Wi-Fi...");
            emit(const WifiPairingDeviceConnecting());
            break;
          case 0x08: // SUCCESS: Router connection successful
            log(
              "Pairing Step: Router connection successful! Adding device to Firestore...",
            );
            // --- Add device to Firestore ---
            _addDeviceToFirestore(_targetDevice!);
            // Emit success state AFTER attempting to add to Firestore
            emit(const WifiPairingSuccess());
            _cleanup();
            break;
          case 0x09: // FAIL: Timeout
          case 0xA0: // FAIL: Wrong credentials
            log("Pairing Step: Router connection failed (CMD: $cmd).");
            emit(
              WifiPairingFailure(
                'Device failed to connect to Wi-Fi (Code: $cmd)',
              ),
            );
            _cleanup();
            break;
          case 0x01: // FAIL: CRC error
            log("Pairing Step: Device reported CRC error.");
            emit(
              const WifiPairingFailure(
                'Device reported a communication error (CRC).',
              ),
            );
            _cleanup();
            break;
          default:
            log("Pairing Step: Received unknown command $cmd");
        }
      } else {
        log("Pairing Step: Received invalid data format: $data");
      }
    }
  }

  // --- New method to add device to Firestore ---
  Future<void> _addDeviceToFirestore(BluetoothDevice bleDevice) async {
    if (isClosed) return;
    log("Attempting to add device ${bleDevice.remoteId} to Firestore...");
    final deviceToAdd = SensorDevice(
      id: bleDevice.remoteId
          .toString(), // Use BLE remote ID as Firestore document ID
      name: bleDevice.platformName.isNotEmpty
          ? bleDevice.platformName
          : 'New Sensor Device',
      type: SensorType.unknown, // Or determine from BLE data if possible
      status: DeviceStatus.online, // Assume online after successful pairing
      registrationDate: DateTime.now(),
      lastUpdated: DateTime.now(),
      // Add other relevant initial fields if needed
      location: null,
      notificationsEnabled: true,
    );

    final result = await sensorRepository.addDeviceToFirestore(deviceToAdd);
    if (isClosed) return;

    result.fold(
      (failure) {
        log("Error adding device to Firestore: ${failure.toString()}");
        // Emit failure state, indicating pairing worked but saving failed
        emit(
          WifiPairingFailure(
            'Wi-Fi connected, but failed to save device: ${failure.toString()}',
          ),
        );
      },
      (_) {
        log("Device ${bleDevice.remoteId} successfully added to Firestore.");
        // Emit final success state for the pairing process
        emit(const WifiPairingSuccess());
        // SensorCubit listening to Firestore stream will automatically pick up the new device.
      },
    );
  }

  Future<void> _sendBleCommand(
    BluetoothDevice device,
    List<int> command,
  ) async {
    if (isClosed) return;
    log("Sending BLE command: $command");
    final result = await sensorRepository.writeBleCharacteristic(
      device,
      wifiPairingServiceUuid,
      wifiPairingWriteCharUuid,
      command,
      withoutResponse: false, // Assume write with response
    );
    if (isClosed) return;
    result.fold(
      (failure) {
        if (!isClosed) {
          emit(
            WifiPairingFailure(
              'Failed to send command via BLE: ${failure.toString()}',
            ),
          );
        }
      },
      (_) {
        log("Sent BLE command successfully.");
      },
    );
  }

  List<int> _buildCommand(int cmd, List<int> data) {
    List<int> command = [0x55, 0xAA];
    command.add(cmd);
    command.add(data.length);
    command.addAll(data);
    int crc = _calculateCrc(command);
    command.add(crc);
    return command;
  }

  int _calculateCrc(List<int> data) {
    int crc = 0;
    for (int byte in data) {
      crc = (crc + byte) & 0xFF;
    }
    return crc;
  }

  void _cleanup() {
    _bleNotificationSubscription?.cancel();
    _bleNotificationSubscription = null;
    // Unsubscribe from BLE notifications
    if (_targetDevice != null) {
      sensorRepository
          .setBleNotification(
            _targetDevice!,
            wifiPairingServiceUuid,
            wifiPairingReadCharUuid,
            false,
          )
          .then((_) {
            log("Unsubscribed from pairing notifications.");
          })
          .catchError((e) {
            log("Error unsubscribing from pairing notifications: $e");
          });
    }
    // Reset target device after cleanup
    // _targetDevice = null;
  }

  void cancelPairing() {
    log("Pairing cancelled by user.");
    _cleanup();
    if (!isClosed) emit(WifiPairingInitial());
  }

  @override
  Future<void> close() {
    stopWifiScan();
    _cleanup();
    return super.close();
  }
}
