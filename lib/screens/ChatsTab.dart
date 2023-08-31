//THIS PAGE IS ACTIVE IN USE

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/models/matches.dart';
import 'package:kaliallendatingapp/models/userData.dart';
import 'package:kaliallendatingapp/screens/ChatScreen.dart';
import 'package:kaliallendatingapp/screens/Home.dart';
import 'package:kaliallendatingapp/widgets/MatchChatBox.dart';
import 'package:kaliallendatingapp/widgets/MatchChatBox2.dart';
import 'package:kaliallendatingapp/widgets/StyledButton.dart';
import 'package:page_transition/page_transition.dart';

class MatchesScreen extends StatefulWidget {
  final String? currentUserId;

  MatchesScreen({this.currentUserId});

  @override
  _MatchesScreenState createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('this means the uid got over: ${widget.currentUserId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kScaffoldBackgroundColor,
        body: SafeArea(
          child: ListView(
            children: [
              Container(
                padding: EdgeInsets.only(left: 25.0, top: 50.0),
                child: Row(
                  children: [
                    Text('Chats',
                        style: TextStyle(
                            fontSize: 26.0,
                            color: kDarkest,
                            fontWeight: FontWeight.w500)),

                  ],
                ),
              ),

              DateList(profileId: widget.currentUserId),
            ],
          ),
        ));
  }
}

class DateList extends StatelessWidget {

  const DateList({
   this.profileId,
  });

  final String? profileId;



  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //TODO: ORGANIZE - Make the steambuilder a seperate class at the bottom
        StreamBuilder<QuerySnapshot>(
          stream: matchesRef
              .doc(profileId)
              .collection('matches').orderBy('activeMatch', descending: false).orderBy('lastMessageTime', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                  child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlue,
              ));
            }
            final matches = snapshot.data!.docs.reversed;

            List<Widget> widgets = [];

            for (var match in matches) {
              print(
                  'this is the loop triggered for match id ${match.id}');

              final matchId = match.id;
              final activeMatch = match['activeMatch'];
              final lastMessage = match['lastMessage'];
              final lastMessageSender = match['lastMessageSender'];
              final lastMessageTime = match['lastMessageTime'].toDate();
              final matchImageUrl = match['matchImageUrl'];
              final matchName = match['matchName'];
              final messageUnread = match['messageUnread'];
              final messagesId = match['messagesId'];
              final dateId = match['dateId'];
              final availability = match['${match.id}'];

              //Find out if the dateTime is today's date
              bool available = availability?.toDate().year == DateTime.now().year && availability?.toDate().day == DateTime.now().day;


            final chatMatchBox = ActiveMatchChatBox(
                matchId: matchId,
                activeMatch: activeMatch,
                lastMessageSender: lastMessageSender,
                lastMessageTime : lastMessageTime,
                matchImageUrl: matchImageUrl,
                matchName: matchName,
                messageUnread: messageUnread,
                messagesId: messagesId,
                dateId: dateId,
                availability: availability,
                available: available,

                lastMessage: lastMessage,


              );

                widgets.add(chatMatchBox);



            }
            //TODO: Need to figure out how to make this a scrollable listView
            return Column(
              // children: matchChatBoxes,
              children:
              widgets,

            );
          },
        ),
      ],
    );
  }
}

