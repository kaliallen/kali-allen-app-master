///TEST
//TODO: Test to see if you leave a screen on for a long time and the time passes after 5 pm, when you click on the screen does it refresh the time? Right now it does not.

import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/models/date.dart';
import 'package:kaliallendatingapp/models/dateManager.dart';
import 'package:kaliallendatingapp/models/userData.dart';
import 'package:kaliallendatingapp/screens/Home.dart';
import 'package:kaliallendatingapp/screens/ProfilePage.dart';
import 'package:kaliallendatingapp/screens/SubmitFeedback.dart';
import 'package:kaliallendatingapp/widgets/DateButton.dart';
import 'package:kaliallendatingapp/widgets/PillButton.dart';
import 'package:kaliallendatingapp/widgets/StyledButton.dart';
import 'package:kaliallendatingapp/widgets/progress.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../widgets/ActivityPillButton.dart';
import '../widgets/MatrixPillButton.dart';


//TODO: Delete unused package below from pubspec yaml
import 'package:draggable_bottom_sheet/draggable_bottom_sheet.dart';

import 'Home.dart';

final backgroundColor = Colors.black;

//Initstate is used to find if the user has already entered in a time and day to find a date
//if it is, the matches screen appears. If not, it goes to the Find a Date screen


class BrowseScreen extends StatefulWidget {
  final String? currentuid;

  BrowseScreen({this.currentuid});

  @override
  _BrowseScreenState createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  //When initState starts, saveUserInfo function is triggered and currentUser is saved here
  UserData? currentUser; //in use
  bool? dateExists; //in use
  String? dateId;

  Date? currentDate;
  DateManager dateManager = DateManager();
  bool? viewAsBrowseMode;



