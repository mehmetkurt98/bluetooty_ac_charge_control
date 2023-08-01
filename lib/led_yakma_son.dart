/*
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  BluetoothConnection? connection;
  List<BluetoothDevice> availableDevices = [];
  BluetoothDevice? selectedDevice;
  String ledStatus = '';

  @override
  void initState() {
    super.initState();
    _getBondedDevices();
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
      await BluetoothConnection.toAddress(device.address).then((_connection) {
        print('Connected to the device');
        Fluttertoast.showToast(
          msg: '${device.name} Bağlantı başarılı!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        setState(() {
          connection = _connection;
        });
      }).catchError((error) {
        print('Bağlantı hatası: $error');
        Fluttertoast.showToast(
          msg: '${device.name} Bağlantı başarısız!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      });
    } else {
      print('Cihaz bulunamadı');
      Fluttertoast.showToast(
        msg: 'Cihaz bulunamadı!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void _sendData(int data) {
    if (connection != null && connection!.isConnected) {
      String charData = String.fromCharCode(data + 48); // Veriyi char formatına dönüştürün
      Uint8List bytes = Uint8List.fromList(charData.codeUnits); // Char veriyi byte dizisine dönüştürün
      connection!.output.add(bytes);
      connection!.output.allSent.then((value) {
        print('Veri gönderildi: $charData');
      }).catchError((error) {
        print('Veri gönderme hatası: $error');
      });
    } else {
      print('Cihaz bağlı değil');
    }
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

  void _updateLedStatus(String status) {
    setState(() {
      ledStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Bluetooth LED Control'),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _sendData(0);
                      _updateLedStatus('Yesil led yandi.');
                    },
                    child: Text('Green'),
                    style: ElevatedButton.styleFrom(primary: Colors.green),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _sendData(1);
                      _updateLedStatus('Mavi led yandi.');
                    },
                    child: Text('Blue'),
                    style: ElevatedButton.styleFrom(primary: Colors.blue),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _sendData(2);
                      _updateLedStatus('Kirmizi led yandi.');
                    },
                    child: Text('Red'),
                    style: ElevatedButton.styleFrom(primary: Colors.red),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Text(
                ledStatus,
                style: TextStyle(fontSize: 18.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


 */