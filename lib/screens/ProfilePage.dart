import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/models/userData.dart';
import 'package:kaliallendatingapp/widgets/MatchChatBox.dart';
import 'package:kaliallendatingapp/widgets/Pill.dart';
import 'package:kaliallendatingapp/widgets/progress.dart';
import 'package:uuid/uuid.dart';
import 'Home.dart';

class ProfilePage extends StatefulWidget {
  final String? profileId;
  final bool? viewAvailabilityInfo;
  final bool? viewingAsBrowseMode;
  final Function()? backButtonFunction;

  ProfilePage({
    this.profileId,
    this.viewAvailabilityInfo,
    this.viewingAsBrowseMode,
    required this.backButtonFunction,
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool profileViewing = true;
  TextEditingController matchMessageController = TextEditingController();
  var uuid = Uuid();

  TextEditingController reportController = TextEditingController();

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

  Future<void> reportPopup(String name, String profileUid) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Report $name?'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  // Text('Reports are annonymous.'),
                  TextField(
                    controller: reportController,
                    maxLines: 10,
                    minLines: 4,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "All reports are anonymous",
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              CupertinoDialogAction(
                child: Text('Report', style: TextStyle(color: Colors.red)),
                onPressed: () async {
                  String? message;

                  await reportsRef.add({
                    'report': 'profile',
                    'userid': profileUid,
                    'message': reportController.text.trim(),
                    'time': DateTime.now(),
                  }).then((value) {
                    message = 'Report Sent!';
                  }).catchError((error) => message = 'Report could not send: $error');

                  SnackBar snackBar = SnackBar(content: Text(message!));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);

                  Future.delayed(Duration(seconds: 1), () {
                    Navigator.pop(context);
                  });
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE5E5E5),
      body: buildProfilePage(),
    );
  }

  FutureBuilder buildProfilePage() {
    return FutureBuilder(
        future: usersRef.doc(widget.profileId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }

          UserData profileUserData = UserData.fromDocument(snapshot.data);

          // //Find out if the dateTime is today's date
          bool dateIsToday = profileUserData.availability?[0].toDate().year ==
                  DateTime.now().year &&
              profileUserData.availability?[0].toDate().day ==
                  DateTime.now().day;
          print('Date is today? $dateIsToday');

          //
          //     //They answered yes or no
          //     bool answered = currentUser?.availability?[1] != null;
          //     print('answered');
          //     print(answered);
          //
          //     //If the date is todays date and the bool is not null, dateExists is true
          //     if (dateIsToday && answered){
          //       print('yo');
          //       setState(() {
          //         dateExists = true;
          //       });
          //     } else {
          //       print('dateExits = $dateExists');
          //       setState(() {
          //         dateExists = false;
          //       });
          //
          //     }

          return
              //Top Picture & Text
              ListView(
            padding: EdgeInsets.zero,
            children: [
              Stack(children: [
                //Profile Picture image
                Container(
                  height: MediaQuery.of(context).size.height * .5,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                      image:
                          CachedNetworkImageProvider(profileUserData.picture1!),
                      fit: BoxFit.cover),
                ),

                //Gradient over Profile Picture image
                //TODO: This gradient doesn't work...?
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
                            padding: const EdgeInsets.only(left: 15.0, top: 40),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back_ios_sharp),
                              color: Colors.white,
                              iconSize: 25.0,
                              onPressed: widget.backButtonFunction,
                            ),
                          ),
                          widget.viewingAsBrowseMode == false
                              ? SizedBox()
                              : Padding(
                                  padding: const EdgeInsets.only(
                                      right: 15.0, top: 40),
                                  child: widget.viewingAsBrowseMode == true
                                      ? PopupMenuButton(
                                          icon: Icon(
                                            Icons.more_horiz_sharp,
                                            color: Colors.white,
                                            size: 25.0,
                                          ),
                                          itemBuilder: (context) =>
                                              <PopupMenuEntry>[
                                            PopupMenuItem(
                                              child: Text(
                                                'Report User',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                              onTap: () {
                                                reportPopup(
                                                    profileUserData!.firstName!,
                                                    profileUserData!.uid!);
                                              },
                                            ),
                                            // PopupMenuItem(
                                            //   child: Text('Cancel'),
                                            // ),
                                          ],
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  //TODO: Fix
                                  //TODO: Decide if this goes here. Should there be compatible "interests" here? Lots of questions...
                                  children: [
                                    dateIsToday == true
                                        ? Pill(
                                            text: profileUserData.memo,
                                            color: Colors.green.withOpacity(.1),
                                          )
                                        : SizedBox(),
                                  ],
                                )
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  profileUserData.firstName != null
                                      ? '${profileUserData.firstName}'
                                      : 'Null',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26.0,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                                SizedBox(width: 10),
                                dateIsToday == true &&
                                        profileUserData.availability?[1] == true
                                    ? Pill(
                                        text: 'Free Tonight',
                                        color: Colors.green.withOpacity(.95),
                                      )
                                    : SizedBox(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ]),

              //Bio Box
              profileUserData.bio != null
                  ? Padding(
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
                    )
                  : SizedBox(height: 0),

              //Info Square Box
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: [
                      //TODO: Make this row scrollable within the container
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconCard(
                                icon: Icons.mood,
                                text: 'She/Her' //profileUserData.occupation,
                                ),
                            profileUserData.relationshipStatus != null
                                ? IconCard(
                                    icon: Icons.favorite_border,
                                    text: profileUserData
                                        .relationshipStatus, //Dating, Not Dating, In A Relationship
                                  )
                                : SizedBox(),
                          ],
                        ),
                      ),
                      profileUserData.location != null ? Divider() : SizedBox(),
                      profileUserData.location != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconCard(
                                  icon: Icons.location_on_outlined,
                                  text: profileUserData
                                      .location, //profileUserData.occupation,
                                ),
                              ],
                            )
                          : SizedBox(),
                      profileUserData.education != null
                          ? Divider()
                          : SizedBox(height: 0),
                      profileUserData.education != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconCard(
                                  icon: Icons.account_balance_sharp,
                                  text: profileUserData.education,
                                  //${profileUserData.gender}
                                ),
                              ],
                            )
                          : SizedBox(height: 0),
                      profileUserData.occupation != null
                          ? Divider()
                          : SizedBox(height: 0),
                      profileUserData.occupation != null
                          ? Row(
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
                            )
                          : SizedBox(height: 0),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 70),
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
  final String? text;
  final IconData? icon;

  IconCard({this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
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
            text!,
            style: kCardTitle,
          ),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final String? text2;
  final IconData? icon2;

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
