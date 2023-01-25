import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kaliallendatingapp/screens/BrowseScreen.dart';
import 'package:kaliallendatingapp/screens/MatchesScreen.dart';
import 'package:kaliallendatingapp/screens/SettingScreen.dart';


class HomeScreen extends StatefulWidget {
  static String id = 'HomeScreen';
  final userId;


  const HomeScreen({this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  PageController pageController;
  int pageIndex = 0;

  onPageChanged(int pageIndex){
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex){
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: [
          BrowseScreen(),
         // NotificationScreen(),
          MatchesScreen(currentUserId: widget.userId),
          SettingScreen(),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Colors.white,

        iconSize: 50.0,
        backgroundColor: Color(0xffE1D6D6),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.local_fire_department)),
          //BottomNavigationBarItem(icon: Icon(Icons.notifications)),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();

  }
}