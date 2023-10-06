import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/screens/Home.dart';
import 'package:kaliallendatingapp/widgets/ActiveMatchChatBox.dart';

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
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * .90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 25.0, right: 10.0, top: 50.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('My Pool',
                            style: TextStyle(
                                fontSize: 26.0,
                                color: kDarkest,
                                fontWeight: FontWeight.w500)),

                         Icon(
                            Icons.add,
                          ),




                      ],
                    ),
                  ),

                  DateList(profileId: widget.currentUserId),
                ],
              ),
            ),
          ),
        ));
  }
}

class DateList extends StatelessWidget {

  const DateList({
   this.profileId,
  });

  final String? profileId;

  bool isTimestampEqualToCurrentTime(Timestamp inputTimestamp) {
    // Get the current Timestamp
    Timestamp currentTimestamp = Timestamp.now();

    // Compare the inputTimestamp with the currentTimestamp
    return inputTimestamp.seconds == currentTimestamp.seconds &&
        inputTimestamp.nanoseconds == currentTimestamp.nanoseconds;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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
          final availability = match['availability'];

          print('yodolay');
          print(availability);
          print(availability[0]);
          print(availability[1]);
          print(matchId);
          print(profileId);

          //Find Out if User is Available


          // Timestamp matchTimestamp = availability[match.id];
          // print(matchTimestamp);

          //Find out if the dateTime is today's date
          // bool available = matchTimestamp.toDate().year == DateTime.now().year && matchTimestamp?.toDate().day == DateTime.now().day;

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
            // available: availability,
            lastMessage: lastMessage,


          );

            widgets.add(chatMatchBox);



        }
        //TODO: Need to figure out how to make this a scrollable listView
        return Expanded(
          child: ListView(
            // children: matchChatBoxes,
            children:
            widgets,

          ),
        );
      },
    );
  }
}

