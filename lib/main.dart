import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kaliallendatingapp/screens/Home.dart';
import 'package:kaliallendatingapp/screens/SplashScreen.dart';
import 'constants.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();


  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: kNavyBlue,
        fontFamily: 'Quicksand',

      ),
      home: Home(),
      routes: {
        Home.id : (context)=>Home(),
      },
    );
  }
}





