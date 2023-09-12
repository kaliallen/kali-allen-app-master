//THIS PAGE IS ACTIVE IN USE

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kaliallendatingapp/models/userData.dart';
import 'package:kaliallendatingapp/screens/BrowseTab.dart';
import 'package:kaliallendatingapp/screens/ChatsTab.dart';
import 'package:kaliallendatingapp/screens/PhoneSignUp.dart';
import 'package:kaliallendatingapp/screens/SettingsTab.dart';
import 'package:kaliallendatingapp/screens/profilesetup/Profile1Location.dart';
import 'package:kaliallendatingapp/widgets/StyledButton.dart';

import '../constants.dart';
import 'MatchesTab.dart';

final datesRef = FirebaseFirestore.instance.collection('dates');
final activeDatesRef = FirebaseFirestore.instance.collection('activeDates');
final usersRef = FirebaseFirestore.instance.collection('users');
final matchesRef = FirebaseFirestore.instance.collection('matches');
final messagesRef = FirebaseFirestore.instance.collection('messages');
final notificationsRef = FirebaseFirestore.instance.collection('notifications');
final storageRef = FirebaseStorage.instance.ref();


class Home extends StatefulWidget {
  static String id = 'Home.id';

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  PageController? pageController;
  int pageIndex = 0;
  bool isAuth = false;
  User? currentUser;

  UserData currentUserData = UserData();

  //Functions in initState

  ///If the account is not null, they are successfully logged in and isAuth is set to true.
  ///If isAuth is true, go to build auth screen...where navigation bar is--the first page is set to the BrowseScreen.
  handleSignIn(User account){

    if (account != null) {
      setState(() {
        //isAuth is true, go to build auth screen...
        // (This is where the screen where the bottom icons exist are--the first page is set to the Discover Icon (aka the BrowseScreen)
        isAuth = true;
        currentUser = account;
      });

      //Go to CreateUserInFirestore...
      createUserInFirestore();

    } else {

      //If the account is empty,
      setState(() {

        //isAuth is False, go to build welcome screen...
        // (This is where they can sign in)
        isAuth = false;
      });
    }
  }

  ///Uses currentUser.uid (Was saved in function called handleSignIn) to check if user exists in the 'users' collection in Firebase.
  createUserInFirestore() async {
    print("Current User ID: ${currentUser!.uid}");

    if (currentUser!.uid != null){
      print('not ');
    }

    final DocumentSnapshot doc = await usersRef.doc(currentUser?.uid).get();
    if (!doc.exists) {
      await Navigator.push(
          context, MaterialPageRoute(builder: (context) => ProfileSetup()));
    } else {
      print("doc doesn't exist?");
    }


    UserData _user = UserData();

    if (currentUser != null) {
      print('This is the currentUser = $currentUser');
      await _user.getUserData(currentUser!.uid);
      setState(() {
        currentUserData = _user;
      });
      print(currentUserData.uid);
    }
  }


  @override
  void initState() {
    super.initState();
    pageController = PageController();

    //If a user is logged in, send User to handleSignIn
    FirebaseAuth.instance.authStateChanges().listen((account){
     if (account == null){
       print('account is null');
       setState(() {
         isAuth = false;
       });
     }
      handleSignIn(account!);
    }, onError: (err){
      print('Error signing in: $err');
    });
  }

  //If isAuth is false, buildWelcomeScreen
  Scaffold buildWelcomeScreen() {
    return Scaffold(
        backgroundColor: kWelcomeScreenBackgroundColor,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children:
            [
              Container(
                padding: EdgeInsets.only(top: 100.0),
                child:
                Text('Tonight',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    letterSpacing: -2.0,
                    fontSize: 61.0,
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.w700,
                    foreground: Paint()..shader = LinearGradient(
                      colors: kAppTitleTextGradient,
                    ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                  )
            ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 45.0, vertical: 20.0),
                child: Text('Date with ~intention~.',
                  textAlign: TextAlign.center,
                  style: kSubTextStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: StyledButton(
                        text: 'Log in with Phone Number',
                        fontColor: kWelcomeScreenStyledButtonTextColor,
                        color: kWelcomeScreenStyledButtonBackgroundColor,
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>PhoneSignUp()));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
    );
  }

  //If isAuth is true, build Auth Screen
  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          BrowseScreen(
            currentUserUid: currentUser?.uid,
          ),
          NotificationScreen(
            currentUserId: currentUser?.uid,
          ),
          MatchesScreen(
            currentUserId: currentUser?.uid,
          ),
          SettingScreen(
            currentUserId: currentUser?.uid,
          ),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar:
          // BottomNavigationBar(
      CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: kButtonColor,
        iconSize: 25.0,
        backgroundColor: Color(0xffffffff),
        items: [
          BottomNavigationBarItem(
              label: 'Find',
              icon: Icon(Icons.bolt,
                color: pageIndex == 0 ? kButtonColor : Color(0xff9D9EA4),
              )),
          BottomNavigationBarItem(
            label: 'Notifications',
            icon: Icon(Icons.notifications,
            color: pageIndex == 1 ? kButtonColor : Color(0xff9D9EA4),
          )),
          BottomNavigationBarItem(
              label: 'My Pool',
              //TODO: Find a better icon and also make it so notifications are shown here
              icon: Icon(Icons.groups,
                color: pageIndex == 2 ? kButtonColor : Color(0xff9D9EA4),
              )),
          BottomNavigationBarItem(
            label: 'My Profile',
            icon: Icon(Icons.account_circle_outlined,
              color: pageIndex == 3 ? kButtonColor : Color(0xff9D9EA4),
            ),
          ),
        ],
      ),
    );
  }

  onPageChanged(int pageIndex){
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex){
    pageController?.animateToPage(
        pageIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut
    );
  }


  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildWelcomeScreen();
  }


  @override
  void dispose() {
    pageController?.dispose();
    super.dispose();
  }




}
