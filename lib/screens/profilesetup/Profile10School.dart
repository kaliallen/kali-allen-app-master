import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/models/userData.dart';
import 'package:kaliallendatingapp/screens/Home.dart';
import 'package:kaliallendatingapp/screens/profilesetup/Profile11Activities.dart';
import 'package:kaliallendatingapp/widgets/StyledButton.dart';
import 'package:page_transition/page_transition.dart';

final DateTime timestamp = DateTime.now();

class ProfileSchool extends StatelessWidget {
 final UserData? _userData;

  ProfileSchool({@required UserData? userData})
      : assert(userData !=null),
        _userData = userData;

  @override
  Widget build(BuildContext context) {
    String? school;

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
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'School and/or Field of Study',
                ),
                onChanged: (value){
                  school = value;

                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0, right: 25.0, left: 25.0),
              child: StyledButton(
                text: 'Continue',
                color: kButtonColor,
                onTap: (){
                  if (school != null){
                    _userData!.education = school;
                  }
                  print(school);
                  print(_userData!.education);
                  Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: ProfileActivities(
                            userData: _userData,
                          )));
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
