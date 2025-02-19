
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  static final MqttServerClient client = MqttServerClient('192.168.1.158', 'flutter_client');

  static Future<void> connect() async {
    try {
      await client.connect();
      if (client.connectionStatus!.state == MqttConnectionState.connected) {
        print('Connected to MQTT Broker');
      } else {
        print('Failed to connect: ${client.connectionStatus!.returnCode}');
      }
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }
  }

  static void publish(String topic, String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
  }
}