import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:else_revamp/screens/community-map.dart';
import 'package:else_revamp/screens/cpr.dart';
import 'package:else_revamp/screens/faq.dart';
import 'package:else_revamp/screens/guideline.dart';
import 'package:else_revamp/screens/home.dart';
import 'package:else_revamp/screens/how-it-works.dart';
import 'package:else_revamp/screens/loading-screen.dart';
import 'package:else_revamp/screens/login.dart';
import 'package:else_revamp/screens/profile.dart';
import 'package:else_revamp/screens/update.dart';
import 'package:else_revamp/screens/pulse.dart';
import 'package:else_revamp/screens/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: const UserSession(),
      getPages: [
        GetPage(name: '/', page: () => const LogIn()),
        GetPage(name: '/signup', page: () => const SignUp()),
        GetPage(name: '/home', page: () => const Home()),
        GetPage(name: '/profile', page: () => Profile()),
        GetPage(name: '/update', page: () => Update('')),
        GetPage(name: '/pulse', page: () => const PulseRate()),
        GetPage(name: '/cpr', page: () => const Cpr()),
        GetPage(name: '/faq', page: () => const FAQ()),
        GetPage(name: '/how-it-works', page: () => const HowTo()),
        GetPage(name: '/guide', page: () => const Guidelines()),
        GetPage(name: '/community', page: () => const Community()),
      ],
    );
  }
}

//Checks whenever a user signed-in or signed-out
//Shows specific Home screen if user already signed-in
//Shows Loading screen transition to login if there is no user
class UserSession extends StatelessWidget {
  const UserSession({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const LoadingScreen(navigate: Home());
        }
        return const LoadingScreen(navigate: LogIn());
      },
    );
  }
}
