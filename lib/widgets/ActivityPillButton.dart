import 'package:flutter/material.dart';
import 'package:kaliallendatingapp/constants.dart';

class ActivityPillButton extends StatelessWidget {
  final bool isSelected;
  final String text;
  final Function onTap;
  final bool infoSaved;


  const ActivityPillButton(
      {Key key, this.text,  this.onTap, this.isSelected, this.infoSaved});

  // selectedDay == DateDay.Today
  // ? Colors.black
  //     : isAvailableTonight
  // ? Colors.white
  //     : Colors.white,

  // isSelected?
  // ? Colors.white
  //     : isAvailableTonight
  // ? Colors.green
  //     : kLightDark,

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: infoSaved ? Colors.white : isSelected ? Colors.white : kButtonColor,
                  fontSize: 14.0,
                )
            ),
          ),
          decoration: BoxDecoration(
              color:
                  infoSaved ? Colors.green : isSelected? kPillButtonSelectedColor : kPillButtonUnselectedColor,

              borderRadius: BorderRadius.circular(20.0)),
        ),
      ),
    );
  }

}