import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:survival/features/sensor_connectivity/domain/entities/sensor_entities.dart';

class FirestoreDatasource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreDatasource(this._firestore, this._auth);

  String? get _userId => _auth.currentUser?.uid;

  // Stream devices for the current user
  Stream<List<SensorDevice>> streamDevices() {
    final userId = _userId;
    if (userId == null) {
      return Stream.value([]); // Return empty stream if user not logged in
    }
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => SensorDevice.fromFirestore(doc))
              .toList();
        });
  }

  // Stream logs for a specific device
  Stream<List<DeviceLog>> streamDeviceLogs(String deviceId) {
    final userId = _userId;
    if (userId == null) {
      return Stream.value([]);
    }
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .doc(deviceId)
        .collection('logs')
        .orderBy('timestamp', descending: true)
        .limit(50) // Limit logs for performance
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => DeviceLog.fromFirestore(doc))
              .toList();
        });
  }

  // Add a new device (example)
  Future<void> addDevice(SensorDevice device) async {
    final userId = _userId;
    if (userId == null) {
      throw Exception('User not logged in');
    }
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .doc(device.id)
        .set(device.toFirestore());
  }

  // Update device data (example for status)
  Future<void> updateDeviceStatus(
    String deviceId,
    Map<String, dynamic> statusData,
  ) async {
    final userId = _userId;
    if (userId == null) {
      throw Exception('User not logged in');
    }
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .doc(deviceId)
        .update(statusData);
  }

  // Add a device log (example)
  Future<void> addDeviceLog(String deviceId, DeviceLog log) async {
    final userId = _userId;
    if (userId == null) {
      throw Exception('User not logged in');
    }
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .doc(deviceId)
        .collection('logs')
        .add(log.toFirestore());
  }

  // Update device settings
  Future<void> updateDeviceSettings(
    String deviceId,
    Map<String, dynamic> settings,
  ) async {
    final userId = _userId;
    if (userId == null) {
      throw Exception('User not logged in');
    }
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .doc(deviceId)
        .update(settings);
  }

  // Fetch device settings
  Future<Map<String, dynamic>?> getDeviceSettings(String deviceId) async {
    final userId = _userId;
    if (userId == null) {
      throw Exception('User not logged in');
    }
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .doc(deviceId)
        .get();
    return doc.data();
  }
}
