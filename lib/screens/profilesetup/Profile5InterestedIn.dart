import 'package:flutter/material.dart';
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/models/userData.dart';
import 'package:kaliallendatingapp/screens/profilesetup/Profile6Height.dart';
import 'package:kaliallendatingapp/screens/profilesetup/Profile7UploadPhoto.dart';
import 'package:kaliallendatingapp/widgets/StyledButton.dart';
import 'package:page_transition/page_transition.dart';

class ProfileInterestedIn extends StatefulWidget {
  final UserData? _userData;


  ProfileInterestedIn({@required UserData? userData})
      : assert(userData !=null),
        _userData = userData;

  @override
  _ProfileInterestedInState createState() => _ProfileInterestedInState();
}

class _ProfileInterestedInState extends State<ProfileInterestedIn> {
  String? selectedInterestedIn;
  double width = 90.0;
  double height = 20.0;
  List<String> genderInterestedInSelection = ['Female','Male','Everyone'];
  bool isGenderInterestedInSelected = true;

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
                padding: EdgeInsets.only(left: 8),
                child:  IconButton(icon: Icon(Icons.arrow_back_ios_sharp,
                  color: kLightDark,
                ), onPressed: () async {
                  Navigator.pop(context);
                }),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: Text(
                    'I\'m looking for a',
                style: kQuestionText,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                child: Wrap(
                    spacing: 10.0,
                    //  runSpacing: 5.0,
                    children: [
                      buildChoiceChip('Man'),
                      buildChoiceChip('Woman'),
                      buildChoiceChip('Everyone'),
                    ]
                ),
              ),
              //TextField/Content
               isGenderInterestedInSelected ? Text('') : Center(
                  child: Text('Select an option to continue.',
                      style: TextStyle(color: Colors.red))
              ),
              //Next Button
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0, right: 25.0, left: 25.0),
                child: Column(
                  children: [
                    StyledButton(
                        text: 'Continue',
                        color: kButtonColor,
                        onTap: () {
                           if (selectedInterestedIn != null) {
                            setState(() {
                              isGenderInterestedInSelected = true;
                            });
                            widget._userData?.isInterestedIn = selectedInterestedIn;
                            Navigator.push(context, PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: ProfileUploadPhoto(
                                  userData: widget._userData,
                                )));
                          } else {
                            setState(() {
                              isGenderInterestedInSelected = false;
                            });
                          }
                        }
                    ),
                  ],
                ),
              )
            ],
          ),
        )
    );

  }

  ChoiceChip buildChoiceChip(String gender) {

    return ChoiceChip(
      label: Container(
        width: width,
        height: height,
        child: Center(child: Text( gender,
          style: TextStyle(
            color: selectedInterestedIn == gender ? Colors.white : Colors.black,
          ),
        )),
      ),
      selectedColor: kNavyBlue,
      selected: selectedInterestedIn == gender,
      onSelected: (selected){
        setState(() {
          selectedInterestedIn = selected ? gender : null;
        });
      },
    );
  }
}