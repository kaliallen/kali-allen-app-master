import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kaliallendatingapp/models/userData.dart';
import 'package:kaliallendatingapp/screens/BrowseTab.dart';
import 'package:kaliallendatingapp/widgets/NotificationBox.dart';
import '../constants.dart';
import 'Home.dart';

class NotificationsTab extends StatefulWidget {
  final String? currentUserId;
  final UserData? currentUser;

  NotificationsTab({this.currentUserId, this.currentUser});

  @override
  _NotificationsTabState createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kScaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: Container(
             width: MediaQuery.of(context).size.width * .90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * .05),
                  Text('Notifications',
                      style: TextStyle(
                          fontSize: 26.0,
                          color: kDarkest,
                          fontWeight: FontWeight.w500)),
                  SizedBox(height: MediaQuery.of(context).size.height * .01),
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
                      return Expanded(
                        child: ListView(
                          // children: matchChatBoxes,
                          children: widgets,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
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
