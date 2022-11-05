import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:else_revamp/screens/update.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Profile extends StatefulWidget {
  Profile({
    Key? key,
  }) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late String name = '';
  late String profilePicture = '';
  TextEditingController birthdateController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController passController = TextEditingController();

  //function to retreive user's data and display it
  //using textfield controllers and other widgets
  getUserInfo() async {
    String useruid = FirebaseAuth.instance.currentUser!.uid;
    var getUserInfo = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: useruid)
        .get();
    setState(() {
      for (var snapshots in getUserInfo.docs) {
        Map<String, dynamic> data = snapshots.data();
        name = data['name'] ?? 'Loading... ';
        birthdateController.text = data['date_of_birth'];
        addressController.text = data['address'];
        emailController.text = data['email'];
        passController.text = data['password'];
        ageController.text = data['age'] ?? 'Not set';
        profilePicture = data['profile_picture'] ?? '';
      }
    });
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(250, 246, 236, 236),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xffC93542),
        leading: IconButton(
            onPressed: () {
              //Get.back();
              Get.offAndToNamed('/home');
              //Navigator.of(context).popAndPushNamed('/home');
            },
            icon: Image.asset('assets/images/icons8-left-96 1.png')),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  height: 240,
                  decoration: BoxDecoration(
                    color: const Color(0xffC93542),
                    borderRadius: BorderRadius.vertical(
                        bottom: Radius.elliptical(
                            MediaQuery.of(context).size.width, 100.0)),
                  ),
                ),
                Center(
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      image: (profilePicture != '')
                          ? DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                profilePicture,
                              ))
                          : const DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage(
                                'assets/images/account_circle.png',
                              ),
                            ),
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 160),
                  child: Center(
                    child: Text(
                      name,
                      style: GoogleFonts.fanwoodText(
                          color: const Color.fromARGB(250, 52, 73, 94),
                          fontSize: 30),
                    ),
                  ),
                )
              ],
            ),
            const Padding(padding: EdgeInsets.only(top: 10)),
            Container(
              margin: const EdgeInsets.only(right: 10, left: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Birthdate', style: GoogleFonts.fanwoodText()),
                        TextFormField(
                          controller: birthdateController,
                          enabled: false,
                          decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              border: const OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              hintText: 'Birthdate',
                              hintStyle: GoogleFonts.fanwoodText()),
                        ),
                      ],
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(left: 10)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Age', style: GoogleFonts.fanwoodText()),
                        TextFormField(
                          controller: ageController,
                          enabled: false,
                          decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              border: const OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              hintText: 'Age',
                              hintStyle: GoogleFonts.fanwoodText()),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 10, left: 10, top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Home Address', style: GoogleFonts.fanwoodText()),
                  TextFormField(
                    controller: addressController,
                    enabled: false,
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        border: const OutlineInputBorder(
                            borderSide: BorderSide.none),
                        hintText: 'Home Address',
                        hintStyle: GoogleFonts.fanwoodText()),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 10, left: 10, top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email Address', style: GoogleFonts.fanwoodText()),
                  TextFormField(
                    controller: emailController,
                    enabled: false,
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        border: const OutlineInputBorder(
                            borderSide: BorderSide.none),
                        hintText: 'Email Address',
                        hintStyle: GoogleFonts.fanwoodText()),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 10, left: 10, top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Password', style: GoogleFonts.fanwoodText()),
                  TextFormField(
                    controller: passController,
                    obscureText: true,
                    enabled: false,
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        border: const OutlineInputBorder(
                            borderSide: BorderSide.none),
                        hintText: 'Password',
                        hintStyle: GoogleFonts.fanwoodText()),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 10, left: 10, top: 10),
              child: Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: const Color.fromARGB(250, 52, 73, 94),
                      minimumSize: Size(150, 40),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                    child: Text(
                      'Update',
                      style: GoogleFonts.fanwoodText(
                          color: Colors.white, fontSize: 25),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => Update(name)));
                    },
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }
}
