import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/models/userData.dart';
import 'package:kaliallendatingapp/screens/profilesetup/Profile4Gender.dart';
import 'package:kaliallendatingapp/widgets/StyledButton.dart';
import 'package:page_transition/page_transition.dart';

//TODO: Make a validation so the user cant pass until they enter in a name that is more than 2 characters long


class ProfileName extends StatefulWidget {
  final UserData _userData;

  ProfileName({@required UserData userData})
      : assert(userData != null),
        _userData = userData;

  @override
  _ProfileNameState createState() => _ProfileNameState();
}

class _ProfileNameState extends State<ProfileName> {
  TextEditingController controller = TextEditingController();
  bool areNamesEntered = true;


  @override
  Widget build(BuildContext context) {
    String lastName;
    String firstName;
    return Scaffold(
        body: SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Big Title Question
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
            child: Text('What\'s your name?',
                style: TextStyle(
                  // letterSpacing: 2.0,
                  fontSize: 30.0,
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.w600,
                  color: kDarkest,
                )),
          ),
          Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 25.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      textAlign: TextAlign.center,
                      textCapitalization: TextCapitalization.words,
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                      ),

                    ),
                  ),
                ],
              )),
          //TextField/Content
          Padding(
            padding:
                const EdgeInsets.only(bottom: 30.0, right: 25.0, left: 25.0),
            child: StyledButton(
              text: 'Continue',
              color: kButtonColor,
              onTap: () {
               if (controller.text.trim().isNotEmpty){
                   widget._userData.firstName = firstName;
                     Navigator.push(
                       context,
                       PageTransition(
                           type: PageTransitionType.rightToLeft,
                           child: ProfileGender(userData: widget._userData)));
               } else {
                 print('No first name entered');
               }

              },
            ),
          )
        ],
      ),
    ));

    // return Scaffold(
    //   body: SafeArea(
    //     child: Padding(
    //       padding: const EdgeInsets.all(20.0),
    //       child: SingleChildScrollView(
    //         child: Padding(
    //           padding: const EdgeInsets.all(20.0),
    //           child: Container(
    //               child: Column(
    //                 children: [
    //                   Text(
    //                     'What\'s your name?',
    //                     style: kHeadingText,
    //                   ),
    //                   TextField(
    //                     decoration: InputDecoration(
    //                       labelText: 'First Name',
    //                     ),
    //                     onChanged: (value){
    //                       firstName = value;
    //                     },
    //                   ),
    //                   TextField(
    //                     decoration: InputDecoration(
    //                       labelText: 'Last Name'
    //                     ),
    //                     onChanged: (value){
    //                       lastName = value;
    //                     },
    //                   ),
    //                   SizedBox(height: 15.0),
    //                   StyledButton(
    //                     text: 'Continue',
    //                     color: Colors.grey,
    //                     onTap: (){
    //                       if (lastName != null && firstName !=null) {
    //                         _userData.firstName = firstName;
    //                          _userData.lastName = lastName;
    //                         Navigator.push(context, PageTransition(
    //                           type: PageTransitionType.rightToLeft,
    //                             child: ProfileGender(userData: _userData)));
    //
    //                       } else {
    //                        print('Error. Need both First and Last name entered');
    //                       }
    //                     },
    //                   ),
    //                 ],
    //               )
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
