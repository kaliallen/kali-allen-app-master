//THIS PAGE IS ACTIVE IN USE

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kaliallendatingapp/screens/BrowseTab.dart';
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
              Padding(
                padding: EdgeInsets.only(left: 25.0, top: 50.0),
                child: Text('Plan 🤝',
                    style: TextStyle(
                        fontSize: 26.0,
                        color: kDarkest,
                        fontWeight: FontWeight.w500)),
              ),
              SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(3.0),
                margin: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  // border: Border.all(color: kPillButtonSelectedColor),
                  // borderRadius: BorderRadius.circular(5.0),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.all(2),
                      width: MediaQuery.of(context).size.width,
                        child: Text(
                            'My Availability (From 3/23 - 3/26)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: kPillButtonSelectedColor,
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CalendarTitle(text: 'Today'),
                        CalendarTitle(text: 'Thursday'),
                        CalendarTitle(text: 'Friday'),
                        CalendarTitle(text: 'Saturday'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CalendarSlot(text: '5-7'),
                        CalendarSlot(text: '5-7'),
                        CalendarSlot(text: '5-7'),
                        CalendarSlot(text: '5-7'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CalendarSlot(text: '7-9'),
                        CalendarSlot(text: '7-9'),
                        CalendarSlot(text: '7-9'),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            padding: const EdgeInsets.all(3),
                            child: Column(
                              children: [
                                Text(
                                    'Late',
                                    style: TextStyle(
                                        color: Colors.white,
                                    )
                                ),
                                Text(
                                  '7-9',
                                  textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                    )
                                ),
                              ],
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: Colors.green,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                Padding(
                  padding: const EdgeInsets.only( right: 15),
                  child: TextButton(
                    child: Text('Clear All'),
                    onPressed: (){

                    },
                  ),
                )
              ],),

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
  final String text;

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
                text,
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
  final String text;

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
                text,
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
