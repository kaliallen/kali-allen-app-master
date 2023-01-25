//THIS PAGE IS ACTIVE IN USE

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kaliallendatingapp/screens/BrowseScreen.dart';
import 'package:kaliallendatingapp/widgets/NotificationBox.dart';

import '../constants.dart';
import 'Home.dart';

class NotificationScreen extends StatefulWidget {
  final String currentUserId;

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 25.0, top: 50.0),
                    child: Text('Notifications',
                        style: TextStyle(
                            fontSize: 26.0,
                            color: kDarkest,
                            fontWeight: FontWeight.w500)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50, right: 15),
                    child: TextButton(
                      child: Text('Clear All'),
                      onPressed: (){

                      },
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  //TODO: ORGANIZE - Make the steambuilder a seperate class at the bottom
                  StreamBuilder<QuerySnapshot>(
                    stream: notificationsRef
                        .doc(widget.currentUserId)
                    //TODO: Add Order By
                        .collection('notifications')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.lightBlue,
                            ));
                      }
                      final notifications = snapshot.data.docs;

                      List<Widget> widgets = [];

                      for (var notification in notifications) {
                        print(
                            'this is the loop triggered for notfication id ${notification.id}');

                        final userId = notification.id;
                        final dateNotification = notification['dateNotification'];
                        final matchImageUrl = notification['matchImageUrl'];
                        final senderId = notification['senderId'];
                        final name = notification['name'];
                        final poolNotification = notification['poolNotification'];
                        final time = notification['time'].toDate();
                        final type = notification['type'];
                        final message = notification['message'];
                        final date = notification['date'];


                        final notificationBox = NotificationBox(
                          notificationId: userId,
                          dateNotification: dateNotification,
                          matchImageUrl: matchImageUrl,
                          senderId: senderId,
                          name: name,
                          poolNotification: poolNotification,
                          time: time,
                          type: type,
                          message: message,
                          date: date,
                          userId: widget.currentUserId,
                        );

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
