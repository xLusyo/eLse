import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:else_revamp/screens/community-map.dart';
import 'package:else_revamp/screens/login.dart';
import 'package:else_revamp/screens/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String useruid = FirebaseAuth.instance.currentUser!.uid;
  String name = '';
  String callNumber = '911';
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late StreamSubscription<QuerySnapshot> notifyEmergency;

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

  Future onSelectnotification(payload) async {
    showDialog(
        //barrierDismissible: false,
        context: context,
        builder: (_) => AlertDialog(
              icon: const Icon(Icons.info, color: Colors.red),
              title: const Text('Emergency'),
              content: const Text('Navigate to Community Map'),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const Community()));
                    },
                    child: const Text('OK')),
              ],
            ));
  }

  Future alertEmergency() async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        "Heads Up!", "There is an Emergency",
        channelDescription: "Notify Emergency",
        enableVibration: true,
        playSound: true,
        importance: Importance.max,
        priority: Priority.high);
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'There is an emergency!',
      'View in order to see details',
      platformChannelSpecifics,
      payload: 'Navigate to Community Map',
    );
  }

  @override
  void initState() {
    getName();
    super.initState();
    var initializationSettingAndroid =
        const AndroidInitializationSettings('ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationSettingAndroid);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onSelectnotification);
    notifyEmergency = FirebaseFirestore.instance
        .collection('emergency')
        .where('active', isEqualTo: true)
        .snapshots()
        .listen((event) {
      for (var element in event.docChanges) {
        if (element.type == DocumentChangeType.added ||
            element.type == DocumentChangeType.modified) {
          if (element.doc.data()!['used_id'] != useruid) {
            alertEmergency();
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF8F8),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 50,
            ),
            Container(
              margin: const EdgeInsets.only(left: 8, right: 8, bottom: 36),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                color: const Color(0xffC93542),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(left: 15, top: 15),
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
            const SizedBox(height: 5),
            Container(
              margin: const EdgeInsets.only(left: 8, right: 8),
              //alignment: Alignment.centerLeft,
              width: MediaQuery.of(context).size.width * 1,
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
                    alignment: Alignment.centerLeft,
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
            const SizedBox(height: 21),
            Container(
              margin: const EdgeInsets.only(left: 8, right: 8),
              width: MediaQuery.of(context).size.width * 1,
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
                    alignment: Alignment.centerLeft,
                    primary: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                  onPressed: () {
                    Get.toNamed('/pulse');
                  }),
            ),
            const SizedBox(height: 21),
            Container(
              //alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(left: 8, right: 8),
              width: 380,
              height: 60,
              child: ElevatedButton.icon(
                  icon:
                      Tab(icon: Image.asset('assets/images/icons8-cpr-58.png')),
                  label: Text(
                    'CPR',
                    style: GoogleFonts.fanwoodText(
                        fontSize: 20, color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    primary: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                  onPressed: () {
                    Get.toNamed('/cpr');
                  }),
            ),
            const SizedBox(height: 21),
            Container(
              //alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(left: 8, right: 8),
              width: 380,
              height: 60,
              child: ElevatedButton.icon(
                  icon: Tab(
                      icon: Image.asset('assets/images/icons8-gps-48 (2).png')),
                  label: Text(
                    'Community',
                    style: GoogleFonts.fanwoodText(
                        fontSize: 20, color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    primary: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                  onPressed: () {
                    Get.toNamed('/community');
                  }),
            ),
            const SizedBox(height: 21),
            Container(
              margin: const EdgeInsets.only(left: 8, right: 8),
              width: 380,
              height: 60,
              child: ElevatedButton.icon(
                  icon: const Tab(
                      icon: Icon(Icons.logout, color: Colors.orange, size: 45)),
                  label: Text(
                    'Log Out',
                    style: GoogleFonts.fanwoodText(
                        fontSize: 20, color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    alignment: Alignment.centerLeft,
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
            const SizedBox(height: 30)
          ],
        ),
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
