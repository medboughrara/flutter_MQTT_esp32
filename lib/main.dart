import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MQTT Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MqttTestScreen(),
    );
  }
}

class MqttTestScreen extends StatefulWidget {
  @override
  _MqttTestScreenState createState() => _MqttTestScreenState();
}

class _MqttTestScreenState extends State<MqttTestScreen> {
  late mqtt.MqttClient client;
  final String brokerAddress = 'f2fa91f4.ala.dedicated.aws.emqxcloud.com';
  final int brokerPort = 1883;
  final String clientId = 'FlutterClient';

  // MQTT Broker Authentication credentials
  final String mqttUsername = '123';  // Add your MQTT username
  final String mqttPassword = '123';  // Add your MQTT password

  bool isConnected = false;
  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    connectToMqtt();
  }

  void connectToMqtt() async {
    client = mqtt.MqttClient(brokerAddress, clientId);
    client.port = brokerPort;

    // Define connection message and include username/password for authentication
    final connMessage = mqtt.MqttConnectMessage()
    .withClientIdentifier(clientId)
    .startClean()
    .withWillQos(mqtt.MqttQos.atMostOnce)
    .authenticateAs(mqttUsername, mqttPassword); // Try this directly in connect message if necessary

client.connectionMessage = connMessage;


    try {
      await client.connect();
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }

    if (client.connectionStatus?.state == mqtt.MqttConnectionState.connected) {
      print('Connected to MQTT broker');
      client.subscribe('test/topic', mqtt.MqttQos.atMostOnce);
    } else {
      print('Failed to connect to MQTT broker');
    }
  }

  void onConnected() {
    setState(() {
      isConnected = true;
    });
    print('MQTT client connected');
  }

  void onDisconnected() {
    setState(() {
      isConnected = false;
    });
    print('MQTT client disconnected');
  }

  void onSubscribed(String topic) {
    print('Subscribed to topic: $topic');
  }

  void onUnsubscribed(String topic) {
    print('Unsubscribed from topic: $topic');
  }

  void onMqttMessage(mqtt.MqttReceivedMessage message) {
    if (message is mqtt.MqttPublishMessage) {
      final payload = mqtt.MqttPublishPayload.bytesToStringAsString(
          message.payload.message);
      setState(() {
        messages.add('Received: $payload');
      });
      print('Received message: $payload');
    }
  }

  void sendMessage(String message) {
    final builder = mqtt.MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage('test/topic', mqtt.MqttQos.atMostOnce, builder.payload!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MQTT Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(messages[index]),
                  );
                },
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Enter message',
              ),
              onSubmitted: (value) {
                sendMessage(value);
              },
            ),
            ElevatedButton(
              onPressed: () {
                sendMessage('Hello from Flutter!');
              },
              child: Text('Send Message'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    client.disconnect();
    super.dispose();
  }
}
