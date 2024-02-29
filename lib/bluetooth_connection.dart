import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';
import './ble_device_list.dart';

class BluetoothScreen1 {
  BluetoothDevice? deviceToConnect;

  // Set<ScanResult> set = {};
  Set<DeviceList> deviceList = {};

  // constructor
  BluetoothScreen1() {
    var subscription = FlutterBluePlus.onScanResults.listen((results)  {
      if (results.isNotEmpty) {
        ScanResult r = results.last; // the most recently found device
        deviceList.add(
            DeviceList('${r.device.remoteId}', r.advertisementData.advName,r.device));
      }
    }, onError: (e) => log('Error $e'));
    FlutterBluePlus.cancelWhenScanComplete(subscription);
  }

  Future<Set<DeviceList>> scan() async {
    log('BLE SCAN ENTERED');
    await FlutterBluePlus.adapterState
        .where((val) => val == BluetoothAdapterState.on)
        .first;

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    await FlutterBluePlus.isScanning.where((val) => val == false).first;

    return deviceList;
  }

  Future<bool> connect({bool autoConnect = false,String? deviceMac}) async {

    if(deviceMac == null){
      log('Invalid or no MacID');
      return false;
    }
    // DeviceList deviceToConnect;
    for (var element in deviceList) {
      if(element.macId == deviceMac){
         deviceToConnect = element.device;
         log('DEVICE TO CONNECT is $deviceToConnect');
      }
    }

    if (deviceToConnect != null) {
      try {
        await deviceToConnect?.connect(autoConnect: autoConnect);
        log('This are the LOGS');
        FlutterBluePlus.setLogLevel(LogLevel.verbose, color:false);
        log('LOG ARE UP TO HERE');
      } on FlutterBluePlusException catch (e) {
          log('Connect Error is ${e.code} trying again');
          if (e.code == 133) {
            connect(); // recursively calling the function
            return true;
          }
      }
      if (deviceToConnect!.isConnected) {
        return true;
      } else {
        log('BLE APP not connected try again');
        return false;
      }
      // Navigator.of(context).push(_createRoute());
    } else {
      log('BLE APP no device to connect');
      return false;
    }


  }

  Future<void> disconnect() async {
    // Disconnect from device
    await deviceToConnect?.disconnect();
    // device.disconnect();
    log("BLE APP Disconnected");
  }

  Future<void> buttonAction(List<int> writeList) async {
    List<BluetoothService>? services =
        await deviceToConnect?.discoverServices();
    services?.forEach((service) async {
      // do something with service
      // Reads all characteristics
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        // Writes to a characteristic
        // print(characteristics);
        if (characteristics[0].serviceUuid.str == 'ffe0') {
          await c.write(writeList);
        }
      }
    });
  }
}


/*
    json file created tested ok
     */
// List<Map<String,String>> jsonList = [];
// for (ScanResult element in set) {
//   Map<String,String> myMap = {"MacId":"${element.device.remoteId}", "advertisementName":element.advertisementData.advName};
//   jsonList.add(myMap);
// }
// Map<String,List> finalMap = {"deviceList":jsonList};
//
// String jsonString = jsonEncode(finalMap);
// debugPrint(jsonString,wrapWidth: 500);
// print(deviceList[0].macId);
// for (var element in deviceList) {
//   debugPrint('${element.macId} and name is ${element.advertisementName}');
// }return true;
