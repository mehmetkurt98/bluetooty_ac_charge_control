/*
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // lottie paketini ekliyoruz
import 'home.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade500,
      body: Center(
        // Animasyonu ekliyoruz
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/charging_splash.json',
              height: 400, // İstenilen boyutları belirleyebilirsiniz
              width: 400,
            ),
            SizedBox(height: 20),
            // Metin ile animasyon arasına boşluk eklemek için
            Text(
              'CW ENERGY', // İstediğiniz metni burada belirtebilirsiniz
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white),
            ),
            Text(
              'AC CHARGİNG MOBİLE APP', // İstediğiniz metni burada belirtebilirsiniz
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}


 */
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'home.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  @override
  void initState() {
    super.initState();
    _checkBluetoothStatus();
  }

  Future<void> _checkBluetoothStatus() async {
    _bluetoothState = await FlutterBluetoothSerial.instance.state;
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      // Bluetooth kapalıysa, kullanıcıya uyarı verelim.
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Bluetooth Kapalı"),
            content: Text("Uygulamanın kullanılabilmesi için Bluetooth'u açmanız gerekiyor."),
            actions: <Widget>[
              ElevatedButton(
                child: Text("İptal"),
                onPressed: () {
                  exit(0);
                },
              ),
              ElevatedButton(
                child: Text("Bluetooth'u Aç"),
                onPressed: () {
                  FlutterBluetoothSerial.instance.requestEnable().then((value) {
                    if (value == true) {
                      _navigateToHomeScreen();
                    }
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      // Bluetooth açıksa, home sayfasına geçiş yapalım.
      _navigateToHomeScreen();
    }
  }

  void _navigateToHomeScreen() {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade500,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/charging_splash.json',
              height: 400,
              width: 400,
            ),
            SizedBox(height: 20),
            Text(
              'CW ENERGY',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              'AC CHARGİNG MOBİLE APP',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
