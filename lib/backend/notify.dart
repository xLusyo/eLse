import 'dart:isolate';

import 'package:else_revamp/backend/bpm.dart';
import 'package:else_revamp/backend/location.dart';
import 'package:else_revamp/backend/sms.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotifyUI extends StatefulWidget {
  NotifyUI({
    Key? key,
  }) : super(key: key);
  @override
  _NotifyUIState createState() => _NotifyUIState();
}

class _NotifyUIState extends State<NotifyUI> {
  @override
  void initState() {
    // TODO: implement initState
    Isolate.spawn(sendMessage, 'Success');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xffA61414),
        title: Text(
          "Success",
          style: GoogleFonts.righteous(color: Colors.white, fontSize: 25),
        ),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 100,
            ),
            Container(
              width: 150,
              height: 150,
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xffA61414),
                size: 150,
              ),
            ),
            Text(
              'Help is on the way',
              style: GoogleFonts.righteous(
                  color: const Color(0xffA61414), fontSize: 10),
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: const Color(0xffA61414),
        height: 60,
        child: InkWell(
          onTap: () {
            Navigator.popAndPushNamed(context, '/');
            sendMessage('Success');
          },
          child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Center(
                child: Text(
                  'DONE',
                  style:
                      GoogleFonts.righteous(color: Colors.white, fontSize: 15),
                ),
              )),
        ),
      ),
    );
  }
}

void sendMessage(String message) async {
  DataBPM xyz = DataBPM();
  UserLocation data = UserLocation();
  SMS sms = SMS();
  String address = await data.getAddress();

  List numbers = await data.locationDataAndSMS();
  String message = 'EMERGENCY!!' +
      '\n\n' +
      'BPM: ' +
      xyz.bpm.toString() +
      '\nLocation:' +
      address;
  for (int i = 0; i < numbers.length; i++) {
    await sms.sendSMS(message, numbers[i]);
  }
  print(message);
}
