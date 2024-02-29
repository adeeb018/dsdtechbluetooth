import 'dart:async';
import 'dart:developer';

import 'package:dsdbluetooth/ble_device_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:io';

import 'bluetooth_connection.dart';
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

  late Set<DeviceList> devices;

  BluetoothScreen1 bluetoothScreen = BluetoothScreen1();

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
              onPressed: () async {
                devices = await bluetoothScreen.scan();
                devices.forEach((element) {
                  log('${element.macId} and ${element.advertisementName}');
                });
                // await scanAndPrintDevices();
                // print(_scanResults);
              },
              child: Text('Scan for Devices'),
            ),
            ElevatedButton(
                onPressed: () async {
                  String? macId;
                  for (var element in devices) {
                    if(element.advertisementName == 'DSD TECH'){
                      macId = element.macId;
                    }
                  }
                  await bluetoothScreen.connect(autoConnect: false,deviceMac: macId);
                }, child: Text('Connect to device')),
            ElevatedButton(
                onPressed: (){
                  bluetoothScreen.disconnect();
                  },
                child: Text('Disconnect to device')),
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

