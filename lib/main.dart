import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:io';

import 'control_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BluetoothScreen(),
    );
  }
}

class BluetoothScreen extends StatefulWidget {

  @override
  BluetoothScreenState createState() => BluetoothScreenState();
}

class BluetoothScreenState extends State<BluetoothScreen> {
  bool _isButtonDisabled = false;
  static ScanResult? deviceToConnect;

  @override
  void initState() {
    var subscription = FlutterBluePlus.onScanResults.listen((results) {
      if (results.isNotEmpty) {
        log("BLE APP result is there");
        ScanResult r = results.last; // the most recently found device
        if (r.advertisementData.advName == "DSD TECH") {
          deviceToConnect = r;
        }
        print('${r.device.remoteId}: "${r.advertisementData.advName}" found!');
      }
    },
      onError: (e) => print(e),
    );
    // usually start scanning, connecting, etc
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Scanner'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                scan();
                // await scanAndPrintDevices();
                // print(_scanResults);
              },
              child: Text('Scan for Devices'),
            ),
            ElevatedButton(
                onPressed: (){
                  _isButtonDisabled?connect():showSnackBar(context, 'device not found on scan, scan again and wait for 5 seconds');
                }, child: Text('Connect to device')),
            ElevatedButton(
                onPressed: disconnect, child: Text('Disconnect to device')),
          ],
        ),
      ),
    );
  }

  void scan() async {
    await FlutterBluePlus.adapterState
        .where((val) => val == BluetoothAdapterState.on)
        .first;

    await FlutterBluePlus.startScan(timeout: Duration(seconds: 5));

    await FlutterBluePlus.isScanning
        .where((val) => val == false)
        .first;
    _isButtonDisabled = true;
  }

  Future<void> connect() async {
    if (deviceToConnect != null) {
      await deviceToConnect?.device.connect();
      Navigator.of(context).push(_createRoute());
    }
  }
  Future<void> disconnect() async {
    // Disconnect from device
    await deviceToConnect?.device.disconnect();
    // device.disconnect();
    _isButtonDisabled = false;
  }
}

showSnackBar(BuildContext context, String s) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(s),
      duration: Duration(seconds: 2),
    ),
  );
}


//created route for moving to next page
Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => Control(),
    //transitionbuilder is optional if we need some animation(but we should write that function and return child)
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween =
      Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}

