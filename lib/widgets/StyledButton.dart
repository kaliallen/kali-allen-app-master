import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants.dart';

class StyledButton extends StatelessWidget {

  StyledButton({this.text, this.onTap, this.color, this.fontColor});

  final String? text;
  final VoidCallback? onTap;
  final Color? color;
  final Color? fontColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
        child: Container(
          height: 50.0,
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.black54,
              blurRadius: 1,
              offset: Offset(3.0, 2.5)
          )
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment(-20.51, 133.59),
          colors: [color!, color!],
        ),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Center(
          child: Text(
              text!,
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: fontColor == null ? kWhiteSquareColor : fontColor,
            //  fontWeight: FontWeight.w500,
            //  letterSpacing: .1,
            ),
          )
      ),


    ));
  }
}