  List<String?>? availableTimeSlots; //in use
  List<bool> usersAvailability = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];


  String? dateActivity;
  RangeValues currentRangeValues = RangeValues(5, 10);
  bool pageOpen = false;
  bool addActivity = false;
  TextEditingController activityController = TextEditingController();

  bool addDrinks = false;
  bool addDinner = false;
  bool addDinnerActivity = false;
  bool isDinnerSaved = false;


  DateTime now = DateTime.now();

  int profilePagesIndex = 0;






  //Functions in initState

  ///Grab user's data using the widget.currentuid, save it in UserData currentUser
  saveUserInfo() async {
    DocumentSnapshot userDoc = await usersRef.doc(widget.currentuid).get();
    currentUser = UserData.fromDocument(userDoc);
  }



  bool findIfDateAdded()  {
    bool enteredAvailability = false;

      if (enteredAvailability == true) {
        return true;
      } else {
        return false;
      }
  }

  ///If there are current dates, dateExists = true and buildMatchesProile2 populates. If false buildWelcomePage2 populates.
  toggleWelcome2BrowseScreen(){
    //Find if they have submitted their availability
    bool isDateAdded = findIfDateAdded();

    if (isDateAdded == true) {
      setState(() {
        dateExists = true;
      });
    } else if (isDateAdded == false) {
      setState(() {
        dateExists = false;
      });
    } else {
      print('isDateAdded is null...');
    }
  }

  @override
  void initState() {
    saveUserInfo();
    toggleWelcome2BrowseScreen();
    super.initState();
  }

  ///Instigates a popup screen to confirm dates, times, and activities selected by user.
  ///Once confirmed, it sends to Firebase under 'dates' collection.
  ///If datedoc is successfully created, it sends user to browse screen
  sendFindADate() {
    bool _saving = false;
    print('availableTimeSlots: $availableTimeSlots');
    print('usersAvailability: $usersAvailability');

    List selectedTimeSlots = dateManager.createSelectedTimeSlots(
        availableTimeSlots, usersAvailability);

    print(selectedTimeSlots);

    String dateIdNames = dateManager.dateIdToName(selectedTimeSlots);
    print(dateIdNames);

    if (selectedTimeSlots.isNotEmpty) {
      //Finds if dinner, drinks, activities selected and creates text
      String activitiesText = '';
      addDinner
          ? activitiesText = activitiesText + 'Dinner, '
          : print('Dinner not selected');
      addDrinks
          ? activitiesText = activitiesText + 'Drinks, '
          : print('Drinks not selected');
      addActivity
          ? activitiesText =
              activitiesText + 'Custom Activity: ${activityController.text}'
          : print('Activity not selected');

      showDialog(
          context: context,
          builder: (ctx) => ModalProgressHUD(
                inAsyncCall: _saving,
                child: AlertDialog(
                    title: const Text('You are available...'),
                    content: Column(
                      children: [
                        Text('These are all the times you are available: ' +
                                dateIdNames

                            //TODO: Add dinner, drinks, what do you want to do here

                            ),
                        Text('Activities: ' + activitiesText),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Back'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        child: Text('Continue'),
                        onPressed: () async {
                          _saving = true;

                          //Create a new date in firestore
                          if (selectedTimeSlots.length >= 1) {
                            await FirebaseFirestore.instance
                                .collection('dates')
                                .doc(widget.currentuid)
                                .set({
                              'availability': selectedTimeSlots,
                              'gender': currentUser!.gender,
                              'interestedIn': currentUser!.isInterestedIn,
                              'interests': {
                                'drinks': addDrinks,
                                'dinner': addDinner,
                                'activity': addActivity,
                              },
                              'rejects': {
                                'test': false,
                              },
                              'time': Timestamp.fromDate(DateTime.now()),
                              'customMessage': activityController.text.trim(),
                            });

                            //TODO: Check to see if it successfully uploaded
                            bool uploadSuccessful = await findIfDateAdded();
                            print('upload successful? $uploadSuccessful');

                            if (uploadSuccessful == true) {
                              _saving = false;

                              setState(() {
                                dateExists = true;
                              });
                              Navigator.pop(context);
                            } else {
                              print('Upload not successful');
                            }
                          }
                        },
                      ),
                    ]),
              ));
    } else {
      print('You have not selected an available date');

      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                  title: const Text('Select a time to continue!'),
                  content: Text(
                      'Please select an available time and date to continue.'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Back'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ]));
    }
  }



  deleteUser() async {
    final doc = await usersRef.doc('sdlfksdjf').get();
    if (doc.exists) {
      usersRef.doc(widget.currentuid).delete();
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
    usersRef.doc(widget.currentuid).update({
      '${widget.currentuid}': now
    }).then((value)=>print('Availability Updated'))
        .catchError((error)=>print('Failed to update availability: $error'));

    //Update Availability in matches

    //Get list of all the uid of your matches
    List<String> matchesUids = [];
   QuerySnapshot querySnapshot = await matchesRef.doc(widget.currentuid).collection('matches').get();
   for (var doc in querySnapshot.docs){
         matchesUids.add(doc.id);
   }
   print(matchesUids);

   //For each uid in the list, update the doc
    for (String name in matchesUids){
      try {
        await matchesRef.doc(name).collection("matches").doc(widget.currentuid).update({
          '$name': now,
        });
      } catch (e) {
        print('Error updating document for user $name: $e');
      }
    }


   //Update each of your matches to notify them you are available




  }

  noPressed() async {


    //Update Availability in user's profile data
    usersRef.doc(widget.currentuid).update({
      '${widget.currentuid}': null
    }).then((value)=>print('Availability Updated'))
        .catchError((error)=>print('Failed to update availability: $error'));

    //Update Availability in matches

    //Get list of all the uid of your matches
    List<String> matchesUids = [];
    QuerySnapshot querySnapshot = await matchesRef.doc(widget.currentuid).collection('matches').get();
    for (var doc in querySnapshot.docs){
      matchesUids.add(doc.id);
    }
    print(matchesUids);

    //For each uid in the list, update the doc
    for (String name in matchesUids){
      try {
        await matchesRef.doc(name).collection("matches").doc(widget.currentuid).update({
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




  ///This screen is where users input their availability and interested activities to find a date
  //TODO: There is a wierd alignment issue when Tonight is Unavailable
  buildWelcomePage() {

    return Scaffold(
      backgroundColor: Colors.white, //kBrowsePageBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 0, left: 25, right: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(DateFormat('MMMEd').format(now),
                  style: kHeadingText),
              Text('Welcome back! Are you free tonight?',
              style: kHeadingText),
              StyledButton(
                text: 'Yes',
                color: kLimeGreen,
                onTap: yesPressed,
              ),
              StyledButton(
                text: 'No',
                color: kLimeGreen,
                onTap: noPressed,
              ),
              Center(
                child: Text(
                  'Change your answer at any time.'
                ),
              ),
              Row(
                children: [
                  Text('Alert your pool you are available tonight'),
                  TextButton(
                    onPressed: (){},
                    child: Text('Yes'),
                  )
                ],
              ),

              Text('Add a note:'),

              TextField(
                decoration: InputDecoration(
                  hintText: 'Looking to get happy hour...',
                )
              ),
              // StyledButton(
              //   text: 'Enter',
              //   color: kButtonColor,
              //   onTap: sendFindADate,
              // ),
              StyledButton(
                text: 'Done',
                color: kButtonColor,
                onTap: (){
                  //Update profile

                  //Update all my matches to reflect my availability
                },
              )
            ],
          ),
        ),
      ),
    );
  }


  viewReportAnIssue(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => SubmitFeedback()));
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
                child: Text(
                    'There are no users available at this time. '),
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
    Date userDateDoc;

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

        for (var user in users) {
          print('this is the loop triggered for match id ${user.id}');

          final userData = ProfilePage(
            profileId: user.id,
            viewPreferenceInfo: false,
            viewingAsBrowseMode: true,

          );

          profilePages.add(userData);
        }
        print('profilePages.length = ${profilePages.length}');
        print('profilePages.isEmpty = ${profilePages.isEmpty}');
        print('profilePagesindex = ${profilePagesIndex}');

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
                                title: const Text('Send'),
                                content: Text(
                                    'Please select an available time and date to continue.'),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('Back'),
                                    onPressed: () {
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

  // return StreamBuilder<QuerySnapshot>(
  //       //Populate userids of people whos available at your date times.
  //       //TODO: Change datesRef to activeDates ref
  //       //TODO:
  //       stream: datesRef
  //           // .where('interestedIn', isEqualTo: currentUser.gender)
  //           // .where('gender', isEqualTo: currentUser.isInterestedIn)
  //           // .where('uid', isNotEqualTo: currentUser.uid)
  //           // .where('availability', arrayContainsAny: userAvailableDates)
  //           // .orderBy('time', descending: false)
  //           .snapshots(),
  //       builder: (context, snapshot) {
  //         if (!snapshot.hasData) {
  //           return Center(
  //               child: CircularProgressIndicator(
  //             backgroundColor: Colors.lightBlue,
  //           ));
  //         }
  //
  //         final dates = snapshot.data!.docs;
  //
  //         List<ProfilePage> profilePages = [];
  //
  //         for (var date in dates) {
  //           print('this is the loop triggered for match id ${date.id}');
  //
  //           userDateDoc = Date.fromDocument(date);
  //
  //           //if userDateDoc's date.id == currentUser's id, move to next date aka break...?
  //           // if (userDateDoc.uid != widget.profileId) {
  //
  //           //TODO: Jan 9, 2023 - This is where i left off--cant' seem to pick up the currentUID
  //           //I'm trying to hide any profile where this current uid is rejected
  //           print('will this print true...?');
  //           // print(userDateDoc.rejects.entri);
  //
  //           print('the userDateDoc.uid is ${userDateDoc.uid}');
  //           print(userDateDoc.availability);
  //           print('userDateDoc.availability!');
  //
  //           final userData = ProfilePage(
  //             profileId: userDateDoc.uid,
  //             viewPreferenceInfo: false,
  //             viewingAsBrowseMode: true,
  //
  //           );
  //
  //           profilePages.add(userData);
  //         }
  //         print('profilePages.length = ${profilePages.length}');
  //         print('profilePages.isEmpty = ${profilePages.isEmpty}');
  //         //if profilePages list is empty, return Text that says "sorry no matches at this time, check back later
  //         return profilePagesIndex < profilePages.length
  //             ? Stack(
  //                 children: [
  //                   profilePages[profilePagesIndex],
  //                   Positioned(
  //                     bottom: 20,
  //                     right: 20,
  //                     child: FloatingActionButton(
  //                       backgroundColor: kPillButtonUnselectedColor,
  //                       heroTag: 'like',
  //                       onPressed: () async {
  //                         // print('presssed!!');
  //                         // print('profilePagesIndex = $profilePagesIndex');
  //                         // print('profilePages.length = ${profilePages.length}');
  //                         // print('this is the userDateDoc.uid ${userDateDoc.uid}');
  //                         // // print(
  //                         // //     'this is the currentDate.dateId ${currentDate.dateId}');
  //                         // print(
  //                         //     'this is the profilePages[profilePagesIndex].profileId ${profilePages[profilePagesIndex].profileId}');
  //                         // String matchId =
  //                         //     profilePages[profilePagesIndex].profileId;
  //                         // //Add to the profile map of user, the profile ID of the liked user with a TRUE bool
  //                         // final doc = await datesRef
  //                         //     .doc(currentDate.dateId)
  //                         //     .collection('users')
  //                         //     .doc(userDateDoc.uid)
  //                         //     .get();
  //                         // print(doc.data()['endTime']);
  //                         // //This adds the profile page to the matches map of the user's date doc
  //                         // doc.reference.update({
  //                         //   'matches.${profilePages[profilePagesIndex].profileId}':
  //                         //   true
  //                         // });
  //                         //
  //                         // //If match on both sides, create a notification for the other user
  //                         //
  //                         // //This grabs the match's match map
  //                         // final matchDoc = await datesRef
  //                         //     .doc(currentDate.dateId)
  //                         //     .collection('users')
  //                         //     .doc(matchId)
  //                         //     .get();
  //                         // //This is the match's match true or false of the current user
  //                         // if (matchDoc.data()['matches'][userDateDoc.uid] ==
  //                         //     true) {
  //                         //   //TODO: Create a notification for the other user --OR-- (Shifali)
  //                         //   print('User has a  ');
  //                         //   //TODO: Automatically starts a chat and temporarily hides them from the feed
  //                         //
  //                         //   //Notify user they are a match
  //                         //   //TODO: Add notification
  //                         //
  //                         //   //Check that a message Id doesn't already exist for the two users
  //                         //   final snapShot = await matchesRef
  //                         //       .doc(widget.profileId)
  //                         //       .collection('matches')
  //                         //       .doc(userDateDoc.uid)
  //                         //       .get();
  //                         //   print(
  //                         //       'Has a match already been created? ${snapShot.exists}');
  //                         //
  //                         //   if (!snapShot.exists) {
  //                         //     //Create a messages doc for both users & saved docRef Id
  //                         //     DocumentReference docRef = await messagesRef
  //                         //         .add({'dateTime': currentDate.startTime});
  //                         //     print('Messages Id is ${docRef.id}');
  //                         //
  //                         //     //Create a new messages collection & automated first message
  //                         //     messagesRef
  //                         //         .doc(docRef.id)
  //                         //         .collection('messages')
  //                         //         .add({
  //                         //       'message':
  //                         //       '${'Want to go on a date? This user has replied to your match request! (SHIFALI)'}',
  //                         //       'sender': widget.profileId,
  //                         //       'time': Timestamp.now(),
  //                         //     });
  //                         //
  //                         //     //Add to chat on user's side
  //                         //     setMatchInFirestore(
  //                         //       matchId: matchId,
  //                         //       messagesId: docRef.id,
  //                         //       lastMessage: 'New Match!',
  //                         //     );
  //                         //
  //                         //     //Add to chat on match's side
  //                         //     setMatchInFirestore(
  //                         //         matchId: widget.profileId,
  //                         //         messagesId: docRef.id,
  //                         //         lastMessage: 'New Match!');
  //                         //
  //                         //     //Make their Date Snapshot inactive
  //                         //     final dateDoc = await datesRef
  //                         //         .doc(dateId)
  //                         //         .collection('users')
  //                         //         .doc(widget.profileId)
  //                         //         .get();
  //                         //     if (doc.exists) {
  //                         //       doc.reference.update({'active': false});
  //                         //     }
  //                         //   } else {
  //                         //     //If a chat already exists, make it active?
  //                         //   }
  //                         // }
  //
  //                         //Go to the next profile
  //                         // if (profilePagesIndex <= profilePages.length - 1) {
  //                         //   setState(() {
  //                         //     profilePagesIndex++;
  //                         //   });
  //                         // } else {
  //                         //   print('no more matches');
  //                         // }
  //                       },
  //                       child: Icon(
  //                         Icons.arrow_forward_ios_rounded,
  //                         color: kPillButtonSelectedColor,
  //                         // Icons.favorite,
  //                         size: 25,
  //                       ),
  //                     ),
  //                   ),
  //                   Positioned(
  //                     bottom: 20,
  //                     left: 20,
  //                     child: FloatingActionButton(
  //                       backgroundColor: kPillButtonUnselectedColor,
  //                       //Colors.red,
  //                       heroTag: 'close',
  //                       onPressed: () {
  //                         print('presssed!!');
  //                         print('profilePagesIndex = $profilePagesIndex');
  //                         print('profilePages.length = ${profilePages.length}');
  //                         if (profilePagesIndex <= profilePages.length - 1) {
  //                           setState(() {
  //                             profilePagesIndex++;
  //                           });
  //                         } else {
  //                           print('no more matches');
  //                         }
  //                       },
  //                       child: Icon(
  //                         Icons.chat,
  //
  //                         color: kPillButtonSelectedColor,
  //                         //Icons.close,
  //                         size: 25,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               )
  //             : buildNoCurrentMatchesWidget();
  //       },
  //     );

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
    return dateExists == null
        ? buildSpinnerPage()
        : dateExists == true
            ? buildMatchesProfiles()
            : buildWelcomePage();
  }

}




