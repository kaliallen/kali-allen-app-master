import 'package:flutter/material.dart';
import 'package:kaliallendatingapp/screens/PhoneSignUp.dart';
import 'package:kaliallendatingapp/widgets/StyledButton.dart';


class WelcomeScreen extends StatefulWidget {

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {

@override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: 
       Color(0xffFFFEF9),
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children:
            [
              Text('Wave',
                textAlign: TextAlign.left,
                style: TextStyle(
                  // letterSpacing: 2.0,
                  fontSize: 61.0,
                  letterSpacing: 1.5,
                  fontFamily: 'RobotoBlack',
                  fontWeight: FontWeight.w700,
                  foreground: Paint()..shader = LinearGradient(colors: <Color>[Color(0xffc200fb), Color(0xfffe4a49)],
                  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                )
            ),
              Text('A new wave of dating.',
                textAlign: TextAlign.start,
                style: TextStyle(
                  // letterSpacing: 2.0,
                  fontSize: 15.0,
                  fontFamily: 'Roboto',
                  //fontWeight: FontWeight.bold,
                  color: Color(0xff69655E),
                  //Colors.black,
                ),
              ),
              SizedBox(height: 10.0),
              StyledButton(
                text: 'Log in with Phone Number',
                //color: Color(0xffD4CDC1),
                color: Color(0xffCAC1B5),
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>PhoneSignUp()));
                },
              ),
            ],
          ),
        )
    );
  }

}


