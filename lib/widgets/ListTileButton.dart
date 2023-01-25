import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

const TextStyle tileFont = TextStyle(
  fontWeight: FontWeight.w500,
);

class ListTileButton extends StatelessWidget {

  final IconData icon;
  final String text;
  final Function onTap;


  const ListTileButton({Key key, this.icon, this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return  ListTile(
      leading: CircleAvatar(
        backgroundColor: kPillButtonUnselectedColor,
        radius: 20,
        child: Icon(
          icon,
          color: kDark,
        ),
      ),
      title: Text(text,
        style: tileFont,
      ),
      trailing: GestureDetector(
        onTap: onTap,
        child: Container(
          //   margin: EdgeInsets.all(5.0),
            width: 45.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: kScaffoldBackgroundColor,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 13.0),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 15.0,
                color: kDark,
              ),
            )
        ),
      ),
    );
  }
}

