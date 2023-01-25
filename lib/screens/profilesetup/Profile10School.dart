import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/models/userData.dart';
import 'package:kaliallendatingapp/screens/Home.dart';
import 'package:kaliallendatingapp/widgets/StyledButton.dart';

final DateTime timestamp = DateTime.now();

class ProfileSchool extends StatelessWidget {
 UserData _userData;

  ProfileSchool({@required UserData userData})
      : assert(userData !=null),
        _userData = userData;

  @override
  Widget build(BuildContext context) {
    String school;

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_sharp,
                    color: kLightDark,
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                  }),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: Text('Add education to your profile',
                  style: TextStyle(
                    // letterSpacing: 2.0,
                    fontSize: 30.0,
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.w600,
                    color: kDarkest,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'School and/or Field of Study',
                ),
                onChanged: (value){
                  school = value;
                },
              ),
            ),
            SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0, right: 25.0, left: 25.0),
              child: StyledButton(
                text: 'Continue',
                color: kButtonColor,
                onTap: () async {
                  if (school != null){
                    _userData.education = school;
                  }

                  //Save UserData data to Firestore under the logged in username
                  _userData.setUserDataInFirestore(
                    firstName: _userData.firstName,
                    lastName: _userData.lastName,
                    birthDate: _userData.birthDate,
                    gender: _userData.gender,
                     isInterestedIn: _userData.isInterestedIn,
                    height: _userData.height,
                    picture1: _userData.picture1,
                    picture2: _userData.picture2,
                    picture3: _userData.picture3,
                    picture4: _userData.picture4,
                    picture5: _userData.picture5,
                    prompt1: _userData.prompt1,
                    answer1: _userData.answer1,
                    occupation: _userData.occupation,
                    education: _userData.education,
                  );
                  final User user = FirebaseAuth.instance.currentUser;
                  DocumentSnapshot doc = await usersRef.doc(user.uid).get();
                  _userData = UserData.fromDocument(doc);
                  print('if uid is not null _userData is successfully saved from firestore..._userData uid is: ${_userData.uid}');
                  if ( doc.exists){
                    //Go to home.dart
                    Navigator.push(context, MaterialPageRoute(
                    builder: (context) => Home()));
                  } else {
                    print('Doc wasnt added to firestore');
                  }
                  }
    ),
            ),

             ],   // }
            ),
        ),
    );
  }
}


// createUserInFirestore({
//   String id,
//   String firstName,
//   String lastName,
//   DateTime birthDate,
//   int age,
//   String gender,
//   String isInterestedIn,
//   String height,
//   String picture1,
//   Image picture2,
//   Image picture3,
//   Image picture4,
//   Image picture5,
//   String prompt1,
//   String answer1,
//   String occupation,
//   String education,
//   DateTime timestamp,
// }) async {
//   String userId = await FirebaseAuth.instance.currentUser.uid;
//   await FirebaseFirestore.instance.collection('users').doc(userId).set({
//     'uid': userId,
//     'firstName' : firstName,
//     'lastName' : lastName,
//     'birthDate': birthDate,
//     'age' : age,
//     'gender':gender,
//     'isInterestedIn' : isInterestedIn,
//     'height' : height,
//     'picture1' : picture1,
//     'picture2' : picture2,
//     'picture3' : picture3,
//     'picture4' : picture4,
//     'picture5' : picture5,
//     'prompt1' : prompt1,
//     'answer1' : answer1,
//     'occupation' : occupation,
//     'education' : education,
//   });

  //currentUser = UserData.fromDocument(doc);
