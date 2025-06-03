import 'dart:async';
import 'dart:core' as sensor_state;
import 'dart:core';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:survival/core/theme/theme.dart';
import 'package:survival/features/sensor_connectivity/presentation/cubit/sensor_cubit.dart';
import 'package:survival/features/sensor_connectivity/presentation/cubit/sensor_state.dart'
    as sensor_state;
import 'package:survival/features/wifi_pairing/presentation/pages/wifi_pairing_page.dart';

class AddDevicePage extends StatefulWidget {
  const AddDevicePage({super.key});

  @override
  State<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  late SensorCubit _sensorCubit;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<List<ScanResult>>? _scanResultsSubscription;
  bool _isScanning = false;
  String _errorMessage = '';
  bool _bluetoothEnabled = false;
  final List<BluetoothDevice> _discoveredDevices = [];

  @override
  void initState() {
    super.initState();
    _sensorCubit = context.read<SensorCubit>();
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    // Check if Bluetooth is available on this device
    bool isAvailable = await FlutterBluePlus.isSupported;
    if (!isAvailable) {
      setState(
        () => _errorMessage = 'Bluetooth is not supported on this device',
      );
      return;
    }

    // Listen to Bluetooth state changes
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      setState(() {
        _bluetoothEnabled = state == BluetoothAdapterState.on;
        if (!_bluetoothEnabled) {
          _errorMessage =
              'Bluetooth is turned off. Please enable Bluetooth to continue.';
        } else {
          _errorMessage = '';
          _checkPermissionsAndStartScan();
        }
      });
    });

    // Initial check
    _bluetoothEnabled =
        await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on;
    if (_bluetoothEnabled) {
      await _checkPermissionsAndStartScan();
    } else {
      setState(
        () => _errorMessage =
            'Bluetooth is turned off. Please enable Bluetooth to continue.',
      );
    }
  }

  Future<void> _checkPermissionsAndStartScan() async {
    // Check and request location permission (required for BLE on Android)
    var status = await Permission.location.status;
    if (!status.isGranted) {
      status = await Permission.location.request();
      if (!status.isGranted) {
        setState(
          () => _errorMessage =
              'Location permission is required to scan for BLE devices',
        );
        return;
      }
    }

    if (status.isGranted) {
      _startScan();
    } else {
      setState(
        () => _errorMessage =
            'Location permission is required to scan for BLE devices',
      );
    }
  }

  void _logDevice(ScanResult result) {
    final device = result.device;
    log('''
--- Device Found ---
Name: ${device.platformName}
ID: ${device.remoteId}
RSSI: ${result.rssi}
Advertisement Data: ${result.advertisementData.toString()}
-------------------
''');

    if (!_discoveredDevices.any((d) => d.remoteId == device.remoteId)) {
      setState(() {
        _discoveredDevices.add(device);
      });
    }
  }

  Future<void> _startScan() async {
    if (_isScanning || !mounted) return;

    setState(() {
      _isScanning = true;
      _errorMessage = '';
      _discoveredDevices.clear();
    });

    try {
      // Cancel any existing subscription
      await _scanResultsSubscription?.cancel();

      _scanResultsSubscription = FlutterBluePlus.scanResults.listen(
        (results) {
          if (!mounted) return;
          for (var result in results) {
            _logDevice(result);
          }
        },
        onError: (e) {
          log('Error in scan results: $e');
          if (mounted) {
            setState(() {
              _errorMessage = 'Error scanning: ${e.toString()}';
              _isScanning = false;
            });
          }
        },
        cancelOnError: true,
      );

      log('Starting BLE device scan...');

      // Start the scan with a timeout
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 6),
        androidUsesFineLocation: true,
      );

      if (!mounted) return;
      log('BLE device scan started');

      // Stop scanning after timeout
      await Future.delayed(const Duration(seconds: 6));

      if (mounted && _isScanning) {
        await FlutterBluePlus.stopScan();
        if (mounted) {
          setState(() => _isScanning = false);
        }
      }
    } catch (e) {
      final errorMsg = 'Error scanning for devices: ${e.toString()}';
      log(errorMsg);
      if (mounted) {
        setState(() => _errorMessage = errorMsg);
      }
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  Future<void> _onDeviceSelected(BluetoothDevice device) async {
    // Stop scanning if needed
    if (_isScanning) {
      await FlutterBluePlus.stopScan();
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }

    log('Selected device: ${device.platformName} (${device.remoteId})');

    if (!mounted) return;
    final navigatorContext = context;

    // Show loading dialog
    final completer = Completer<void>();

    // Show loading dialog
    if (navigatorContext.mounted) {
      showDialog<void>(
        context: navigatorContext,
        barrierDismissible: false,
        builder: (BuildContext context) => const PopScope(
          canPop: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ).then((_) => completer.complete());
    }

    try {
      // Connect to the device
      log('Connecting to ${device.platformName}...');
      await device.connect(autoConnect: false);
      log('Connected to ${device.platformName}');

      if (!mounted) return;

      // Dismiss the dialog
      if (navigatorContext.mounted) {
        Navigator.of(navigatorContext, rootNavigator: true).pop();
      }
      await completer.future; // Wait for dialog to be dismissed

      log('Navigating to WiFi pairing page');
      if (mounted) {
        // Use a small delay to ensure the dialog is fully dismissed
        await Future.delayed(const Duration(milliseconds: 50));

        // Navigate to WiFi pairing page using MaterialPageRoute for more reliable navigation
        if (context.mounted) {
          await Navigator.of(navigatorContext, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => WifiPairingPage(deviceFromRoute: device),
            ),
          );
        }
      }
    } catch (e) {
      log('Error connecting to device: $e');

      // Dismiss loading dialog if still showing
      if (navigatorContext.mounted) {
        Navigator.of(navigatorContext, rootNavigator: true).pop();
      }

      // Show error message
      if (navigatorContext.mounted) {
        ScaffoldMessenger.of(navigatorContext)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Failed to connect: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
      }
    }
  }

  @override
  void dispose() {
    _adapterStateSubscription?.cancel();
    _scanResultsSubscription?.cancel();
    _isScanning = false; // Ensure we don't try to update state after dispose
    // Don't await here, just stop the scan
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  Widget _buildDeviceListWithDiscoveredDevices() {
    // Filter to show only Radar devices
    final radarDevices = _discoveredDevices.where((device) {
      final name = device.platformName.toLowerCase();
      return name.contains('radar');
    }).toList();

    if (radarDevices.isEmpty) {
      return _buildEmptyState(
        'No Radar devices found.\nMake sure your Radar device is powered on and in pairing mode.',
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Found ${radarDevices.length} Radar device${radarDevices.length != 1 ? 's' : ''} nearby',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: radarDevices.length,
            itemBuilder: (context, index) {
              final device = radarDevices[index];
              final deviceName = device.platformName.isNotEmpty
                  ? device.platformName
                  : 'Radar Device';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                elevation: 1,
                child: ListTile(
                  leading: const Icon(Icons.radar, color: primaryColor),
                  title: Text(
                    deviceName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${device.remoteId}'),
                      Text('Signal: ${_getRssiForDevice(device) ?? 'N/A'} dBm'),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.bluetooth_searching,
                    color: Colors.blue,
                  ),
                  onTap: () => _onDeviceSelected(device),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Helper method to get RSSI for a device
  int? _getRssiForDevice(BluetoothDevice device) {
    try {
      // This is a placeholder - you'll need to track RSSI values in your scan results
      // and return the latest one for the given device
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Device'),
        actions: [
          IconButton(
            icon: _isScanning
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isScanning ? null : _startScan,
            tooltip: 'Rescan for devices',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<SensorCubit, sensor_state.SensorState>(
        bloc: _sensorCubit,
        builder: (context, state) {
          // Show error message if any
          if (_errorMessage.isNotEmpty) {
            return _buildErrorState(_errorMessage);
          }

          // Show discovered devices if we have any
          if (_discoveredDevices.isNotEmpty) {
            return _buildDeviceListWithDiscoveredDevices();
          }

          // Show loading state
          if (_isScanning) {
            return _buildLoadingState('Scanning for nearby devices...');
          }

          // Initial state
          return _buildEmptyState(
            'Press the refresh button to start scanning.',
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, {bool showRetry = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: accentRed),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
            ),
            if (showRetry) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _startScan,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
            if (!_bluetoothEnabled) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  await FlutterBluePlus.turnOn();
                },
                icon: const Icon(Icons.bluetooth),
                label: const Text('Enable Bluetooth'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isScanning
                ? const CircularProgressIndicator()
                : Icon(
                    Icons.bluetooth_searching,
                    size: 64,
                    color: Colors.grey[400],
                  ),
            const SizedBox(height: 16),
            Text(
              _isScanning
                  ? 'Scanning for devices...\n\nPlease wait...'
                  : message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            if (!_isScanning) ...[
              ElevatedButton.icon(
                onPressed: _startScan,
                icon: const Icon(Icons.refresh),
                label: const Text('Scan Again'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ] else ...[
              const Text('Looking for nearby devices...'),
            ],
          ],
        ),
      ),
    );
  }
}
