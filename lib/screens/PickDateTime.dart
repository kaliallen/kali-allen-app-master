import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:kaliallendatingapp/screens/BrowseStartPage.dart';
import 'package:kaliallendatingapp/screens/Home.dart';
import 'package:kaliallendatingapp/widgets/PillButton.dart';
import 'package:kaliallendatingapp/widgets/StyledButton.dart';

import '../constants.dart';

class PickDateTimePage extends StatefulWidget {
  bool viewAsBrowseMode;
  DateDay selectedDay;
  String dateActivity;
  RangeValues currentRangeValues; // = RangeValues(5,10);
  bool drinksSelected;
  bool friendsSelected;
  bool splitBillSelected;

  PickDateTimePage(
      {this.viewAsBrowseMode,
      this.dateActivity,
      this.currentRangeValues,
      this.drinksSelected,
      this.friendsSelected,
      this.splitBillSelected,
      this.selectedDay});

  @override
  _PickDateTimePageState createState() => _PickDateTimePageState();
}

class _PickDateTimePageState extends State<PickDateTimePage> {
  TextEditingController activityController = TextEditingController();
  FixedExtentScrollController endTimeController = FixedExtentScrollController(initialItem: 5);
  ScrollController _firstController = ScrollController();

  DateTime now = DateTime.now();
  DateTime availableDateTime = DateTime.now();
  int startTime = 0;
  int endTime = 5;
  int dropDownValue = 5;
  bool addMessageSelected = false;
  bool addPreferenceSelected = false;
  bool addDinner = false;
  bool addDrinks = false;
  bool addAdventure = false;
  bool addMessage = false;
  DateDay selectedDay = DateDay.Today;

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
              color: kLightDark,
            ),
          ),
        ),
        Container(
            child: Text(
                widget.viewAsBrowseMode
                    ? 'Edit Time & Date'
                    : 'Pick Time & Date',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                  color: kDarkest,
                ))),
      ],
    );
  }

  buildDateButtonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        DateButton(
            text: 'Tonight',
            color: widget.selectedDay == DateDay.Today
                ? kButtonColor
                : Colors.white,
            fontColor: widget.selectedDay == DateDay.Today
                ? Colors.white
                : kLightDark,
            border: widget.selectedDay == DateDay.Today
                ? null
                : Border.all(width: 1, color: kLightDark),
            onTap: () {
              setState(() {
                widget.selectedDay = DateDay.Today;
              });
            }),
        DateButton(
          text: 'Tomorrow',
          color: widget.selectedDay == DateDay.Tomorrow
              ? kButtonColor
              : Colors.white,
          fontColor: widget.selectedDay == DateDay.Tomorrow
              ? Colors.white
              : kLightDark,
          border: widget.selectedDay == DateDay.Tomorrow
              ? null
              : Border.all(width: 1, color: kLightDark),
          onTap: () {
            setState(() {
              widget.selectedDay = DateDay.Tomorrow;
            });
          },
        ),
        DateButton(
          text: DateFormat.EEEE().format(now.add(Duration(days: 2))),
          color: widget.selectedDay == DateDay.ThirdDay
              ? kButtonColor
              : Colors.white,
          fontColor: widget.selectedDay == DateDay.ThirdDay
              ? Colors.white
              : kLightDark,
          border: widget.selectedDay == DateDay.ThirdDay
              ? null
              : Border.all(width: 1, color: kLightDark),
          onTap: () {
            setState(() {
              widget.selectedDay = DateDay.ThirdDay;
            });
          },
        ),
      ],
    );
  }

  buildIconAndText({String text, IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              color: kDarkish,
            ),
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 17.0,
              color: kDarkish,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  buildReviewText(){
    return Center(
      child: Column(
        children: [
          Text(
           widget.selectedDay == DateDay.Today ? 'Tonight' : widget.selectedDay == DateDay.Tomorrow ? 'Tomorrow night' : '${DateFormat.EEEE().format(now.add(Duration(days: 2)))}',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            widget.selectedDay == DateDay.Today ? '${DateFormat.MEd().format(now)}' : widget.selectedDay == DateDay.Tomorrow ? '${DateFormat.MEd().format(now.add(Duration(days: 1)))}' : '${DateFormat.MEd().format(now.add(Duration(days: 2)))}',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            '${startTime}-${widget.currentRangeValues.end.round()} pm',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }


  buildActivityField(){
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
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
    );
  }

  createDateDoc() {
    String userId = FirebaseAuth.instance.currentUser.uid;
    //Create Doc for Date Selected
    String selectedDate;
    if (widget.selectedDay == DateDay.Today) {
      selectedDate = DateFormat.yMMMEd().format(now);
      //TODO: Conver this format, whatever it is, to DateTime.
    } else if (widget.selectedDay == DateDay.Tomorrow) {
      selectedDate =
          DateFormat.yMMMEd().format(now.add(Duration(days: 1)));
    } else if (widget.selectedDay == DateDay.ThirdDay) {
      selectedDate =
          DateFormat.yMMMEd().format(now.add(Duration(days: 2)));
    } else {
      print('error');
    }


    //Create Map for Preference Data
    Map<String, bool> preferences = {
      'drinksSelected': widget.drinksSelected,
      'friendsSelected': widget.friendsSelected,
      'splitBillSelected': widget.splitBillSelected,
    };

    //Must create document and collection before you can set data
    datesRef.doc(selectedDate).set({
      'exampleData': null,
    });

    //Set Data to Dates Collection
    datesRef.doc(selectedDate).collection('users').doc(userId).set({
      'uid': userId,
      'startTime': widget.currentRangeValues.start.toInt(),
      'endTime': widget.currentRangeValues.end.toInt(),
      'matches': null,
      'activityText': widget.dateActivity,
      'preferences': preferences,
    });
  }

  getDateData() {
    setState(() {
      widget.dateActivity != null
          ? activityController.text = widget.dateActivity
          : print('activity is null');
    });
  }

  @override
  void initState() {
    getDateData();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.viewAsBrowseMode ? 'Edit Time & Date' : 'Pick Time & Date',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
            color: kDarkest,
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: kLightDark,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                    padding: const EdgeInsets.only(
                        bottom: 15, left: 5, top: 15),
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
                        style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500)),
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
                    text: 'Find a date',
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
          )
              ],
            ),
          ),
        );

  }



  @override
  void dispose() {
    // TODO: implement dispose
    activityController.dispose();
    super.dispose();

  }
}



