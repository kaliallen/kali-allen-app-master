import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/screens/Home.dart';
import 'package:kaliallendatingapp/screens/profilesetup/Profile2Birthday.dart';
import 'package:kaliallendatingapp/widgets/StyledButton.dart';
import 'package:location/location.dart';
import 'package:page_transition/page_transition.dart';



class ProfileLocation extends StatefulWidget {



  @override
  _ProfileLocationState createState() => _ProfileLocationState();
}

class _ProfileLocationState extends State<ProfileLocation> {
  Location location = Location();
  bool _serviceEnabled;
  TextEditingController locationController = TextEditingController();
  PermissionStatus _permissionGranted;
  LocationData _currentPosition;
  String area;




  @override
  void initState() {
    checkLocationServiceStatus();
    getCurrentPosition();
    super.initState();
  }

  checkLocationServiceStatus() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled){
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied){
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted){
        return;
      }
    }
  }

  getCurrentPosition() async {

    print('get current position called');

    _currentPosition = await location.getLocation();
    print(_currentPosition.latitude);

    List<geo.Placemark> placemarks =
    await geo.placemarkFromCoordinates(_currentPosition.latitude, _currentPosition.longitude);
    geo.Placemark placemark = placemarks[0];

    setState(() {
      area = placemark.subAdministrativeArea;

      area != null? locationController.text = area: print('Location is null');
    });

    print(area);

    // setState(() {
    //   userData.education != null? educationController.text = userData.education: print('education is null');
    //   isLoading = false;
    // });



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Big Title Question
          IconButton(icon: Icon(Icons.arrow_back_ios_sharp,
            color: kLightDark,
          ), onPressed: () async {
            await FirebaseAuth.instance.signOut();
            // Navigator.popUntil(context, ModalRoute.withName(Home.id));
            Navigator.pushNamed(context, Home.id);

          }),
          Text('Where do you live?',
            style: TextStyle(
              // letterSpacing: 2.0,
              fontSize: 30.0,
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.w600,
              color: kDarkest,
            ),
          ),
          Column(
            children: [
              TextField(
                decoration: InputDecoration(
                    hintText: 'Dupont Circle, H-Street Corridor, etc.'
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'This can be changed later.',
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
              ),

            ],
          ),
          //TextField/Content
          //Next Button
          Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: StyledButton(
              text: 'Start',
              color: kButtonColor,
              onTap: () {
                Navigator.push(context, PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: ProfileBirthday()));
              },
            ),
          )
        ],
      ),
    ),
        )
    );
  }
}
