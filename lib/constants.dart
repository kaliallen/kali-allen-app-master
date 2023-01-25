import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

//Home

    //buildWelcomeScreen
    const kWelcomeScreenBackgroundColor = Color(0xffFFFFFF);
    const kAppTitleTextGradient = [
      Color(0xff2dff8f), Color(0xff00d463), Color(0xff01c4bdd), Color(0xffc200fb), Color(0xfffe4a49),
    ];
    const kSubTextStyle = TextStyle(
      // letterSpacing: 2.0,
      fontSize: 20.0,
      fontFamily: 'Quicksand',
      fontWeight: FontWeight.w300,
      color: Color(0xff1D1E2F),
    );
    const kWelcomeScreenStyledButtonBackgroundColor = Colors.black;
    const kWelcomeScreenStyledButtonTextColor = Colors.white;

    //buildAuthScreen

//PhoneSignUp + profilesetup screens

    //Question TextStyle
    const kQuestionText = TextStyle(
      // letterSpacing: 2.0,
      fontSize: 30.0,
      fontFamily: 'Quicksand',
      fontWeight: FontWeight.w600,
      color: kDarkest,
    );

    //NextButtonColor
    const kButtonColor = Colors.black;
    // Color(0xff141551);//
// Color(0xff3860F2);
    //Color(0xffF85B8B);

//Browse Page
      const kBrowsePageBackgroundColor = kScaffoldBackgroundColor;
      const kTimeDateTextStyle = TextStyle(
        color: kDarkest,
        fontSize: 20.0,
        fontWeight: FontWeight.w800,
      );

      //SlidingUpPanel
      const kBrowsePageSlidingUpPanelColor = Colors.white;//Color(0xffF8E6DC);//Color(0xffFBF3E6);//
      const kBrowsePageTitleText = TextStyle(
          fontSize: 20.0,
          color: kDarkest,
          fontWeight: FontWeight.w600);
      const kDateTimeIconTextColor = kDarkish;
      const kDateTimeIconTextStyle = TextStyle(
        fontSize: 17.0,
        color: kDarkish,
        fontWeight: FontWeight.w500,
      );



//Somitro Colors
const kScaffoldBackgroundColor = Color(0xffF6F7FB);//;//Color(0xffF6F7FB);
const kWhiteSquareColor = Colors.white;

//Pill Button Colors
const kPillButtonSelectedColor = Color(0xffC0B9BE);//Color(0xff6A4C93);
const kPillButtonUnselectedColor = Color(0xffF0EDF4);
const kPillButtonTextStyle = TextStyle(

);

//MatchBox Colors
const kMatchBoxTimeFill = Color(0xffEFEAEE);
const kMatchBoxTimeFont = Color(0xff5C2751);

//Button Color

const kLightGrey = Color(0xff9D9EA4);
const kNavyBlue = Color(0xff1c4bdd);
const kLimeGreen = Color(0xff7EF29D);

const kDarkest = Color(0xff070D1B);
const kDark = Color(0xff393D49);
const kDarkish = Color(0xff6A6E76);
const kLightDark = Color(0xff9C9EA4);
const kLightestGrey = Color(0xffF9FAFC);

//Settings Tab Yellow Color
const kYellow = Color(0xffFEF2C5);


//SplashScreen Colorize Animation Colors
const kColorizeColors = [
    Color(0xffc200fb),
    Color(0xFFFE4a49),
    Color(0xffe8dab2),
    Color(0xffc0d6df),
    Color(0xffeaeaea),
];

enum Gender {male, female, androgyne, androgynous, bigender}

enum DateDay {None, Today, Tomorrow, ThirdDay, FourthDay}

//SplashScreen Colorize Animation TextStyle
const kColorizeTextStyle = TextStyle(
  fontSize: 50.0,
  fontFamily: 'RobotoBlack',
);


const kHeadingText = TextStyle(
  fontSize: 25.0,
  fontFamily: 'RobotoLight',
);

const kBodyText = TextStyle(
  fontFamily: 'Roboto',
  fontSize: 20.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  border: InputBorder.none,
);

const kMatchTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
  hintText: 'Hey...',
  border: OutlineInputBorder(

  ),
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: Color(0xffEFEFF4), width: 2.0),
  ),
);

const kSendButtonTextStyle = TextStyle(
  color: Colors.lightBlueAccent,
  fontWeight: FontWeight.w500,
  fontSize: 18.0,
);

//Content Decoupling

//Times
const List<int> times = [
  5,
  6,
  7,
  8,
  9,
  10
];