import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class HowTo extends StatelessWidget {
  const HowTo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(250, 250, 95, 95),
      appBar: AppBar(
        title: Text('How It Works',
            style: GoogleFonts.fanwoodText(
                color: const Color.fromARGB(250, 52, 73, 94), fontSize: 30)),
        elevation: 0,
        backgroundColor: const Color.fromARGB(250, 250, 95, 95),
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Image.asset('assets/images/icons8-left-96 1.png')),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 25, bottom: 25, left: 10, right: 10),
        decoration: BoxDecoration(
            color: Color.fromARGB(250, 255, 248, 248),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: <Widget>[
            const Padding(padding: EdgeInsets.only(top: 15)),
            Container(
              height: 400,
              //Content for Guidelines
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: const Color.fromARGB(250, 52, 73, 94),
                minimumSize: Size(200, 50),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
              child: Text(
                'Proceed',
                style:
                    GoogleFonts.fanwoodText(color: Colors.white, fontSize: 20),
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
