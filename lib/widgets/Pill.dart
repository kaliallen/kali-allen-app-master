import 'package:flutter/material.dart';
import 'package:kaliallendatingapp/constants.dart';

class Pill extends StatelessWidget {
  final String? text;
  final Color? color;

  const Pill({Key? key, this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, top: 10),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.only(right: 10, left: 10, top: 5.0, bottom: 5.0),
          child: Text(
            text!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(15.0)),
      ),
    );
  }
}
