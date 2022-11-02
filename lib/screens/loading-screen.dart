import 'dart:async';
import 'package:flutter/material.dart';

//app loading screen whenever the app is opened
// can be reused to load into different pages
//requires a page to navigate into after the loading screen finishes
class LoadingScreen extends StatefulWidget {
  final Widget navigate;
  const LoadingScreen({super.key, required this.navigate});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    Timer(const Duration(seconds: 5), () async {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => widget.navigate));
      //widget.navigate;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Image.asset('assets/images/loading_image.gif', fit: BoxFit.contain),
      ]),
    ));
  }
}
