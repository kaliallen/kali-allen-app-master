import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants.dart';

class StyledButton extends StatelessWidget {

  StyledButton({this.text, this.onTap, this.color, this.fontColor, this.border, this.height, this.width});

  final String? text;
  final VoidCallback? onTap;
  final Color? color;
  final Color? fontColor;
  final Border? border;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
        child: Container(
          height: height == null ? 50.0 : height,
      width: width == null ? MediaQuery
          .of(context)
          .size
          .height : width,
      decoration: BoxDecoration(
        border: border == null ? Border.all() : border,
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.black54,
              blurRadius: 1,
              // offset: Offset(3.0, 2.5)
          )
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment(-20.51, 133.59),
          colors: [color!, color!],
        ),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Center(
          child: Text(
              text!,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color: fontColor == null ? kWhiteSquareColor : fontColor,
            //  fontWeight: FontWeight.w500,
            //  letterSpacing: .1,
            ),
          )
      ),


    ));
  }
}
