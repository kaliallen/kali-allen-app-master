//THIS PAGE IS ACTIVE IN USE

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/models/userData.dart';
import 'package:kaliallendatingapp/screens/EditProfile.dart';
import 'package:kaliallendatingapp/screens/Home.dart';
import 'package:kaliallendatingapp/screens/ProfilePage.dart';
import 'package:kaliallendatingapp/screens/SubmitFeedback.dart';
import 'package:kaliallendatingapp/widgets/ListTileButton.dart';
import 'package:kaliallendatingapp/widgets/progress.dart';

const TextStyle tileFont = TextStyle(
  fontWeight: FontWeight.w500,
);

class SettingScreen extends StatefulWidget {
  static String id = 'settings_screen';
  final String? currentUserId;

  SettingScreen({this.currentUserId});

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;

  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EditProfile(currentUserId: widget?.currentUserId)));
  }

  viewProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          backButtonFunction: () {},
          profileId: widget?.currentUserId,
          viewPreferenceInfo: false,
        ),
      ),
    );
  }

  viewPreferences() {
    print('Preferences tapped');
  }

  viewInviteFriends() {
    print('Invite friends tapped');
  }

  viewReportAnIssue() {
    print('Report an issue tapped');
    print(widget.currentUserId);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SubmitFeedback()));
  }

  Future<void> logOut() async {
    return await FirebaseAuth.instance.signOut();
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: usersRef.doc(widget.currentUserId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(50.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        Container(
                          // color: Colors.red,
                          height: 135,
                          width: 135,
                        ),
                        Container(
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey,
                          ),
                        ),
                        Positioned(
                          left: 50,
                          bottom: 5,
                          child: RawMaterialButton(
                            onPressed: () {
                              print('Nothing happens');
                            },
                            elevation: 2.0,
                            fillColor: kScaffoldBackgroundColor,
                            child: Icon(
                              Icons.create_rounded,
                              color: kLightDark,
                              size: 25.0,
                            ),
                            padding: EdgeInsets.all(5.0),
                            shape: CircleBorder(),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 15.0),
                    Text(
                      'Loading',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                        color: kDark,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text('Loading',
                        style: TextStyle(
                          fontSize: 15.0,
                          color: kDark,
                          fontWeight: FontWeight.w400,
                        )),
                  ],
                ),
              ),
            ),
          );
        }
        UserData userData =
            UserData.fromDocument(snapshot.data as DocumentSnapshot<Object?>);
        return SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(50.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      Container(
                        // color: Colors.red,
                        height: 135,
                        width: 135,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfilePage(
                                        profileId: widget.currentUserId,
                                        viewingAsBrowseMode: false,
                                        viewPreferenceInfo: false,
                                        backButtonFunction: () {
                                          Navigator.pop(context);
                                        },
                                      )));
                        },
                        child: Container(
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey,
                            backgroundImage:
                                CachedNetworkImageProvider(userData.picture1!),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 50,
                        bottom: 5,
                        child: RawMaterialButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditProfile(
                                        currentUserId: widget.currentUserId)));
                          },
                          elevation: 2.0,
                          fillColor: kScaffoldBackgroundColor,
                          child: Icon(
                            Icons.create_rounded,
                            color: kLightDark,
                            size: 25.0,
                          ),
                          padding: EdgeInsets.all(5.0),
                          shape: CircleBorder(),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 15.0),
                  Text(
                    '${userData.firstName} ${userData.lastName}',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                      color: kDark,
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text('The Tonight App Test User',
                      style: TextStyle(
                        fontSize: 15.0,
                        color: kDark,
                        fontWeight: FontWeight.w400,
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  buildListTiles() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          ListTileButton(
            icon: Icons.settings,
            text: 'Preferences',
            onTap: viewPreferences,
          ),
          ListTileButton(
            icon: Icons.groups,
            text: 'Invite friends',
            onTap: viewInviteFriends,
          ),
          ListTileButton(
            icon: Icons.flag,
            text: 'Submit Feedback',
            onTap: viewReportAnIssue,
          ),
        ],
      ),
    );
  }

  buildLogOutButton() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: GestureDetector(
        onTap: logOut,
        child: ListTile(
          leading: ListTileIcon(
            icon: Icons.exit_to_app,
          ),
          title: Text(
            'Log Out',
            style: tileFont,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildProfileHeader(),
            buildListTiles(),
            buildLogOutButton(),
          ],
        ));
  }
}

loadingView() {
  SafeArea(
    child: Center(
      child: Padding(
        padding: EdgeInsets.all(50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Container(
                  // color: Colors.red,
                  height: 135,
                  width: 135,
                ),
                Container(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                  ),
                ),
                Positioned(
                  left: 50,
                  bottom: 5,
                  child: RawMaterialButton(
                    onPressed: () {
                      print('Nothing happens');
                    },
                    elevation: 2.0,
                    fillColor: kScaffoldBackgroundColor,
                    child: Icon(
                      Icons.create_rounded,
                      color: kLightDark,
                      size: 25.0,
                    ),
                    padding: EdgeInsets.all(5.0),
                    shape: CircleBorder(),
                  ),
                )
              ],
            ),
            SizedBox(height: 15.0),
            Text(
              'Loading',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
                color: kDark,
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            Text('Loading',
                style: TextStyle(
                  fontSize: 15.0,
                  color: kDark,
                  fontWeight: FontWeight.w400,
                )),
          ],
        ),
      ),
    ),
  );
}

class ListTileIcon extends StatelessWidget {
  final IconData? icon;

  ListTileIcon({
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: kScaffoldBackgroundColor,
      radius: 20,
      child: Icon(
        icon,
        color: kDark,
      ),
    );
  }
}
