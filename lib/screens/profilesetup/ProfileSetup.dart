import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/screens/profilesetup/Profile3Name.dart';
import 'package:kaliallendatingapp/widgets/StyledButton.dart';


class ProfileSetup extends StatefulWidget {
  @override
  _ProfileSetupState createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {

  bool isAdult(DateTime birthDate) {
    DateTime today = DateTime.now();
    DateTime adultDate = DateTime(birthDate.year + 18, birthDate.month, birthDate.day);
    return adultDate.isBefore(today);
  }

  DateTime adultAge(){
    DateTime today = DateTime.now();
    DateTime adultDate = DateTime(today.year - 18, today.month, today.day);
    return adultDate;
  }

  DateTime _age;
  DateTime ofAge = DateTime.now();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: SingleChildScrollView(
            child: Container(
                child: Column(
                  children: [
                    Text(
                      'What is your birthday?',
                      style: kHeadingText,
                    ),
                    SizedBox(height: 20.0),
                    Container(),
                    SizedBox(height: 20),
                    StyledButton(
                        text: 'Continue',
                        color: Colors.grey,
                        onTap: () {
                          //Saves info into UserData class
                          //Moves on to the next widget
                        }
                    ),
                    Text(
                        _age != null && isAdult(_age) == false ? 'Must be 18 years or older to continue': ' ',
                        style: TextStyle(
                          color: Colors.red,
                        )
                    ),
                  ],
                )
            ),
          ),
        ),
      ),
    );
  }
}
