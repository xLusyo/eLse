import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//Cloud Functions, updating user info including password and profile display
Future updateUserInfowithoutPassword(
    address, birthdate, email, age, imageURL) async {
  String useruid = FirebaseAuth.instance.currentUser!.uid;
  await FirebaseFirestore.instance.collection('users').doc(useruid).set({
    'address': address,
    'date_of_birth': birthdate,
    'email': email,
    'age': age,
    'profile_picture': imageURL,
  }, SetOptions(merge: true));
}

Future updateUserInfoWithPassword(
    address, birthdate, email, age, newpassword, imageURL) async {
  String useruid = FirebaseAuth.instance.currentUser!.uid;
  await FirebaseFirestore.instance.collection('users').doc(useruid).set({
    'address': address,
    'date_of_birth': birthdate,
    'email': email,
    'age': age,
    'password': newpassword,
    'profile_picture': imageURL,
  }, SetOptions(merge: true));
}

Future updateProfilePicture(imageURL) async {
  String useruid = FirebaseAuth.instance.currentUser!.uid;
  await FirebaseFirestore.instance.collection('users').doc(useruid).set({
    'profile_picture': imageURL,
  }, SetOptions(merge: true));
}
