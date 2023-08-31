import 'package:flutter/material.dart';
import 'package:kaliallendatingapp/constants.dart';

class ActivityPillButton extends StatelessWidget {
  final bool? isSelected;
  final String ?text;
  final void Function()? onTap;
  final bool? infoSaved;


  const ActivityPillButton(
      {Key? key, this.text,  this.onTap, this.isSelected, this.infoSaved});

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
        onTap: onTap!,
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
                text!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: infoSaved == true ? Colors.white : isSelected == true ? Colors.white : kButtonColor,
                  fontSize: 14.0,
                )
            ),
          ),
          decoration: BoxDecoration(
              color:
                  infoSaved == true ? Colors.green : isSelected == true ? kPillButtonSelectedColor : kPillButtonUnselectedColor,

              borderRadius: BorderRadius.circular(20.0)),
        ),
      ),
    );
  }

}