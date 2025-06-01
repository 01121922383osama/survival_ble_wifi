import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:survival/features/auth/domain/entities/user.dart';
import 'package:survival/features/sensor_connectivity/data/datasources/mqtt_datasource.dart';

class MqttService {
  final MqttDatasource _mqttDatasource;
  final Logger _log = Logger('MqttService');

  User? _currentUser;

  final String _brokerIp = '167.71.52.138';
  final int _port = 1883;
  final String _baseTopic = '/Radar60FL/#';

  final ValueNotifier<MqttConnectionState> connectionStateNotifier =
      ValueNotifier(MqttConnectionState.disconnected);

  MqttService(this._mqttDatasource) {
    _log.info("MqttService initialized");

    connectionStateNotifier.addListener(_logConnectionState);
  }

  void _logConnectionState() {
    _log.info(
      "MQTT Connection State Changed: ${connectionStateNotifier.value}",
    );
  }

  Future<void> connectWithCredentials(User user, String password) async {
    _currentUser = user;
    _log.info("Attempting MQTT connection for user: ${user.email}");

    if (connectionStateNotifier.value == MqttConnectionState.connected ||
        connectionStateNotifier.value == MqttConnectionState.connecting) {
      _log.warning("MQTT connection already active or in progress.");
      return;
    }

    final clientId =
        'survival_app_${user.id}_${DateTime.now().millisecondsSinceEpoch}';

    try {
      connectionStateNotifier.value = MqttConnectionState.connecting;
      final client = await _mqttDatasource.connect(
        _brokerIp,
        _port,
        clientId,
        user.email,
        password,
      );

      if (client) {
        connectionStateNotifier.value = MqttConnectionState.connected;
        _log.info("MQTT connected successfully for user: ${user.email}");

        await subscribeToTopic();
      } else {
        connectionStateNotifier.value = MqttConnectionState.faulted;
        _log.warning("MQTT connection failed after connect call.");
      }
    } catch (e) {
      connectionStateNotifier.value = MqttConnectionState.faulted;
      _log.severe("MQTT connection error for user ${user.email}: $e");
    }
  }

  Future<void> subscribeToTopic() async {
    if (connectionStateNotifier.value == MqttConnectionState.connected) {
      try {
        _log.info("Subscribing to MQTT topic: $_baseTopic");
        _mqttDatasource.subscribeToTopic(_baseTopic);
      } catch (e) {
        _log.severe("Error subscribing to topic $_baseTopic: $e");
      }
    } else {
      _log.warning("Cannot subscribe to topic, MQTT not connected.");
    }
  }

  Future<void> disconnect() async {
    _log.info("Disconnecting MQTT for user: ${_currentUser?.email}");
    _currentUser = null;
    _mqttDatasource.disconnect();
    connectionStateNotifier.value = MqttConnectionState.disconnected;
  }

  void dispose() {
    _log.info("Disposing MqttService");
    connectionStateNotifier.removeListener(_logConnectionState);
    disconnect();
    connectionStateNotifier.dispose();
  }
}
