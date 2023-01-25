import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/models/userData.dart';
import 'package:kaliallendatingapp/screens/profilesetup/Profile7UploadPhoto.dart';
import 'package:kaliallendatingapp/widgets/StyledButton.dart';
import 'package:page_transition/page_transition.dart';
// import 'package:pinput/pin_put/pin_put.dart';


class ProfileHeight extends StatefulWidget {

  final UserData _userData;

  ProfileHeight({@required UserData userData})
      : assert(userData !=null),
        _userData = userData;

  @override
  _ProfileHeightState createState() => _ProfileHeightState();
}

class _ProfileHeightState extends State<ProfileHeight> {
  TextEditingController heightController = TextEditingController();
  int ft = 0;
  int inches = 0;
  int selectitem = 31;
  List<String> heights = [

    '5 \' 7',
    '5 \'8',
    '5 \' 9',
    '5 \' 10',
    '5 \' 11', '6 \' 0',
    '6 \' 1',
    '6 \' 2',
    '6 \' 3',
    '6 \' 4',
    '6 \' 5',
    '6 \' 6',
    '6 \' 7',
    '6 \'8',
    '6 \' 9',
    '6 \' 10',
    '6 \' 11', '7 \' 0',
    '7 \' 1',
    '7 \' 2',
    '7 \' 3',
    '7 \' 4',
    '7 \' 5',
    '7 \' 6',
    '7 \' 7',
    '7 \'8',
    '7 \' 9',
    '7 \' 10',
    '7 \' 11',
    '3 \' 0',
    '3 \' 1',
    '3 \' 2',
    '3 \' 3',
    '3 \' 4',
    '3 \' 5',
    '3 \' 6',
    '3 \' 7',
    '3 \'8',
    '3 \' 9',
    '3 \' 10',
    '3 \' 11',
    '4 \' 0',
    '4 \' 1',
    '4 \' 2',
    '4 \' 3',
    '4 \' 4',
    '4 \' 5',
    '4 \' 6',
    '4 \' 7',
    '4 \'8',
    '4 \' 9',
    '4 \' 10',
    '4 \' 11', '5 \' 0',
    '5 \' 1',
    '5 \' 2',
    '5 \' 3',
    '5 \' 4',
    '5 \' 5',
    '5 \' 6',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                'What is your height?',
                style: kQuestionText,
              ),
            ),

            GestureDetector(
              onTap: (){

              },
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * .5,
                  height: 100,
                  child: CupertinoPicker(
                    magnification: 1,
                      children: [
                        Text('5 \' 7'),
                        Text('5 \'8'),
                        Text('5 \' 9'),
                        Text('5 \' 10'),
                        Text('5 \' 11'),
                        Text('6 \' 0'),
                        Text('6 \' 1'),
                        Text('6 \' 2'),
                        Text('6 \' 3'),
                        Text('6 \' 4'),
                        Text('6 \' 5'),
                        Text('6 \' 6'),
                        Text('6 \' 7'),
                        Text('6 \'8'),
                        Text('6 \' 9'),
                        Text('6 \' 10'),
                        Text('6 \' 11'),
                        Text('7 \' 0'),
                        Text('7 \' 1'),
                        Text('7 \' 2'),
                        Text('7 \' 3'),
                        Text('7 \' 4'),
                        Text('7 \' 5'),
                        Text('7 \' 6'),
                        Text('7 \' 7'),
                        Text('7 \'8'),
                        Text('7 \' 9'),
                        Text('7 \' 10'),
                        Text('7 \' 11'),
                        Text('3 \' 0'),
                        Text('3 \' 1'),
                        Text('3 \' 2'),
                        Text('3 \' 3'),
                        Text('3 \' 4'),
                        Text('3 \' 5'),
                        Text('3 \' 6'),
                        Text('3 \' 7'),
                        Text('3 \'8'),
                        Text('3 \' 9'),
                        Text('3 \' 10'),
                        Text('3 \' 11'),
                        Text('4 \' 0'),
                        Text('4 \' 1'),
                        Text('4 \' 2'),
                        Text('4 \' 3'),
                        Text('4 \' 4'),
                        Text('4 \' 5'),
                        Text('4 \' 6'),
                        Text('4 \' 7'),
                        Text('4 \'8'),
                        Text('4 \' 9'),
                        Text('4 \' 10'),
                        Text('4 \' 11'),
                        Text('5 \' 0'),
                        Text('5\' 1'),
                        Text('5 \' 2'),
                        Text('5 \' 3'),
                        Text('5 \' 4'),
                        Text('5 \' 5'),
                        Text('5 \' 6'),
                      ],
                    itemExtent: 30,
                      looping: true,
                    onSelectedItemChanged: (int index){
                      selectitem = index;
                      print(heights[selectitem]);
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0, right: 25.0, left: 25.0),
              child: StyledButton(
                text: 'Continue',
                color: kButtonColor,
                onTap: (){
                  widget._userData.height = heights[selectitem];
                  Navigator.push(context, PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: ProfileUploadPhoto(
                            userData: widget._userData,
                          )));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
