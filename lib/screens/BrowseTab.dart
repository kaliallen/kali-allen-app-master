//TODO: Test to see if you leave a screen on for a long time and the time passes after 5 pm, when you click on the screen does it refresh the time? Right now it does not.


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart';
import 'package:intl/intl.dart';
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/models/userData.dart';
import 'package:kaliallendatingapp/screens/EventsPage.dart';
import 'package:kaliallendatingapp/screens/Home.dart';
import 'package:kaliallendatingapp/screens/ProfilePage.dart';
import 'package:kaliallendatingapp/screens/SubmitFeedback.dart';
import 'package:kaliallendatingapp/widgets/StyledButton.dart';
import 'package:kaliallendatingapp/widgets/progress.dart';

import '../widgets/Pill.dart';

final backgroundColor = Colors.black;

//Initstate is used to find if the user has already entered in a time and day to find a date
//if it is, the matches screen appears. If not, it goes to the Find a Date screen

UserData? currentUser; //in use
bool? dateExists; //in use

class BrowseScreen extends StatefulWidget {
  final String? currentUserUid;

  BrowseScreen({this.currentUserUid});

  @override
  _BrowseScreenState createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  bool availableTonight = true;

  TextEditingController addMemoController = TextEditingController();
  bool addMemo = false;

  bool notifyPool = false;

  //When initState starts, saveUserInfo function is triggered and currentUser is saved here

  TextEditingController sendMessageController = TextEditingController();
  DateTime now = DateTime.now();
  int profilePagesIndex = 0;

  //Functions in initState

  ///Grab user's data using the widget.currentuid, save it in UserData currentUser
  saveUserInfo() async {
    DocumentSnapshot userDoc = await usersRef.doc(widget.currentUserUid).get();

    currentUser = UserData.fromDocument(userDoc);
  }

  bool findIfDateAdded() {
    bool enteredAvailability = false;

    if (currentUser != null) {
      print(currentUser!.availability);
    } else {
      print('currentUser is null');
    }

    if (enteredAvailability == true) {
      return true;
    } else {
      return false;
    }
  }

  ///If there are current dates, dateExists = true and buildMatchesProile2 populates. If false buildWelcomePage2 populates.
  toggleWelcome2BrowseScreen() async {
    DocumentSnapshot userDoc = await usersRef.doc(widget.currentUserUid).get();

    setState(() {
      currentUser = UserData.fromDocument(userDoc);
    });

    print(currentUser?.firstName);
    print(currentUser?.availability);
    print('hopsdf');

    //Find if they have submitted their availability

    //Find out if the dateTime is today's date
    bool dateIsToday =
        currentUser?.availability?[0].toDate().year == DateTime.now().year &&
            currentUser?.availability?[0].toDate().day == DateTime.now().day;
    print('Date is today?:');
    print(dateIsToday);

    //They answered yes or no
    bool answered = currentUser?.availability?[1] != null;
    print('answered');
    print(answered);

    //If the date is todays date and the bool is not null, dateExists is true
    if (dateIsToday && answered) {
      print('yo');
      setState(() {
        dateExists = true;
      });
    } else {
      print('dateExits = $dateExists');
      setState(() {
        dateExists = false;
      });
    }
  }

  @override
  void initState() {
    // saveUserInfo();
    toggleWelcome2BrowseScreen();
    super.initState();
  }

  deleteUser() async {
    final doc = await usersRef.doc('sdlfksdjf').get();
    if (doc.exists) {
      usersRef.doc(widget.currentUserUid).delete();
    }
  }

  getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    print(placemark.subAdministrativeArea);
  }

  yesPressed() async {

    //Update Availability in user's profile data
    usersRef
        .doc(widget.currentUserUid)
        .update({
          'availability': [now, availableTonight],
          'memo': addMemoController.text.toString().trim(),
        })
        .then((value) => print('Availability Updated'))
        .catchError((error) => print('Failed to update availability: $error'));

    //Update Availability in matches

    //Get list of all the uid of your matches
    List<String> matchesUids = [];
    QuerySnapshot querySnapshot =
        await matchesRef.doc(widget.currentUserUid).collection('matches').get();
    for (var doc in querySnapshot.docs) {
      matchesUids.add(doc.id);
    }
    print('here are the matches uids:');
    print(matchesUids);

    //With the list of uids, update their match list to show that the current user's availability
    if (availableTonight == true) {
      //For each uid in the list, update the doc
      for (String matchUid in matchesUids) {
        if (addMemo == true) {
          try {
            await matchesRef
                .doc(matchUid)
                .collection("matches")
                .doc(widget.currentUserUid)
                .update({
              'availability': [now, true],
              'memo': addMemoController.text.trim(),
            });
          } catch (e) {
            print('Error updating document for user $matchUid: $e');
          }
        } else {
          try {
            await matchesRef
                .doc(matchUid)
                .collection("matches")
                .doc(widget.currentUserUid)
                .update({
              'availability': [now, true],
              'memo': null,
            });
          } catch (e) {
            print('Error updating document for user $matchUid: $e');
          }
        }
      }
    } else {
      for (String name in matchesUids) {
        if (addMemo == true) {
          try {
            await matchesRef
                .doc(name)
                .collection("matches")
                .doc(widget.currentUserUid)
                .update({
              'availability': [now, false],
              'memo': addMemoController.text.trim(),
            });
          } catch (e) {
            print('Error updating document for user $name: $e');
          }
        } else {
          try {
            await matchesRef
                .doc(name)
                .collection("matches")
                .doc(widget.currentUserUid)
                .update({
              'availability': [now, false],
              'memo': null,
            });
          } catch (e) {
            print('Error updating document for user $name: $e');
          }
        }
      }
    }

    //Notify user's pool
    if (notifyPool == true){
      for (String matchUid in matchesUids) {
        try {
          await notificationsRef
              .doc(matchUid)
              .collection("notifications")
              .add({
            'matchImageUrl': currentUser!.picture1,
            'message': addMemoController.text.trim(),
            'name': currentUser!.firstName,
            'senderId': currentUser!.uid,
            'time': now,
            'type': 'looking',
          });
        } catch (e) {
          print('Error updating document for user $matchUid: $e');
        }
      }

    }

    //Change the screen to show the profile pages
    setState(() {
      dateExists = true;
    });
  }

  noPressed() async {
    setState(() {
      availableTonight = false;
    });

    //Update Availability in user's profile data
    usersRef
        .doc(widget.currentUserUid)
        .update({
          'availability': [now, false]
        })
        .then((value) => print('Availability Updated'))
        .catchError((error) => print('Failed to update availability: $error'));

    //Update Availability in matches

    //Get list of all the uid of your matches
    List<String> matchesUids = [];
    QuerySnapshot querySnapshot =
        await matchesRef.doc(widget.currentUserUid).collection('matches').get();
    for (var doc in querySnapshot.docs) {
      matchesUids.add(doc.id);
    }
    print(matchesUids);

    //For each uid in the list, update the doc
    for (String name in matchesUids) {
      try {
        await matchesRef
            .doc(name)
            .collection("matches")
            .doc(widget.currentUserUid)
            .update({
          '$name': null,
        });
      } catch (e) {
        print('Error updating document for user $name: $e');
      }
    }

    setState(() {
      dateExists = true;
    });
  }

  goToEventsPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => EventsPage()));
  }

  double deviceHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;

  ///This screen is where users input their availability and interested activities to find a date
  buildWelcomePage() {
    return Scaffold(
      backgroundColor: kScaffoldBackgroundColor,
      //Color(0xffd4fcc3),//Color(0xfff3c969),//Color(0xffff5b2),//Color(0xffEDFF86),//Color(0xff362C28),
      //Colors.white, //kBrowsePageBackgroundColor,
      body: SafeArea(
        //TODO: Make the padding adjust with screen size
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * .90,
            height: MediaQuery.of(context).size.height * .75,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Center(
                  child: Text(
                      //'🗓 ' +
                      DateFormat('MMMEd').format(now),
                      style: kDateTextStyle),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Center(
                    //   child: Text(
                    //       //'🗓 ' +
                    //       DateFormat('MMMEd').format(now),
                    //       style: kDateTextStyle),
                    // ),
                    // Text('Hey, Kali!', style: kHeyKaliText),
                    // SizedBox(height: MediaQuery.of(context).size.height * .01),
                    Text('Are you available', style: kAreYouFreeText),
                    Text('tonight?', style: kAreYouFreeText),
                    SizedBox(height: MediaQuery.of(context).size.height * .02),
                    StyledButton(
                      text: "Yes",
                      color: availableTonight ? kDark : Colors.white,
                      fontColor: availableTonight ? Colors.white : kDarkish,
                      border: kYesNoButtonBorder,
                      onTap: () {
                        if (availableTonight == false) {
                          setState(() {
                            availableTonight = true;
                          });
                        }
                      },
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * .02),
                    StyledButton(
                      text: "No",
                      color: availableTonight ? Colors.white : kDark,
                      fontColor: availableTonight ? kDarkish : Colors.white,
                      border: kYesNoButtonBorder,
                      onTap: () {
                        if (availableTonight == true) {
                          setState(() {
                            availableTonight = false;
                          });
                        }
                      },
                    ),
                  ],
                ),
                Divider(),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Add a note', style: kToggleTextStyle),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * .01),
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          // border: kYesNoButtonBorder,
                          borderRadius: BorderRadius.circular(
                              20.0), // Adjust the radius as needed
                        ),
                        child: TextField(
                          controller: addMemoController,
                          readOnly: addMemo ? true : false,
                          style: kToggleTextStyle,
                          maxLines: 2,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10.0),
                            // Padding inside the TextField
                            hintText: '(Optional) Write something you\'re looking to do!',

                            border: InputBorder
                                .none, // Remove the default TextField border
                          ),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * .01),
                      GestureDetector(
                        child: Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: addMemo ? kYesNoButtonColor : Colors.white,
                            border: kYesNoButtonBorder,
                            borderRadius: BorderRadius.circular(
                                20.0), // Adjust the radius as needed
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              addMemo
                                  ? Text('Note added!',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        //  fontWeight: FontWeight.w500,
                                        //  letterSpacing: .1,
                                      ))
                                  : Text('Save', style: kToggleTextStyle),
                            ],
                          ),
                        ),
                        onTap: () {
                          if (addMemo == false) {

                            if (addMemoController.text.trim().isNotEmpty) {
                              setState(() {
                                addMemo = true;
                              });
                            }
                          } else {
                            setState(() {
                              addMemo = false;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Send a notification to my pool',
                        style: kToggleTextStyle),
                    Switch(
                      value: notifyPool,
                      activeColor: kYesNoButtonColor,
                      onChanged: (bool value) {
                        setState(() {
                          notifyPool = value;
                        });
                      },
                    )
                  ],
                ),
                StyledButton(
                  text: 'Done',
                  color: kDoneButtonColor,
                  fontColor: kDoneButtonTextColor,
                  onTap: yesPressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  viewReportAnIssue() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SubmitFeedback()));
  }

  buildNoCurrentMatchesWidget() {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: EdgeInsets.all(20.0),
                child: Text('There are no users available at this time. '),
              ),
              TextButton(
                child: Text('Report an Error'),
                onPressed: viewReportAnIssue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildMatchesProfiles() {
    return StreamBuilder<QuerySnapshot>(
      stream: usersRef
          // .where('interestedIn', isEqualTo: currentUser.gender)
          // .where('gender', isEqualTo: currentUser.isInterestedIn)
          // .where('uid', isNotEqualTo: currentUser.uid)
          // .where('availability', arrayContainsAny: userAvailableDates)
          // .orderBy('time', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
              child: CircularProgressIndicator(
            backgroundColor: Colors.lightBlue,
          ));
        }

        final users = snapshot.data!.docs;

        List<ProfilePage> profilePages = [];
        List<String?> profileNames = [];
        List<String?> profileIds = [];
        List<String?> profilePicUrls = [];
        List<List?> profileAvailabilities = [];

        for (var user in users) {
          print('this is the loop triggered for match id ${user.id}');

          String? profilePic = user['picture1'];
          profilePicUrls.add(profilePic);

          String? profileName = user['firstName'];
          profileNames.add(profileName);

          String? profileId = user['uid'];
          profileIds.add(profileId);

          List? profileAvailability = user['availability'];
          profileAvailabilities.add(profileAvailability);

          final userProfile = ProfilePage(
            profileId: user.id,
            viewAvailabilityInfo: true,
            viewingAsBrowseMode: true,
            backButtonFunction: () {
              setState(() {
                dateExists = false;
              });
            },
          );

          profilePages.add(userProfile);
        }
        print('profilePages.length = ${profilePages.length}');
        print('profilePages.isEmpty = ${profilePages.isEmpty}');
        print('profilePagesindex = $profilePagesIndex');
        print(
            'profile name of this index = ${profileNames[profilePagesIndex]}');
        print('profileId of this index = ${profileIds[profilePagesIndex]}');

        print(
            'profilePicUrls[profilePagesIndex] = ${profilePicUrls[profilePagesIndex]}');
        print(
            "profileNames[profilePagesIndex] = ${profileNames[profilePagesIndex]}");
        print(
            "profileIds[profilePagesIndex] = ${profileIds[profilePagesIndex]}");
        print(
            "profileAvailabilities[profilePagesIndex] = ${profileAvailabilities[profilePagesIndex]}");

        print('helooooo');

        return profilePagesIndex < profilePages.length
            ? Stack(
                children: [
                  profilePages[profilePagesIndex],
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: FloatingActionButton(
                      backgroundColor: kPillButtonUnselectedColor,
                      onPressed: () {
                        print('presssed!!');
                        print('profilePagesIndex = $profilePagesIndex');
                        print('profilePages.length = ${profilePages.length}');

                        if (profilePagesIndex < profilePages.length - 1) {
                          setState(() {
                            profilePagesIndex++;
                          });
                        } else {
                          setState(() {
                            profilePagesIndex = 0;
                          });
                        }
                      },
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: kPillButtonSelectedColor,
                        size: 25,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: FloatingActionButton(
                      backgroundColor: kPillButtonUnselectedColor,
                      //Colors.red,
                      onPressed: () async {
                        print('presssed!!');

                        //Popup
                        showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                                    title: const Text('Send a message !'),
                                    content: TextField(
                                      controller: sendMessageController,
                                      maxLines: 10,
                                      minLines: 4,
                                      decoration: InputDecoration(
                                        hintText: 'Type your message here...',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('Back'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      TextButton(
                                        child: Text('Send'),
                                        onPressed: () async {
                                          //Message
                                          final message =
                                              sendMessageController.text.trim();
                                          print(message);

                                          print(profileIds[profilePagesIndex]);
                                          print(profileIds[profilePagesIndex]);
                                          print(currentUser?.picture1);

                                          //Send Notification to the MATCH user
                                          await notificationsRef
                                              .doc(
                                                  profileIds[profilePagesIndex])
                                              .collection('notifications')
                                              .doc(widget.currentUserUid)
                                              .set({
                                                'matchImageUrl':
                                                    currentUser?.picture1,
                                                'message': message,
                                                'name': currentUser?.firstName,
                                                'senderId':
                                                    widget.currentUserUid,
                                                'time': now,
                                                'type': 'match',
                                              })
                                              .then(
                                                  (value) => print('Success!'))
                                              .catchError((onError) => print(
                                                  'There was an error sending notification. $onError'));

                                          //Filter the user out so they dont show up in the find section anymore?
                                          // Maybe not necessary rn.

                                          //Go to Next Profile
                                          if (profilePagesIndex <
                                              profilePages.length - 1) {
                                            setState(() {
                                              profilePagesIndex++;
                                            });
                                          } else {
                                            setState(() {
                                              profilePagesIndex = 0;
                                            });
                                          }

                                          sendMessageController.clear();

                                          Navigator.pop(context);
                                        },
                                      ),
                                    ]));
                      },
                      child: Icon(
                        Icons.chat,

                        color: kPillButtonSelectedColor,
                        //Icons.close,
                        size: 25,
                      ),
                    ),
                  ),
                ],
              )
            : buildNoCurrentMatchesWidget();
      },
    );
  }

  buildSpinnerPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        circularProgress(),
      ],
    );
  }

  @override
  Widget build(context) {
    double paddingValue = MediaQuery.of(context).size.width * .03;

    return dateExists == null
        ? buildSpinnerPage()
        : dateExists == true
            ? buildMatchesProfiles()
            : buildWelcomePage();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
