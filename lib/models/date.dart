import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:kaliallendatingapp/screens/Home.dart';

class Date {

  String uid;
  String gender;
  String interestedIn;
  List availability;
  Map<String, bool> interests;
  Map<String, bool> rejects;
  Timestamp time;
  String customMessage;

  Date({
        this.uid,
      this.gender,
        this.interestedIn,
        this.availability,
      this.interests,
    this.rejects,
        this.time,
    this.customMessage
      });

  factory Date.fromDocument(DocumentSnapshot doc) {
    return Date(
      uid: doc.id,
      gender: doc['gender'],
      interestedIn: doc['interestedIn'],
      availability: doc['availability'],
      interests: Map<String, bool>.from(doc['interests']),
      rejects: Map<String, bool>.from(doc['rejects']),
      time: doc['time'],
      customMessage: doc['customMessage']

    );
  }

 setDateInFirestore({
   String uid,
   String gender,
   String interestedIn,
   List availability,
   Map<String, bool> interests,
   Map<String, bool> rejects,
   String customMessage,
}) async {
    await FirebaseFirestore.instance.collection('dates').doc(uid).set({
      'availability':availability,
      'gender':gender,
      'interestedIn':interestedIn,
      'interests':interests,
      'rejects':rejects,
      'time': Timestamp.fromDate(DateTime.now()),
      'customMessage': customMessage,
    });
 }

  List<String> identifyDateTimes(DateTime now) {

    DateFormat dateFormat = DateFormat('yyyyMMdd');
    List<String> datesSlots = [];

    datesSlots.add(
        dateFormat.format(now) + '-46'
    );
    datesSlots.add(
      dateFormat.format(now) + '-68',
    );
    datesSlots.add(
      dateFormat.format(now) + '-810',
    );
    datesSlots.add(
        dateFormat
            .format(now.add(Duration(days: 1))) + '-46');
    datesSlots.add(
        dateFormat
            .format(now.add(Duration(days: 1))) +
            '-68');
    datesSlots.add(
        dateFormat
            .format(now.add(Duration(days: 1))) +
            '-810');
    datesSlots.add(
        dateFormat
            .format(now.add(Duration(days: 2))) +
            '-46');
    datesSlots.add(
        dateFormat
            .format(now.add(Duration(days: 2))) +
            '-68');
    datesSlots.add(
        dateFormat
            .format(now.add(Duration(days: 2))) +
            '-810');
    datesSlots.add(
        dateFormat
            .format(now.add(Duration(days: 3))) +
            '-46');
    datesSlots.add(
        dateFormat
            .format(now.add(Duration(days: 3))) +
            '-68');
    datesSlots.add(
        dateFormat
            .format(now.add(Duration(days: 3))) +
            '-810');

    return datesSlots;
  }

  List<String> identifyActiveDateTimes(DateTime now){

    List<String> availableDates = identifyDateTimes(now);
    int hourNow = int.parse('${DateFormat.H().format(now)}');
    print('The hour is $hourNow');


    if (hourNow >= 16 && hourNow < 18){
      availableDates[0] = null;
    }

    if (hourNow >= 18 && hourNow < 20){
      availableDates[0] = null;
      availableDates[1] = null;
    }

    if (hourNow >= 20){
      availableDates[0] = null;
      availableDates[1] = null;
      availableDates[2] = null;
    }

    print(availableDates);

    return availableDates;
  }

  findActiveDatesFromList(List datesList){

    List availableDates = identifyActiveDateTimes(DateTime.now());
    print('Available Dates Are:');
    print(availableDates);

    for (String dateId in datesList){
      if (availableDates.contains(dateId)){
        print('$dateId is an available date');
      }
    }




  }

//TODO: want to get the age from the birth date
  // List convertToString(List availabilities){
  //   for (String date in availabilities){
  //     date.split
  //   }
  //
  // }




}
