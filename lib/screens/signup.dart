import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:else_revamp/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();
  TextEditingController pnumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xffFFF8F8),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 75,
            ),
            Container(
              alignment: Alignment.center,
              child: Text(
                'Welcome to eLSe!',
                style: GoogleFonts.fanwoodText(
                    color: const Color.fromARGB(250, 52, 73, 94), fontSize: 30),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(right: 20, left: 20, top: 30),
              margin: const EdgeInsets.only(right: 10, left: 10, top: 10),
              height: 490,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: const Color(0xffC93542),
                  borderRadius: BorderRadius.circular(25)),
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Create your Account now!',
                      style: GoogleFonts.fanwoodText(
                          fontSize: 20, color: Colors.white),
                    ),
                  ),
                  Container(
                    height: 50,
                    padding: const EdgeInsets.only(top: 10),
                    alignment: Alignment.topLeft,
                    child: TextFormField(
                      controller: usernameController,
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(5),
                          fillColor: Colors.white,
                          filled: true,
                          border: const OutlineInputBorder(
                              borderSide: BorderSide.none),
                          hintText: 'Username',
                          hintStyle: GoogleFonts.fanwoodText()),
                    ),
                  ),
                  Container(
                    height: 50,
                    padding: const EdgeInsets.only(top: 10),
                    alignment: Alignment.topLeft,
                    child: TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(5),
                          fillColor: Colors.white,
                          filled: true,
                          border: const OutlineInputBorder(
                              borderSide: BorderSide.none),
                          hintText: 'Name',
                          hintStyle: GoogleFonts.fanwoodText()),
                    ),
                  ),
                  Container(
                    height: 50,
                    padding: const EdgeInsets.only(top: 10),
                    alignment: Alignment.topLeft,
                    child: TextFormField(
                      controller: addressController,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(5),
                          fillColor: Colors.white,
                          filled: true,
                          border: const OutlineInputBorder(
                              borderSide: BorderSide.none),
                          hintText: 'Address',
                          hintStyle: GoogleFonts.fanwoodText()),
                    ),
                  ),
                  Container(
                    height: 50,
                    padding: const EdgeInsets.only(top: 10),
                    alignment: Alignment.topLeft,
                    child: TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(5),
                          fillColor: Colors.white,
                          filled: true,
                          border: const OutlineInputBorder(
                              borderSide: BorderSide.none),
                          hintText: 'Email Address',
                          hintStyle: GoogleFonts.fanwoodText()),
                    ),
                  ),
                  Container(
                    height: 50,
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            controller: dateOfBirthController,
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(5),
                                fillColor: Colors.white,
                                filled: true,
                                border: const OutlineInputBorder(
                                    borderSide: BorderSide.none),
                                hintText: 'Date of Birth',
                                hintStyle: GoogleFonts.fanwoodText()),
                            onTap: () async {
                              DateTime? date = DateTime(1900);
                              FocusScope.of(context).requestFocus(FocusNode());
                              date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1990),
                                  lastDate: DateTime(2030));
                              if (date != null) {
                                dateOfBirthController.text =
                                    date.toIso8601String().split('T')[0];
                              }
                            },
                          ),
                        ),
                        const Padding(
                            padding: EdgeInsets.only(left: 15, right: 5)),
                        Expanded(
                          child: TextFormField(
                            controller: pnumberController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(5),
                                fillColor: Colors.white,
                                filled: true,
                                border: const OutlineInputBorder(
                                    borderSide: BorderSide.none),
                                hintText: 'Phone Number',
                                hintStyle: GoogleFonts.fanwoodText()),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 50,
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            obscureText: true,
                            controller: passwordController,
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(5),
                                fillColor: Colors.white,
                                filled: true,
                                border: const OutlineInputBorder(
                                    borderSide: BorderSide.none),
                                hintText: 'Password',
                                hintStyle: GoogleFonts.fanwoodText()),
                          ),
                        ),
                        const Padding(
                            padding: EdgeInsets.only(left: 5, right: 5)),
                        Expanded(
                          child: TextFormField(
                            obscureText: true,
                            controller: confirmPasswordController,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(5),
                                fillColor: Colors.white,
                                filled: true,
                                border: const OutlineInputBorder(
                                    borderSide: BorderSide.none),
                                hintText: 'Retype Password',
                                hintStyle: GoogleFonts.fanwoodText()),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 50),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xff34495E),
                        minimumSize: const Size(350, 50),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                      ),
                      child: Text(
                        'Create Account',
                        style: GoogleFonts.fanwoodText(
                            color: Colors.white, fontSize: 30),
                      ),
                      onPressed: () async {
                        final String username = usernameController.text.trim();
                        final String name = nameController.text.trim();
                        final String address = addressController.text.trim();
                        final String email = emailController.text.trim();
                        final String dateOfBirth =
                            dateOfBirthController.text.trim();
                        final String pnumber = pnumberController.text.trim();
                        final String password = passwordController.text.trim();
                        final String confirmPassword =
                            confirmPasswordController.text.trim();

                        bool hasInternet =
                            await InternetConnectionChecker().hasConnection;

                        if (username.isEmpty ||
                            name.isEmpty ||
                            address.isEmpty ||
                            email.isEmpty ||
                            dateOfBirth.isEmpty ||
                            pnumber.isEmpty ||
                            password.isEmpty ||
                            confirmPassword.isEmpty) {
                          //Pop up dialog when fields are not filled out.
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    'Complete the fields to proceed',
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
                        } else if (pnumber.length != 11) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    'Max Length of Phone Number is 11',
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
                        } else if (password != confirmPassword) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    "Password don't match",
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
                          //proceeds to create user account if there is internet and notifies the user
                          //if creating the account is successful or has failed.
                          try {
                            await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                    email: '$username@else.revamp',
                                    password: password)
                                .then((value) async {
                              User? user = FirebaseAuth.instance.currentUser;
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user?.uid)
                                  .set({
                                'uid': user?.uid,
                                'username': '$username@else.revamp',
                                'name': name,
                                'address': address,
                                'email': email,
                                'date_of_birth': dateOfBirth,
                                'phone_number': pnumber,
                                'password': password,
                              });
                            });
                            return showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Account Created!',
                                        style: GoogleFonts.fanwoodText()),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          //Navigator.pop(context);
                                          Get.offAndToNamed('/home');
                                        },
                                        child: Text(
                                          'OK',
                                          style: GoogleFonts.fanwoodText(),
                                        ),
                                      )
                                    ],
                                  );
                                });
                          } catch (error) {
                            return showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Error',
                                        style: GoogleFonts.fanwoodText()),
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
                                      style: GoogleFonts.fanwoodText()),
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
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 5),
              alignment: Alignment.center,
              child: TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Text(
                    "Already have an account? Login",
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
