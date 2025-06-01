import 'package:equatable/equatable.dart';

class WiFiNetwork extends Equatable {
  final String ssid;
  final String bssid;
  final int level; // Signal level in dBm
  final int frequency; // Frequency in MHz
  final String capabilities; // Network security capabilities
  final bool isCurrentNetwork;

  const WiFiNetwork({
    required this.ssid,
    required this.bssid,
    this.level = 0,
    this.frequency = 0,
    this.capabilities = '',
    this.isCurrentNetwork = false,
  });

  // Factory constructor for creating from WiFiAccessPoint
  factory WiFiNetwork.fromAccessPoint(dynamic accessPoint, {bool isCurrent = false}) {
    return WiFiNetwork(
      ssid: accessPoint.ssid,
      bssid: accessPoint.bssid ?? '',
      level: accessPoint.level ?? 0,
      frequency: accessPoint.frequency ?? 0,
      capabilities: accessPoint.capabilities?.toString() ?? '',
      isCurrentNetwork: isCurrent,
    );
  }

  // Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'ssid': ssid,
      'bssid': bssid,
      'level': level,
      'frequency': frequency,
      'capabilities': capabilities,
      'isCurrentNetwork': isCurrentNetwork,
    };
  }

  // Create from map for deserialization
  factory WiFiNetwork.fromMap(Map<String, dynamic> map) {
    return WiFiNetwork(
      ssid: map['ssid'] ?? '',
      bssid: map['bssid'] ?? '',
      level: map['level']?.toInt() ?? 0,
      frequency: map['frequency']?.toInt() ?? 0,
      capabilities: map['capabilities'] ?? '',
      isCurrentNetwork: map['isCurrentNetwork'] ?? false,
    );
  }

  // Copy with method for immutability
  WiFiNetwork copyWith({
    String? ssid,
    String? bssid,
    int? level,
    int? frequency,
    String? capabilities,
    bool? isCurrentNetwork,
  }) {
    return WiFiNetwork(
      ssid: ssid ?? this.ssid,
      bssid: bssid ?? this.bssid,
      level: level ?? this.level,
      frequency: frequency ?? this.frequency,
      capabilities: capabilities ?? this.capabilities,
      isCurrentNetwork: isCurrentNetwork ?? this.isCurrentNetwork,
    );
  }

  @override
  List<Object?> get props => [ssid, bssid, level, frequency, capabilities, isCurrentNetwork];

  @override
  bool get stringify => true;
}
