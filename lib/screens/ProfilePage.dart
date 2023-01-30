import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/models/date.dart';
import 'package:kaliallendatingapp/models/userData.dart';
import 'package:kaliallendatingapp/screens/BrowseScreen.dart';
import 'package:kaliallendatingapp/screens/PickDateTime.dart';
import 'package:kaliallendatingapp/widgets/MatchChatBox.dart';
import 'package:kaliallendatingapp/widgets/progress.dart';
import 'package:uuid/uuid.dart';

import '../models/dateManager.dart';
import 'Home.dart';

class ProfilePage extends StatefulWidget {
  final String profileId;
  final bool viewPreferenceInfo;
  final bool viewingAsBrowseMode;
  final Date dateDoc;
  Function backFunction;

  ProfilePage(
      {this.profileId,
      this.viewPreferenceInfo,
      this.viewingAsBrowseMode,
      this.dateDoc, this.backFunction});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool profileViewing = true;
  TextEditingController matchMessageController = TextEditingController();
  var uuid = Uuid();

  ///When user matches with a profile, a match is created and a notification is created
  startAChat(String date, String name, String imageUrl) {
    //Create a match
    print('Profile Id: ${widget.profileId}');
    print(userId);

    // matchesRef
    //     .doc(userId).collection('matches').doc(widget.profileId)
    //     .set({
    //   'activeMatch': false,
    //   'dateId': widget.profileId,
    //   'lastMessage': matchMessageController.text,
    //   'lastMessageSender': userId,
    //   'lastMessageTime': Timestamp.fromDate(DateTime.now()),
    //   'matchImageUrl': ,
    //   'matchName': widget.userName,
    //   'messageUnread': true,
    //   'messagesId': uuid.v4(),
    //     });

    //Create a notification

    Navigator.pop(context);
  }

