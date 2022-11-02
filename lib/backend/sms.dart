import 'package:telephony/telephony.dart';

class SMS {
  final Telephony sms = Telephony.instance;

  Future<void> sendSMS(String message, String recievers) async {
    try {
      sms.sendSms(to: recievers, message: message);
    } catch (exception) {
      print(exception);
    }
  }
}
