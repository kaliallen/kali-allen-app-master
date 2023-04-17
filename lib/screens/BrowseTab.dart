///TEST
//TODO: Test to see if you leave a screen on for a long time and the time passes after 5 pm, when you click on the screen does it refresh the time? Right now it does not.

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
import '../widgets/ActivityPillButton.dart';
import '../widgets/MatrixPillButton.dart';
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

  List<String> availableTimeSlots; //in use
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
  TextEditingController activityController = TextEditingController();

  bool addDrinks = false;
  bool addDinner = false;
  bool addDinnerActivity = false;
  bool isDinnerSaved = false;
  TextEditingController dinnerActivityController = TextEditingController();

  bool addAdventure = false;
  bool friendsSelected = false;
  bool splitBillSelected = false;

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
  final startTimeIndex = 0;
  final endTimeIndex = 5;

  bool hide46 = false;
  bool hide68 = false;
  bool hide810 = false;



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

      availableTimeSlots = dateManager.identifyAvailableTimeSlots(now);
      print('availableTimeSlots: $availableTimeSlots');
    });
  }

  ///Takes what time it is now, and if the time now is later than the available times for tonight, it hides them.
  hideUnavailableTimes() {
    int hourNow = int.parse('${DateFormat.H().format(now)}');

    //If time is earlier than 3pm
    if (availableTimeSlots[0] == null) {
      hide46 = true;
    }

    //If time is between 3pm and 5pm
    if (availableTimeSlots[1] == null) {
      hide68 = true;
    }

    //if time is earlier than 7pm,
    if (availableTimeSlots[2] == null) {
      hide810 = true;
    }

    print('hide46 = $hide46');
    print('hide68 = $hide68');
    print('hide810 = $hide810');
  }

  ///Take availableTimeSlots and currentDate.availability to create the bool usersAvailability list and use the usersAvailable list to populate the input screen when they press the back button
  populateInputScreen(Date currentDate) {
    //Take availableTimeSlots and currentDate.availability to create the bool usersAvailability list

    usersAvailability = dateManager.createUsersAvailabilityFromDateDoc(
        availableTimeSlots, currentDate.availability);

    print(usersAvailability);

    if (usersAvailability[0] == true) {
      isAvailableTonight = true;
    } else if (usersAvailability[1] == true) {
      isAvailableTonight = true;
    } else if (usersAvailability[2] == true) {
      isAvailableTonight = true;
    }
    print('isAvailableTonight: $isAvailableTonight');

    if (usersAvailability[3] == true) {
      isAvailableTomorrow = true;
    } else if (usersAvailability[4] == true) {
      isAvailableTomorrow = true;
    } else if (usersAvailability[5] == true) {
      isAvailableTomorrow = true;
    }

    print('isAvailableTomorrow: $isAvailableTomorrow');

    if (usersAvailability[6] == true) {
      isAvailableThirdDay = true;
    } else if (usersAvailability[7] == true) {
      isAvailableThirdDay = true;
    } else if (usersAvailability[8] == true) {
      isAvailableThirdDay = true;
    }

    print('isAvailableThirdDay: $isAvailableThirdDay');

    if (usersAvailability[9] == true) {
      isAvailableFourthDay = true;
    } else if (usersAvailability[10] == true) {
      isAvailableFourthDay = true;
    } else if (usersAvailability[11] == true) {
      isAvailableFourthDay = true;
    }

    print('isAvailableFourthDay: $isAvailableFourthDay');

    toggle46 = usersAvailability[0];
    toggle68 = usersAvailability[1];
    toggle810 = usersAvailability[2];

    addActivity = currentDate.interests['activity'];
    addDrinks = currentDate.interests['drinks'];
    addDinner = currentDate.interests['dinner'];

    activityController.text = currentDate.customMessage;
  }

  ///Find if the user has already entered availability.
  ///Grab the list of current dates from Firebase.
  ///If it exists, check to see which dates are current.
  Future<bool> findIfDateAdded() async {
    //Grab list of current dates user has submitted
    DocumentSnapshot dateDoc = await datesRef.doc(widget.currentuid).get();
    print('dateDoc exists? ${dateDoc.exists}');

    //If a dateDoc exists, check to see that the time slots are not expired.
    if (dateDoc.exists) {
      currentDate = Date.fromDocument(dateDoc);

      print('currentDate.availability: ${currentDate.availability}');

      //Check to see that time slots are not expired
      bool areTimeSlotsExpired = dateManager.areAvailableTimeSlotsExpired(
          availableTimeSlots, currentDate.availability);

      print('areTimeSlotsExpired: $areTimeSlotsExpired');

      if (areTimeSlotsExpired == true) {
        //Delete expired dateDoc
        datesRef.doc(widget.currentuid).delete();

        return false;
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  ///If there are current dates, dateExists = true and buildMatchesProile2 populates. If false buildWelcomePage2 populates.
  toggleWelcome2BrowseScreen() async {
    //Find if they have submitted their availability
    bool isDateAdded = await findIfDateAdded();

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
    dateCreator();
    hideUnavailableTimes();
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
                              'gender': currentUser.gender,
                              'interestedIn': currentUser.isInterestedIn,
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

  ///These
  deleteDateDoc() async {
    //Check if doc exists
    //Delete the doc
    print(dateId);
    final doc = await datesRef.doc('Wed, Aug 17, 2022').get();
    if (doc.exists) {
      usersRef.doc(widget.currentuid).delete();
    }
  }

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
      backgroundColor: Colors.white, //kBrowsePageBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 0, left: 25, right: 25),
          child: ListView(
            reverse: true,
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //TODO: vvv   Resize using Media Query    vvv
              SizedBox(height: 25),
              StyledButton(
                text: 'Find a Date',
                color: kButtonColor,
                onTap: sendFindADate,
              ),
              //TODO: vvv     Resize using Media Query      vvv
              SizedBox(height: 30),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                          child: Icon(Icons.info_outline),
                          onTap: () {
                            print('hello');
                          }),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                          left: 5,
                        ),
                        child: Text(
                            "Are you free tonight?"
                            // "👀 "
                            ,
                            style: TextStyle(
                                fontSize: 30.0,
                                color: kDarkest,
                                fontWeight: FontWeight.w600)),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(
                            left: 5, top: 5, bottom: 15, right: 5),
                        child: Text(
                          'Select the dates and times you are available.',
                          //'Include an activity if you have something in mind. Fill this out as many times as you\'d like!',
                          style: TextStyle(
                              fontSize: 15.0, fontWeight: FontWeight.w300),
                        ),
                      ),

                      //TODO: Hide Dates for MVP
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: 5, left: 5, top: 5),
                        child: Text(
                          'Date',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      buildDateButtonsRow(),
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: 5, left: 5, top: 5),
                        child: Text(
                          'Time',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      hide810
                          ? Center(
                              child: Padding(
                              padding: const EdgeInsets.all(25.0),
                              child: Text('Tonight unavailable'),
                            ))
                          : Wrap(
                              children: [
                                hide46
                                    ? SizedBox(width: 0)
                                    : DateButton(
                                        text: '5 - 7 PM',
                                        text2: selectedText,
                                        color: toggle46
                                            ? kPillButtonSelectedColor
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
                                              if (usersAvailability[0] ==
                                                  true) {
                                                usersAvailability[0] = false;
                                                toggle46 = false;
                                              } else {
                                                usersAvailability[0] = true;
                                                toggle46 = true;
                                              }
                                            } else if (selectedDay ==
                                                DateDay.Tomorrow) {
                                              if (usersAvailability[3] ==
                                                  true) {
                                                usersAvailability[3] = false;
                                                toggle46 = false;
                                              } else {
                                                usersAvailability[3] = true;
                                                toggle46 = true;
                                              }
                                            } else if (selectedDay ==
                                                DateDay.ThirdDay) {
                                              if (usersAvailability[6] ==
                                                  true) {
                                                usersAvailability[6] = false;
                                                toggle46 = false;
                                              } else {
                                                usersAvailability[6] = true;
                                                toggle46 = true;
                                              }
                                            } else if (selectedDay ==
                                                DateDay.FourthDay) {
                                              if (usersAvailability[9] ==
                                                  true) {
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
                                            ? kPillButtonSelectedColor
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
                                              if (usersAvailability[1] ==
                                                  true) {
                                                usersAvailability[1] = false;
                                                toggle68 = false;
                                              } else {
                                                usersAvailability[1] = true;
                                                toggle68 = true;
                                              }
                                            } else if (selectedDay ==
                                                DateDay.Tomorrow) {
                                              if (usersAvailability[4] ==
                                                  true) {
                                                usersAvailability[4] = false;
                                                toggle68 = false;
                                              } else {
                                                usersAvailability[4] = true;
                                                toggle68 = true;
                                              }
                                            } else if (selectedDay ==
                                                DateDay.ThirdDay) {
                                              if (usersAvailability[7] ==
                                                  true) {
                                                usersAvailability[7] = false;
                                                toggle68 = false;
                                              } else {
                                                usersAvailability[7] = true;
                                                toggle68 = true;
                                              }
                                            } else if (selectedDay ==
                                                DateDay.FourthDay) {
                                              if (usersAvailability[10] ==
                                                  true) {
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
                                  color: toggle810
                                      ? kPillButtonSelectedColor
                                      : Colors.white,
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
                      SizedBox(height: 15),
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

                      Padding(
                        padding:
                            const EdgeInsets.only(left: 5, top: 10, bottom: 0),
                        child: Text(
                          'What do you want to do?',
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5, top: 5),
                        child: Text(
                          'Add any details like place or vibe. ',
                          //'Be specific. Being specific is attractive!',
                          style: TextStyle(
                              fontSize: 15.0, fontWeight: FontWeight.w300),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 0, top: 15),
                        child: Wrap(
                          children: [
                            PillButton(
                                text: '🎶 Music',
                                isSelected: addAdventure,
                                onTap: () {
                                  setState(() {
                                    addAdventure == true
                                        ? addAdventure = false
                                        : addAdventure = true;
                                  });
                                }),
                            PillButton(
                                text: '🏈 Sports',
                                isSelected: addAdventure,
                                onTap: () {
                                  setState(() {
                                    addAdventure == true
                                        ? addAdventure = false
                                        : addAdventure = true;
                                  });
                                }),
                            PillButton(
                                text: '🤼 Activity',
                                isSelected: addAdventure,
                                onTap: () {
                                  setState(() {
                                    addAdventure == true
                                        ? addAdventure = false
                                        : addAdventure = true;
                                  });
                                }),
                            PillButton(
                                text: '☕️ Coffee',
                                isSelected: addAdventure,
                                onTap: () {
                                  setState(() {
                                    addAdventure == true
                                        ? addAdventure = false
                                        : addAdventure = true;
                                  });
                                }),

                            ///////////////////////////////////////////////////////
                            ActivityPillButton(
                                infoSaved: isDinnerSaved,
                                text: '🍱 Dinner',
                                isSelected: addDinner,
                                onTap: () {
                                  setState(() {
                                    addDinner == true
                                        ? addDinner = false
                                        : addDinner = true;

                                    //TODO: Add--If an activity pill button is selected, close all the other pills that are open by making 'addDinner' false

                                    addDinnerActivity == true
                                        ? addDinnerActivity = false
                                        : addDinnerActivity = true;
                                  });
                                }),

                            addDinnerActivity
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5.0, right: 5.0, bottom: 5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .68,
                                          child: TextField(
                                            controller:
                                                dinnerActivityController,
                                            decoration: InputDecoration(
                                              hintText:
                                                  '\"There\'s a new sushi happy hour spot...👀\"',
                                              hintStyle: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                color: kLightDark,
                                              ),
                                            ),
                                          ),
                                        ),
                                        PillButton(
                                          isSelected: true,
                                          text: 'Done',
                                          onTap: () {
                                            setState(() {
                                              //Close the textfield
                                              print(addDinnerActivity);
                                              addDinnerActivity == true
                                                  ? addDinnerActivity = false
                                                  : addDinnerActivity = true;

                                              //If the textfield is populated, save that info somewhere, if not, isDinnerSaved = false

                                              if (dinnerActivityController.text
                                                  .trim()
                                                  .isNotEmpty) {
                                                isDinnerSaved = true;
                                              } else {
                                                isDinnerSaved = false;
                                                addDinner = false;
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox(height: 0),

                            //////////////////////////////////////
                            PillButton(
                                text: '🍸 Drinks',
                                isSelected: addDrinks,
                                onTap: () {
                                  setState(() {
                                    addDrinks == true
                                        ? addDrinks = false
                                        : addDrinks = true;
                                  });
                                }),
                            PillButton(
                                text: 'Something else',
                                isSelected: addActivity,
                                onTap: () {
                                  setState(() {
                                    addActivity == true
                                        ? addActivity = false
                                        : addActivity = true;
                                  });
                                }),
                          ],
                        ),
                      ),

                      //TODO: Find out why column shifts to the right when addMessage is clicked
                      addActivity
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 10.0, bottom: 0),
                              child: TextField(
                                controller: activityController,
                                decoration: InputDecoration(
                                  hintText:
                                      '\"There\'s a new sushi happy hour spot...👀\"',
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

  ///This screen is where users input their availability and interested activities to find a date
  //TODO: There is a wierd alignment issue when Tonight is Unavailable
  buildWelcomePage() {
    return Scaffold(
      backgroundColor: Colors.white, //kBrowsePageBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 0, left: 25, right: 25),
          child: ListView(
            reverse: true,
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //TODO: vvv   Resize using Media Query    vvv
              SizedBox(height: 25),
              StyledButton(
                text: 'Find a Date',
                color: kButtonColor,
                onTap: sendFindADate,
              ),
              //TODO: vvv     Resize using Media Query      vvv
              SizedBox(height: 30),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                          child: Icon(Icons.info_outline),
                          onTap: () {
                            print('hello');
                          }),
                    ],
                  ),
                  Column(

                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                          left: 15,
                        ),
                        child: Column(

                          children: [
                            Text(
                             // 'Match with people who are available when you are '
                              'When are you free? '
                                  "👀 "
                                // "Are you free tonight?"
                                ,

                                style: TextStyle(
                                    fontSize: 25.0,
                                    color: kDarkest,
                                    fontWeight: FontWeight.w600),
                            ),
                            // Text(
                            //     // "Are you free tonight?"
                            //         "👀 "
                            //     ,
                            //     style: TextStyle(
                            //         fontSize: 25.0,
                            //         color: kDarkest,
                            //
                            //         fontWeight: FontWeight.w600)),

                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15, top: 5, bottom: 15, right: 5),
                        child: Text(
                          'Check the times you are free and want to go out on a date.',
                          //'Include an activity if you have something in mind. Fill this out as many times as you\'d like!',
                          style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w400,

                          ),

                        ),
                      ),
                     buildTimeMatrix(),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 25, top: 10, bottom: 0),
                        child: Text(
                          'What do you want to do?',
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 25, top: 5),
                        child: Text(
                          'Add any details like place or vibe. ',
                          //'Be specific. Being specific is attractive!',
                          style: TextStyle(
                              fontSize: 15.0, fontWeight: FontWeight.w400),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 5),
                        child: Wrap(
                          children: [
                            PillButton(
                                text: '🎶 Music',
                                isSelected: addAdventure,
                                onTap: () {
                                  setState(() {
                                    addAdventure == true
                                        ? addAdventure = false
                                        : addAdventure = true;
                                  });
                                }),
                            PillButton(
                                text: '🏈 Sports',
                                isSelected: addAdventure,
                                onTap: () {
                                  setState(() {
                                    addAdventure == true
                                        ? addAdventure = false
                                        : addAdventure = true;
                                  });
                                }),
                            PillButton(
                                text: '🤼 Activity',
                                isSelected: addAdventure,
                                onTap: () {
                                  setState(() {
                                    addAdventure == true
                                        ? addAdventure = false
                                        : addAdventure = true;
                                  });
                                }),
                            PillButton(
                                text: '☕️ Coffee',
                                isSelected: addAdventure,
                                onTap: () {
                                  setState(() {
                                    addAdventure == true
                                        ? addAdventure = false
                                        : addAdventure = true;
                                  });
                                }),

                            /////////////////////////////////////////////////////
                            ActivityPillButton(
                                infoSaved: isDinnerSaved,
                                text: '🍱 Dinner',
                                isSelected: addDinner,
                                onTap: () {
                                  setState(() {
                                    addDinner == true
                                        ? addDinner = false
                                        : addDinner = true;

                                    //TODO: Add--If an activity pill button is selected, close all the other pills that are open by making 'addDinner' false

                                    addDinnerActivity == true
                                        ? addDinnerActivity = false
                                        : addDinnerActivity = true;
                                  });
                                }),

                            addDinnerActivity
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5.0, right: 5.0, bottom: 5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .68,
                                          child: TextField(
                                            controller:
                                                dinnerActivityController,
                                            decoration: InputDecoration(
                                              hintText:
                                                  '\"There\'s a new sushi happy hour spot...👀\"',
                                              hintStyle: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                color: kLightDark,
                                              ),
                                            ),
                                          ),
                                        ),
                                        PillButton(
                                          isSelected: true,
                                          text: 'Done',
                                          onTap: () {
                                            setState(() {
                                              //Close the textfield
                                              print(addDinnerActivity);
                                              addDinnerActivity == true
                                                  ? addDinnerActivity = false
                                                  : addDinnerActivity = true;

                                              //If the textfield is populated, save that info somewhere, if not, isDinnerSaved = false

                                              if (dinnerActivityController.text
                                                  .trim()
                                                  .isNotEmpty) {
                                                isDinnerSaved = true;
                                              } else {
                                                isDinnerSaved = false;
                                                addDinner = false;
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox(height: 0),

                            ////////////////////////////////////
                            PillButton(
                                text: '🍸 Drinks',
                                isSelected: addDrinks,
                                onTap: () {
                                  setState(() {
                                    addDrinks == true
                                        ? addDrinks = false
                                        : addDrinks = true;
                                  });
                                }),
                            PillButton(
                                text: 'Add details',
                                isSelected: addActivity,
                                onTap: () {
                                  setState(() {
                                    addActivity == true
                                        ? addActivity = false
                                        : addActivity = true;
                                  });
                                }),
                            PillButton(
                                text: '+',
                                isSelected: addActivity,
                                onTap: () {
                                  setState(() {
                                    addActivity == true
                                        ? addActivity = false
                                        : addActivity = true;
                                  });
                                }),
                          ],
                        ),
                      ),

                      //TODO: Find out why column shifts to the right when addMessage is clicked
                      addActivity
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 10.0, bottom: 0),
                              child: TextField(
                                controller: activityController,
                                decoration: InputDecoration(
                                  hintText:
                                      '\"There\'s a new sushi happy hour spot...👀\"',
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


  buildTimeMatrix() {
    Tonight _tonight = Tonight.early;

    double h = 50;
    double w = 90;

    Tonight tonight = Tonight.early;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * .8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: h,
                    width: w
                  ),
                  Container(
                    height: h,
                    width: w,
                    child: Text(
                        'Earlier (Around 5-7 PM)',
                      textAlign: TextAlign.end,
                    )
                  ),
                  Container(
                    height: h,
                    width: w,
                    child: Text(
                        'Later  (Around 7-9 PM)',
                      textAlign: TextAlign.end,
                    )
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                      height: h,
                      width: w,
                    child: Center(
                      child: Text(
                        'Monday',
                        style: kDayOfTheWeekText,
                      ),
                    )
                  ),
                  Container(
                    height: h,
                    width: w,
                    child:
                      MatrixPillButton(
                        isSelected: usersAvailability[0],
                        onTap: (){
                          print(usersAvailability[0]);
                          setState(() {
                            if (usersAvailability[0] == true) {
                              usersAvailability[0] = false;
                            } else {
                              usersAvailability[0] = true;
                            }
                          });
                        },
                      ),
                    // Checkbox(
                    //   value: usersAvailability[0],
                    //   onChanged: (value){
                    //     print(value);
                    //     setState(() {
                    //       usersAvailability[0] = value;
                    //     });
                    //   },
                    // )
                  ),
                  Container(
                      height: h,
                      width: w,
                    child: MatrixPillButton(
                      isSelected: usersAvailability[1],
                      onTap: (){
                        print(usersAvailability[1]);
                        setState(() {
                          if (usersAvailability[1] == true) {
                            usersAvailability[1] = false;
                          } else {
                            usersAvailability[1] = true;
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                      height: h,
                      width: w,
                      child: Center(
                        child: Text(
                          'Monday',
                          style: kDayOfTheWeekText,
                        ),
                      )
                  ),
                  Container(
                      height: h,
                      width: w,
                      child:
                      MatrixPillButton(
                        isSelected: usersAvailability[2],
                        onTap: (){
                          print(usersAvailability[2]);
                          setState(() {
                            if (usersAvailability[2] == true) {
                              usersAvailability[2] = false;
                            } else {
                              usersAvailability[2] = true;
                            }
                          });
                        },
                      ),
                  ),
                  Container(
                      height: h,
                      width: w,
                      child: MatrixPillButton(
                        isSelected: usersAvailability[3],
                        onTap: (){
                          print(usersAvailability[3]);
                          setState(() {
                            if (usersAvailability[3] == true) {
                              usersAvailability[3] = false;
                            } else {
                              usersAvailability[3] = true;
                            }
                          });
                        },
                      ),
                  ),
                ],
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                      height: h,
                      width: w,
                      child: Center(
                        child: Text(
                          'Monday',
                          style: kDayOfTheWeekText,
                        ),
                      )
                  ),
                  Container(
                    height: h,
                    width: w,
                    child:
                    MatrixPillButton(
                      isSelected: usersAvailability[2],
                      onTap: (){
                        print(usersAvailability[2]);
                        setState(() {
                          if (usersAvailability[2] == true) {
                            usersAvailability[2] = false;
                          } else {
                            usersAvailability[2] = true;
                          }
                        });
                      },
                    ),
                  ),
                  Container(
                    height: h,
                    width: w,
                    child: MatrixPillButton(
                      isSelected: usersAvailability[3],
                      onTap: (){
                        print(usersAvailability[3]);
                        setState(() {
                          if (usersAvailability[3] == true) {
                            usersAvailability[3] = false;
                          } else {
                            usersAvailability[3] = true;
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                      height: h,
                      width: w,
                      child: Center(
                        child: Text(
                          'Monday',
                          style: kDayOfTheWeekText,
                        ),
                      )
                  ),
                  Container(
                    height: h,
                    width: w,
                    child:
                    MatrixPillButton(
                      isSelected: usersAvailability[2],
                      onTap: (){
                        print(usersAvailability[2]);
                        setState(() {
                          if (usersAvailability[2] == true) {
                            usersAvailability[2] = false;
                          } else {
                            usersAvailability[2] = true;
                          }
                        });
                      },
                    ),
                  ),
                  Container(
                    height: h,
                    width: w,
                    child: MatrixPillButton(
                      isSelected: usersAvailability[3],
                      onTap: (){
                        print(usersAvailability[3]);
                        setState(() {
                          if (usersAvailability[3] == true) {
                            usersAvailability[3] = false;
                          } else {
                            usersAvailability[3] = true;
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                      height: h,
                      width: w,
                      child: Center(
                        child: Text(
                          'Monday',
                          style: kDayOfTheWeekText,
                        ),
                      )
                  ),
                  Container(
                    height: h,
                    width: w,
                    child:
                    MatrixPillButton(
                      isSelected: usersAvailability[2],
                      onTap: (){
                        print(usersAvailability[2]);
                        setState(() {
                          if (usersAvailability[2] == true) {
                            usersAvailability[2] = false;
                          } else {
                            usersAvailability[2] = true;
                          }
                        });
                      },
                    ),
                  ),
                  Container(
                    height: h,
                    width: w,
                    child: MatrixPillButton(
                      isSelected: usersAvailability[3],
                      onTap: (){
                        print(usersAvailability[3]);
                        setState(() {
                          if (usersAvailability[3] == true) {
                            usersAvailability[3] = false;
                          } else {
                            usersAvailability[3] = true;
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),





            ],
          ),
        ),
      ),
    );
  }


  // buildTimeMatrix() {
  //   Tonight tonight = Tonight.early;
  //   return Column(
  //     children: [
  //       //Row #1
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //         children: [
  //           //Time Column
  //           // Column(
  //           //   children: [
  //           //     Text(''), //Ghost
  //           //     Text('5-7 PM'),
  //           //     Text('7-9 PM')
  //           //   ],
  //           // ),
  //           //Mon Column
  //           Column(
  //             crossAxisAlignment: CrossAxisAlignment.end,
  //             children: [
  //               Text('Tomorrow'),
  //               Row(
  //                 children: [
  //                   Text('5-7 PM'),
  //                   SizedBox(width: 30),
  //                   Radio(),
  //                 ],
  //               ),
  //               Row(
  //                 children: [
  //                   Text('7-9 PM'),
  //                   SizedBox(width: 30),
  //                   Radio(),
  //                 ],
  //               ),
  //             ],
  //           ),
  //           //Tues Column
  //           Column(
  //             children: [
  //               Text(
  //                 DateFormat.EEEE().format(now.add(Duration(days: 2))),
  //               ),
  //               Radio(),
  //               Radio(),
  //             ],
  //           ),
  //           //Wed Column
  //           Column(
  //             children: [
  //               Text(
  //                 DateFormat.EEEE().format(now.add(Duration(days: 3))),
  //               ),
  //               Radio(),
  //               Radio(),
  //             ],
  //           ),
  //           //Thurs Column
  //           Column(
  //             children: [
  //               Text(
  //                 DateFormat.EEEE().format(now.add(Duration(days: 4))),
  //               ),
  //               Radio(),
  //               Radio(),
  //             ],
  //           ),
  //         ],
  //       ),
  //
  //     ],
  //   );
  // }

  buildDateButtonsRow() {
    return Wrap(
      children: [
        DateButton(
            text: 'Tonight',
            text2: tonightText,
            color: selectedDay == DateDay.Today
                ? kPillButtonSelectedColor
                : isAvailableTonight
                    ? kPillButtonUnselectedColor
                    : kPillButtonUnselectedColor,
            fontColor: selectedDay == DateDay.Today
                ? Colors.white
                : isAvailableTonight
                    ? Colors.green
                    : kButtonColor,
            border: selectedDay == DateDay.Today
                ? Border.all(width: 1, color: Colors.black)
                : isAvailableTonight
                    ? Border.all(width: 1, color: Colors.green)
                    : Border.all(width: 0, color: kPillButtonUnselectedColor),
            onTap: () {
              setState(() {
                //Hide past times
                print(hide46);
                if (availableTimeSlots[0] == null) {
                  hide46 = true;
                  print(hide46);
                }
                if (availableTimeSlots[1] == null) {
                  hide68 = true;
                }
                if (availableTimeSlots[2] == null) {
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
              ? kPillButtonSelectedColor
              : isAvailableTomorrow
                  ? kPillButtonUnselectedColor
                  : kPillButtonUnselectedColor,
          // ? Colors.white
          // : Colors.white,
          fontColor: selectedDay == DateDay.Tomorrow
              ? Colors.white
              : isAvailableTomorrow
                  ? Colors.green
                  : kButtonColor,
          //: kLightDark,
          border: selectedDay == DateDay.Tomorrow
              ? Border.all(width: 1, color: Colors.black)
              : isAvailableTomorrow
                  ? Border.all(width: 1, color: Colors.green)
                  : Border.all(width: 0, color: kPillButtonUnselectedColor),
          // : Border.all(width: 1, color: kLightDark),
          onTap: () {
            setState(() {
              //Hide past times
              if (hide46 == true) {
                hide46 = false;
              }
              if (hide68 == true) {
                hide68 = false;
              }
              if (hide810 == true) {
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
              ? kPillButtonSelectedColor
              : isAvailableThirdDay
                  ? kPillButtonUnselectedColor
                  : kPillButtonUnselectedColor,
          fontColor: selectedDay == DateDay.ThirdDay
              ? Colors.white
              : isAvailableThirdDay
                  ? Colors.green
                  : kButtonColor,
          border: selectedDay == DateDay.ThirdDay
              ? Border.all(width: 1, color: Colors.black)
              : isAvailableThirdDay
                  ? Border.all(width: 1, color: Colors.green)
                  : Border.all(width: 0, color: kPillButtonUnselectedColor),
          // : Border.all(width: 1, color: kLightDark),
          onTap: () {
            setState(() {
              //Hide past times
              if (hide46 == true) {
                hide46 = false;
              }
              if (hide68 == true) {
                hide68 = false;
              }
              if (hide810 == true) {
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
        // DateButton(
        //     text: DateFormat.EEEE().format(now.add(Duration(days: 3))),
        //     text2: '${DateFormat.Md().format(now.add(Duration(days: 3)))}',
        //     color: selectedDay == DateDay.FourthDay
        //         ? kPillButtonSelectedColor
        //         : isAvailableFourthDay
        //             ? Colors.white
        //             : Colors.white,
        //     fontColor: selectedDay == DateDay.FourthDay
        //         ? Colors.white
        //         : isAvailableFourthDay
        //             ? Colors.green
        //             : kLightDark,
        //     border: selectedDay == DateDay.FourthDay
        //         ? Border.all(width: 1, color: Colors.black)
        //         : isAvailableFourthDay
        //             ? Border.all(width: 1, color: Colors.green)
        //             : Border.all(width: 1, color: kLightDark),
        //     onTap: () {
        //       setState(() {
        //         //Hide past times
        //         if (hide46 == true){
        //           hide46 = false;
        //         }
        //         if (hide68 == true){
        //           hide68 = false;
        //         }
        //         if (hide810 == true){
        //           hide810 = false;
        //         }
        //
        //         //Toggle selectedDay
        //         if (selectedDay == DateDay.FourthDay) {
        //           selectedDay = DateDay.None;
        //           selectedText = '';
        //           toggle46 = false;
        //           toggle68 = false;
        //           toggle810 = false;
        //         } else {
        //           selectedDay = DateDay.FourthDay;
        //           selectedText = fourthDayText;
        //           toggle46 = usersAvailability[9];
        //           toggle68 = usersAvailability[10];
        //           toggle810 = usersAvailability[11];
        //         }
        //
        //         //Toggle isAvailableTonight
        //         if (usersAvailability[0] == false &&
        //             usersAvailability[1] == false &&
        //             usersAvailability[2] == false) {
        //           isAvailableTonight = false;
        //         } else {
        //           isAvailableTonight = true;
        //         }
        //
        //         //Toggle isAvailableTomorrow
        //         if (usersAvailability[3] == false &&
        //             usersAvailability[4] == false &&
        //             usersAvailability[5] == false) {
        //           isAvailableTomorrow = false;
        //         } else {
        //           isAvailableTomorrow = true;
        //         }
        //
        //         //Toggle isAvailableThirdDay
        //         if (usersAvailability[6] == false &&
        //             usersAvailability[7] == false &&
        //             usersAvailability[8] == false) {
        //           isAvailableThirdDay = false;
        //         } else {
        //           isAvailableThirdDay = true;
        //         }
        //
        //         //Toggle isAvailableFourthDay
        //         if (usersAvailability[9] == false &&
        //             usersAvailability[10] == false &&
        //             usersAvailability[11] == false) {
        //           isAvailableFourthDay = false;
        //         } else {
        //           isAvailableFourthDay = true;
        //         }
        //
        //       });
        //     }),
      ],
    );
  }

  buildNoCurrentMatchesWidget({Date dateDoc}) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              padding: EdgeInsets.all(20.0),
              child: Text(
                  'There are no more availabilities at this time. Check back later or widen your availability by pressing Edit Availability.'),
            ),
            TextButton(
              child: Text('Edit Availability'),
              onPressed: () {
                populateInputScreen(currentDate);

                setState(
                  () {
                    dateExists = false;
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  buildMatchesProfiles() {
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
            backFunction: () {
              populateInputScreen(currentDate);

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
                      backgroundColor: kPillButtonUnselectedColor,
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
                        Icons.arrow_forward_ios_rounded,
                        color: kPillButtonSelectedColor,
                        // Icons.favorite,
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
                        Icons.arrow_back_ios_new_sharp,
                        color: kPillButtonSelectedColor,
                        //Icons.close,
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
            ? buildMatchesProfiles()
            : buildWelcomePage();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    activityController.dispose();
    dinnerActivityController.dispose();
    super.dispose();
  }
}




