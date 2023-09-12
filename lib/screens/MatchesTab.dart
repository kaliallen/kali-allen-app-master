//THIS PAGE IS ACTIVE IN USE

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kaliallendatingapp/screens/BrowseTab.dart';
import 'package:kaliallendatingapp/widgets/NotificationBox.dart';

import '../constants.dart';
import 'Home.dart';

class NotificationScreen extends StatefulWidget {
  final String? currentUserId;

  NotificationScreen({this.currentUserId});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kScaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 25.0, top: 50.0),
                child: Text('Notifications',
                    style: TextStyle(
                        fontSize: 26.0,
                        color: kDarkest,
                        fontWeight: FontWeight.w500)),
              ),
              Column(
                children: [
                  //TODO: ORGANIZE - Make the steambuilder a seperate class at the bottom
                  StreamBuilder<QuerySnapshot>(
                    stream: notificationsRef
                        .doc(widget.currentUserId)
                    //TODO: Add Order By
                        .collection('notifications').orderBy('time', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.lightBlue,
                            ));
                      }

                      final notifications = snapshot.data!.docs;

                      List<Widget> widgets = [];

                      for (var notification in notifications) {
                        print(
                            'this is the loop triggered for notfication id ${notification.id}');

                        final userId = notification.id;
                        final matchImageUrl = notification['matchImageUrl'];
                        final senderId = notification['senderId'];
                        final name = notification['name'];
                        final time = notification['time'].toDate();
                        final type = notification['type'];
                        final message = notification['message'];




                        final notificationBox = NotificationBox(
                          notificationId: userId,
                          matchImageUrl: matchImageUrl,
                          matchId: senderId,
                          name: name,
                          time: time,
                          type: type,
                          message: message,

                          userId: widget.currentUserId,
                        );


                        //
                        widgets.add(notificationBox);
                      }
                      //TODO: Need to figure out how to make this a scrollable listView
                      return Column(
                        // children: matchChatBoxes,
                        children: widgets,
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        ));
  }
}

class CalendarTitle extends StatelessWidget {
  final String? text;

  CalendarTitle({this.text});

  @override
  Widget build(BuildContext context) {
  return
    Expanded(
      child: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
          color: kPillButtonSelectedColor,
        ),
        child: Column(
          children: [
            Text(
                text!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white)
            ),
          ],
        ),
      ),
    );
  }
}

class CalendarSlot extends StatelessWidget {
  final String? text;

  CalendarSlot({this.text});

  @override
  Widget build(BuildContext context) {
    return
      Expanded(
        child: Container(
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.all(3),
          child: Column(
            children: [
              Text(
                'Early',
                  style: TextStyle(
                      color: kLightDark
                  ),
              ),
              Text(
                text!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kLightDark
                ),
              ),
            ],
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: kPillButtonUnselectedColor,
          ),
        ),
      );
  }
}
