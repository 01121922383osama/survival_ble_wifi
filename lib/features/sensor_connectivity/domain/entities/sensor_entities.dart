import 'package:cloud_firestore/cloud_firestore.dart';

enum SensorType { fallDetection, motionDetection, sleepMonitoring, unknown }

enum DeviceStatus {
  unknown,
  online,
  offline,
  moving,
  fallDetected,
  alert,
  lowBattery,
}

class SensorDevice {
  final String id;
  final String name;
  final SensorType type;
  final String? location;
  final bool
  isConnected; // Kept for potential BLE status, but Firestore status is primary
  final bool
  hasAlert; // Kept for potential BLE status, but Firestore status is primary
  final String? alertMessage;
  final int? batteryLevel;
  final DateTime? lastUpdated;
  final String? serialNumber; // New field
  final DateTime? registrationDate; // New field
  final DeviceStatus status; // New field for dynamic status
  final bool notificationsEnabled; // New field

  SensorDevice({
    required this.id,
    required this.name,
    this.type = SensorType.unknown,
    this.location,
    this.isConnected = false,
    this.hasAlert = false,
    this.alertMessage,
    this.batteryLevel,
    this.lastUpdated,
    this.serialNumber,
    this.registrationDate,
    this.status = DeviceStatus.unknown,
    this.notificationsEnabled = true,
  });

  // Factory constructor to create SensorDevice from Firestore document
  factory SensorDevice.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Helper to safely get timestamp
    DateTime? getTimestamp(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    // Helper to safely get DeviceStatus from string
    DeviceStatus getDeviceStatus(String? statusString) {
      if (statusString == null) return DeviceStatus.unknown;
      try {
        return DeviceStatus.values.firstWhere(
          (e) => e.toString() == 'DeviceStatus.$statusString',
          orElse: () => DeviceStatus.unknown,
        );
      } catch (_) {
        return DeviceStatus.unknown;
      }
    }

    // Helper to safely get SensorType from string
    SensorType getSensorType(String? typeString) {
      if (typeString == null) return SensorType.unknown;
      try {
        return SensorType.values.firstWhere(
          (e) => e.toString() == 'SensorType.$typeString',
          orElse: () => SensorType.unknown,
        );
      } catch (_) {
        return SensorType.unknown;
      }
    }

    return SensorDevice(
      id: doc.id,
      name: data['name'] ?? 'Unknown Device',
      type: getSensorType(data['type']),
      location: data['location'] as String?,
      isConnected: data['isConnected'] ?? false, // Still useful for BLE state?
      hasAlert: data['hasAlert'] ?? false, // Still useful for BLE state?
      alertMessage: data['alertMessage'] as String?,
      batteryLevel: data['batteryLevel'] as int?,
      lastUpdated: getTimestamp(data['lastUpdated']),
      serialNumber: data['serialNumber'] as String?,
      registrationDate: getTimestamp(data['registrationDate']),
      status: getDeviceStatus(data['status']), // Get status from Firestore
      notificationsEnabled: data['notificationsEnabled'] ?? true,
    );
  }

  // Method to convert SensorDevice to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type.toString().split('.').last, // Store enum as string
      'location': location,
      'isConnected': isConnected,
      'hasAlert': hasAlert,
      'alertMessage': alertMessage,
      'batteryLevel': batteryLevel,
      'lastUpdated': lastUpdated != null
          ? Timestamp.fromDate(lastUpdated!)
          : null,
      'serialNumber': serialNumber,
      'registrationDate': registrationDate != null
          ? Timestamp.fromDate(registrationDate!)
          : null,
      'status': status.toString().split('.').last, // Store enum as string
      'notificationsEnabled': notificationsEnabled,
    };
  }

  // CopyWith method for immutability
  SensorDevice copyWith({
    String? id,
    String? name,
    SensorType? type,
    String? location,
    bool? isConnected,
    bool? hasAlert,
    String? alertMessage,
    int? batteryLevel,
    DateTime? lastUpdated,
    String? serialNumber,
    DateTime? registrationDate,
    DeviceStatus? status,
    bool? notificationsEnabled,
  }) {
    return SensorDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      location: location ?? this.location,
      isConnected: isConnected ?? this.isConnected,
      hasAlert: hasAlert ?? this.hasAlert,
      alertMessage: alertMessage ?? this.alertMessage,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      serialNumber: serialNumber ?? this.serialNumber,
      registrationDate: registrationDate ?? this.registrationDate,
      status: status ?? this.status,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

class SensorData {
  final String deviceId;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  SensorData({
    required this.deviceId,
    required this.data,
    required this.timestamp,
  });
}

class DeviceLog {
  final String id; // Firestore document ID
  final String message;
  final DateTime timestamp;
  final String level; // e.g., INFO, WARNING, ERROR, ALERT

  DeviceLog({
    required this.id,
    required this.message,
    required this.timestamp,
    this.level = 'INFO',
  });

  factory DeviceLog.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DeviceLog(
      id: doc.id,
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      level: data['level'] ?? 'INFO',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'level': level,
    };
  }
}