  Future<void> matchPopup(String date, String name, String imageUrl) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Match with $name?'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text('Start a chat to meet with $name on $date'),
                  SizedBox(height: 10),
                  TextField(
                    controller: matchMessageController,
                    decoration: kMatchTextFieldDecoration,
                  )
                ],
              ),
            ),
            actions: [
              CupertinoDialogAction(
                child: Text('Match'),
                onPressed: () {
                  String messagesId = uuid.v4();
                  Timestamp time = Timestamp.now();

                  // matchesRef
                  //     .doc(userId).collection('matches').doc(widget.profileId)
                  //     .set({
                  //   'activeMatch': false,
                  //   'dateId': widget.profileId,
                  //   'lastMessage': matchMessageController.text,
                  //   'lastMessageSender': userId,
                  //   'lastMessageTime': time,
                  //   'matchImageUrl': imageUrl,
                  //   'matchName': name,
                  //   'messageUnread': true,
                  //   'messagesId': messagesId,
                  //   //TODO: Add 'Date'
                  //     });
                  //
                  // //Create a new Message
                  //   messagesRef.doc(messagesId).collection('messages')
                  //   .add({
                  //     'message': matchMessageController.text,
                  //     'sender': userId,
                  //     'time': time,
                  //   });

                  //Create a notification
                  notificationsRef
                      .doc(widget.profileId)
                      .collection('notifications')
                      .add({
                    'senderId': userId,
                    'dateNotification': true,
                    'isActive': true,
                    'matchImageUrl': imageUrl,
                    'name': name,
                    'poolNotification': false,
                    'time': time,
                    'type': "match",
                    'message': matchMessageController.text,
                    'date': date,
                  });
                  print('issssa sent');

                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                child: Text('Close'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  Wrap availabilities(UserData profileData) {
    //TODO add a method here that takes out all the expired dates...
    List<Widget> timebuttonchildren = [];

    print(widget.dateDoc.availability);
    //
    // widget.dateDoc.findActiveDatesFromList()     ;
    //

    //TODO: only relevent dates
    for (String dateid in widget.dateDoc.availability) {
      var newid = dateid.split('-');
      String date = newid[0];
      String time = newid[1];

      //Date
      DateTime dateDay = DateTime.parse(date);
      date = '${DateFormat.MEd().format(dateDay)}';

      //Time
      if (time == '46') {
        time = '4-6 PM';
      }
      if (time == '68') {
        time = '6-8 PM';
      }
      if (time == '810') {
        time = '8-10 PM';
      }

      print('$date' + ' $time');

      GestureDetector child = GestureDetector(
        onTap: () {
          print(date);
          //TODO: when pressed, send a notification to user
          //TODO: create a new chat with the user

          //Create a new Uuid for matches ID
          // var uuid = Uuid().v4();
          // print(uuid);

          print('widget profile id ${widget.profileId}');
          print('profile data uid ${profileData.uid}');
          print(profileData.firstName);

          //Create Popup to confirm matching and send an optional message
          matchPopup('$date' + ' from $time', '${profileData.firstName}',
              profileData.picture1);

          // Create the match ref for the user
          // matchesRef.doc(widget.profileId).collection('matches').doc(profileData.uid).set({
          //   'activeMatch': true,
          //   'lastMessage': 'New Date Request!',
          //   'lastMessageSender': '${widget.profileId}',
          //   'lastMessageTime': DateTime.now(),
          //   'matchImageUrl': '${profileData.picture1}',
          //   'matchName': '${profileData.firstName}',
          //   'messageUnread': true,
          //   'messagesId': uuid,
          // });

          //Create match ref for the profile user
        },
        child: Pill(
          text: '$date' + ' $time',
          color: Colors.black,
        ),
      );

      timebuttonchildren.add(child);
    }

    return Wrap(
      children: timebuttonchildren,
    );
  }

  ///If profile's available times (dateDoc.availability) are out of date, DELETE? or make inactive
  eraseOldDates() {}

  @override
  void initState() {
    eraseOldDates();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE5E5E5),
      body: buildProfilePage(),
    );
  }

  ///This is everything that lays on top of the profile picture, ie name, age, location
  FutureBuilder buildProfilePage() {
    return FutureBuilder(
        future: usersRef.doc(widget.profileId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          UserData profileUserData = UserData.fromDocument(snapshot.data);
          return
              //Top Picture & Text
              ListView(
                padding: EdgeInsets.zero,
            children: [
              //Profile image/Name/Quick Info
              Stack(children: [
                //TODO: This gradient doesn't work...?

                //Profile Picture image
                Container(
                  height: MediaQuery.of(context).size.height * .5,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                      image:
                          CachedNetworkImageProvider(profileUserData.picture1),
                      fit: BoxFit.cover),
                ),

                //Gradient over Profile Picture image
                Container(
                  height: MediaQuery.of(context).size.height * .5,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment(0, .8),
                        colors: [
                          Color(0xff22242A).withOpacity(.05),
                          Color(0xff000000).withOpacity(.4)
                        ],
                      )),
                ),

                //This Container contains top buttons and bottom text
                Container(
                  height: MediaQuery.of(context).size.height * .5,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      //Buttons on top
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left:15.0, top: 40),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back_ios_sharp),
                              color: Colors.white,
                              iconSize: 25.0,
                              onPressed: () {
                                widget.viewingAsBrowseMode
                                    ? widget.backFunction()
                                    : Navigator.pop(context);
                              },
                            ),
                          ),
                          widget.viewPreferenceInfo
                              ? SizedBox()
                              : Padding(
                            padding: const EdgeInsets.only(right:15.0, top: 40),
                                  child: widget.viewingAsBrowseMode
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.more_horiz_sharp,
                                            color: Colors.white,
                                            size: 25.0,
                                          ),
                                          //TODO: Integrate this everywhere....
                                          onPressed: widget.backFunction,
                                        )
                                      : SizedBox(),
                                ),
                        ],
                      ),
                      //Header info
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              //TODO: If the firstName is null, the screen will crash! Fix by adding condition -- UPDATE: I dont actually know if this is necessary. Or if we should curb this from happening upstream
                              profileUserData.firstName != null
                                  ? profileUserData.firstName
                                  : profileUserData.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26.0,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: widget.viewPreferenceInfo
                                  ? []
                                  : [
                                      widget.viewingAsBrowseMode
                                          ? Wrap(
                                              //TODO: Fix
                                              //TODO: Decide if this goes here. Should there be compatible "interests" here? Lots of questions...
                                              children: [
                                                //Custom message as a pill?
                                                // widget.dateDoc
                                                //         .interests['activity']
                                                //     ? Pill(
                                                //         text: widget.dateDoc
                                                //             .customMessage,
                                                //         color: Colors.green
                                                //             .withOpacity(.3),
                                                //       )
                                                //     : SizedBox(width: 0),
                                                widget.dateDoc
                                                        .interests['drinks']
                                                    ? Pill(
                                                        text: 'Drinks',
                                                        color: Colors.white
                                                            .withOpacity(.1),
                                                      )
                                                    : SizedBox(width: 0),
                                                widget.dateDoc
                                                        .interests['dinner']
                                                    ? Pill(
                                                        text: 'Dinner',
                                                        color: Colors.white
                                                            .withOpacity(.1),
                                                      )
                                                    : SizedBox(width: 0),
                                              ],
                                            )
                                          : SizedBox(),
                                //TODO: This is where the bug is
                                widget.dateDoc == null ? SizedBox(height: 0): Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child:  Text(
                      //TODO: Change the font here
                      widget.dateDoc.customMessage,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ]),

              //Info Square Box
              Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                  right: 20.0,
                  left: 20.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: [
                      //TODO: Make this row scrollable within the container
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconCard(
                              icon: Icons.location_on_outlined,
                              text: 'Dupont Circle' //profileUserData.occupation,
                              //${profileUserData.gender}
                              ),
                          IconCard(
                            icon: Icons.cake_outlined,
                            text: '26',
                          ),
                          IconCard(
                            icon: Icons.straighten,
                            text: '5\'5',
                          ),
                        ],
                      ),
                      profileUserData.education != null ? Divider() : SizedBox(height: 0),
                      profileUserData.education != null ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconCard(
                              icon: Icons.account_balance_sharp,
                              text: profileUserData.education,
                              //${profileUserData.gender}
                              ),
                        ],
                      ) : SizedBox(height: 0),
                      profileUserData.occupation != null ? Divider() : SizedBox(height: 0),
                      profileUserData.occupation != null ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconCard(
                            icon: Icons.business_center,
                            text: profileUserData.occupation,
                          ),
                          // IconCard(
                          //   icon: Icons.cake_outlined,
                          //   text: '26',
                          // ),
                        ],
                      ) : SizedBox(height: 0),
                    ],
                  ),
                ),
              ),

              //Photo 2 Box
              Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                  right: 20.0,
                  left: 20.0,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image(
                    width: MediaQuery.of(context).size.width,
                    height: 300.0,
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(profileUserData.picture1),
                  ),
                ),
              ),

              //Prompt Square
              // Padding(
              //   padding: const EdgeInsets.all(20),
              //   child: Container(
              //     decoration: BoxDecoration(
              //       color: Colors.white,
              //       borderRadius: BorderRadius.circular(10.0),
              //     ),
              //     child: Column(
              //       children: [
              //         //TODO: Make this row scrollable within the container
              //         Text(
              //           'What do you like to do for fun?'
              //         ),
              //         Text(
              //           'Hang out with friends'
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              //Photo 2 Box


              //Bio Box
              profileUserData.bio != null ? Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                  right: 20.0,
                  left: 20.0,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 20.0),
                    child: Text('${profileUserData.bio}',
                        style: TextStyle(
                          color: Color(0xff070D1B),
                        )),
                  ),
                ),
              ) : SizedBox(height: 0),

