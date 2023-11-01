import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/models/userData.dart';
import 'package:kaliallendatingapp/screens/Home.dart';
import 'package:kaliallendatingapp/screens/WelcomeScreen.dart';
import 'package:kaliallendatingapp/screens/profilesetup/Profile1Location.dart';




class SplashScreen1 extends StatefulWidget {
  @override
  _SplashScreen1State createState() => _SplashScreen1State();
}

class _SplashScreen1State extends State<SplashScreen1> {

  handleSignInn(User account) async {
    print('2. If account is not null, check to see if doc exists in firebase. if it does, take them to home. if not, take them to create profile. ');
    if (account != null) {
      print('...user is not null');
      DocumentSnapshot doc = await usersRef.doc(account.uid).get();
      if (doc.exists){
        DocumentSnapshot doc = await usersRef.doc(account.uid).get();
        UserData _userData = UserData.fromDocument(doc);
        Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileSetup()));
      }
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => WelcomeScreen()));
    }
  }
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((account) {
      print('1. Init State listens for an account...(?)');
      handleSignInn(account!);
    }, onError: (err){
      print('Error signing in: $err');
    });

  }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: SizedBox(
              width: 250.0,
              child: AnimatedTextKit(
                animatedTexts: [
                  ColorizeAnimatedText(
                    'Tonighhhht',
                    textStyle: kColorizeTextStyle,
                    colors: kColorizeColors,
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
