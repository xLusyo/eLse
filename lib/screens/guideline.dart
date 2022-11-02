import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Guidelines extends StatefulWidget {
  const Guidelines({Key? key}) : super(key: key);

  @override
  State<Guidelines> createState() => _GuidelinesState();
}

class _GuidelinesState extends State<Guidelines> {
  bool value = false;
  bool value2 = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(250, 250, 95, 95),
      body: Container(
        margin: EdgeInsets.only(top: 40, bottom: 25, left: 10, right: 10),
        decoration: BoxDecoration(
            color: Color.fromARGB(250, 255, 248, 248),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: <Widget>[
            const Padding(padding: EdgeInsets.only(top: 15)),
            Center(
              child: Text(
                'Guidelines',
                style: GoogleFonts.fanwoodText(
                    color: const Color.fromARGB(250, 79, 77, 77), fontSize: 30),
              ),
            ),
            Container(
              height: 400,
              //Content for Guidelines
            ),
            Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 15),
                  alignment: Alignment.topLeft,
                  child: Checkbox(
                      value: value,
                      onChanged: (bool? onChanged) {
                        setState(() {
                          value = onChanged!;
                        });
                      }),
                ),
                Text(
                  'I understand ...',
                  style: GoogleFonts.fanwoodText(
                      color: const Color.fromARGB(250, 79, 77, 77),
                      fontSize: 20),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 15),
                  alignment: Alignment.topLeft,
                  child: Checkbox(
                      value: value2,
                      onChanged: (bool? onChanged) {
                        setState(() {
                          value2 = onChanged!;
                        });
                      }),
                ),
                Text(
                  'I accept ...',
                  style: GoogleFonts.fanwoodText(
                      color: const Color.fromARGB(250, 79, 77, 77),
                      fontSize: 20),
                )
              ],
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
