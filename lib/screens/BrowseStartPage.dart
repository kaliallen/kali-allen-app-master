import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
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
  DateTime now = DateTime.now();
  DateTime availableDateTime = DateTime.now();
  int startTime;
  int endTime;

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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
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
      ),
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
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Text(
              'Available',
              style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w300,
            ),
            ),
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
              '${widget.currentRangeValues.start.round()}-${widget.currentRangeValues.end.round()} pm',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildActivityField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text('Include an Activity',
              textAlign: TextAlign.left,
              style: TextStyle(
                color: kDarkish,
                fontWeight: FontWeight.w700,
                fontSize: 17.0,
              )),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: TextField(
            //TextEditingController
            decoration: InputDecoration(
              hintText: '\"Happy hour at my favorite dive bar\"',
              hintStyle: TextStyle(
                fontStyle: FontStyle.italic,
                color: kLightDark,
              ),
            ),
          ),
        ),
      ],
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
          widget.viewAsBrowseMode ? 'Reset Time & Date' : 'Pick Time & Date',
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
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(top: 15.0, bottom: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildReviewText(),
                buildIconAndText(
                  text: 'Date',
                  icon: Icons.event,
                ),
                buildDateButtonsRow(),
                Column(
                  children: [
                    buildIconAndText(
                      text: 'Time',
                      icon: Icons.access_time,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: RangeSlider(
                        activeColor: kButtonColor,
                        inactiveColor: kDarkish,
                        values: widget.currentRangeValues,
                        min: 5,
                        max: 10,
                        divisions: 5,
                        labels: RangeLabels(
                          '${widget.currentRangeValues.start.round().toString()} PM',
                          '${widget.currentRangeValues.end.round().toString()} PM',
                        ),
                        onChanged: (RangeValues values) {
                          setState(() {
                            widget.currentRangeValues = values;
                          });
                        },
                      ),
                    ),
                    // Text(
                    //   '${widget.currentRangeValues.start.toInt().toString()} pm - ${widget.currentRangeValues.end.toInt().toString()} pm',
                    //   textAlign: TextAlign.center,
                    // ),
                  ],
                ),
                Divider(
                  color: kLightDark,
                ),
                //IncludeActivity
                buildActivityField(),
                //Include Preferences
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text('Include Preferences',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: kDarkish,
                        fontSize: 17.0,
                        fontWeight: FontWeight.w700,
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Wrap(
                    children: [
                      PillButton(
                          text: 'Drinks',
                          isSelected: widget.drinksSelected,
                          onTap: () {
                            setState(() {
                              widget.drinksSelected == true
                                  ? widget.drinksSelected = false
                                  : widget.drinksSelected = true;
                            });
                          }),
                      PillButton(
                          text: 'Friends are welcome',
                          isSelected: widget.friendsSelected,
                          onTap: () {
                            setState(() {
                              widget.friendsSelected == true
                                  ? widget.friendsSelected = false
                                  : widget.friendsSelected = true;
                            });
                          }),
                      PillButton(
                          text: 'We split the bill',
                          isSelected: widget.splitBillSelected,
                          onTap: () {
                            setState(() {
                              widget.splitBillSelected == true
                                  ? widget.splitBillSelected = false
                                  : widget.splitBillSelected = true;
                            });
                          }),
                      PillButton(
                          //TODO: Figure this one out...
                          text: 'Pre-date video chat',
                          isSelected: widget.splitBillSelected,
                          onTap: () {
                            print('Drinks was selected');
                          }),
                    ],
                  ),
                ),
                Divider(
                  color: kLightDark,
                ),

                SizedBox(height: 15.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: StyledButton(
                      text: 'Search for Matches',
                      color: kButtonColor,
                      onTap: () {
                        //Check to see if there is a doc created,
                        //If not, create one
                        createDateDoc();
                        //If yes, add to doc
                        print('${DateFormat.yMMMEd().format(now)}');
                        Navigator.pop(context);
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DateButton extends StatelessWidget {
  DateButton(
      {this.text,
      this.onTap,
      this.color,
      this.dateDay,
      this.border,
      this.fontColor});

  final DateDay dateDay;
  final String text;
  final Function onTap;
  final Color color;
  final Color fontColor;
  final Border border;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          height: 50.0,
          width: MediaQuery.of(context).size.width * .27,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment(-20.51, 133.59),
              colors: [color, color],
            ),
            borderRadius: BorderRadius.circular(10.0),
            border: border,
          ),
          child: Center(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 16.0,
                color: fontColor,
              ),
            ),
          )),
        ));
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
// }
