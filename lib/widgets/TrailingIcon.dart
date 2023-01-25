import 'package:flutter/material.dart';
import '../constants.dart';

class LeadingIcon extends StatelessWidget {
  IconData icon;
  Function function;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        print('Pressed');
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: kYellow,
            radius: 20,
            child: Icon(
              icon,
              color: kDark,
            ),
          ),
          Text('title'),
        ],
      ),
    );
  }
}