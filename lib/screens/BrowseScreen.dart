import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/models/date.dart';
import 'package:kaliallendatingapp/models/dateManager.dart';
import 'package:kaliallendatingapp/models/matches.dart';
import 'package:kaliallendatingapp/models/userData.dart';
import 'package:kaliallendatingapp/screens/Home.dart';
import 'package:kaliallendatingapp/screens/Home.dart';
import 'package:kaliallendatingapp/screens/PickDateTime.dart';
import 'package:kaliallendatingapp/screens/ProfilePage.dart';
import 'package:kaliallendatingapp/widgets/DateButton.dart';
import 'package:kaliallendatingapp/widgets/PillButton.dart';
import 'package:kaliallendatingapp/widgets/StyledButton.dart';
import 'package:kaliallendatingapp/widgets/progress.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import "Home.dart";

//TODO: Delete unused package below from pubspec yaml
import 'package:draggable_bottom_sheet/draggable_bottom_sheet.dart';

import 'Home.dart';

final backgroundColor = Colors.black;

//Initstate is used to find if the user has already entered in a time and day to find a date
//if it is, the matches screen appears. If not, it goes to the Find a Date screen

class BrowseScreen extends StatefulWidget {
  final String currentuid;

  BrowseScreen({this.currentuid});

  @override
  _BrowseScreenState createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  //When initState starts, saveUserInfo function is triggered and currentUser is saved here
  UserData currentUser; //in use
  bool dateExists; //in use
  String dateId;


  Date currentDate;
  DateManager dateManager = DateManager();
  bool viewAsBrowseMode;

  DateDay selectedDay = DateDay.Today;
  String selectedText = '';
  String tonightText = '';
  String tomorrowText = '';
  String thirdDayText = '';
  String fourthDayText = '';

  List<String> userAvailableDates; //in use
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

  bool isAvailableTonight = false;
  bool isAvailableTomorrow = false;
  bool isAvailableThirdDay = false;
  bool isAvailableFourthDay = false;

  bool toggle46 = false;
  bool toggle68 = false;
  bool toggle810 = false;

  String dateActivity;
  RangeValues currentRangeValues = RangeValues(5, 10);
  bool pageOpen = false;
  bool addActivity = false;
  bool addMessage = false;
  bool addDrinks = false;
  bool addDinner = false;
  bool addAdventure = false;
  bool friendsSelected = false;
  bool splitBillSelected = false;
  TextEditingController activityController = TextEditingController();
  bool activitySelected = false;
  DateTime now = DateTime.now();
  int startTime;
  int endTime;
  BorderRadiusGeometry radius = BorderRadius.only(
    topLeft: Radius.circular(30.0),
    topRight: Radius.circular(30.0),
  );
  PanelController panelController = PanelController();
  int profilePagesIndex = 0;
  FixedExtentScrollController endTimeController;
  FixedExtentScrollController startTimeController;
  final startTimeIndex = 0;
  final endTimeIndex = 5;

  bool hide46;
  bool hide68;
  bool hide810;


  //Functions in initState

  ///Grab user's data using the widget.currentuid, save it in UserData currentUser
  saveUserInfo() async {
    DocumentSnapshot userDoc = await usersRef.doc(widget.currentuid).get();
    currentUser = UserData.fromDocument(userDoc);
  }

  ///Identifies the time now and creates the text for Tonight, Tomorrow, ThirdDay, and FourthDay.
  ///Also populates List userAvailableDates which identifies all the times slots available for user to choose from.
  dateCreator() {

    setState(() {
      tonightText = '${DateFormat.MEd().format(now)}';
      tomorrowText = '${DateFormat.MEd().format(now.add(Duration(days: 1)))}';
      thirdDayText = '${DateFormat.MEd().format(now.add(Duration(days: 2)))}';
      fourthDayText = '${DateFormat.MEd().format(now.add(Duration(days: 3)))}';
      selectedText = tonightText;
      userAvailableDates = dateManager.identifyActiveDateTimes(now);
      print(userAvailableDates);
    });
  }

  ///Takes what time it is now, and if the time now is later than the available times for tonight, it hides them.
  hideUnavailableTimes(){
    int hourNow = int.parse('${DateFormat.H().format(now)}');

    //If time is earlier than 3pm
    if (hourNow < 15) {
      hide46 = false;
      hide68 = false;
      hide810 = false;

      //If time is between 3pm and 5pm
    } else if (hourNow > 15 && hourNow < 18){
      hide46 = true;
      hide68 = false;
      hide810 = false;

      //if time is earlier than 7pm,
    } else if (hourNow < 19) {
      hide46 = true;
      hide68 = true;
      hide810 = false;

    } else if (hourNow > 20) {
      //TODO: hide all times and show tonight as "unavailable".
      hide46 = true;
      hide68 = true;
      hide810 = true;
    } else {
      hide46 = false;
      hide68 = false;
      hide810 = false;
    }

  print('hide46 = $hide46');
    print('hide68 = $hide68');
    print('hide810 = $hide810');

  }

  ///Find if the user has already entered availability.
  ///Grab the list of current dates from Firebase.
  ///If it exists, check to see which dates are current.
  Future<bool> findIfDateAdded() async {

    //Does the user have any ACTIVE availability?

    //Grab list of current dates
    List currentActiveDateIDs = createActiveDateIDs();
    List userDateIDs = [];

    //Grab list of current dates user has submitted
    DocumentSnapshot dateDoc =
    await datesRef.doc(widget.currentuid).get();
    print('dateDoc exists? ${dateDoc.exists}');
    if (dateDoc.exists) {
      currentDate = Date.fromDocument(dateDoc);


      //If dateDoc does exist, check to see if it's dates are current
      List currentActiveDates = anyCurrentActiveDates(currentDate.availability);

      print('currentActiveDates is $currentActiveDates');

      if (currentActiveDates != null) {
        return true;
      } else {
        return false;
      }
    } else {
      print('dateDoc does not exist');
      return false;
    }
    
  }

  ///If there are current dates, dateExists = true and buildMatchesProile2 populates. If false buildWelcomePage2 populates.
  toggleWelcome2BrowseScreen() async {

    //Find if they have submitted their availability
    bool isDateAdded = await findIfDateAdded();

    if (isDateAdded == true){
      setState(() {
        dateExists = true;
      });
    } else if (isDateAdded == false){
      setState(() {
        dateExists = false;
      });
    } else {
      print('isDateAdded is null...');
    }
  }

  List createActiveDateIDs() {
    int hourNow = int.parse('${DateFormat.H().format(now)}');
    print('The hour now is $hourNow');

    print(
        'Todays date is: ${DateFormat.yMd().format(now).replaceAll(RegExp('[^A-Za-z0-9]'), '')}');
    print('${DateFormat.MEd().format(now.add(Duration(days: 1)))}');
    List<String> activeDates = [];

    //If time is earlier than 3pm
    if (hourNow < 15) {
      //Add all 3 times
      activeDates.add(
        DateFormat.yMd().format(now).replaceAll(RegExp('[^A-Za-z0-9]'), '') +
            '46',
      );
      activeDates.add(
        DateFormat.yMd().format(now).replaceAll(RegExp('[^A-Za-z0-9]'), '') +
            '68',
      );
      activeDates.add(
        DateFormat.yMd().format(now).replaceAll(RegExp('[^A-Za-z0-9]'), '') +
            '810',
      );

      //if time is earlier than 5pm,
    } else if (hourNow < 17) {
      //Add 6-8 and 8-10 only
      activeDates.add(
          DateFormat.yMd().format(now).replaceAll(RegExp('[^A-Za-z0-9]'), '') +
              '68');
      activeDates.add(
        DateFormat.yMd().format(now).replaceAll(RegExp('[^A-Za-z0-9]'), '') +
            '810',
      );

      //if time is earlier than 7pm,
    } else if (hourNow < 19) {
      //Add 8-10 only
      activeDates.add(
        DateFormat.yMd().format(now).replaceAll(RegExp('[^A-Za-z0-9]'), '') +
            '810',
      );

    }

    activeDates.add(DateFormat.yMd()
        .format(now.add(Duration(days: 1)))
        .replaceAll(RegExp('[^A-Za-z0-9]'), '') +
        '46');
    activeDates.add(DateFormat.yMd()
        .format(now.add(Duration(days: 1)))
        .replaceAll(RegExp('[^A-Za-z0-9]'), '') +
        '68');
    activeDates.add(DateFormat.yMd()
        .format(now.add(Duration(days: 1)))
        .replaceAll(RegExp('[^A-Za-z0-9]'), '') +
        '810');
    activeDates.add(DateFormat.yMd()
        .format(now.add(Duration(days: 2)))
        .replaceAll(RegExp('[^A-Za-z0-9]'), '') +
        '46');
    activeDates.add(DateFormat.yMd()
        .format(now.add(Duration(days: 2)))
        .replaceAll(RegExp('[^A-Za-z0-9]'), '') +
        '68');
    activeDates.add(DateFormat.yMd()
        .format(now.add(Duration(days: 2)))
        .replaceAll(RegExp('[^A-Za-z0-9]'), '') +
        '810');
    activeDates.add(DateFormat.yMd()
        .format(now.add(Duration(days: 3)))
        .replaceAll(RegExp('[^A-Za-z0-9]'), '') +
        '46');
    activeDates.add(DateFormat.yMd()
        .format(now.add(Duration(days: 3)))
        .replaceAll(RegExp('[^A-Za-z0-9]'), '') +
        '68');
    activeDates.add(DateFormat.yMd()
        .format(now.add(Duration(days: 3)))
        .replaceAll(RegExp('[^A-Za-z0-9]'), '') +
        '810');

    print(activeDates);
    return activeDates;
  }

