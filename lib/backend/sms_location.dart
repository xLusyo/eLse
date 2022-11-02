import 'dart:isolate';

import 'package:else_revamp/backend/location.dart';
import 'package:else_revamp/backend/sms.dart';

class Process {
  SMS _sms = SMS();
  UserLocation locationData = UserLocation();
  List<String> numbers = <String>[];
  int? _bpm;
  var address;
  String? message;

  Future<void> callback(int _bpm, SendPort sendPort) async {
    numbers = numbers = locationData.locationDataAndSMS() as List<String>;
    address = locationData.getAddress().toString();
    message = 'Emergency!' + '\n' + address + '\n' + this._bpm.toString();

    for (int i = 0; i < numbers.length; i++) {
      _sms.sendSMS(message!, numbers[i]);
    }
  }
}
