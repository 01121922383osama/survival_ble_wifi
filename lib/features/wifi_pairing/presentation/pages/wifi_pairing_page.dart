import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:survival/features/sensor_connectivity/presentation/cubit/sensor_cubit.dart';
import 'package:survival/features/sensor_connectivity/presentation/cubit/sensor_state.dart'
    as sensor;
import 'package:survival/features/wifi_pairing/presentation/cubit/wifi_pairing_cubit.dart';
import 'package:survival/features/wifi_pairing/presentation/cubit/wifi_pairing_state.dart';

class WifiPairingPage extends StatefulWidget {
  final BluetoothDevice? deviceFromRoute;

  const WifiPairingPage({super.key, this.deviceFromRoute});

  @override
  State<WifiPairingPage> createState() => _WifiPairingPageState();
}

class _WifiPairingPageState extends State<WifiPairingPage> {
  WiFiNetwork? _selectedNetwork;
  final _passwordController = TextEditingController();
  final TextEditingController _manualSsidController = TextEditingController();
  final TextEditingController _manualPasswordController =
      TextEditingController();
  final FocusNode _ssidFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  BluetoothDevice? _targetDevice;
  late final WifiPairingCubit _wifiPairingCubit;
  String? _lastManualSsid;

  @override
  void initState() {
    super.initState();
    _wifiPairingCubit = context.read<WifiPairingCubit>();

    if (widget.deviceFromRoute != null) {
      _targetDevice = widget.deviceFromRoute;
      log(
        "WifiPairingPage: Received device from route: ${_targetDevice!.remoteId}",
      );
    } else {
      final sensorState = context.read<SensorCubit>().state;
      if (sensorState is sensor.BleDeviceConnectionStateChanged &&
          sensorState.connectionState == BluetoothConnectionState.connected) {
        _targetDevice = sensorState.device;
        log(
          "WifiPairingPage: Using already connected device from SensorCubit: ${_targetDevice!.remoteId}",
        );
      } else {
        log(
          "WifiPairingPage: No device passed via route and no device connected in SensorCubit.",
        );

        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Error: No sensor device selected or connected.'),
              ),
            );
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });
      }
    }

    if (_targetDevice != null) {
      _wifiPairingCubit.startWifiScan();
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _manualSsidController.dispose();
    _manualPasswordController.dispose();
    _ssidFocusNode.dispose();
    _passwordFocusNode.dispose();
    _wifiPairingCubit.stopWifiScan();
    super.dispose();
  }

  bool _isNetworkOpen(String capabilities) {
    capabilities = capabilities.toUpperCase();
    return !capabilities.contains('WPA') &&
        !capabilities.contains('WEP') &&
        !capabilities.contains('ESS');
  }

  void _startPairing() {
    if (_targetDevice == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Error: No target sensor device specified.'),
          ),
        );
      return;
    }
    if (_selectedNetwork == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Please select a Wi-Fi network.')),
        );
      return;
    }
    final password = _passwordController.text;
    if (!_isNetworkOpen(_selectedNetwork!.capabilities) && password.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Please enter the Wi-Fi password.')),
        );
      return;
    }

    _wifiPairingCubit.startPairingProcess(
      _targetDevice!,
      _selectedNetwork!.ssid,
      password,
    );
  }

  Widget _buildLocationPermissionFab() {
    return BlocBuilder<WifiPairingCubit, WifiPairingState>(
      builder: (context, state) {
        if (state is WifiPairingFailure && state.action != null) {
          return FloatingActionButton.extended(
            onPressed: state.action!.onAction,
            icon: const Icon(Icons.settings),
            label: Text(state.action!.label),
            backgroundColor: Colors.orange,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildErrorState(WifiPairingFailure state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, size: 64, color: Colors.orange),
            const SizedBox(height: 24),
            Text(
              'Location Services Required',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              state.error,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (state.action != null)
              ElevatedButton.icon(
                onPressed: state.action!.onAction,
                icon: const Icon(Icons.settings),
                label: Text(state.action!.label),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_targetDevice == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pair Sensor with Wi-Fi')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Error: Could not identify the sensor device to pair. Please go back and select a device.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pair ${_targetDevice!.platformName.isNotEmpty ? _targetDevice!.platformName : _targetDevice!.remoteId}',
        ),
      ),
      floatingActionButton: _buildLocationPermissionFab(),
      body: BlocConsumer<WifiPairingCubit, WifiPairingState>(
        listener: (context, state) {
          log('WifiPairingPage: Pairing state changed: $state');
          if (state is WifiPairingFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text('Pairing Failed: ${state.error}')),
              );
          } else if (state is WifiPairingSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('Wi-Fi Pairing Successful!')),
              );

            if (context.canPop()) {
              context.pop();
            }
          }
        },
        builder: (context, state) {
          debugPrint('WiFi Pairing State: $state');

          if (state is WifiPairingIosManualEntryRequired) {
            return _buildManualEntryUI(state);
          }

          if (state is WifiPairingLoading) {
            return Stack(
              children: [
                Column(
                  children: [
                    const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Checking network...'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<WifiPairingCubit>().startWifiScan(
                          forceManual: true,
                        );
                      },
                      icon: const Icon(Icons.wifi_find),
                      label: const Text('Enter Network Manually'),
                    ),
                  ),
                ),
              ],
            );
          }

          if (state is WifiPairingFailure) {
            return Stack(
              children: [
                Column(children: [Expanded(child: _buildErrorState(state))]),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<WifiPairingCubit>().startWifiScan(
                          forceManual: true,
                        );
                      },
                      icon: const Icon(Icons.wifi_find),
                      label: const Text('Enter Network Manually'),
                    ),
                  ),
                ),
              ],
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Rescan Wi-Fi Networks'),
                  onPressed: state is WifiPairingLoading
                      ? null
                      : () {
                          _wifiPairingCubit.startWifiScan();
                        },
                ),
                const SizedBox(height: 16),
                if (state is WifiPairingLoading &&
                    state.message.contains('Wi-Fi'))
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state is WifiScanResultsReady)
                  Expanded(child: _buildWifiList(state.accessPoints))
                else if (state is WifiPairingInProgress ||
                    state is WifiPairingDeviceConnecting)
                  Expanded(child: _buildPairingProgressIndicator(state))
                else
                  const Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Scanning for Wi-Fi networks...'),
                          SizedBox(height: 8),
                          Text(
                            'No networks found or manual entry required.',
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_selectedNetwork != null &&
                    state is! WifiPairingInProgress &&
                    state is! WifiPairingDeviceConnecting &&
                    state is! WifiPairingSuccess)
                  _buildPasswordInputAndPairButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWifiList(List<WiFiNetwork> accessPoints) {
    if (accessPoints.isEmpty) {
      return const Center(
        child: Text('No Wi-Fi networks found. Try scanning again.'),
      );
    }

    accessPoints.sort((a, b) => b.level.compareTo(a.level));

    return ListView.builder(
      itemCount: accessPoints.length,
      itemBuilder: (context, index) {
        final ap = accessPoints[index];
        final isSelected =
            _selectedNetwork?.ssid == ap.ssid &&
            _selectedNetwork?.bssid == ap.bssid;
        final bool isOpen = _isNetworkOpen(ap.capabilities);
        return Card(
          color: isSelected
              ? Theme.of(context).primaryColor.withAlpha(30)
              : null,
          child: ListTile(
            leading: Icon(_getWifiIcon(ap.level, !isOpen)),
            title: Text(ap.ssid.isNotEmpty ? ap.ssid : '(Hidden Network)'),
            subtitle: Text(
              '${isOpen ? "Open" : "Secured"} | Signal: ${ap.level} dBm | ${ap.frequency > 4900 ? '5GHz' : '2.4GHz'}',
            ),
            selected: isSelected,
            onTap: () {
              setState(() {
                _selectedNetwork = ap;
                _passwordController.clear();
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildPasswordInputAndPairButton() {
    if (_selectedNetwork == null) return const SizedBox.shrink();

    final bool needsPassword = !_isNetworkOpen(_selectedNetwork!.capabilities);
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        children: [
          Text(
            'Selected: ${_selectedNetwork!.ssid}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (needsPassword)
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
            )
          else
            const Text(
              'This network is open.',
              style: TextStyle(color: Colors.green),
            ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.wifi_tethering),
            label: const Text('Pair Device with Wi-Fi'),
            onPressed: _startPairing,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPairingProgressIndicator(WifiPairingState state) {
    String message = "Pairing...";
    if (state is WifiPairingInProgress) {
      message = state.message;
    } else if (state is WifiPairingDeviceConnecting) {
      message = "Device connecting to Wi-Fi...";
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildManualEntryUI(WifiPairingIosManualEntryRequired state) {
    // Update controller values if the current SSID has changed
    if (state.currentSsid != null && state.currentSsid != _lastManualSsid) {
      _manualSsidController.text = state.currentSsid!;
      _lastManualSsid = state.currentSsid;

      // Auto-focus the password field if SSID is already filled
      if (state.currentSsid!.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _passwordFocusNode.requestFocus();
          }
        });
      }
    }

    // Request focus on SSID field if it's empty
    if ((state.currentSsid == null || state.currentSsid!.isEmpty) &&
        !_ssidFocusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _ssidFocusNode.requestFocus();
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Wi-Fi Setup'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.read<WifiPairingCubit>().startWifiScan(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Show message from state if available
                if (state.message != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      state.message!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Header Section
                Column(
                  children: [
                    Icon(
                      Icons.wifi_find,
                      size: 64,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Enter Wi-Fi Details',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter the details of the Wi-Fi network you want to connect to.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Wi-Fi Form
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // SSID Field
                        Text(
                          'Network Name (SSID)',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _manualSsidController,
                          focusNode: _ssidFocusNode,
                          decoration: const InputDecoration(
                            labelText: 'Wi-Fi Network Name (SSID)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.wifi),
                            hintText: 'Enter your Wi-Fi network name',
                          ),
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) {
                            _passwordFocusNode.requestFocus();
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _manualPasswordController,
                          focusNode: _passwordFocusNode,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock_outline),
                            hintText: 'Enter your Wi-Fi password',
                          ),
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) {
                            _handleManualEntry(
                              _manualSsidController,
                              _manualPasswordController,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Connect Button
                ElevatedButton(
                  onPressed: () => _handleManualEntry(
                    _manualSsidController,
                    _manualPasswordController,
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Connect', style: TextStyle(fontSize: 16)),
                ),

                const SizedBox(height: 16),

                // Scan Networks Button
                OutlinedButton(
                  onPressed: () {
                    context.read<WifiPairingCubit>().startWifiScan();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh, size: 20),
                      SizedBox(width: 8),
                      Text('SCAN NETWORKS'),
                    ],
                  ),
                ),

                // Bottom padding for better scrolling
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleManualEntry(
    TextEditingController ssidController,
    TextEditingController passwordController,
  ) {
    final ssid = ssidController.text.trim();
    final password = passwordController.text;

    if (ssid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Wi-Fi network name')),
      );
      return;
    }

    // Create a custom WiFiNetwork with the entered details
    final network = WiFiNetwork(
      ssid: ssid,
      bssid: 'manual_entry',
      level: -50,
      frequency: 2400,
      capabilities: password.isNotEmpty ? 'WPA2' : 'OPEN',
    );

    setState(() {
      _selectedNetwork = network;
      _passwordController.text = password;
    });

    // Start the pairing process
    if (_targetDevice != null) {
      // Clear the password field but keep the SSID
      _manualPasswordController.clear();

      // Start the pairing process
      context.read<WifiPairingCubit>().startPairingProcess(
        _targetDevice!,
        ssid,
        password,
      );

      // Auto-start pairing if no password is required
      if (password.isEmpty) {
        _startPairing();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No device connected')),
      );
    }
  }

  IconData _getWifiIcon(int level, bool isSecure) {
    IconData icon;
    if (level > -55) {
      icon = Icons.wifi;
    } else if (level > -70) {
      icon = Icons.wifi_2_bar;
    } else if (level > -85) {
      icon = Icons.wifi_1_bar;
    } else {
      icon = Icons.signal_wifi_0_bar;
    }

    return isSecure ? Icons.wifi_lock : icon;
  }
}