//Photo 2 Box
              Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                  right: 20.0,
                  left: 20.0,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image(
                    width: MediaQuery.of(context).size.width,
                    height: 300.0,
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(profileUserData.picture1),
                  ),
                ),
              ),

              //Time Slots
              widget.viewingAsBrowseMode
                  ? Padding(
                      padding: const EdgeInsets.only(
                        top: 30.0,
                        right: 0.0,
                        left: 20.0,
                        bottom: 100.0,
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Click a time slot below to match with ${profileUserData.firstName}: '),
                            Center(child: availabilities(profileUserData)),
                          ],
                        ),
                      ),
                      // Wrap(
                      //         children: [
                      //           //TODO: Somehow figure out how to add availabilities here.
                      //           GestureDetector(
                      //             onTap: () {
                      //               // print(widget.dateDoc.availability);
                      //               // for (String date in widget.dateDoc.availability) {
                      //               //   String datetime = date.substring(8, 10);
                      //               //
                      //               //   String dateday = date.substring(0, 8);
                      //               //   DateTime datey = DateTime.parse(dateday);
                      //               //
                      //               //   String dater = '${DateFormat.MEd().format(datey)}';
                      //               //   print(dater);
                      //               //
                      //               //   if (datetime == '46') {
                      //               //     datetime = '4-6 PM';
                      //               //     // print('4-6 PM');
                      //               //   }
                      //               //   if (datetime == '68') {
                      //               //     // print('6-8 PM');
                      //               //     datetime = '6-8 PM';
                      //               //   }
                      //               //   if (datetime == '810') {
                      //               //     // print('8-10 PM');
                      //               //     datetime = '8-10 PM';
                      //               //   }
                      //               //
                      //               //   print('$dater' + ' $datetime');
                      //               // }
                      //             },
                      //             child: Pill(
                      //               text: 'Tonight 4-6 PM',
                      //               color: Color(0xff6A4C93),
                      //             ),
                      //           ),
                      //           Pill(
                      //             text: 'Tuesday 4-6 PM',
                      //             color: Color(0xff6A4C93),
                      //           ),
                      //         ],
                      //       ),
                    )
                  : SizedBox(),

            ],
          );
        });
  }

  @override
  void dispose() {
    matchMessageController.dispose();
    super.dispose();
  }
}

class IconCard extends StatelessWidget {
  final String text;
  final IconData icon;

  IconCard({this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Color(0xff393D49),
            size: 25.0,
          ),
          SizedBox(
            width: 10.0,
          ),
          Text(
            text,
            style: TextStyle(
              color: Color(0xff6A6E76),
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String text;
  final IconData icon;
  final String text2;
  final IconData icon2;

  InfoRow({this.text, this.icon, this.text2, this.icon2});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconCard(
          icon: icon,
          text: text,
        ),
        IconCard(
          icon: icon2,
          text: text2,
        ),
      ],
    );
  }
}

class Pill extends StatelessWidget {
  final String text;
  final Color color;

  const Pill({Key key, this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, top: 10),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(15.0)),
      ),
    );
  }
}
