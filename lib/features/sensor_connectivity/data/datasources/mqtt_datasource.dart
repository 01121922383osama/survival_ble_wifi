import 'dart:async';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

abstract class MqttDatasource {
  Future<bool> connect(
    String server,
    int port,
    String clientIdentifier,
    String? username,
    String? password,
  );
  void disconnect();
  Stream<String> subscribeToTopic(String topic);
  void publish(String topic, String message);
  MqttConnectionState? get connectionState;
}

// Implementation using mqtt_client package
class MqttDatasourceImpl implements MqttDatasource {
  MqttServerClient? _client;
  final Map<String, StreamController<String>> _topicControllers = {};

  @override
  Future<bool> connect(
    String server,
    int port,
    String clientIdentifier,
    String? username,
    String? password,
  ) async {
    print('MQTT Datasource: Connecting to $server:$port as $clientIdentifier');

    try {
      _client = MqttServerClient.withPort(server, clientIdentifier, port);
      _client!.logging(on: false);
      _client!.keepAlivePeriod = 60;
      _client!.onDisconnected = _onDisconnected;
      _client!.onConnected = _onConnected;
      _client!.onSubscribed = _onSubscribed;

      final connMessage = MqttConnectMessage()
          .withClientIdentifier(clientIdentifier)
          .withWillQos(MqttQos.atLeastOnce);

      if (username != null && password != null) {
        connMessage.authenticateAs(username, password);
      }

      _client!.connectionMessage = connMessage;

      await _client!.connect();
      return _client!.connectionStatus!.state == MqttConnectionState.connected;
    } catch (e) {
      print('MQTT Datasource: Connection failed - $e');
      return false;
    }
  }

  @override
  void disconnect() {
    print('MQTT Datasource: Disconnecting');
    _client?.disconnect();

    // Close all topic controllers
    for (var controller in _topicControllers.values) {
      controller.close();
    }
    _topicControllers.clear();
  }

  @override
  Stream<String> subscribeToTopic(String topic) {
    if (_topicControllers.containsKey(topic)) {
      return _topicControllers[topic]!.stream;
    }

    final controller = StreamController<String>.broadcast();
    _topicControllers[topic] = controller;

    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      _client!.subscribe(topic, MqttQos.atLeastOnce);

      _client!.updates!.listen((
        List<MqttReceivedMessage<MqttMessage>> messages,
      ) {
        for (var message in messages) {
          if (message.topic == topic) {
            final payload =
                (message.payload as MqttPublishMessage).payload.message;
            final payloadString = MqttPublishPayload.bytesToStringAsString(
              payload,
            );
            controller.add(payloadString);
          }
        }
      });
    } else {
      controller.addError('MQTT client not connected');
    }

    return controller.stream;
  }

  @override
  void publish(String topic, String message) {
    print('MQTT Datasource: Publishing to $topic: $message');
    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    }
  }

  @override
  MqttConnectionState? get connectionState => _client?.connectionStatus?.state;

  // Callbacks
  void _onConnected() {
    print('MQTT Datasource: Connected');

    // Resubscribe to all topics
    for (var topic in _topicControllers.keys) {
      _client!.subscribe(topic, MqttQos.atLeastOnce);
    }
  }

  void _onDisconnected() {
    print('MQTT Datasource: Disconnected');
  }

  void _onSubscribed(String topic) {
    print('MQTT Datasource: Subscribed to $topic');
  }
}
