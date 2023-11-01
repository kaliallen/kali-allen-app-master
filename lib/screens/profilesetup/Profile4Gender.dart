import 'package:flutter/material.dart';
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/models/userData.dart';
import 'package:kaliallendatingapp/screens/profilesetup/Profile5InterestedIn.dart';
import 'package:kaliallendatingapp/widgets/StyledButton.dart';
import 'package:page_transition/page_transition.dart';

class ProfileGender extends StatefulWidget {
  final UserData? _userData;


  ProfileGender({@required UserData? userData})
      : assert(userData !=null),
        _userData = userData;

  @override
  _ProfileGenderState createState() => _ProfileGenderState();
}

class _ProfileGenderState extends State<ProfileGender> {
  String? selectedGender;
  double width = 90.0;
  double height = 20.0;
  bool otherSelected = false;

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
                    'I am a...',
                    style: TextStyle(
                      // letterSpacing: 2.0,
                      fontSize: 30.0,
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w600,
                      color: kDarkest,
                    )
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                  child: Wrap(
                      spacing: 10.0,
                      //  runSpacing: 5.0,
                      children: [
                        buildChoiceChip('She/Her'),
                        buildChoiceChip('He/Him'),
                        buildChoiceChip('They/Them'),
                        buildChoiceChip('Ze/Hir'),

                  ChoiceChip(
                    label: Container(
                      width: width,
                      height: height,
                      child: Center(child: Text( 'Other',
                        style: TextStyle(
                          color: otherSelected ? Colors.white : Colors.black,
                        ),
                      )),
                    ),
                    selectedColor: kNavyBlue,
                    selected: otherSelected,
                    onSelected: (selected) {
                      if (otherSelected == true) {
                        setState(() {
                          otherSelected = false;
                        });
                      } else {
                        setState(() {
                          otherSelected = true;
                        });
                      }
                    },
                  ),
                      ]
                  ),
              ),
              //TextField/Content
              otherSelected ? TextField() : SizedBox(),
              //Next Button
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0, right: 25.0, left: 25.0),
                child: Column(
                  children: [
                    StyledButton(
                      text: 'Continue',
                      color: kButtonColor,
                        onTap: () {
                            widget._userData!.gender = selectedGender;
                            Navigator.push(context, PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: ProfileInterestedIn(
                                  userData: widget._userData,
                                )));
                        }
                    ),
                  ],
                ),
              )
            ],
          ),
        )
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'I identify as a $selectedGender',
                      style: kHeadingText,
                    ),
                    SizedBox(height: 10.0),
                    Wrap(
                        spacing: 10.0,
                        //  runSpacing: 5.0,
                        children: [
                          buildChoiceChip('Man'),
                          buildChoiceChip('Woman'),
                          buildChoiceChip('Bigender'),
                          buildChoiceChip('Androgyne'),
                          buildChoiceChip('Androgynous'),
                        ]
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    StyledButton(
                        text: 'Continue',
                        color: Colors.grey,
                        onTap: () {
                            if (selectedGender != null) {
                              widget._userData!.gender = selectedGender;
                              Navigator.push(context, PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: ProfileInterestedIn(
                                    userData: widget._userData,
                                  )));
                            }
                        }
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  ChoiceChip buildChoiceChip(String gender) {

    return ChoiceChip(
      label: Container(
        width: width,
        height: height,
        child: Center(child: Text( gender,
          style: TextStyle(
            color: selectedGender == gender ? Colors.white : Colors.black,
          ),
        )),
      ),
      selectedColor: kNavyBlue,
      selected: selectedGender == gender,
      onSelected: (selected){
        setState(() {
          selectedGender = (selected ? gender : null)!;
        });
        print(gender);
      },
    );
  }
}