class TimeText extends StatelessWidget {
  final String text;

  TimeText(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
          child: Text(text,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
              )),
        )
    );
  }
}


// class PillButton extends StatelessWidget {
//   final String text;
//   final Color color;
//   final Function onTap;
//   final Color fontColor;
//
//   const PillButton(
//       {Key key, this.text, this.color, this.onTap, this.fontColor});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(5),
//       child: GestureDetector(
//         onTap: onTap,
//         child: Container(
//           child: Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Text(
//               text,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: fontColor,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           decoration: BoxDecoration(
//               color: color, borderRadius: BorderRadius.circular(20.0)),
//         ),
//       ),
//     );
//   }
//
// }


//Slider Option
// Column(
// children: [
// buildIconAndText(
// text: 'Time',
// icon: Icons.access_time,
// ),
// Padding(
// padding: const EdgeInsets.symmetric(horizontal: 30.0),
// child: RangeSlider(
// activeColor: kButtonColor,
// inactiveColor: kDarkish,
// values: widget.currentRangeValues,
// min: 5,
// max: 10,
// divisions: 5,
// labels: RangeLabels(
// '${widget.currentRangeValues.start.round().toString()} PM',
// '${widget.currentRangeValues.end.round().toString()} PM',
// ),
// onChanged: (RangeValues values) {
// setState(() {
// widget.currentRangeValues = values;
// });
// },
// ),
// ),
// // Text(
// //   '${widget.currentRangeValues.start.toInt().toString()} pm - ${widget.currentRangeValues.end.toInt().toString()} pm',
// //   textAlign: TextAlign.center,
// // ),
// ],
// )