import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/models/userData.dart';
import 'package:kaliallendatingapp/screens/profilesetup/Profile10School.dart';
import 'package:kaliallendatingapp/widgets/StyledButton.dart';
import 'package:page_transition/page_transition.dart';

class ProfileJob extends StatelessWidget {
  final UserData? _userData;

  ProfileJob({@required UserData? userData})
      : assert(userData !=null),
        _userData = userData;

  @override
  Widget build(BuildContext context) {
    String? work;

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_sharp,
                    color: kLightDark,
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                  }),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: Text('What do you do?',
                  style: TextStyle(
                    // letterSpacing: 2.0,
                    fontSize: 30.0,
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.w600,
                    color: kDarkest,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: TextField(
                // textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Job',
                ),
                onChanged: (value){
                  work = value;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0, right: 25.0, left: 25.0),
              child: StyledButton(
                text: 'Continue',
                color: kButtonColor,
                onTap: (){

                  if (work != null){
                    _userData!.occupation = work;
                  }

                  Navigator.push(context, PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: ProfileSchool(
                        userData: _userData,
                      )));

                  // } else {
                  //   print('Error. Need both First and Last name entered');
                  // }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
