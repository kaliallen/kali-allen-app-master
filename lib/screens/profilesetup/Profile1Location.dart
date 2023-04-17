//TODO: Make it so you must have a value to continue...?
//TODO: What if people make a really long string here. Is there a character cutoff? How will that affect what the profile looks like?

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/screens/Home.dart';
import 'package:kaliallendatingapp/screens/profilesetup/Profile2Birthday.dart';
import 'package:kaliallendatingapp/widgets/StyledButton.dart';
import 'package:location/location.dart';
import 'package:page_transition/page_transition.dart';

import '../../models/userData.dart';



class ProfileSetup extends StatefulWidget {
  final UserData _userData = UserData();



  @override
  _ProfileSetupState createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  TextEditingController controller = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Big Title Question
              IconButton(icon: Icon(Icons.arrow_back_ios_sharp,
                color: kLightDark,
              ), onPressed: () async {
                await FirebaseAuth.instance.signOut();
                  // Navigator.popUntil(context, ModalRoute.withName(Home.id));
                Navigator.pushNamed(context, Home.id);

              }),
              Text('Where do you live?',
                  style: TextStyle(
                    // letterSpacing: 2.0,
                    fontSize: 30.0,
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.w600,
                    color: kDarkest,
                  ),
              ),
              Column(
                children: [
                  TextField(
                    controller: controller,
                    textCapitalization: TextCapitalization.words,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Dupont Circle, H-Street Corridor, etc.'
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      '(This can be changed later.)',
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ),

                ],
              ),
              //TextField/Content
              //Next Button
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: StyledButton(
                  text: 'Next',
                  color: kButtonColor,
                  onTap: () {
                    //Add location to userData
                    if (controller.text.trim().isNotEmpty){
                      widget._userData.location = controller.text.trim();
                    } else {
                      print('No Location moving on...');
                    }

                    //Go to next page
                    Navigator.push(context, PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: ProfileBirthday(
                      userData: widget._userData,
                    )));

                  },
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}
