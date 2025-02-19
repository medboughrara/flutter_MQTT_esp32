import 'package:flutter/material.dart';
import 'mqtt_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isConnected = false;

  Future<void> connectToMQTT() async {
    try {
      await MqttService.connect();
      setState(() {
        isConnected = true;
      });
    } catch (e) {
      print('Exception: $e');
    }
  }

  void publishMessage(String message) {
    if (isConnected) {
      MqttService.publish('led_topic', message);
    } else {
      print('Not connected to MQTT broker');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('MQTT LED Control')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await connectToMQTT();
                  publishMessage('1'); // Send '1' to turn on LED 1
                },
                child: Text('Turn On LED 1'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await connectToMQTT();
                  publishMessage('2'); // Send '2' to turn on LED 2
                },
                child: Text('Turn On LED 2'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}