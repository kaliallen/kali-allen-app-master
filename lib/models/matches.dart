import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kaliallendatingapp/models/userData.dart';
import 'package:kaliallendatingapp/screens/Home.dart';

class Matches {
  bool activeMatch;
  String lastMessage;
  String lastMessageSender;
  DateTime lastMessageTime;
  String matchImageUrl;
  String matchName;
  String matchId;
  bool messageUnread;
  String messagesId;
  String dateId;

  Matches(
      {this.matchId, this.messagesId, this.messageUnread, this.activeMatch, this.lastMessage, this.lastMessageSender, this.matchName, this.lastMessageTime, this.matchImageUrl, this.dateId});


  // setMatchesDataInFireStore({
  //   bool activeMatch,
  //   String lastMessage,
  //   String lastMessageSender,
  //   DateTime lastMessageTime,
  //   String matchImageUrl,
  //   String matchName,
  //   String matchId,
  //   bool messageUnread,
  //   String messagesId,
  //   String dateId,
  // }) async {
  //   await FirebaseFirestore.instance.collection('matches').doc()
  //
  // }

}

