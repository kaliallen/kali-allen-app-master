import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:kaliallendatingapp/constants.dart';

class UserData {
  String uid;
  String firstName;
  String lastName;
  Timestamp birthDate;
  int age;
  String gender;
  String isInterestedIn;
  String height;
  String picture1;
  String picture2;
  String picture3;
  String picture4;
  String picture5;
  String prompt1;
  String prompt2;
  String prompt3;
  String answer1;
  String answer2;
  String answer3;
  String occupation;
  String education;
  Timestamp timestamp;
  String location;
  String bio;
  Map dates;

  UserData({
    this.uid,
    this.firstName,
    this.lastName,
    this.birthDate,
    this.age,
    this.gender,
    this.isInterestedIn,
    this.height,
    this.picture1,
    this.picture2,
    this.picture3,
    this.picture4,
    this.picture5,
    this.prompt1,
    this.prompt2,
    this.prompt3,
    this.answer1,
    this.answer2,
    this.answer3,
    this.occupation,
    this.education,
    this.timestamp,
    this.location,
    this.bio,
    this.dates,
  });

  factory UserData.fromDocument(DocumentSnapshot doc){
    return UserData(
      uid: doc['uid'],
      firstName: doc['firstName'],
      lastName: doc['lastName'],
      birthDate: doc['birthDate'],
      age: doc['age'],
      gender: doc['gender'],
      isInterestedIn: doc['isInterestedIn'],
      height: doc['height'],
      picture1: doc['picture1'],
      picture2: doc['picture2'],
      picture3: doc['picture3'],
      picture4: doc['picture4'],
      picture5: doc['picture5'],
      prompt1: doc['prompt1'],
      prompt2: doc['prompt2'],
      prompt3: doc['prompt3'],
      answer1: doc['answer1'],
      answer2: doc['answer2'],
      answer3: doc['answer3'],
      occupation: doc['occupation'],
      education: doc['education'],
      timestamp: doc['timestamp'],
      location: doc['location'],
      bio: doc['bio'],
      dates: doc['dates'],
    );
  }

  int findAgeFromBirthdate(){

  }

  Future getUserData(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).get().then((
        value) {
      UserData.fromDocument(value);

    });
  }

  setUserDataInFirestore({
    String firstName,
    String lastName,
    Timestamp birthDate,
    int age,
    String gender,
    String isInterestedIn,
    String height,
    String picture1,
    String picture2,
    String picture3,
    String picture4,
    String picture5,
    String prompt1,
    String prompt2,
    String prompt3,
    String answer1,
    String answer2,
    String answer3,
    String occupation,
    String education,
    String location,
    String bio,
    Map dates,
  }) async {
    String userId = await FirebaseAuth.instance.currentUser.uid;
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'uid': userId,
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': birthDate,
      'age': age,
      'gender': gender,
      'isInterestedIn': isInterestedIn,
      'height': height,
      'picture1': picture1,
      'picture2': picture2,
      'picture3': picture3,
      'picture4': picture4,
      'picture5': picture5,
      'prompt1': prompt1,
      'prompt2': prompt2,
      'prompt3':prompt3,
      'answer1': answer1,
      'answer2': answer2,
      'answer3': answer3,
      'occupation': occupation,
      'education': education,
      'timestamp': Timestamp.fromDate(DateTime.now()),
      'location': location,
      'bio': bio,
      'dates': dates,
    });
  }
}