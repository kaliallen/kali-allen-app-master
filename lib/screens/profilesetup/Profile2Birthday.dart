import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/models/userData.dart';
import 'package:kaliallendatingapp/screens/profilesetup/Profile3Name.dart';
import 'package:kaliallendatingapp/widgets/StyledButton.dart';
import 'package:page_transition/page_transition.dart';


//TODO:

class ProfileBirthday extends StatefulWidget {
  final UserData? _userData;

  ProfileBirthday({@required UserData? userData})
  : assert(userData != null),
  _userData = userData;

  @override
  _ProfileBirthdayState createState() => _ProfileBirthdayState();
}

class _ProfileBirthdayState extends State<ProfileBirthday> {
  TextEditingController monthController = TextEditingController();
  TextEditingController dayController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  final _formKey = new GlobalKey<FormState>();

  int? _day;
  bool isAdult = true;
  DateTime? _age;
  DateTime ofAge = DateTime.now();

// You need to save the user's BIRTHDATE so you can automatically update the age of the person on their profile each day they log in!
  bool adultVerifier(DateTime birthDate) {
    print(birthDate);
    DateTime today = DateTime.now();
    DateTime adultDate =
        DateTime(birthDate.year + 18, birthDate.month, birthDate.day);
    return adultDate.isBefore(today);
  }

  //Use the adultAge to view on the screen so they know they typed in the right year before continuing...
  DateTime adultAge() {
    DateTime today = DateTime.now();
    DateTime adultDate = DateTime(today.year - 18, today.month, today.day);
    return adultDate;
  }

// TODO: Fix????
  addBirthday() {
    int day = int.parse(dayController.text);
    int month = int.parse(monthController.text);
    int year = int.parse(yearController.text);


    //Create a dateTime
      var birthDate = DateTime.utc(year, month, day);

      //Use isAdult to find out if birthDate is 18 years or older
      isAdult = adultVerifier(birthDate);
      print('is the birthday over 18 years old ? $isAdult');

      //If birthDate is 18 or older, set data & go to next screen
      if (isAdult == true) {
        widget._userData!.birthDate = Timestamp.fromDate(birthDate);


        if (widget._userData!.birthDate != null) {
          print(widget._userData!.birthDate);
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: ProfileName(
                    userData: widget._userData,
                  )));
        } else {
          print('error');
        }
      } else {
        //If birthDate is younger than 18, setState to show error
        setState(() {
          isAdult = false;
        });
      }
  }

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
            padding: const EdgeInsets.all(25.0),
            child: Text('What\'s your birthday?',
                style: TextStyle(
                  // letterSpacing: 2.0,
                  fontSize: 30.0,
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.w600,
                  color: kDarkest,
                )),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60.0),
            child: Form(
              key: _formKey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 40.0,
                    child:
                    TextFormField(
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17.0,
                      ),
                      controller: monthController,
                      validator: (String? val) {
                        if (val!.trim().length < 2 ||
                            val.isEmpty ||
                            int.parse(val) > 31 ||
                            int.parse(val) < 1) {
                          return '';
                        } else {
                          return null;
                        }
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                      decoration: InputDecoration(
                        labelText: 'MM',
                        counterText: '',
                      ),
                    ),
                  ),
                  Text(
                    '/',
                    style: TextStyle(
                      fontSize: 25.0,
                    ),
                  ),
                  SizedBox(
                    width: 40.0,
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17.0,
                      ),
                      controller: dayController,
                      validator: (val) {
                        if (val!.trim().length < 2 ||
                            val.isEmpty ||
                            int.parse(val) > 12 ||
                            int.parse(val) < 1) {
                          return '';
                        } else {
                          return null;
                        }
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                      decoration: InputDecoration(
                        // border: OutlineInputBorder(
                        //   borderRadius: BorderRadius.circular(15.0),
                        // ),
                        labelText: 'DD',
                        counterText: '',
                      ),
                    ),
                  ),
                  Text(
                    '/',
                    style: TextStyle(
                      fontSize: 25.0,
                    ),
                  ),
                  SizedBox(
                    width: 60.0,
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17.0,
                      ),
                      controller: yearController,
                      validator: (val) {
                        if (val!.trim().length < 4 ||
                            val.isEmpty ||
                            int.parse(val) > DateTime.now().year ||
                            int.parse(val) < 1911) {
                          return '';
                        } else {
                          return null;
                        }
                      },
                      keyboardType: TextInputType.number,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      maxLength: 4,
                      decoration: InputDecoration(
                        // border: OutlineInputBorder(
                        //   borderRadius: BorderRadius.circular(15.0),
                        // ),
                        labelText: 'YYYY',
                        counterText: '',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          //TextField/Content
          isAdult
              ? Text('')
              : Center(
                  child: Text(
                    'Must be 18 years or older to continue.',
                    style: TextStyle(
                      fontSize: 17.0,
                      color: Colors.red,
                    ),
                  ),
                ),
          Padding(
            padding:
                const EdgeInsets.only(bottom: 30.0, right: 25.0, left: 25.0),
            child: StyledButton(
              text: 'Continue',
              color: kButtonColor,
              onTap: () {
                print(isAdult);
                if (_formKey.currentState!.validate()) {
                  print('werked!!');
                  addBirthday();

                }
              },
            ),
          ),
        ],
      ),
    ));
  }

  @override
  void dispose() {
    dayController.dispose();
    monthController.dispose();
    yearController.dispose();
    super.dispose();
  }
}

//Template
// return Scaffold(
// body: SafeArea(
// child: Column(
// mainAxisAlignment: MainAxisAlignment.spaceBetween,
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// //Big Title Question
// Padding(
// padding: EdgeInsets.all(8),
// child:  IconButton(icon: Icon(Icons.arrow_back_ios_sharp,
// color: kLightDark,
// ), onPressed: () async {
// Navigator.pop(context);
// }),
// ),
// Column(
// children: [
// Padding(
// padding: const EdgeInsets.all(25.0),
// child: Text(
// 'Set Location',
// style: TextStyle(
// // letterSpacing: 2.0,
// fontSize: 30.0,
// fontFamily: 'Quicksand',
// fontWeight: FontWeight.w800,
// color: kDarkest,
// )
// ),
// ),
// Text(
// 'This can be changed later.',
// ),
// ],
// ),
// //TextField/Content
// //Next Button
// Padding(
// padding: const EdgeInsets.only(bottom: 30.0, right: 25.0, left: 25.0),
// child: StyledButton(
// text: 'Continue',
// color: kButtonColor,
// onTap: () {
// Navigator.push(context, PageTransition(
// type: PageTransitionType.rightToLeft,
// child: ProfileBirthday()));
// },
// ),
// )
// ],
// ),
// )
// );
