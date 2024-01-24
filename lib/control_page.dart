
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'main.dart';

class Control extends StatelessWidget {
  const Control({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Controller'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () {
                      buttonAction([0xA0, 0x01, 0x01, 0xA2]);
                    },
                    child: Text('LEFT ON')),
                ElevatedButton(onPressed: () {
                  buttonAction([0xA0, 0x02, 0x01, 0xA3]);
                }, child: Text('RIGHT ON')),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: () {
                  buttonAction([0xA0, 0x01, 0x00, 0xA1]);
                }, child: Text('LEFT OFF')),
                ElevatedButton(onPressed: () {
                  buttonAction([0xA0, 0x02, 0x00, 0xA2]);
                }, child: Text('RIGHT OFF')),
                // ElevatedButton(onPressed: (){}, child: child)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: () {
                  buttonAction([0xA0, 0x01, 0x00, 0xA1]);
                  buttonAction([0xA0, 0x02, 0x00, 0xA2]);

                }, child: Text('FULL OFF')),
                // ElevatedButton(onPressed: (){}, child: child)
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> buttonAction(List<int> writeList) async {
    List<BluetoothService>? services =
    await BluetoothScreenState.deviceToConnect?.device.discoverServices();
    services?.forEach((service) async {
      // do something with service
      // Reads all characteristics
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        // Writes to a characteristic
        await c.write(writeList);
      }
    });
  }
}