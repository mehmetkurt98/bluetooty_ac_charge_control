

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  BluetoothConnection? connection;
  List<BluetoothDevice> availableDevices = [];
  BluetoothDevice? selectedDevice;
  String busVoltage = '';
  String shuntVoltage = '';
  String loadVoltage = '';
  String current = '';
  String power = '';
  StreamSubscription? dataStreamSubscription;

  @override
  void initState() {
    super.initState();
    _getBondedDevices();
  }

  @override
  void dispose() {
    dataStreamSubscription?.cancel();
    super.dispose();
  }

  void _getBondedDevices() async {
    List<BluetoothDevice> bondedDevices =
    await FlutterBluetoothSerial.instance.getBondedDevices();
    setState(() {
      availableDevices = bondedDevices;
    });
  }

  void _connectToDevice(BluetoothDevice device) async {
    if (device != null) {
      await BluetoothConnection.toAddress(device.address)
          .then((_connection) {
        print('Connected to the device');
        setState(() {
          connection = _connection;
        });
        _startDataStreaming();
      }).catchError((error) {
        print('Connection error: $error');
      });
    } else {
      print('Device not found');
    }
  }

  void _startDataStreaming() {
    dataStreamSubscription = connection!.input!.listen((Uint8List data) {
      String sensorData = utf8.decode(data);
      _updateSensorData(sensorData);
    }, onError: (dynamic error) {
      print('Data stream error: $error');
    }, cancelOnError: true);

    Timer.periodic(Duration(seconds: 1), (timer) {
      if (connection != null && connection!.isConnected) {
        connection!.output.add(Uint8List.fromList([1])); // Arduino'dan veri isteği gönder
      } else {
        timer.cancel();
      }
    });
  }

  void _updateSensorData(String data) {
    setState(() {
      List<String> values = data.trim().split('\n');
      if (values.length >= 5) {
        busVoltage = values[0].trim();
        shuntVoltage = values[1].trim();
        loadVoltage = values[2].trim();
        current = values[3].trim();
        power = values[4].trim();
      }
    });
  }

  void _disconnect() {
    if (connection != null && connection!.isConnected) {
      connection!.finish();
      print('Disconnected from the device');
      setState(() {
        connection = null;
      });
    } else {
      print('Not connected to any device');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Bluetooth Sensor Data'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<BluetoothDevice>(
                value: selectedDevice,
                items: availableDevices.map((device) {
                  return DropdownMenuItem<BluetoothDevice>(
                    value: device,
                    child: Text(device.name.toString()),
                  );
                }).toList(),
                onChanged: (BluetoothDevice? device) {
                  if (connection != null && connection!.isConnected) {
                    _disconnect();
                  }
                  setState(() {
                    selectedDevice = device;
                  });
                  if (device != null) {
                    _connectToDevice(device);
                  }
                },
              ),
              SizedBox(height: 20.0),
              Text(
                'Bus Voltage: ${busVoltage.isNotEmpty ? busVoltage : 'N/A'} V',
                style: TextStyle(fontSize: 18.0),
              ),
              Text(
                'Shunt Voltage: ${shuntVoltage.isNotEmpty ? shuntVoltage : 'N/A'} mV',
                style: TextStyle(fontSize: 18.0),
              ),
              Text(
                'Load Voltage: ${loadVoltage.isNotEmpty ? loadVoltage : 'N/A'} V',
                style: TextStyle(fontSize: 18.0),
              ),
              Text(
                'Current: ${current.isNotEmpty ? current : 'N/A'} mA',
                style: TextStyle(fontSize: 18.0),
              ),
              Text(
                'Power: ${power.isNotEmpty ? power : 'N/A'} mW',
                style: TextStyle(fontSize: 18.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