  @override
  void initState() {
    saveUserInfo();
    dateCreator();
    hideUnavailableTimes();
    toggleWelcome2BrowseScreen();
    super.initState();

    //TODO: Tis where you left off.
    endTimeController = FixedExtentScrollController(initialItem: endTimeIndex);

    startTimeController =
        FixedExtentScrollController(initialItem: startTimeIndex);
  }







  // findIfDateAdded() async {
  //   //1) Runs through dates collection,going through each day listed (snapshot) and seeing if the user's id exists in each of them. If a date exists in any of them, it will change dateExists to true AND grabs the date info and puts it into currentDate.
  //   await datesRef.snapshots().forEach((snapshot) {
  //     for (var date in snapshot.docs) {
  //       print(date.id);
  //       var doc = datesRef
  //           .doc(date.id)
  //           .collection('users')
  //           .doc(widget.profileId)
  //           .get()
  //           .then((snapshot) {
  //         print('For ${date.id} does doc exist? ${snapshot.exists}');
  //         print(
  //             'Is the date active? (i.e. the user has not matched with anyone for that date yet) ${snapshot.get('active')}');
  //         if (snapshot.exists && snapshot.get('active')) {
  //           setState(() {
  //             dateExists = true;
  //             dateId = date.id;
  //           });
  //           print('dateExists = ${dateExists}');
  //
  //           //Grabbing the Date Info and Putting into Date currentDate for the rest of the screen
  //           currentDate = Date.fromDocument(snapshot);
  //           print("currentDate.dateId = ${currentDate.dateId}");
  //           currentDate.dateId = date.id;
  //           print('currentDate.dateId = ${currentDate.dateId}');
  //         }
  //       });
  //     }
  //     print('loop is finished.');
  //     if (dateExists != true) {
  //       setState(() {
  //         dateExists = false;
  //       });
  //       print('date does not exists. Set to false.');
  //     }
  //   });
  // }

  List anyCurrentActiveDates(List activeDates) {
    List currentActiveDatesIDs = createActiveDateIDs();

    //Create a new list of userActiveDates
    List userActiveDatesIDs = [];

    for (String date in currentActiveDatesIDs) {
      if ((activeDates).contains(date) == true) {
        userActiveDatesIDs.add(date);
      }
    }

    print(userActiveDatesIDs);

    return userActiveDatesIDs;
  }



  getMatchesById() async {
    List<Matches> myMatches = [];
    print('is this thing on');
    final matches = await matchesRef
        .doc(widget.currentuid)
        .collection('matches')
        .snapshots()
        .forEach((snapshot) async {
      for (var match in snapshot.docs) {
        print('this is the loop triggered for match id ${match.id}');
        print(match['isActive']);

        //Get Match's User Data
        final doc = await usersRef.doc(match.id).get();
        print(doc.exists);
        UserData _match = UserData.fromDocument(doc);

        //Get Match's match info/Save Everything to match list
        Matches _newMatch = Matches(
          matchId: match.id,
          messagesId: match['messagesID'],
          activeMatch: match['isActive'],
        );
        myMatches.add(_newMatch);
      }
    });
  }

  submitDateDoc() {
    //Does a date doc already exist for this user? If so, edit the date doc:

    //else

    //Create a new datedoc
  }

  createDateDoc() {
    //TODO: Left off testing this part. I think i may need to add setstate back. IDK.
    //Create Doc for Date Selected

    DateTime selectedDateTime;
    String selectedDate;
    if (selectedDay == DateDay.Today) {
      selectedDate = DateFormat.yMMMEd().format(now).toString();
      print(selectedDate);
      //TODO: Conver this format, whatever it is, to DateTime.
    } else if (selectedDay == DateDay.Tomorrow) {
      selectedDate =
          DateFormat.yMMMEd().format(now.add(Duration(days: 1))).toString();
      print(selectedDate);
    } else if (selectedDay == DateDay.ThirdDay) {
      selectedDate =
          DateFormat.yMMMEd().format(now.add(Duration(days: 2))).toString();
      print(selectedDate);
    } else {
      print('error');
    }

    //Create Map for Preference Data
    Map<String, bool> preferences = {
      'drinksSelected': addDinner,
      'friendsSelected': friendsSelected,
      'splitBillSelected': splitBillSelected,
    };

    //Must create the document and collection before you can set data.
    datesRef.doc(selectedDate).set({
      'exampleData': null,
    });

    //Set Data to Dates Collection
    datesRef.doc(selectedDate).collection('users').doc(widget.currentuid).set({
      'uid': widget.currentuid,
      'startTime': currentRangeValues.start.toInt(),
      'endTime': currentRangeValues.end.toInt(),
      'matches': null,
      'activityText': dateActivity,
      'preferences': preferences,
      'active': true,
    });
  }

  // Future<void> availabilityConfirmation() async {
  //
  //   return showDialog(
  //       context: context,
  //       builder: (BuildContext context){
  //         return AlertDialog(
  //           title: Text('Your Availability'),
  //           content: SingleChildScrollView(
  //             child: ListBody(
  //               children: [
  //                 Text('The following are the times you are available for a date: [...]'),
  //                 SizedBox(height: 10),
  //
  //               ],
  //             ),
  //           ),
  //           actions: [
  //             CupertinoDialogAction(child: Text('Submit')),
  //             CupertinoDialogAction(
  //               child: Text('Back'),
  //               onPressed: (){
  //                 Navigator.pop(context);
  //               },
  //             )
  //           ],
  //         );
  //       });
  // }

