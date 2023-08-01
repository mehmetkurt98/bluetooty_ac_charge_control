import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BluetoothConnection? connection;
  List<BluetoothDevice> availableDevices = [];
  BluetoothDevice? selectedDevice;
  String chargerStatus = 'Soket takılı değil.Lütfen soketi yerleştirin';
  bool showChargingReadyAnimation = false;
  bool showChargingStartAnimation = false;
  bool showChargingStopAnimation = false;
  bool showChargingSocketAnimation = false;
  bool showChargingSocketAnimation2 = false;

  @override
  void initState() {
    super.initState();
    _getBondedDevices();
    showChargingSocketAnimation2 = true;
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
      try {
        connection = await BluetoothConnection.toAddress(device.address);
        print('Connected to the device');
        Fluttertoast.showToast(
          msg: '${device.name} Bağlantı başarılı!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        _listenData();
      } catch (error) {
        print('Bağlantı hatası: $error');
        Fluttertoast.showToast(
          msg: '${device.name} Bağlantı başarısız!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
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

  void _disconnect() async {
    if (connection != null && connection!.isConnected) {
      await connection!.finish();
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
        showChargingSocketAnimation = true;
        showChargingSocketAnimation2 = false;
      } else if (status == 9) {
        displayText = 'Araç şarja hazır';
        showChargingStartAnimation = false;
        showChargingReadyAnimation = true;
        showChargingStopAnimation = false;
        showChargingSocketAnimation = false;
        showChargingSocketAnimation2 = false;
      } else if (status == 6) {
        displayText = 'Araç şarja başladı';
        showChargingStartAnimation = true;
        showChargingReadyAnimation = false;
        showChargingStopAnimation = false;
        showChargingSocketAnimation = false;
        showChargingSocketAnimation2 = false;
        _stopChargingStartTimer();
      } else {
        displayText = 'Bilinmeyen durum';
        showChargingStartAnimation = false;
        showChargingReadyAnimation = false;
        showChargingStopAnimation = false;
        showChargingSocketAnimation = false;
        showChargingSocketAnimation2 = false;
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.green.shade500,
        /*
        appBar: AppBar(
          backgroundColor: Colors.green,
          centerTitle: true,
          title: Text('Bluetooth Charger Status'),
        ),
        */
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 100),
              DropdownButton<BluetoothDevice>(
                value: selectedDevice,
                hint: Container(
                  alignment: Alignment.center,
                  child: Text(
                    "Cihaz Seçin",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
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
              SizedBox(height: 100.0),
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
              showChargingSocketAnimation
                  ? Container(
                height: 300,
                width: 300,
                child: Lottie.asset('assets/socket.json'),
              )
                  : Container(),
              showChargingSocketAnimation2
                  ? Container(
                height: 300,
                width: 300,
                child: Lottie.asset('assets/socket2.json'),
              )
                  : Container(),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      chargerStatus,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(
                      height: 100,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _sendData(1);
                              showChargingSocketAnimation2 = false;
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blue,
                              onPrimary: Colors.blue.shade900,
                              padding: EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                              ),
                            ),
                            child: Text(
                              "Start Charging",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        VerticalDivider(
                          color: Colors.black,
                          thickness: 1,
                          width: 1,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _sendData(0);
                              setState(() {
                                showChargingStopAnimation = true;
                                showChargingReadyAnimation = false;
                                showChargingSocketAnimation = false;
                                showChargingSocketAnimation2 = false;
                                showChargingStartAnimation=false;
                                _stopChargingStartTimer();
                                chargerStatus="Şarj işlemi sonlandırıldı,Tekrar başlatmak için Start butonuna tıklayın";
                              });


                              /*
                              if (chargerStatus == "Soket takılı değil") {
                                setState(() {
                                  showChargingStopAnimation = true;
                                  showChargingReadyAnimation = false;
                                  showChargingSocketAnimation = false;
                                  showChargingSocketAnimation2 = false;
                                });
                                _stopChargingStartTimer();
                              }

                               */
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                              onPrimary: Colors.blue.shade900,
                              padding: EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                            ),
                            child: Text(
                              "Stop Charging",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

