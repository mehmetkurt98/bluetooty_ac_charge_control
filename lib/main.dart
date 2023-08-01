/*
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_data_transfer/view/splash.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';

void main() => runApp(SplashScreen());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  BluetoothConnection? connection;
  List<BluetoothDevice> availableDevices = [];
  BluetoothDevice? selectedDevice;
  String chargerStatus = '';
  bool showChargingReadyAnimation = false;
  bool showChargingStartAnimation = false;
  bool showChargingStopAnimation = false;

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
        _listenData();
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

  void _listenData() {
    connection!.input!.listen((Uint8List data) {
      String receivedData = utf8.decode(data);
      print('Received data: $receivedData');
      int status = int.parse(receivedData);
      _updateChargerStatus(status);
    }).onDone(() {
      print('Disconnected from the device');
      setState(() {
        connection = null;
      });
    });
  }

  void _sendData(int data) {
    if (connection != null && connection!.isConnected) {
      String charData = data.toString();
      Uint8List bytes = Uint8List.fromList(charData.codeUnits);
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

  void _updateChargerStatus(int status) {
    String displayText;

    setState(() {
      if (status == 12) {
        displayText = 'Soket takılı değil';
        showChargingStartAnimation = false;
        showChargingReadyAnimation = false;
        showChargingStopAnimation = false;
      } else if (status == 9) {
        displayText = 'Araç şarja hazır';
        showChargingStartAnimation = false;
        showChargingReadyAnimation = true;
        showChargingStopAnimation = false;
      } else if (status == 6) {
        displayText = 'Araç şarja başladı';
        showChargingStartAnimation = true;
        showChargingReadyAnimation = false;
        showChargingStopAnimation = false;
        _stopChargingStartTimer();
      } else {
        displayText = 'Bilinmeyen durum';
        showChargingStartAnimation = false;
        showChargingReadyAnimation = false;
        showChargingStopAnimation = false;
      }
      chargerStatus = displayText;
    });
  }

  void _stopChargingStartTimer() {
    Timer(Duration(seconds: 2), () {
      setState(() {
        showChargingStopAnimation = false;
      });
    });
  }

  // ... (yukarıdaki kodlar aynı kalmış)

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: Text('Bluetooth Charger Status'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
              SizedBox(height: 150.0),
              showChargingReadyAnimation
                  ? Container(
                height: 300,
                width: 300,
                child: Lottie.asset('assets/charging_ready.json'),
              )
                  : Container(),
              showChargingStartAnimation
                  ? Container(
                height: 300,
                width: 300,
                child: Lottie.asset('assets/charging_start.json'),
              )
                  : Container(),
              showChargingStopAnimation
                  ? Container(
                height: 300,
                width: 300,
                child: Lottie.asset('assets/charging_close.json'),
              )
                  : Container(),
              SizedBox(height: 20.0),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(height: 20.0),
                    Card(
                        elevation: 5,
                        child: Text("chargerStatus", style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(width: 50,),
                        ElevatedButton(
                          onPressed: () {
                            _sendData(1);
                          },
                          child: Text('Start Charging'),
                          style: ElevatedButton.styleFrom(primary: Colors.green),
                        ),
                        SizedBox(height: 20.0,width: 40,),
                        ElevatedButton(
                          onPressed: () {
                            _sendData(0);
                            setState(() {
                              chargerStatus = "";
                              showChargingStopAnimation = true;
                              showChargingReadyAnimation=false;
                            });
                            _stopChargingStartTimer();
                          },
                          child: Text('Stop Charging'),
                          style: ElevatedButton.styleFrom(primary: Colors.red),
                        ),
                      ],
                    )

                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

 */

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_data_transfer/view/splash.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
    );
  }
}


