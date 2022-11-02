import 'package:else_revamp/screens/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class LogIn extends StatefulWidget {
  const LogIn({Key? key}) : super(key: key);

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  //TextFormField Controllers
  //Can be used to manipulate text inputs and also retreive user inputs
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xffFFF8F8),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 110,
            ),
            Container(
              alignment: Alignment.topLeft,
              child: Image.asset(
                'assets/images/icons8-lifebuoy-96 1.png',
                width: 150,
                height: 150,
                scale: 0.1,
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(left: 20),
              child: Text('Hello there!',
                  style: GoogleFonts.fanwoodText(
                      fontSize: 30,
                      color: const Color.fromARGB(250, 52, 73, 94))),
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(left: 20),
              child: Text('Welcome',
                  style: GoogleFonts.fanwoodText(
                      fontSize: 25,
                      color: const Color.fromARGB(250, 52, 73, 94))),
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(left: 20, right: 36, top: 20),
              child: TextFormField(
                controller: usernameController,
                decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    border:
                        const OutlineInputBorder(borderSide: BorderSide.none),
                    prefixIcon: const ImageIcon(
                      AssetImage(
                          'assets/images/icons8-security-user-female-48 1.png'),
                      color: Color.fromARGB(250, 52, 73, 94),
                    ),
                    hintText: 'Username',
                    hintStyle: GoogleFonts.fanwoodText()),
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(left: 20, right: 36, top: 10),
              child: TextFormField(
                obscureText: true,
                controller: passwordController,
                decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    border:
                        const OutlineInputBorder(borderSide: BorderSide.none),
                    prefixIcon: const ImageIcon(
                      AssetImage('assets/images/icons8-key-2-48 1.png'),
                      color: Color.fromARGB(250, 52, 73, 94),
                    ),
                    hintText: 'Password',
                    hintStyle: GoogleFonts.fanwoodText()),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(right: 36, top: 1, bottom: 10),
              alignment: Alignment.topRight,
              child: TextButton(
                  onPressed: () {},
                  child: Text('Forgot password?',
                      style: GoogleFonts.fanwoodText(
                          fontSize: 15,
                          color: const Color.fromARGB(250, 52, 73, 94)))),
            ),
            Container(
              alignment: Alignment.center,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromARGB(250, 243, 111, 111),
                  minimumSize: Size(350, 50),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
                child: Text(
                  'Login',
                  style: GoogleFonts.fanwoodText(
                      color: Colors.white, fontSize: 30),
                ),
                onPressed: () async {
                  final String username = usernameController.text.trim();
                  final String password = passwordController.text.trim();
                  bool hasInternet = //from plugin to check if there is internet
                      await InternetConnectionChecker()
                          .hasConnection; //connection, returns true if there is
                  if (username.isEmpty || password.isEmpty) {
                    //popup dialog that notifies users when there are fields not filled out
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                              'Invalid or empty inputs',
                              style: GoogleFonts.fanwoodText(
                                  color: Colors.black, fontSize: 30),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'CLOSE',
                                  style: GoogleFonts.fanwoodText(),
                                ),
                              )
                            ],
                          );
                        });
                  } else if (hasInternet == true) {
                    //executes signing in of users if there is internet connection
                    //then shows popup error if they failed to sign in
                    try {
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: '$username@else.revamp', password: password);
                      //Get.offAndToNamed('/home');
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const Home()));
                    } catch (error) {
                      return showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Error',
                                  style: GoogleFonts.fanwoodText(
                                      color: Colors.red)),
                              content: Text('$error'),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('CLOSE',
                                        style: GoogleFonts.fanwoodText()))
                              ],
                            );
                          });
                    }
                  } else {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('NO INTERNET',
                                style:
                                    GoogleFonts.fanwoodText(color: Colors.red)),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('CLOSE',
                                      style: GoogleFonts.fanwoodText()))
                            ],
                          );
                        });
                  }
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 10),
              alignment: Alignment.center,
              child: TextButton(
                  onPressed: () {
                    Get.toNamed('/signup');
                  },
                  child: Text(
                    "Don't have an account? Create Account",
                    style: GoogleFonts.fanwoodText(
                        color: const Color.fromARGB(250, 52, 73, 94),
                        fontSize: 15),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
