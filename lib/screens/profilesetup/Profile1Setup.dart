import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/screens/Home.dart';
import 'package:kaliallendatingapp/screens/profilesetup/Profile2Birthday.dart';
import 'package:kaliallendatingapp/widgets/StyledButton.dart';
import 'package:location/location.dart';
import 'package:page_transition/page_transition.dart';



class ProfileSetup extends StatefulWidget {



  @override
  _ProfileSetupState createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Big Title Question
            Padding(
              padding: EdgeInsets.all(8),
              child:  IconButton(icon: Icon(Icons.arrow_back_ios_sharp,
                color: kLightDark,
              ), onPressed: () async {
                await FirebaseAuth.instance.signOut();
                  // Navigator.popUntil(context, ModalRoute.withName(Home.id));
                Navigator.pushNamed(context, Home.id);

              }),
            ),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Text('Where do you live?',
                  style: TextStyle(
                    // letterSpacing: 2.0,
                    fontSize: 30.0,
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.w600,
                    color: kDarkest,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    'This can be changed later.',
                    style: TextStyle(
                      fontSize: 13,
                    ),
                  ),

                ],
              ),
            ),
            //TextField/Content
            //Next Button
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0, right: 25.0, left: 25.0),
              child: StyledButton(
                text: 'Start',
                color: kButtonColor,
                onTap: () {
                  Navigator.push(context, PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: ProfileBirthday()));
                },
              ),
            )
          ],
        ),
      )
    );
  }
}
