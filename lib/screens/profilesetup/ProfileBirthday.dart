import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/models/userData.dart';
import 'package:kaliallendatingapp/screens/profilesetup/Profile3Name.dart';
import 'package:kaliallendatingapp/widgets/StyledButton.dart';
import 'package:page_transition/page_transition.dart';


class ProfileBirthday extends StatefulWidget {
  final UserData _userData = UserData();

  @override
  _ProfileBirthdayState createState() => _ProfileBirthdayState();
}

class _ProfileBirthdayState extends State<ProfileBirthday> {
  TextEditingController monthController = TextEditingController();

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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Text(
                        'What\'s your birthday?',
                        style: kHeadingText,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    // Row(
                    //   children: [
                    //     TextField(
                    //       keyboardType: TextInputType.number,
                    //       controller: monthController,
                    //       decoration: InputDecoration(
                    //         border: OutlineInputBorder(),
                    //         labelText: 'MM',
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    GestureDetector(
                      child: Container(
                        child: Text(
                          _age == null ? " Year / Month / Day " : '${_age.year} / ${_age.month} / ${_age.day}',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                      onTap: (){
                        DatePicker.showDatePicker(context,
                            showTitleActions: false,
                            currentTime: _age == null ? adultAge() : _age,
                            onChanged: (date){
                              print('change $date');
                              setState(() {
                                _age = date;
                              });
                            });
                      },
                    ),
                    Divider(),
                    SizedBox(height: 20),
                    StyledButton(
                        text: 'Continue',
                        color: Colors.grey,
                        onTap: () {
                          // if (_age != null && isAdult(_age) == true) {
                          // widget._userRepository.age = _age;
                          Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: ProfileName(userData: widget._userData,),
                          ));

                          //} else {
                          //  print('Cant proceed because not old enough...');
                          // }
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
