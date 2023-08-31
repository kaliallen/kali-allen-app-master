import 'package:flutter/material.dart';
import 'package:kaliallendatingapp/constants.dart';

class PillButton extends StatelessWidget {
  final bool? isSelected;
  final String? text;
  final void Function()? onTap;



  const PillButton(
      {Key? key, this.text,  this.onTap, this.isSelected});

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
                color: isSelected == true ? Colors.white :  kButtonColor,
                fontSize: 14.0,
              )
            ),
          ),
          decoration: BoxDecoration(
              color: isSelected == true ? kPillButtonSelectedColor : kPillButtonUnselectedColor,
              borderRadius: BorderRadius.circular(20.0)),
        ),
      ),
    );
  }

}