

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceList{

  String macId;
  String advertisementName;
  BluetoothDevice device;
  DeviceList(this.macId,this.advertisementName,this.device);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DeviceList &&
              runtimeType == other.runtimeType &&
              macId == other.macId;

  @override
  int get hashCode => macId.hashCode;


}