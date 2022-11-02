import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:else_revamp/screens/login.dart';
import 'package:else_revamp/screens/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String name = '';
  String callNumber = '911';

  // function to get the Name of the user from database to display
  getName() async {
    String useruid = FirebaseAuth.instance.currentUser!.uid;
    var getUserInfo = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: useruid)
        .get();
    setState(() {
      for (var snapshots in getUserInfo.docs) {
        Map<String, dynamic> data = snapshots.data();
        name = data['name'] ?? 'Loading...';
      }
    });
  }

  // function that navigates the user outside the app
  // then dials 911 and ready for calling
  dialCall() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: '911',
    );
    await UrlLauncher.launchUrl(launchUri);
  }

  @override
  void initState() {
    getName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF8F8),
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 25,
          ),
          Container(
            margin: const EdgeInsets.only(left: 8, right: 8, bottom: 36),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              color: const Color.fromARGB(250, 205, 95, 95),
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(left: 8),
                    alignment: Alignment.topLeft,
                    child: Text(
                      'eLse',
                      style: GoogleFonts.fanwoodText(
                          fontSize: 25, color: Colors.white),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Image.asset(
                        'assets/images/icons8-medical-doctor-48 1 (2).png'),
                  ),
                  Container(
                    padding: const EdgeInsets.only(bottom: 16),
                    alignment: Alignment.center,
                    child: Text(
                      'Hello, $name',
                      style: GoogleFonts.fanwoodText(
                          fontSize: 25, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.only(bottom: 36)),
          Container(
            width: 380,
            height: 60,
            child: ElevatedButton.icon(
                icon: Tab(
                    icon: Image.asset(
                        'assets/images/icons8-doctors-folder-48 1.png')),
                label: Text(
                  'Your Profile',
                  style: GoogleFonts.fanwoodText(
                      fontSize: 20, color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
                onPressed: () {
                  //Get.toNamed('/profile');
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => Profile(),
                  ));
                }),
          ),
          Container(
            margin: const EdgeInsets.only(top: 21),
            width: 380,
            height: 60,
            child: ElevatedButton.icon(
                icon: Tab(
                    icon: Image.asset(
                        'assets/images/icons8-heart-with-pulse-48 1.png')),
                label: Text(
                  'Heart Rate Monitor',
                  style: GoogleFonts.fanwoodText(
                      fontSize: 20, color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
                onPressed: () {
                  Get.toNamed('/pulse');
                }),
          ),
          Container(
            margin: const EdgeInsets.only(top: 21),
            width: 380,
            height: 60,
            child: ElevatedButton.icon(
                icon: Tab(
                    icon:
                        Image.asset('assets/images/icons8-lifebuoy-48 1.png')),
                label: Text(
                  'CPR',
                  style: GoogleFonts.fanwoodText(
                      fontSize: 20, color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
                onPressed: () {
                  Get.toNamed('/cpr');
                }),
          ),
          Container(
            margin: const EdgeInsets.only(top: 21),
            width: 380,
            height: 60,
            child: ElevatedButton.icon(
                icon: const Tab(icon: Icon(Icons.logout)),
                label: Text(
                  'Log Out',
                  style: GoogleFonts.fanwoodText(
                      fontSize: 20, color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const LogIn()));
                  FirebaseAuth.instance.signOut();
                }),
          ),
        ],
      ),
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Colors.white,
        style: TabStyle.fixedCircle,
        items: [
          TabItem(
              icon: Image.asset('assets/images/icons8-google-home-48 1.png')),
          TabItem(
              icon:
                  Image.asset('assets/images/icons8-important-book-48 1.png')),
          TabItem(icon: Image.asset('assets/images/icons8-hospital-48 1.png')),
          TabItem(icon: Image.asset('assets/images/icons8-inquiry-48 1.png')),
          TabItem(icon: Image.asset('assets/images/icons8-add-phone-48 1.png'))
        ],
        onTap: (int i) {
          switch (i) {
            case 1:
              {
                Get.toNamed('/how-it-works');
              }
              break;

            case 3:
              {
                Get.toNamed('/faq');
              }
              break;
            case 4:
              {
                dialCall();
              }
              break;
          }
        }, //Array like
      ),
    );
  }
}
