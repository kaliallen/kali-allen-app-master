import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kaliallendatingapp/screens/Home.dart';
import 'package:kaliallendatingapp/widgets/StyledButton.dart';
import 'package:kaliallendatingapp/widgets/progress.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:kaliallendatingapp/screens/profilesetup/Profile1Location.dart';


import '../constants.dart';

FirebaseAuth _auth = FirebaseAuth.instance;

class PhoneSignUp extends StatefulWidget {
  static String id = 'PhoneSignUp';

  @override
  _PhoneSignUpState createState() => _PhoneSignUpState();
}

class _PhoneSignUpState extends State<PhoneSignUp> {
  bool _errorExists = false;
  String _errorMessage = '';
  final _phoneNumberController = TextEditingController();
  bool _validate = false;
  final _codeController = TextEditingController();
  bool _loading = false;

  Future<bool> isFirstTime(String userId) async {
    bool exist;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((user) {
      exist = user.exists;
    });

    return exist;
  }

  createUserInFirestore() async {
    //check if user exists in users collection in database (according to their id)
    bool exist;
    final currentUser = _auth.currentUser;
    final doc = await usersRef.doc(currentUser.uid).get();
    //if the user doesn't exist, then we want to take them to the create account page
    if (!doc.exists) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ProfileSetup()));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
    }
    //get username from create account, use it to make new user document in users collection
  }

  Future<void> loginUserWithPhone(
      String phoneNumber, BuildContext context) async {
    _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          Navigator.of(context).pop();
          setState(() {
            _loading = false;
          });
          UserCredential result = await _auth.signInWithCredential(credential);
          User user = result.user;
          //make auth credential object
          String uid = user.uid;
          bool isFirst = await isFirstTime(uid);
          print(isFirst);
          if (user != null && isFirst == true) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProfileSetup()));
          } else {
            if (user != null && isFirst == false) {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Home()));
            } else {
              print('User is null or error occured');
            }
          }
        },
        verificationFailed: (FirebaseAuthException exception) {
          print('this was triggered!!!! verification failed.');

          print(exception);
          setState(() {
            _loading = false;
            _errorMessage = exception.toString();
            _errorExists = true;
          });
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          setState(() {
            _loading = false;
          });
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  //TODO: DESIGN - this is an ugly alert idk.
                  title: Text("Enter SMS Code",
                      style:
                          TextStyle(color: kDark, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center),
                  content: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: _codeController,
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    ElevatedButton(
                        child: Text('Close'),
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(Colors.black),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    ElevatedButton(
                      child: Text('Confirm'),
                      style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.black),
                ),
                      onPressed: () async {
                        final code = _codeController.text.trim();
                        //make auth credential object
                        try {
                          PhoneAuthCredential credential =
                              PhoneAuthProvider.credential(
                                  verificationId: verificationId,
                                  smsCode: code);
                          UserCredential result =
                              await _auth.signInWithCredential(credential);
                          User user = result.user;
                          String uid = user.uid;
                          bool isFirst = await isFirstTime(uid);
                          print(isFirst);
                          if (user != null && isFirst == true) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Home()));
                          } else {
                            if (user != null && isFirst == false) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProfileSetup()));
                            } else {
                              print('User is null or error occured');
                            }
                          }
                        } catch (e) {
                          print("Exception caught => $e");
                          Navigator.pop(context);
                          setState(() {
                            _codeController.clear();
                            _loading = false;
                            _errorMessage = e.toString();
                            _errorExists = true;
                          });

                        }
                      },
                    )
                  ],
                );
              });
        },
        codeAutoRetrievalTimeout: null);
  }


  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _loading,
      dismissible: true,
      progressIndicator: circularProgress(),
      child: Scaffold(
        backgroundColor: Colors.white,
        //Color(0xffFFFCF3),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _errorExists ? MaterialBanner(
                //TODO: DESIGN - material banner - icon color, flat button, box color, font
                content: Padding(
                  padding: EdgeInsets.all(5),
                    child: Text(_errorMessage)),
                leading: CircleAvatar(child: Icon(Icons.warning_amber)),
                actions: [
                  OutlinedButton(
                    child: const Text('Close'),
                    onPressed: () {
                      setState(() {
                        //Maybe clear the mobile number controller?
                        _errorExists = false;
                        _errorMessage = '';
                      });
                    },
                  ),
                ],
              ):  Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        icon: Icon(
                          Icons.close,
                          color: _loading ? Colors.black : Colors.grey,
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                        }),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Text(
                        'What\'s your phone number?',
                        style: kQuestionText,
                      ),
                    ),
                    _errorExists ? SizedBox(height: 0) : TextField(
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        fillColor: Colors.black,
                        hoverColor: Colors.black,
                        labelText: 'Mobile Number',
                        prefixText: '+1 ',
                        // errorText: _validate ? 'Enter in a valid phone number' : null,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    bottom: 30.0, right: 25.0, left: 25.0),
                child: StyledButton(
                  text: 'Next',
                  color: kButtonColor,
                  onTap: () {
                    print(_phoneNumberController.text.trim().length);
                    setState(() {
                      //Check to see if the phone number is valid
                      if (_phoneNumberController.text.isEmpty) {
                        _validate = true;
                      } else if (_phoneNumberController.text.trim().length != 10) {
                        print(_phoneNumberController.text
                            .trim()
                            .length);
                        _validate = true;
                      } else {
                        _validate = false;
                      }
                    });

                    // If the phone number is valid, proceed
                    if (_validate == false) {
                      setState(() {
                        _loading = true;
                      });

                      String phoneNumber =
                          '+1' + _phoneNumberController.text.toString().trim();
                      try {
                        loginUserWithPhone(phoneNumber, context);
                      } catch (e) {
                        print("$e this is the error for the try catch on loginUserWithPhone function");
                        setState(() {
                          _loading = false;
                          _errorMessage = e.toString();
                          _errorExists = true;
                        });
                        print(e);
                      }
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _codeController.dispose();
    super.dispose();
  }
}
