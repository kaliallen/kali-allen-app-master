//TODO: Make a "Save for later" button below the Continue button
//TODO: Automate the activitybuttons and activityboxes (Don't know how to right now)
//TODO: Add a custom activity button

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/main.dart';
import 'package:kaliallendatingapp/models/userData.dart';
import 'package:kaliallendatingapp/screens/Home.dart';
import 'package:kaliallendatingapp/widgets/PillButton.dart';
import 'package:kaliallendatingapp/widgets/StyledButton.dart';

final DateTime timestamp = DateTime.now();

class ProfileActivities extends StatefulWidget {
  UserData? _userData;


  ProfileActivities({@required UserData? userData})
      : assert(userData != null),
        _userData = userData;

  @override
  State<ProfileActivities> createState() => _ProfileActivitiesState();
}

class _ProfileActivitiesState extends State<ProfileActivities> {
  int dateIdeasCount = 0;

  List<String> activities = [
    '🍝 Dinner',
    '🍸 Drinks',
    '🥾 Hike',
    '🌮 Tacos',
    '🎾 Tennis'
  ];

  List<bool> activitiesSelected = [
    false,
    false,
    false,
    false,
    false,
  ];

  List<ActivityBox> activityBoxes = [];

  Map<String, String> activitiesMap = {};

  TextEditingController dinnerController = TextEditingController();
  TextEditingController drinksController = TextEditingController();
  TextEditingController hikeController = TextEditingController();
  TextEditingController tacosController = TextEditingController();
  TextEditingController tennisController = TextEditingController();

  addActivities(){


    for (int i = 0; i < activitiesSelected.length; i++){

      print(activities[i]);
      print(activitiesSelected[i]);

      if (activitiesSelected[i] == true){

      }


    }
  }

  Future uploadUserToFirebase() async {
    //Save UserData data to Firestore under the logged in username
    widget._userData!.setUserDataInFirestore(
      firstName: widget._userData!.firstName,
      lastName: widget._userData!.lastName,
      birthDate: widget._userData!.birthDate,
      gender: widget._userData!.gender,
      isInterestedIn: widget._userData!.isInterestedIn,
      height: widget._userData!.height,
      picture1: widget._userData!.picture1,
      picture2: widget._userData!.picture2,
      picture3: widget._userData!.picture3,
      picture4: widget._userData!.picture4,
      picture5: widget._userData!.picture5,
      prompt1: widget._userData!.prompt1,
      answer1: widget._userData!.answer1,
      occupation: widget._userData!.occupation,
      education: widget._userData!.education,
    );
    final User? user = FirebaseAuth.instance.currentUser;
    DocumentSnapshot doc = await usersRef.doc(user!.uid).get();
    widget._userData = UserData.fromDocument(doc);
    print(
        'if uid is not null _userData is successfully saved from firestore..._userData uid is: ${widget._userData!.uid}');
    if (doc.exists) {
      //Go to home.dart
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => Home()));
    } else {
      print('Doc wasnt added to firestore');
    }
  }

  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_sharp,
                    color: kLightDark,
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                  }),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 25.0),
              child: Text(
                  'List some of your go-to date ideas or any dates that sound fun to you right now.',
                  style: TextStyle(
                    // letterSpacing: 2.0,
                    fontSize: 25.0,
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.w600,
                    color: kDarkest,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Wrap(
                children:
                [
                  ActivityButton(
                    text: '🍝 Dinner',
                    isSelected: activitiesSelected[0],
                    onTap: (){
                      setState(() {
                        if (activitiesSelected[0] == true){
                          activitiesSelected[0] = false;
                          //Remove from Map
                          activitiesMap['🍝 Dinner'] = 'Add details';
                          //Remove from list
                          activityBoxes.removeWhere((element) => element.text == '🍝 Dinner');
                          //Decrease Count
                          dateIdeasCount--;
                        } else {
                          activitiesSelected[0] = true;
                          //Add to list
                          //Increase Count
                          dateIdeasCount++;
                        }
                      });
                    },
                  ),
                  ActivityButton(
                    text: '🍸 Drinks',
                    isSelected: activitiesSelected[1],
                    onTap: (){
                      setState(() {
                        if (activitiesSelected[1] == true){
                          activitiesSelected[1] = false;
                          //Remove from list
                          activityBoxes.removeWhere((element) => element.text == '🍸 Drinks');
                          //Decrease Count
                          dateIdeasCount--;
                        } else {
                          activitiesSelected[1] = true;

                          //Increase Count
                          dateIdeasCount++;
                        }
                      });


                    },
                  ),

                ],
              ),
            ),
            Container(
              // color: Colors.blue,
              padding: const EdgeInsets.all(25.0),
              height: 398.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date Ideas ($dateIdeasCount/5)'),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: activityBoxes,
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(bottom: 30.0, right: 25.0, left: 25.0),
              child: StyledButton(
                  text: 'Continue',
                  color: kButtonColor,
                  onTap: () async {
                    addActivities();
                   //uploadUserToFirebase();
                  }),
            ),
          ], // }
        ),
      ),
    );
  }

  @override
  void dispose() {
    dinnerController.dispose();
    drinksController.dispose();
    hikeController.dispose();
    tacosController.dispose();
    tennisController.dispose();
    super.dispose();
  }

}

class ActivityButton extends StatelessWidget {
  final bool? isSelected;
  final String? text;
  final VoidCallback? onTap;

  const ActivityButton({Key? key, this.text, this.onTap, this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(text!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected == true ? Colors.white : kButtonColor,
                  fontSize: 12.0,
                )),
          ),
          decoration: BoxDecoration(
              color: isSelected == true
                  ? kPillButtonSelectedColor
                  : kPillButtonUnselectedColor,
              borderRadius: BorderRadius.circular(5.0)),
        ),
      ),
    );
  }
}

class ActivityBox extends StatelessWidget {
  final String? text;
  final void Function()? onTap;
  final TextEditingController? controller;
  final Function(String)?  onSubmitted;


  const ActivityBox({Key? key, this.text, this.onTap, this.controller, this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  
                  color: Color(0xFFA7A7A7),
                  width: .5,
                ),
              ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(text!,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15.0,
                        ),
                      ),
                      TextField(
                          onSubmitted: onSubmitted,
                        style: TextStyle(
                          fontSize: 14.0,
    ),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Add details',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(2),
                        )
                      ),
                    ],
                  ),
                ),
            ),
          ),
        ),
        Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
                onTap: onTap,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xffD9D9D9),
                  ),
                  child: Center(
                    child: Text(
                      'X',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                )))
      ],
    );
  }
}
