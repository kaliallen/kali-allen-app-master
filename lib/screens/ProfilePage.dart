import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/models/userData.dart';
import 'package:kaliallendatingapp/widgets/MatchChatBox.dart';
import 'package:kaliallendatingapp/widgets/progress.dart';
import 'package:uuid/uuid.dart';
import 'Home.dart';

class ProfilePage extends StatefulWidget {
  final String? profileId;
  final bool? viewPreferenceInfo;
  final bool? viewingAsBrowseMode;

  ProfilePage(
      {this.profileId,
      this.viewPreferenceInfo,
      this.viewingAsBrowseMode,
      });

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

          //Find out if the dateTime is today's date
          bool available = profileUserData.availability?.toDate().year == DateTime.now().year && profileUserData.availability?.toDate().day == DateTime.now().day;

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
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),

                              widget.viewPreferenceInfo == true ?
                              SizedBox()
                              : Padding(
                                  padding: const EdgeInsets.only(
                                      right: 15.0, top: 40),
                                  child:
                                  widget.viewingAsBrowseMode == true
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.more_horiz_sharp,
                                            color: Colors.white,
                                            size: 25.0,
                                          ),
                                          //TODO: Integrate this everywhere....
                                          onPressed: (){},
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
                              children: widget.viewPreferenceInfo == true
                                  ? []
                                  : [

                                      widget.viewingAsBrowseMode == true
                                          ?
                                      Wrap(
                                              //TODO: Fix
                                              //TODO: Decide if this goes here. Should there be compatible "interests" here? Lots of questions...
                                              children: [

                                                available == true ? Pill(
                                                  text: 'Anyone want to go to a meditation happy hour? 🧘🏻‍',
                                                  color: Colors.green
                                                      .withOpacity(.1),
                                                ): SizedBox(),
                                              ],
                                            )
                                          : SizedBox(),

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
                                available == true ? Pill(
                                  text: 'Free Tonight',
                                  color: Colors.green
                                      .withOpacity(.95),
                                ) : SizedBox(),
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
                    image: CachedNetworkImageProvider(profileUserData.picture1!),
                  ),
                ),
              ),

              //Info Square Box
              Padding(
                padding: const EdgeInsets.all(20.0),
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
                              icon: Icons.mood,
                              text:
                              'She/Her' //profileUserData.occupation,
                            //${profileUserData.gender}
                          ),
                          IconCard(
                              icon: Icons.emoji_people,
                              text:
                              'Straight' //profileUserData.occupation,
                            //${profileUserData.gender}
                          ),
                          IconCard(
                            icon: Icons.favorite_border,
                            text: 'Dating',
                          ),
                          // IconCard(
                          //   icon: Icons.straighten,
                          //   text: '5\'5',
                          // ),
                        ],
                      ),
                      profileUserData.location != null ?
                      Divider(): SizedBox(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconCard(
                              icon: Icons.location_on_outlined,
                              text:
                              'Dupont Circle' //profileUserData.occupation,
                            //${profileUserData.gender}
                          ),
                          // IconCard(
                          //   icon: Icons.cake_outlined,
                          //   text: '26',
                          // ),

                        ],
                      ),
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

// Photo 2 Box
              Padding(
                padding: const EdgeInsets.only(
                  right: 20.0,
                  left: 20.0,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image(
                    width: MediaQuery.of(context).size.width,
                    height: 300.0,
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(profileUserData.picture1!),
                  ),
                ),
              ),



              //Prompt Box
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //TODO: Make this row scrollable within the container
                        Text(
                          'My favorite things to do in DC are...',
                          style: kCardTitle,
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Thai food, going to the park, & going to Flash ;)',
                              style: kCardAnswer
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 50),
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

class Pill extends StatelessWidget {
  final String? text;
  final Color? color;

  const Pill({Key? key, this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, top: 10),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.only(right: 10, left: 10, top: 5.0, bottom: 5.0),
          child: Text(
            text!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(15.0)),
      ),
    );
  }
}