  ///Instigates a popup screen to confirm dates, times, and activities selected by user.
  ///Once confirmed, it sends to Firebase under 'dates' collection.
  ///If datedoc is successfully created, it sends user to browse screen
  sendFindADate() {

    bool _saving = false;

    List usersAvailabilityDateCodes = dateManager.userAvailabilityDateCodes(userAvailableDates, usersAvailability);
    String dateIdNames = dateManager.dateIdToName(usersAvailabilityDateCodes);

    print(usersAvailabilityDateCodes);

    if (usersAvailabilityDateCodes.isNotEmpty) {
      //Finds if dinner, drinks, activities selected and creates text
      String activitiesText = '';
      addDinner ? activitiesText = activitiesText + 'Dinner, ' : print(
          'Dinner not selected');
      addDrinks ? activitiesText = activitiesText + 'Drinks, ' : print(
          'Drinks not selected');
      addMessage ? activitiesText = activitiesText + 'Custom Activity: ${activityController.text}' : print('Activity not selected');


      showDialog(
          context: context,
          builder: (ctx) =>
              ModalProgressHUD(
                inAsyncCall: _saving,
                child: AlertDialog(
                    title: const Text('You are available...'),
                    content:
                    Column(
                      children: [
                        Text('These are all the times you are available: ' + dateIdNames

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
                          if (usersAvailabilityDateCodes.length >= 1) {
                            await FirebaseFirestore.instance.collection('dates')
                                .doc(widget.currentuid)
                                .set({
                              'availability': usersAvailabilityDateCodes,
                              'gender': currentUser.gender,
                              'interestedIn': currentUser.isInterestedIn,
                              'interests': {
                                'drinks': addDrinks,
                                'dinner': addDinner,
                                'activity': addMessage,
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

                            if (uploadSuccessful == true){
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
                    ]
                ),
              )
      );
    } else {
      print('You have not selected an available date');

      showDialog(
          context: context,
          builder: (ctx) =>
              AlertDialog(
                  title: const Text('Select a date to continue!'),
                  content:
                  Text('Please select an available time and date to continue.'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Back'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ]
              )
      );

    }
  }

  deleteDateDoc() async {
    //Check if doc exists
    //Delete the doc
    print(dateId);
    final doc = await datesRef.doc('Wed, Aug 17, 2022').get();
    if (doc.exists) {
      usersRef.doc(widget.currentuid).delete();
    }
  }

  getUserNameAndPicById() async {}

  createUser() {
    usersRef
        .doc('id234098')
        .set({'firstname': 'Annemarie', 'lastName': 'Allen'});
  }

  updateUser() async {
    final doc = await usersRef.doc('sdlfksdjf').get();
    if (doc.exists) {
      doc.reference.update({'firstname': 'Annemarie', 'lastName': 'Allen'});
    }
  }

  // addUserToMatchMap() async {
  //   final doc = await datesRef.doc(widget.profileId).get();
  //   if (doc.exists){
  //     doc.reference.update({'matches'.});
  //   }
  // }

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

  ///This screen is where users input their availability and interested activities to find a date
  //TODO: There is a wierd alignment issue when Tonight is Unavailable
  buildWelcomePage2() {
    return Scaffold(
      backgroundColor: kBrowsePageBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            reverse: true,
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StyledButton(
                text: 'Find a Date',
                color: kButtonColor,
                onTap: (){
                  print(currentDate.availability);
                }
                //sendFindADate,
              ),
              SizedBox(height: 40),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding:
                            EdgeInsets.only(left: 0, top: 30.0, bottom: 10),
                        child: Text("Are you free tonight?",
                            style: TextStyle(
                                fontSize: 30.0,
                                color: kDarkest,
                                fontWeight: FontWeight.w500)),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: 5, left: 5, top: 5),
                        child: Text(
                          'Select your availability.',
                          style: TextStyle(
                              fontSize: 20.0,
                              color: kDarkest,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      Padding(
                        padding:
                        const EdgeInsets.only(bottom: 5, left: 5, top: 15),
                        child: Text('Date'),
                      ),
                      // Padding(
                      //   padding:
                      //   const EdgeInsets.only(bottom: 5, top: 5),
                      //   child: buildIconAndText(text:'Date', icon: Icons.calendar_month),
                      // ),
                      SizedBox(height: 5),
                      buildDateButtonsRow(),
                      Padding(
                        padding:
                        const EdgeInsets.only(bottom: 5, left: 5, top: 15),
                        child: Text('Time'),
                      ),
                      hide810
                          ? Center(child: Padding(
                            padding: const EdgeInsets.all(25.0),
                            child: Text('Tonight unavailable'),
                          ))
                          : Wrap(
                              children: [
                                hide46
                                    ? SizedBox(width: 0)
                                    : DateButton(
                                        text: '4 - 6 PM',
                                        text2: selectedText,
                                        color: toggle46
                                            ? kButtonColor
                                            : Colors.white,
                                        fontColor: toggle46
                                            ? kWhiteSquareColor
                                            : kLightDark,
                                        border: toggle46
                                            ? null
                                            : Border.all(
                                                width: 1, color: kLightDark),
                                        onTap: () {
                                          setState(() {
                                            //find out what day is selected, then add true to that day/time
                                            print(selectedDay);
                                            if (selectedDay == DateDay.Today) {
                                              if (usersAvailability[0] == true) {
                                                usersAvailability[0] = false;
                                                toggle46 = false;

                                              } else {
                                                usersAvailability[0] = true;
                                                toggle46 = true;

                                              }
                                            } else if (selectedDay ==
                                                DateDay.Tomorrow) {
                                              if (usersAvailability[3] == true) {
                                                usersAvailability[3] = false;
                                                toggle46 = false;

                                              } else {
                                                usersAvailability[3] = true;
                                                toggle46 = true;

                                              }
                                            } else if (selectedDay ==
                                                DateDay.ThirdDay) {
                                              if (usersAvailability[6] == true) {
                                                usersAvailability[6] = false;
                                                toggle46 = false;

                                              } else {
                                                usersAvailability[6] = true;
                                                toggle46 = true;

                                              }
                                            } else if (selectedDay ==
                                                DateDay.FourthDay) {
                                              if (usersAvailability[9] == true) {
                                                usersAvailability[9] = false;
                                                toggle46 = false;

                                              } else {
                                                usersAvailability[9] = true;
                                                toggle46 = true;

                                              }
                                            }
                                          });
                                        }),
                                hide68
                                    ? SizedBox(width: 0)
                                    : DateButton(
                                        text: '6 - 8 PM',
                                        text2: selectedText,
                                        color: toggle68
                                            ? kButtonColor
                                            : Colors.white,
                                        fontColor: toggle68
                                            ? Colors.white
                                            : kLightDark,
                                        border: toggle68
                                            ? null
                                            : Border.all(
                                                width: 1, color: kLightDark),
                                        onTap: () {
                                          setState(() {
                                            //find out what day is selected, then add true to that day/time
                                            print(selectedDay);
                                            if (selectedDay == DateDay.Today) {
                                              if (usersAvailability[1] == true) {
                                                usersAvailability[1] = false;
                                                toggle68 = false;

                                              } else {
                                                usersAvailability[1] = true;
                                                toggle68 = true;

                                              }
                                            } else if (selectedDay ==
                                                DateDay.Tomorrow) {
                                              if (usersAvailability[4] == true) {
                                                usersAvailability[4] = false;
                                                toggle68 = false;

                                              } else {
                                                usersAvailability[4] = true;
                                                toggle68 = true;

                                              }
                                            } else if (selectedDay ==
                                                DateDay.ThirdDay) {
                                              if (usersAvailability[7] == true) {
                                                usersAvailability[7] = false;
                                                toggle68 = false;

                                              } else {
                                                usersAvailability[7] = true;
                                                toggle68 = true;

                                              }
                                            } else if (selectedDay ==
                                                DateDay.FourthDay) {
                                              if (usersAvailability[10] == true) {
                                                usersAvailability[10] = false;
                                                toggle68 = false;

                                              } else {
                                                usersAvailability[10] = true;
                                                toggle68 = true;

                                              }
                                            }
                                          });
                                        },
                                      ),
                                DateButton(
                                  text: '8 - 10',
                                  text2: selectedText,
                                  color:
                                      toggle810 ? kButtonColor : Colors.white,
                                  fontColor:
                                      toggle810 ? Colors.white : kLightDark,
                                  border: toggle810
                                      ? null
                                      : Border.all(width: 1, color: kLightDark),
                                  onTap: () {
                                    setState(() {
                                      //TODO: toggle on and off, depending on what date is chosen
                                      //find out what day is selected, then add true to that day/time
                                      print(selectedDay);
                                      if (selectedDay == DateDay.Today) {
                                        if (usersAvailability[2] == true) {
                                          usersAvailability[2] = false;
                                          toggle810 = false;

                                        } else {
                                          usersAvailability[2] = true;
                                          toggle810 = true;

                                        }
                                      } else if (selectedDay ==
                                          DateDay.Tomorrow) {
                                        if (usersAvailability[5] == true) {
                                          usersAvailability[5] = false;
                                          toggle810 = false;

                                        } else {
                                          usersAvailability[5] = true;
                                          toggle810 = true;

                                        }
                                      } else if (selectedDay ==
                                          DateDay.ThirdDay) {
                                        if (usersAvailability[8] == true) {
                                          usersAvailability[8] = false;
                                          toggle810 = false;

                                        } else {
                                          usersAvailability[8] = true;
                                          toggle810 = true;

                                        }
                                      } else if (selectedDay ==
                                          DateDay.FourthDay) {
                                        if (usersAvailability[11] == true) {
                                          usersAvailability[11] = false;
                                          toggle810 = false;

                                        } else {
                                          usersAvailability[11] = true;
                                          toggle810 = true;

                                        }
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                      SizedBox(height: 10),
                      // Padding(
                      //   padding: const EdgeInsets.only(
                      //       bottom: 15, left: 5, top: 15),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Text(
                      //         'My Dating Preferences',
                      //         style: TextStyle(
                      //             fontSize: 18.0,
                      //             color: kDarkest,
                      //             fontWeight: FontWeight.w600),
                      //       ),
                      //       // Text(
                      //       //   'Edit',
                      //       //   style: TextStyle(
                      //       //       fontSize: 15.0,
                      //       //       color: kDarkest,
                      //       //       fontWeight: FontWeight.w600),
                      //       // ),
                      //     ],
                      //   ),
                      // ),

                      Text(
                        'Include an activity',
                        style: TextStyle(
                            fontSize: 15.0, fontWeight: FontWeight.w400),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          children: [
                            PillButton(
                                text: 'Dinner',
                                isSelected: addDinner,
                                onTap: () {
                                  setState(() {
                                    addDinner == true
                                        ? addDinner = false
                                        : addDinner = true;
                                  });
                                }),
                            PillButton(
                                text: 'Drinks',
                                isSelected: addDrinks,
                                onTap: () {
                                  setState(() {
                                    addDrinks == true
                                        ? addDrinks = false
                                        : addDrinks = true;
                                  });
                                }),
                            // PillButton(
                            //     text: 'Adventure',
                            //     isSelected: addAdventure,
                            //     onTap: () {
                            //       setState(() {
                            //         addAdventure == true
                            //             ? addAdventure = false
                            //             : addAdventure = true;
                            //       });
                            //     }),
                            PillButton(
                                text: 'What do you want to do?',
                                isSelected: addMessage,
                                onTap: () {
                                  setState(() {
                                    addMessage == true
                                        ? addMessage = false
                                        : addMessage = true;
                                  });
                                }),
                          ],
                        ),
                      ),

                      //TODO: Find out why column shifts to the right when addMessage is clicked
                      addMessage
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 10.0, bottom: 0),
                              child: TextField(
                                controller: activityController,
                                decoration: InputDecoration(
                                  hintText: '\"Comedy show\"',
                                  hintStyle: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: kLightDark,
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(height: 0),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // buildWelcomePage() {
  //   return Scaffold(
  //     backgroundColor: kBrowsePageBackgroundColor,
  //     body: SafeArea(
  //       child: SlidingUpPanel(
  //         slideDirection: SlideDirection.UP,
  //         color: kBrowsePageSlidingUpPanelColor,
  //         borderRadius: radius,
  //         controller: panelController,
  //         //minHeight: addMessage ? 350.0 : 280.0,
  //         // maxHeight: addMessage
  //         //     ? addActivity
  //         //         ? 430
  //         //         : 330
  //         //     : addActivity
  //         //         ? 400
  //         //         : 390.0,
  //         // minHeight: addMessage
  //         //     ? addActivity
  //         //         ? 430
  //         //         : 340
  //         //     : addActivity
  //         //         ? 400
  //         //         : 390.0,
  //         panel: Center(
  //           child: buildDateTimePage(),
  //         ),
  //         body: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             // MaterialBanner(
  //             //   content: Text('You are currently not searching for dates'),
  //             //   actions: [
  //             //     Switch(
  //             //       value: false,
  //             //     ),
  //             //Text('Edit'),
  //             // Text('Close'),
  //             // Row(
  //             //   mainAxisAlignment: MainAxisAlignment.end,
  //             //   children: [
  //             //     Container(
  //             //       padding: EdgeInsets.all(5),
  //             //       child: Icon(
  //             //         Icons.view_headline,
  //             //         size: 30.0,
  //             //         color: kLightDark,
  //             //       ),
  //             //       decoration: BoxDecoration(
  //             //         color: kBrowsePageSlidingUpPanelColor,
  //             //         borderRadius: BorderRadius.circular(10),
  //             //         boxShadow: [
  //             //           BoxShadow(
  //             //             color: Colors.grey.withOpacity(0.5),
  //             //             spreadRadius: 3,
  //             //             blurRadius: 7,
  //             //             offset: Offset(0, 2), // changes position of shadow
  //             //           ),
  //             //         ],
  //             //       ),
  //             //     ),
  //             //   ],
  //             // ),
  //             ///Old background
  //             // Padding(
  //             //   padding: addMessage
  //             //       ? const EdgeInsets.only(top: 5.0)
  //             //       : const EdgeInsets.only(top: 40),
  //             //   child: Column(
  //             //     mainAxisAlignment: MainAxisAlignment.start,
  //             //     crossAxisAlignment: CrossAxisAlignment.center,
  //             //     children: [
  //             //       Text(
  //             //         selectedDay == DateDay.Today
  //             //             ? 'Tonight'
  //             //             : selectedDay == DateDay.Tomorrow
  //             //                 ? 'Tomorrow night'
  //             //                 : '${DateFormat.EEEE().format(now.add(Duration(days: 2)))}',
  //             //         style: kTimeDateTextStyle,
  //             //       ),
  //             //       Text(
  //             //         selectedDay == DateDay.Today
  //             //             ? '${DateFormat.MEd().format(now)}'
  //             //             : selectedDay == DateDay.Tomorrow
  //             //                 ? '${DateFormat.MEd().format(now.add(Duration(days: 1)))}'
  //             //                 : '${DateFormat.MEd().format(now.add(Duration(days: 2)))}',
  //             //         style: kTimeDateTextStyle,
  //             //       ),
  //             //       Text(
  //             //         '',
  //             //         // startTimeController == null ? '${startTimeController.initialItem}' : '${startTimeController.selectedItem}',
  //             //         style: kTimeDateTextStyle,
  //             //       ),
  //             //       addMessage ? Text(activityController.text) : Container(),
  //             //     ],
  //             //   ),
  //             // ),
  //             ///New background
  //             SizedBox(height: 50),
  //             Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 20.0),
  //               child: Text(
  //                 'Welcome back,',
  //                 style: TextStyle(
  //                   fontSize: 30.0,
  //                 ),
  //               ),
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 20.0),
  //               child: Text(
  //                 'Poo!',
  //                 style: TextStyle(
  //                   fontSize: 30.0,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // buildProfileHeader() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.stretch,
  //     children: [
  //       Container(
  //         height: 200.0,
  //         padding: EdgeInsets.all(15.0),
  //         color: kScaffoldBackgroundColor,
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Text(
  //               selectedDay == DateDay.Today
  //                   ? 'Tonight'
  //                   : selectedDay == DateDay.Tomorrow
  //                       ? 'Tomorrow night'
  //                       : '${DateFormat.EEEE().format(now.add(Duration(days: 2)))}',
  //               style: TextStyle(
  //                 fontSize: 18.0,
  //                 fontWeight: FontWeight.w800,
  //               ),
  //             ),
  //             Text(
  //               selectedDay == DateDay.Today
  //                   ? '${DateFormat.MEd().format(now)}'
  //                   : selectedDay == DateDay.Tomorrow
  //                       ? '${DateFormat.MEd().format(now.add(Duration(days: 1)))}'
  //                       : '${DateFormat.MEd().format(now.add(Duration(days: 2)))}',
  //               style: TextStyle(
  //                 fontSize: 18.0,
  //                 fontWeight: FontWeight.w800,
  //               ),
  //             ),
  //             Text(
  //               '${currentRangeValues.start.round()}-${currentRangeValues.end.round()} pm',
  //               style: TextStyle(
  //                 fontSize: 18.0,
  //                 fontWeight: FontWeight.w800,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  buildIconAndText({String text, IconData icon}) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            color: kDark,
            //kDateTimeIconTextColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            bottom: 8.0,
            top: 8.0,
          ),
          child: Text(
            text,
            // style: kDateTimeIconTextStyle,
          ),
        ),
      ],
    );
  }

  buildDateButtonsRow() {
    return Wrap(
      children: [
        DateButton(
            text: 'Tonight',
            text2: tonightText,
            color: selectedDay == DateDay.Today
                ? Colors.black
                : isAvailableTonight
                    ? Colors.white
                    : Colors.white,
            fontColor: selectedDay == DateDay.Today
                ? Colors.white
                : isAvailableTonight
                    ? Colors.green
                    : kLightDark,
            border: selectedDay == DateDay.Today
                ? Border.all(width: 1, color: Colors.black)
                : isAvailableTonight
                    ? Border.all(width: 1, color: Colors.green)
                    : Border.all(width: 1, color: kLightDark),
            onTap: () {

              setState(() {

                //Hide past times
                print(hide46);
                if (userAvailableDates[0] == null){
                  hide46 = true;
                  print(hide46);

                }
                if (userAvailableDates[1] == null){
                  hide68 = true;
                }
                if (userAvailableDates[2] == null){
                  hide810 = true;
                }

                //Toggle selectedDay
                if (selectedDay == DateDay.Today) {
                  selectedDay = DateDay.None;
                  selectedText = '';
                  toggle46 = false;
                  toggle68 = false;
                  toggle810 = false;
                } else {
                  selectedDay = DateDay.Today;
                  selectedText = tonightText;
                  toggle46 = usersAvailability[0];
                  toggle68 = usersAvailability[1];
                  toggle810 = usersAvailability[2];
                }

                //Toggle isAvailableTonight
                if (usersAvailability[0] == false &&
                    usersAvailability[1] == false &&
                    usersAvailability[2] == false) {
                  isAvailableTonight = false;
                } else {
                  isAvailableTonight = true;
                }

                //Toggle isAvailableTomorrow
                if (usersAvailability[3] == false &&
                    usersAvailability[4] == false &&
                    usersAvailability[5] == false) {
                  isAvailableTomorrow = false;
                } else {
                  isAvailableTomorrow = true;
                }

                //Toggle isAvailableThirdDay
                if (usersAvailability[6] == false &&
                    usersAvailability[7] == false &&
                    usersAvailability[8] == false) {
                  isAvailableThirdDay = false;
                } else {
                  isAvailableThirdDay = true;
                }

                //Toggle isAvailableFourthDay
                if (usersAvailability[9] == false &&
                    usersAvailability[10] == false &&
                    usersAvailability[11] == false) {
                  isAvailableFourthDay = false;
                } else {
                  isAvailableFourthDay = true;
                }

              });


            }),
        DateButton(
          text: 'Tomorrow',
          text2: tomorrowText,
          color: selectedDay == DateDay.Tomorrow
              ? Colors.black
              : isAvailableTomorrow
                  ? Colors.white
                  : Colors.white,
          fontColor: selectedDay == DateDay.Tomorrow
              ? Colors.white
              : isAvailableTomorrow
                  ? Colors.green
                  : kLightDark,
          border: selectedDay == DateDay.Tomorrow
              ? Border.all(width: 1, color: Colors.black)
              : isAvailableTomorrow
                  ? Border.all(width: 1, color: Colors.green)
                  : Border.all(width: 1, color: kLightDark),
          onTap: () {
            setState(() {
              //Hide past times
              if (hide46 == true){
                hide46 = false;
              }
              if (hide68 == true){
                hide68 = false;
              }
              if (hide810 == true){
                hide810 = false;
              }

              //Toggle selectedDay
              if (selectedDay == DateDay.Tomorrow) {
                selectedDay = DateDay.None;
                selectedText = '';
                toggle46 = false;
                toggle68 = false;
                toggle810 = false;
              } else {
                selectedDay = DateDay.Tomorrow;
                selectedText = tomorrowText;
                toggle46 = usersAvailability[3];
                toggle68 = usersAvailability[4];
                toggle810 = usersAvailability[5];
              }

              //Toggle isAvailableTonight
              if (usersAvailability[0] == false &&
                  usersAvailability[1] == false &&
                  usersAvailability[2] == false) {
                isAvailableTonight = false;
              } else {
                isAvailableTonight = true;
              }

              //Toggle isAvailableTomorrow
              if (usersAvailability[3] == false &&
                  usersAvailability[4] == false &&
                  usersAvailability[5] == false) {
                isAvailableTomorrow = false;
              } else {
                isAvailableTomorrow = true;
              }

              //Toggle isAvailableThirdDay
              if (usersAvailability[6] == false &&
                  usersAvailability[7] == false &&
                  usersAvailability[8] == false) {
                isAvailableThirdDay = false;
              } else {
                isAvailableThirdDay = true;
              }

              //Toggle isAvailableFourthDay
              if (usersAvailability[9] == false &&
                  usersAvailability[10] == false &&
                  usersAvailability[11] == false) {
                isAvailableFourthDay = false;
              } else {
                isAvailableFourthDay = true;
              }

            });
          },
        ),
        DateButton(
          text: DateFormat.EEEE().format(now.add(Duration(days: 2))),
          text2: '${DateFormat.Md().format(now.add(Duration(days: 2)))}',
          color: selectedDay == DateDay.ThirdDay
              ? Colors.black
              : isAvailableThirdDay
                  ? Colors.white
                  : Colors.white,
          fontColor: selectedDay == DateDay.ThirdDay
              ? Colors.white
              : isAvailableThirdDay
                  ? Colors.green
                  : kLightDark,
          border: selectedDay == DateDay.ThirdDay
              ? Border.all(width: 1, color: Colors.black)
              : isAvailableThirdDay
                  ? Border.all(width: 1, color: Colors.green)
                  : Border.all(width: 1, color: kLightDark),
          onTap: () {
            setState(() {
              //Hide past times
              if (hide46 == true){
                hide46 = false;
              }
              if (hide68 == true){
                hide68 = false;
              }
              if (hide810 == true){
                hide810 = false;
              }

              //Toggle selectedDay
              if (selectedDay == DateDay.ThirdDay) {
                selectedDay = DateDay.None;
                selectedText = '';
                toggle46 = false;
                toggle68 = false;
                toggle810 = false;
              } else {
                selectedDay = DateDay.ThirdDay;
                selectedText = thirdDayText;
                toggle46 = usersAvailability[6];
                toggle68 = usersAvailability[7];
                toggle810 = usersAvailability[8];
              }

              //Toggle isAvailableTonight
              if (usersAvailability[0] == false &&
                  usersAvailability[1] == false &&
                  usersAvailability[2] == false) {
                isAvailableTonight = false;
              } else {
                isAvailableTonight = true;
              }

              //Toggle isAvailableTomorrow
              if (usersAvailability[3] == false &&
                  usersAvailability[4] == false &&
                  usersAvailability[5] == false) {
                isAvailableTomorrow = false;
              } else {
                isAvailableTomorrow = true;
              }

              //Toggle isAvailableThirdDay
              if (usersAvailability[6] == false &&
                  usersAvailability[7] == false &&
                  usersAvailability[8] == false) {
                isAvailableThirdDay = false;
              } else {
                isAvailableThirdDay = true;
              }

              //Toggle isAvailableFourthDay
              if (usersAvailability[9] == false &&
                  usersAvailability[10] == false &&
                  usersAvailability[11] == false) {
                isAvailableFourthDay = false;
              } else {
                isAvailableFourthDay = true;
              }

            });
          },
        ),
        DateButton(
            text: DateFormat.EEEE().format(now.add(Duration(days: 3))),
            text2: '${DateFormat.Md().format(now.add(Duration(days: 3)))}',
            color: selectedDay == DateDay.FourthDay
                ? Colors.black
                : isAvailableFourthDay
                    ? Colors.white
                    : Colors.white,
            fontColor: selectedDay == DateDay.FourthDay
                ? Colors.white
                : isAvailableFourthDay
                    ? Colors.green
                    : kLightDark,
            border: selectedDay == DateDay.FourthDay
                ? Border.all(width: 1, color: Colors.black)
                : isAvailableFourthDay
                    ? Border.all(width: 1, color: Colors.green)
                    : Border.all(width: 1, color: kLightDark),
            onTap: () {
              setState(() {
                //Hide past times
                if (hide46 == true){
                  hide46 = false;
                }
                if (hide68 == true){
                  hide68 = false;
                }
                if (hide810 == true){
                  hide810 = false;
                }

                //Toggle selectedDay
                if (selectedDay == DateDay.FourthDay) {
                  selectedDay = DateDay.None;
                  selectedText = '';
                  toggle46 = false;
                  toggle68 = false;
                  toggle810 = false;
                } else {
                  selectedDay = DateDay.FourthDay;
                  selectedText = fourthDayText;
                  toggle46 = usersAvailability[9];
                  toggle68 = usersAvailability[10];
                  toggle810 = usersAvailability[11];
                }

                //Toggle isAvailableTonight
                if (usersAvailability[0] == false &&
                    usersAvailability[1] == false &&
                    usersAvailability[2] == false) {
                  isAvailableTonight = false;
                } else {
                  isAvailableTonight = true;
                }

                //Toggle isAvailableTomorrow
                if (usersAvailability[3] == false &&
                    usersAvailability[4] == false &&
                    usersAvailability[5] == false) {
                  isAvailableTomorrow = false;
                } else {
                  isAvailableTomorrow = true;
                }

                //Toggle isAvailableThirdDay
                if (usersAvailability[6] == false &&
                    usersAvailability[7] == false &&
                    usersAvailability[8] == false) {
                  isAvailableThirdDay = false;
                } else {
                  isAvailableThirdDay = true;
                }

                //Toggle isAvailableFourthDay
                if (usersAvailability[9] == false &&
                    usersAvailability[10] == false &&
                    usersAvailability[11] == false) {
                  isAvailableFourthDay = false;
                } else {
                  isAvailableFourthDay = true;
                }

              });
            }),
      ],
    );
  }

  //Date Time Page Contents
  buildDateTimePage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 15, left: 5, top: 15),
                child: Text(
                  'When are you available for a date?',
                  style: TextStyle(
                      fontSize: 20.0,
                      color: kDarkest,
                      fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: 5),
              buildDateButtonsRow(),
              SizedBox(height: 20),
              Text(' Include date type',
                  style:
                      TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  children: [
                    PillButton(
                        text: 'Dinner',
                        isSelected: addDinner,
                        onTap: () {
                          setState(() {
                            addDinner == true
                                ? addDinner = false
                                : addDinner = true;
                          });
                        }),
                    PillButton(
                        text: 'Drinks',
                        isSelected: addDrinks,
                        onTap: () {
                          setState(() {
                            addDrinks == true
                                ? addDrinks = false
                                : addDrinks = true;
                          });
                        }),
                    PillButton(
                        text: 'Adventure',
                        isSelected: addAdventure,
                        onTap: () {
                          setState(() {
                            addAdventure == true
                                ? addAdventure = false
                                : addAdventure = true;
                          });
                        }),
                    PillButton(
                        text: 'Custom event',
                        isSelected: addMessage,
                        onTap: () {
                          setState(() {
                            addMessage == true
                                ? addMessage = false
                                : addMessage = true;
                          });
                        }),
                  ],
                ),
              ),
              addMessage
                  ? Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, bottom: 20),
                      child: TextField(
                        controller: activityController,
                        decoration: InputDecoration(
                          hintText: '\"Comedy show\"',
                          hintStyle: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: kLightDark,
                          ),
                        ),
                      ),
                    )
                  : SizedBox(height: 0),
            ],
          ),
          StyledButton(
              text: 'Find a poop date',
              color: kButtonColor,
              onTap: () {
                //Check to see if there is a doc created,
                //If not, create one
                //TODO: Add Create Doc function below
                createDateDoc();
                //If yes, add to doc
                print(selectedDay);
              }),
        ],
      ),
    );
    //           Padding(
    //             padding: const EdgeInsets.only(bottom: 15, left: 5, top: 15),
    //             child: Text(
    //               'When are you looking for a date?',
    //               style: TextStyle(
    //                   fontSize: 20.0,
    //                   color: kDarkest,
    //                   fontWeight: FontWeight.w600),
    //             ),
    //           ),
    //           // buildIconAndText(
    //           //   text: 'Date',
    //           //   icon: Icons.event,
    //           // ),
    //           buildDateButtonsRow(),
    //           Divider(),
    //           // buildIconAndText(
    //           //   text: 'Add Time',
    //           //   icon: Icons.access_time,
    //           // ),
    //           pageOpen
    //               ? Row(
    //                   mainAxisAlignment: MainAxisAlignment.center,
    //                   children: [
    //                     Container(
    //                       decoration: BoxDecoration(
    //                         borderRadius:
    //                             BorderRadius.all(Radius.circular(15.0)),
    //                         color: kLightestGrey,
    //                       ),
    //                       child: Column(
    //                         children: [
    //                           Icon(
    //                             Icons.arrow_drop_up,
    //                             color: kLightDark,
    //                           ),
    //                           Container(
    //                               width: 100,
    //                               height: 30,
    //                               child: Center(
    //                                 child: ListWheelScrollView(
    //                                   controller: startTimeController,
    //                                   diameterRatio: .80,
    //                                   useMagnifier: true,
    //                                   magnification: 1.3,
    //                                   physics: FixedExtentScrollPhysics(),
    //                                   onSelectedItemChanged: (index) {
    //                                     setState(() {
    //                                       startTime = index;
    //                                     });
    //                                   },
    //                                   itemExtent: 40.0,
    //                                   children: [
    //                                     TimeText('5'),
    //                                     TimeText('6'),
    //                                     TimeText('7'),
    //                                     TimeText('8'),
    //                                     TimeText('9'),
    //                                   ],
    //                                 ),
    //                               )),
    //                           Icon(
    //                             Icons.arrow_drop_down,
    //                             color: kLightDark,
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                     Padding(
    //                       padding: const EdgeInsets.all(8.0),
    //                       child: Text('to', style: kDateTimeIconTextStyle),
    //                     ),
    //                     Container(
    //                       margin: EdgeInsets.all(8.0),
    //                       decoration: BoxDecoration(
    //                         borderRadius:
    //                             BorderRadius.all(Radius.circular(15.0)),
    //                         color: kLightestGrey,
    //                       ),
    //                       child: Column(
    //                         children: [
    //                           Icon(
    //                             Icons.arrow_drop_up,
    //                             color: kLightDark,
    //                           ),
    //                           Container(
    //                               width: 100,
    //                               height: 30,
    //                               child: Center(
    //                                 child: ListWheelScrollView(
    //                                   controller: endTimeController,
    //                                   diameterRatio: .80,
    //                                   useMagnifier: true,
    //                                   magnification: 1.3,
    //                                   physics: FixedExtentScrollPhysics(),
    //                                   onSelectedItemChanged: (index) {
    //                                     setState(() {
    //                                       endTime = index;
    //                                     });
    //                                   },
    //                                   itemExtent: 40.0,
    //                                   children: [
    //                                     TimeText('5'),
    //                                     TimeText('6'),
    //                                     TimeText('7'),
    //                                     TimeText('8'),
    //                                     TimeText('9'),
    //                                     TimeText('10'),
    //                                   ],
    //                                 ),
    //                               )),
    //                           Icon(
    //                             Icons.arrow_drop_down,
    //                             color: kLightDark,
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                     Padding(
    //                       padding: const EdgeInsets.all(8.0),
    //                       child: Text('PM'),
    //                     )
    //                   ],
    //                 )
    //               : SizedBox(height: 0),
    //
    //           ///This was the old one
    //           SizedBox(height: 10),
    //           Text('What do you want to do?',
    //               style:
    //                   TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500)),
    //           // PillButton(
    //           //   text: 'Include a desired activity',
    //           //   isSelected: addActivity,
    //           //   onTap: (){
    //           //     setState(() {
    //           //       addActivity == true ?
    //           //           addActivity = false
    //           //           : addActivity = true;
    //           //     });
    //           //   }
    //           // ),
    //           ///This is the new one
    //           //         GestureDetector(
    //           //           onTap: (){
    //           //   setState(() {
    //           //     addActivity == true ?
    //           //         addActivity = false
    //           //         : addActivity = true;
    //           //   });
    //           // },
    //           //           child: Padding(
    //           //             padding: const EdgeInsets.only(top: 10.0, right: 10),
    //           //             child: Row(
    //           //               mainAxisAlignment: MainAxisAlignment.end,
    //           //               children: [
    //           //                 Column(
    //           //                   crossAxisAlignment: CrossAxisAlignment.end,
    //           //                   children: [
    //           //                     SizedBox(height: 4),
    //           //                     Container(
    //           //                       child: Padding(
    //           //                         padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 3),
    //           //                         child: Icon(Icons.local_bar_outlined,
    //           //                           color: addActivity ? Colors.white : kButtonColor,
    //           //                         ),
    //           //                       ),
    //           //                       decoration: BoxDecoration(
    //           //                           color: addActivity ?  kButtonColor : Color(0xffF8E6DC),
    //           //                           borderRadius: BorderRadius.circular(20.0),
    //           //                        //border: Border.all(width: 1, color: kButtonColor),
    //           //                       ),
    //           //                     ),
    //           //                     SizedBox(height: 4),
    //           //                     Text(
    //           //                         'Add an activity',
    //           //                         textAlign: TextAlign.center,
    //           //                         style: TextStyle(
    //           //                           color: kDarkest,
    //           //                           fontSize: 14.0,
    //           //                         )
    //           //                     ),
    //           //                   ],
    //           //                 ),
    //           //               ],
    //           //             ),
    //           //           ),
    //           //         ),
    //           //         // Divider(
    //           //         //   color: Colors.black,
    //           //         // ),
    //           Padding(
    //             padding: const EdgeInsets.all(8.0),
    //             child: Wrap(
    //               children: [
    //                 PillButton(
    //                     text: 'Dinner',
    //                     isSelected: addDinner,
    //                     onTap: () {
    //                       setState(() {
    //                         addDinner == true
    //                             ? addDinner = false
    //                             : addDinner = true;
    //                       });
    //                     }),
    //                 PillButton(
    //                     text: 'Drinks',
    //                     isSelected: addDrinks,
    //                     onTap: () {
    //                       setState(() {
    //                         addDrinks == true
    //                             ? addDrinks = false
    //                             : addDrinks = true;
    //                       });
    //                     }),
    //                 PillButton(
    //                     text: 'Adventure',
    //                     isSelected: addMessage,
    //                     onTap: () {
    //                       setState(() {
    //                         addMessage == true
    //                             ? addMessage = false
    //                             : addMessage = true;
    //                       });
    //                     }),
    //                 PillButton(
    //                     text: 'Custom event',
    //                     isSelected: addMessage,
    //                     onTap: () {
    //                       setState(() {
    //                         addMessage == true
    //                             ? addMessage = false
    //                             : addMessage = true;
    //                       });
    //                     }),
    //                 // PillButton(
    //                 //     text: 'Add Preferences',
    //                 //     isSelected: addMessage,
    //                 //     onTap: () {
    //                 //       setState(() {
    //                 //         addMessage == true
    //                 //             ? addMessage = false
    //                 //             : addMessage = true;
    //                 //       });
    //                 //     }),
    //               ],
    //             ),
    //           ),
    //           addMessage
    //               ? Padding(
    //                   padding: const EdgeInsets.only(left: 16.0, right: 16.0),
    //                   child: TextField(
    //                     controller: activityController,
    //                     decoration: InputDecoration(
    //                       hintText: '\"Comedy show\"',
    //                       hintStyle: TextStyle(
    //                         fontStyle: FontStyle.italic,
    //                         color: kLightDark,
    //                       ),
    //                     ),
    //                   ),
    //                 )
    //               : SizedBox(height: 0),
    //         ],
    //       ),
    //       StyledButton(
    //           text: 'Search Potential Soulmates',
    //           color: kButtonColor,
    //           onTap: () {
    //             //Check to see if there is a doc created,
    //             //If not, create one
    //             //TODO: Add Create Doc function below
    //             createDateDoc();
    //             //If yes, add to doc
    //             print(selectedDay);
    //             // Navigator.pop(context);
    //           }),
    //       // Text('Continue in Browse Mode'),
    //       // Divider(),
    //       // Text('or'),
    //       // Text('Just browsing for now',
    //       // style: TextStyle(fontWeight: FontWeight.w500)),
    //     ],
    //   ),
    // );
  }

  //Middle Content
  buildMiddleContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Today is',
          style: TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.w700,
            // fontFamily: 'Roboto',
          ),
        ),
        Text('Friday, July 22nd'),
        SizedBox(
          height: 30.0,
        ),
        Text(
          'Looking for something to do?',
          style: TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.w500,
            // fontFamily: 'Roboto',
          ),
        ),
      ],
    );
  }

  //Bottom Content & Find a Date Button
  buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Image(
          //   image: AssetImage('images/pablo-love-affair.png'),
          // ),
          Container(child: Text('')),
          // Container(
          //   margin: EdgeInsets.all(15.0),
          //   child: Text('Invite someone to do something.',
          //       textAlign: TextAlign.center,
          //       style: TextStyle(
          //         fontSize: 20.0,
          //         fontWeight: FontWeight.w500,
          //         // fontFamily: 'Roboto',
          //       )),
          // ),
          StyledButton(
              text: 'Find a poop Date',
              fontColor: kDark,
              color: kYellow,
              //FIX PLZ
              onTap: () async {
                //  Navigator.push(context, MaterialPageRoute(builder: (context) => PickDateTimePage()));
                bool doesDateExists = await Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.bottomToTop,
                        child: PickDateTimePage(
                          viewAsBrowseMode: false,
                          selectedDay: DateDay.Today,
                          dateActivity: '',
                          currentRangeValues: RangeValues(5, 10),
                          drinksSelected: false,
                          friendsSelected: false,
                          splitBillSelected: false,
                        )));
                //showBottomSheet(context: context, builder: buildBottomSheet,
                //);
              }),
          // ElevatedButton(onPressed: getMatchesById, child: Text('Test')),
        ],
      ),
    );
  }

  // //Pick Time & Place BottomSheet
  // SafeArea buildBottomSheet(BuildContext context) {
  //   return SafeArea(
  //     child: Container(
  //         color: Colors.grey,
  //         child: Padding(
  //           padding: const EdgeInsets.only(top: 30.0),
  //           child: Container(
  //             decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.only(
  //                   topLeft: Radius.circular(20.0),
  //                   topRight: Radius.circular(20),
  //                 )),
  //             child: Column(
  //               children: [
  //                 buildTopBar(),
  //                 Divider(
  //                   color: Color(0xff4d4d4d),
  //                 ),
  //                 buildIconAndText(
  //                   text: 'Date',
  //                   icon: Icons.event,
  //                 ),
  //                 Row(
  //                   children: [
  //                     Padding(
  //                       padding: const EdgeInsets.all(8.0),
  //                       child: GestureDetector(
  //                         onTap: () {
  //                           print('Today was pressed');
  //                         },
  //                         child: Container(
  //                           height: 50.0,
  //                           decoration: BoxDecoration(
  //                             gradient: LinearGradient(
  //                               begin: Alignment.topLeft,
  //                               end: Alignment(-20.51, 133.59),
  //                               colors: [kButtonColor, kButtonColor],
  //                             ),
  //                             borderRadius: BorderRadius.circular(10.0),
  //                           ),
  //                           child: Center(
  //                               child: Text(
  //                             'Today',
  //                             style: TextStyle(
  //                               fontFamily: 'RobotoBlack',
  //                               fontSize: 16.0,
  //                               color: Colors.white,
  //                             ),
  //                           )),
  //                         ),
  //                       ),
  //                     ),
  //                     StyledButton(
  //                       text: 'Tomorrow',
  //                       color: Color(0xffFF427A),
  //                       onTap: () {
  //                         print('Today was pressed');
  //                       },
  //                     ),
  //                     StyledButton(
  //                       text: 'Saturday',
  //                       color: Color(0xffFF427A),
  //                       onTap: () {
  //                         print('Today was pressed');
  //                       },
  //                     ),
  //                   ],
  //                 ),
  //                 buildIconAndText(
  //                   text: 'Time',
  //                   icon: Icons.access_time,
  //                 ),
  //
  //                 Divider(
  //                   color: Color(0xff4d4d4d),
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.all(8.0),
  //                   child: Text('Include Preferences',
  //                       textAlign: TextAlign.left,
  //                       style: TextStyle(
  //                         color: kLightGrey,
  //                         fontSize: 17.0,
  //                       )),
  //                 ),
  //                 Wrap(
  //                   children: [],
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.symmetric(horizontal: 30.0),
  //                   child: StyledButton(
  //                       text: 'Search for Matches',
  //                       color: kButtonColor,
  //                       onTap: () {
  //                         Navigator.pop(context);
  //                       }),
  //                 )
  //               ],
  //             ),
  //           ),
  //         )),
  //   );
  // }

  //Parts for the BottomSheet page

  buildTopBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            padding: EdgeInsets.all(20.0),
            child: Icon(
              Icons.close,
              color: Color(0xff4d4d4d),
            ),
          ),
        ),
        Container(
            child: Text('Pick Time & Date',
                style: TextStyle(
                  fontSize: 20.0,
                  fontFamily: 'Roboto',
                  color: Colors.black,
                ))),
      ],
    );
  }

  buildMatchesProfiless(List profilePages) {
    int profilePagesIndex = 0;
    return Stack(
      children: [
        profilePages[profilePagesIndex],
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            heroTag: 'like',
            onPressed: () {
              print('presssed!!');
              print('profilePagesIndex = $profilePagesIndex');
              print('profilePages.length = ${profilePages.length}');

              // if (profilePagesIndex <= profilePages.length - 1) {
              //   setState(() {
              //     profilePagesIndex++;
              //   });
              // } else {
              //   print('no more matches');
              // }
            },
            child: Icon(
              Icons.favorite,
              size: 25,
            ),
          ),
        ),
      ],
    );
  }

  buildNoCurrentMatchesWidget({Date dateDoc}) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // TextButton(
            //   child: Text('Edit Date'),
            //   onPressed: () {
            //     // //TODO: Navigate to edit date with datedatadoc info
            //     // Navigator.push(
            //     //   context,
            //     //   MaterialPageRoute(
            //     //     builder: (context) => PickDateTimePage(
            //     //       viewAsBrowseMode: true,
            //     //       //TODO: Need to include full date in properties of PickDateTimePage.
            //     //       selectedDay: DateDay.Today,
            //     //       dateActivity: dateDoc.activityText,
            //     //       currentRangeValues: RangeValues(
            //     //           dateDoc.startTime.toDouble(),
            //     //           dateDoc.endTime.toDouble()),
            //     //       drinksSelected: dateDoc.interests['drinkSelected'],
            //     //       friendsSelected: dateDoc.interests['friendsSelected'],
            //     //       splitBillSelected:
            //     //           dateDoc.interests['splitBillSelected'],
            //     //     ),
            //     //   ),
            //     // );
            //   },
            // ),
            Container(
              padding: EdgeInsets.all(20.0),
              child: Text(
                  'There are no more availabilities at this time. Check back later or widen your availability by pressing Edit Availability.'),
            ),
            TextButton(
              child: Text('Edit Availability'),
              onPressed: () {
                setState(() {
                  dateExists = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // buildMatchesProfiles() {
  //   Date userDateDoc;
  //
  //   return StreamBuilder<QuerySnapshot>(
  //     //Populate userids of people whos available at your date times.
  //     stream: datesRef.doc(currentDate.dateId).collection('users').snapshots(),
  //     builder: (context, snapshot) {
  //       if (!snapshot.hasData) {
  //         return Center(
  //             child: CircularProgressIndicator(
  //           backgroundColor: Colors.lightBlue,
  //         ));
  //       }
  //
  //       final dates = snapshot.data.docs;
  //
  //       List<ProfilePage> profilePages = [];
  //
  //       for (var date in dates) {
  //         print('this is the loop triggered for match id ${date.id}');
  //
  //         userDateDoc = Date.fromDocument(date);
  //
  //         //if userDateDoc's date.id == currentUser's id, move to next date aka break...?
  //         // if (userDateDoc.uid != widget.profileId) {
  //         print('the userDateDoc.uid is ${userDateDoc.uid}');
  //
  //         final userData = ProfilePage(
  //           profileId: userDateDoc.uid,
  //           viewPreferenceInfo: false,
  //           viewingAsBrowseMode: true,
  //           dateDoc: userDateDoc,
  //         );
  //
  //         profilePages.add(userData);
  //       }
  //       print('profilePages.length = ${profilePages.length}');
  //       print('profilePages.isEmpty = ${profilePages.isEmpty}');
  //       //if profilePages list is empty, return Text that says "sorry no matches at this time, check back later
  //       return profilePagesIndex < profilePages.length
  //           ? Stack(
  //               children: [
  //                 profilePages[profilePagesIndex],
  //                 Positioned(
  //                   right: 0,
  //                   child: SafeArea(
  //                     child: Container(
  //                       width: MediaQuery.of(context).size.width,
  //                       color: Colors.white,
  //                       child: Padding(
  //                         padding: const EdgeInsets.all(8.0),
  //                         child: Row(
  //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                           children: [
  //                             Row(
  //                               children: [
  //                                 Text('Availability:  ',
  //                                     style: TextStyle(
  //                                         fontWeight: FontWeight.w600)),
  //                                 Text(
  //                                   'Mon, Tues, Wed, Thurs',
  //                                 ),
  //                               ],
  //                             ),
  //                             GestureDetector(
  //                               onTap: deleteDateDoc,
  //                               child: Text('Edit',
  //                                   style:
  //                                       TextStyle(fontWeight: FontWeight.w500)),
  //                             )
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 Positioned(
  //                   bottom: 20,
  //                   right: 20,
  //                   child: FloatingActionButton(
  //                     heroTag: 'like',
  //                     onPressed: () async {
  //                       print('presssed!!');
  //                       print('profilePagesIndex = $profilePagesIndex');
  //                       print('profilePages.length = ${profilePages.length}');
  //                       print('this is the userDateDoc.uid ${userDateDoc.uid}');
  //                       print(
  //                           'this is the currentDate.dateId ${currentDate.dateId}');
  //                       print(
  //                           'this is the profilePages[profilePagesIndex].profileId ${profilePages[profilePagesIndex].profileId}');
  //                       String matchId =
  //                           profilePages[profilePagesIndex].profileId;
  //                       //Add to the profile map of user, the profile ID of the liked user with a TRUE bool
  //                       final doc = await datesRef
  //                           .doc(currentDate.dateId)
  //                           .collection('users')
  //                           .doc(userDateDoc.uid)
  //                           .get();
  //                       print(doc.data()['endTime']);
  //                       //This adds the profile page to the matches map of the user's date doc
  //                       doc.reference.update({
  //                         'matches.${profilePages[profilePagesIndex].profileId}':
  //                             true
  //                       });
  //
  //                       //If match on both sides, create a notification for the other user
  //
  //                       //This grabs the match's match map
  //                       final matchDoc = await datesRef
  //                           .doc(currentDate.dateId)
  //                           .collection('users')
  //                           .doc(matchId)
  //                           .get();
  //                       //This is the match's match true or false of the current user
  //                       if (matchDoc.data()['matches'][userDateDoc.uid] ==
  //                           true) {
  //                         //TODO: Create a notification for the other user --OR-- (Shifali)
  //                         print('User has a  ');
  //                         //TODO: Automatically starts a chat and temporarily hides them from the feed
  //
  //                         //Notify user they are a match
  //                         //TODO: Add notification
  //
  //                         //Check that a message Id doesn't already exist for the two users
  //                         final snapShot = await matchesRef
  //                             .doc(widget.profileId)
  //                             .collection('matches')
  //                             .doc(userDateDoc.uid)
  //                             .get();
  //                         print(
  //                             'Has a match already been created? ${snapShot.exists}');
  //
  //                         if (!snapShot.exists) {
  //                           //Create a messages doc for both users & saved docRef Id
  //                           DocumentReference docRef = await messagesRef
  //                               .add({'dateTime': currentDate.startTime});
  //                           print('Messages Id is ${docRef.id}');
  //
  //                           //Create a new messages collection & automated first message
  //                           messagesRef
  //                               .doc(docRef.id)
  //                               .collection('messages')
  //                               .add({
  //                             'message':
  //                                 '${'Want to go on a date? This user has replied to your match request! (SHIFALI)'}',
  //                             'sender': widget.profileId,
  //                             'time': Timestamp.now(),
  //                           });
  //
  //                           //Add to chat on user's side
  //                           setMatchInFirestore(
  //                             matchId: matchId,
  //                             messagesId: docRef.id,
  //                             lastMessage: 'New Match!',
  //                           );
  //
  //                           //Add to chat on match's side
  //                           setMatchInFirestore(
  //                               matchId: widget.profileId,
  //                               messagesId: docRef.id,
  //                               lastMessage: 'New Match!');
  //
  //                           //Make their Date Snapshot inactive
  //                           final dateDoc = await datesRef
  //                               .doc(dateId)
  //                               .collection('users')
  //                               .doc(widget.profileId)
  //                               .get();
  //                           if (doc.exists) {
  //                             doc.reference.update({'active': false});
  //                           }
  //                         } else {
  //                           //If a chat already exists, make it active?
  //                         }
  //                       }
  //
  //                       //Go to the next profile
  //                       // if (profilePagesIndex <= profilePages.length - 1) {
  //                       //   setState(() {
  //                       //     profilePagesIndex++;
  //                       //   });
  //                       // } else {
  //                       //   print('no more matches');
  //                       // }
  //                     },
  //                     child: Icon(
  //                       Icons.favorite,
  //                       size: 25,
  //                     ),
  //                   ),
  //                 ),
  //                 Positioned(
  //                   bottom: 20,
  //                   left: 20,
  //                   child: FloatingActionButton(
  //                     backgroundColor: Colors.red,
  //                     heroTag: 'close',
  //                     onPressed: () {
  //                       print('presssed!!');
  //                       print('profilePagesIndex = $profilePagesIndex');
  //                       print('profilePages.length = ${profilePages.length}');
  //                       if (profilePagesIndex <= profilePages.length - 1) {
  //                         setState(() {
  //                           profilePagesIndex++;
  //                         });
  //                       } else {
  //                         print('no more matches');
  //                       }
  //                     },
  //                     child: Icon(
  //                       Icons.close,
  //                       size: 25,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             )
  //           : buildNoCurrentMatchesWidget(dateDoc: currentDate);
  //     },
  //   );
  // }

  buildMatchesProfiles2() {
    Date userDateDoc;

    return StreamBuilder<QuerySnapshot>(
      //Populate userids of people whos available at your date times.
      //TODO: Change datesRef to activeDates ref
      //TODO:
      stream: datesRef
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

        final dates = snapshot.data.docs;

        List<ProfilePage> profilePages = [];

        for (var date in dates) {
          print('this is the loop triggered for match id ${date.id}');

          userDateDoc = Date.fromDocument(date);

          //if userDateDoc's date.id == currentUser's id, move to next date aka break...?
          // if (userDateDoc.uid != widget.profileId) {

          //TODO: Jan 9, 2023 - This is where i left off--cant' seem to pick up the currentUID
          //I'm trying to hide any profile where this current uid is rejected
          print('will this print true...?');
          // print(userDateDoc.rejects.entri);


          print('the userDateDoc.uid is ${userDateDoc.uid}');
          print(userDateDoc.availability);
          print('userDateDoc.availability!');

          final userData = ProfilePage(
            profileId: userDateDoc.uid,
            viewPreferenceInfo: false,
            viewingAsBrowseMode: true,
            dateDoc: userDateDoc,
            backFunction: (){
              setState(() {
                dateExists = false;
              });
            },
          );

          profilePages.add(userData);
        }
        print('profilePages.length = ${profilePages.length}');
        print('profilePages.isEmpty = ${profilePages.isEmpty}');
        //if profilePages list is empty, return Text that says "sorry no matches at this time, check back later
        return profilePagesIndex < profilePages.length
            ? Stack(
                children: [
                  profilePages[profilePagesIndex],
                  // Positioned(
                  //   right: 0,
                  //   child: SafeArea(
                  //     child: Container(
                  //       width: MediaQuery.of(context).size.width,
                  //       color: Colors.white,
                  //       child: Padding(
                  //         padding: const EdgeInsets.all(8.0),
                  //         child: Row(
                  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //           children: [
                  //             Row(
                  //               children: [
                  //                 Text('Availability:  ',
                  //                     style: TextStyle(
                  //                         fontWeight: FontWeight.w600)),
                  //                 Text(
                  //                   'Mon, Tues, Wed, Thurs',
                  //                 ),
                  //               ],
                  //             ),
                  //             GestureDetector(
                  //               onTap: (){
                  //                 setState(() {
                  //                   dateExists = false;
                  //                 });
                  //               },
                  //               child: Text('Edit',
                  //                   style:
                  //                       TextStyle(fontWeight: FontWeight.w500)),
                  //             )
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: FloatingActionButton(
                      heroTag: 'like',
                      onPressed: () async {
                        // print('presssed!!');
                        // print('profilePagesIndex = $profilePagesIndex');
                        // print('profilePages.length = ${profilePages.length}');
                        // print('this is the userDateDoc.uid ${userDateDoc.uid}');
                        // // print(
                        // //     'this is the currentDate.dateId ${currentDate.dateId}');
                        // print(
                        //     'this is the profilePages[profilePagesIndex].profileId ${profilePages[profilePagesIndex].profileId}');
                        // String matchId =
                        //     profilePages[profilePagesIndex].profileId;
                        // //Add to the profile map of user, the profile ID of the liked user with a TRUE bool
                        // final doc = await datesRef
                        //     .doc(currentDate.dateId)
                        //     .collection('users')
                        //     .doc(userDateDoc.uid)
                        //     .get();
                        // print(doc.data()['endTime']);
                        // //This adds the profile page to the matches map of the user's date doc
                        // doc.reference.update({
                        //   'matches.${profilePages[profilePagesIndex].profileId}':
                        //   true
                        // });
                        //
                        // //If match on both sides, create a notification for the other user
                        //
                        // //This grabs the match's match map
                        // final matchDoc = await datesRef
                        //     .doc(currentDate.dateId)
                        //     .collection('users')
                        //     .doc(matchId)
                        //     .get();
                        // //This is the match's match true or false of the current user
                        // if (matchDoc.data()['matches'][userDateDoc.uid] ==
                        //     true) {
                        //   //TODO: Create a notification for the other user --OR-- (Shifali)
                        //   print('User has a  ');
                        //   //TODO: Automatically starts a chat and temporarily hides them from the feed
                        //
                        //   //Notify user they are a match
                        //   //TODO: Add notification
                        //
                        //   //Check that a message Id doesn't already exist for the two users
                        //   final snapShot = await matchesRef
                        //       .doc(widget.profileId)
                        //       .collection('matches')
                        //       .doc(userDateDoc.uid)
                        //       .get();
                        //   print(
                        //       'Has a match already been created? ${snapShot.exists}');
                        //
                        //   if (!snapShot.exists) {
                        //     //Create a messages doc for both users & saved docRef Id
                        //     DocumentReference docRef = await messagesRef
                        //         .add({'dateTime': currentDate.startTime});
                        //     print('Messages Id is ${docRef.id}');
                        //
                        //     //Create a new messages collection & automated first message
                        //     messagesRef
                        //         .doc(docRef.id)
                        //         .collection('messages')
                        //         .add({
                        //       'message':
                        //       '${'Want to go on a date? This user has replied to your match request! (SHIFALI)'}',
                        //       'sender': widget.profileId,
                        //       'time': Timestamp.now(),
                        //     });
                        //
                        //     //Add to chat on user's side
                        //     setMatchInFirestore(
                        //       matchId: matchId,
                        //       messagesId: docRef.id,
                        //       lastMessage: 'New Match!',
                        //     );
                        //
                        //     //Add to chat on match's side
                        //     setMatchInFirestore(
                        //         matchId: widget.profileId,
                        //         messagesId: docRef.id,
                        //         lastMessage: 'New Match!');
                        //
                        //     //Make their Date Snapshot inactive
                        //     final dateDoc = await datesRef
                        //         .doc(dateId)
                        //         .collection('users')
                        //         .doc(widget.profileId)
                        //         .get();
                        //     if (doc.exists) {
                        //       doc.reference.update({'active': false});
                        //     }
                        //   } else {
                        //     //If a chat already exists, make it active?
                        //   }
                        // }

                        //Go to the next profile
                        // if (profilePagesIndex <= profilePages.length - 1) {
                        //   setState(() {
                        //     profilePagesIndex++;
                        //   });
                        // } else {
                        //   print('no more matches');
                        // }
                      },
                      child: Icon(
                        Icons.favorite,
                        size: 25,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: FloatingActionButton(
                      backgroundColor: Colors.red,
                      heroTag: 'close',
                      onPressed: () {
                        print('presssed!!');
                        print('profilePagesIndex = $profilePagesIndex');
                        print('profilePages.length = ${profilePages.length}');
                        if (profilePagesIndex <= profilePages.length - 1) {
                          setState(() {
                            profilePagesIndex++;
                          });
                        } else {
                          print('no more matches');
                        }
                      },
                      child: Icon(
                        Icons.close,
                        size: 25,
                      ),
                    ),
                  ),
                ],
              )
            : buildNoCurrentMatchesWidget(dateDoc: currentDate);
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
    return dateExists == null
        ? buildSpinnerPage()
        : dateExists
            ? buildMatchesProfiles2()
            : buildWelcomePage2();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    startTimeController.dispose();
    endTimeController.dispose();
    super.dispose();
  }

  void setMatchInFirestore({
    String matchId,
    String messagesId,
    String lastMessage,
  }) async {
    //Get UserId
    String userId = FirebaseAuth.instance.currentUser.uid;

    //Get Match Info
    final doc = await usersRef.doc(matchId).get();
    print(doc.exists);
    UserData _match = UserData.fromDocument(doc);

    //Set Data into User's matches
    await matchesRef.doc(userId).collection('matches').doc(matchId).set({
      'activeMatch': true,
      'lastMessage': lastMessage,
      'lastMessageSender': userId,
      'lastMessageTime': DateTime.now(),
      'matchImageUrl': _match.picture1,
      'matchName': _match.firstName,
      'messageUnread': true,
      'messagesId': messagesId,
    });
  }
}
