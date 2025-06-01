import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';

/// Represents a WiFi network with basic information
class WiFiNetwork extends Equatable {
  final String ssid;
  final String bssid;
  final int level;
  final int frequency;
  final String capabilities;

  const WiFiNetwork({
    required this.ssid,
    required this.bssid,
    required this.level,
    required this.frequency,
    required this.capabilities,
  });

  @override
  List<Object?> get props => [ssid, bssid, level, frequency, capabilities];
}

abstract class WifiPairingState extends Equatable {
  const WifiPairingState();

  @override
  List<Object?> get props => [];
}

class WifiPairingInitial extends WifiPairingState {}

class WifiPairingLoading extends WifiPairingState {
  final String message;
  const WifiPairingLoading({this.message = 'Loading...'});
  @override
  List<Object?> get props => [message];
}

class WifiScanResultsReady extends WifiPairingState {
  final List<WiFiNetwork> accessPoints;
  const WifiScanResultsReady(this.accessPoints);
  @override
  List<Object?> get props => [accessPoints];
}

// State indicating the pairing process over BLE has started
class WifiPairingInProgress extends WifiPairingState {
   final String message;
   const WifiPairingInProgress({this.message = 'Sending credentials...'});
   @override
   List<Object?> get props => [message];
}

// State indicating the device is attempting to connect to the router
class WifiPairingDeviceConnecting extends WifiPairingState {
   const WifiPairingDeviceConnecting();
}

class WifiPairingSuccess extends WifiPairingState {
   const WifiPairingSuccess();
}

class WifiPairingAction {
  final String label;
  final VoidCallback onAction;
  
  const WifiPairingAction({
    required this.label,
    required this.onAction,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WifiPairingAction &&
          runtimeType == other.runtimeType &&
          label == other.label;

  @override
  int get hashCode => label.hashCode;
}

class WifiPairingFailure extends WifiPairingState {
  final String error;
  final WifiPairingAction? action;
  
  const WifiPairingFailure(this.error, {this.action});
  
  @override
  List<Object?> get props => [error, action];
}

/// State indicating that the current WiFi network was detected (used for iOS)
class CurrentWifiNetworkDetected extends WifiPairingState {
  final WiFiNetwork network;
  
  const CurrentWifiNetworkDetected(this.network);
  
  @override
  List<Object?> get props => [network];
}

/// State indicating that iOS requires manual Wi-Fi entry
class WifiPairingIosManualEntryRequired extends WifiPairingState {
  final String? currentSsid;
  final bool showManualOption;
  final String? message;

  const WifiPairingIosManualEntryRequired({
    this.currentSsid,
    required this.showManualOption,
    this.message,
  });

  @override
  List<Object?> get props => [currentSsid, showManualOption, message];

  @override
  String toString() => 'WifiPairingIosManualEntryRequired($currentSsid, $showManualOption, $message)';
}
