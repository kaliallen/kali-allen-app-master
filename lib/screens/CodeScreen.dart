import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/models/userRepository.dart';
import 'package:kaliallendatingapp/screens/Home.dart';
import 'package:kaliallendatingapp/screens/HomeScreen.dart';
import 'package:kaliallendatingapp/widgets/StyledButton.dart';
// import 'package:pinput/pin_put/pin_put.dart';
//
// class CodeScreen extends StatefulWidget {
//   final String phone;
//
//
//   CodeScreen({@required this.phone});
//
//   @override
//   _CodeScreenState createState() => _CodeScreenState();
// }

// class _CodeScreenState extends State<CodeScreen> {
//
//   final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
//   String _verificationCode;
//   final TextEditingController _pinPutController = TextEditingController();
//   final FocusNode _pinPutFocusNode = FocusNode();
//   final BoxDecoration pinPutDecoration = BoxDecoration(
//     color: const Color.fromRGBO(43, 46, 66, 1),
//     borderRadius: BorderRadius.circular(10.0),
//     border: Border.all(
//       color: const Color.fromRGBO(126, 203, 224, 1),
//     ),
//   );
//
//
//   @override
//   // Widget build(BuildContext context) {
//   //   return Scaffold(
//   //     key: _scaffoldkey,
//   //     backgroundColor: Colors.white,
//   //     body: SafeArea(
//   //       child: ListView(
//   //         //HERE
//   //         children: [
//   //           Row(
//   //             mainAxisAlignment: MainAxisAlignment.end,
//   //             children: [
//   //               IconButton(icon: Icon(Icons.arrow_back_ios_sharp,
//   //                 color: Colors.grey,), onPressed: () {
//   //                 Navigator.pop(context);
//   //               }),
//   //             ],
//   //           ),
//   //           Column(
//   //             mainAxisAlignment: MainAxisAlignment.center,
//   //             children: [
//   //               Container(
//   //                 padding: EdgeInsets.all(20.0),
//   //                 child: Expanded(
//   //                   child: Column(
//   //                     crossAxisAlignment: CrossAxisAlignment.start,
//   //                     children: [
//   //                       SizedBox(height: 10.0),
//   //                       Text(
//   //                           'Enter SMS Code ${widget.phone}',
//   //                           style: TextStyle(
//   //                             // letterSpacing: 2.0,
//   //                             fontSize: 40.0,
//   //                             fontFamily: 'RobotoBlack',
//   //                             fontWeight: FontWeight.w900,
//   //                             color: kButtonColor,
//   //                           )
//   //                       ),
//   //                     ],
//   //                   ),
//   //                 ),
//   //               ),
//   //             ],
//   //           ),
//   //           Container(
//   //             padding: EdgeInsets.all(30.0),
//   //             child: Column(
//   //               children: [
//   //                 PinPut(
//   //                   fieldsCount: 6,
//   //                   textStyle: const TextStyle(fontSize: 25.0, color: Colors.white),
//   //                   eachFieldWidth: 40.0,
//   //                   eachFieldHeight: 55.0,
//   //                   focusNode: _pinPutFocusNode,
//   //                   controller: _pinPutController,
//   //                   submittedFieldDecoration: pinPutDecoration,
//   //                   selectedFieldDecoration: pinPutDecoration,
//   //                   followingFieldDecoration: pinPutDecoration,
//   //                   pinAnimationType: PinAnimationType.fade,
//   //                   onSubmit: (pin) async {
//   //                     try {
//   //                       await FirebaseAuth.instance
//   //                           .signInWithCredential(PhoneAuthProvider.credential(
//   //                           verificationId: _verificationCode, smsCode: pin))
//   //                           .then((value) async {
//   //                         if (value.user != null) {
//   //                           print('this one was done instead!!!');
//   //                           Navigator.pushAndRemoveUntil(
//   //                               context,
//   //                               MaterialPageRoute(builder: (context) => Home()),
//   //                                   (route) => false);
//   //                         }
//   //                       });
//   //                     } catch (e) {
//   //                       FocusScope.of(context).unfocus();
//   //                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('invalid OTP')));
//   //
//   //                     }
//   //                   },
//   //                 ),
//   //               ],
//   //             ),
//   //           ),
//   //         ],
//   //
//   //
//   //       ),
//   //     ),
//   //   );
//   // }
//
//   _verifyPhone() async {
//     await FirebaseAuth.instance.verifyPhoneNumber(
//         phoneNumber: widget.phone,
//         verificationCompleted: (PhoneAuthCredential credential) async {
//           await FirebaseAuth.instance
//               .signInWithCredential(credential)
//               .then((value) async {
//             if (value.user != null) {
//               print('verificationcomplete route was initialized');
//              // BlocProvider.of<AuthenticationBloc>(context).add(LoggedIn());
//              Navigator.push(context, MaterialPageRoute(builder: (context)=>Home()));
//             }
//           });
//         },
//         verificationFailed: (FirebaseAuthException e) {
//           print('verificationfailed route was initialized');
//           print(e.message);
//         },
//         codeSent: (String verficationID, int resendToken) {
//           print('codesent route was initialized');
//           setState(() {
//             _verificationCode = verficationID;
//           });
//         },
//         codeAutoRetrievalTimeout: (String verificationID) {
//           print('codeautoretrieval route was initialized');
//           setState(() {
//             _verificationCode = verificationID;
//           });
//         },
//         timeout: Duration(seconds: 120));
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _verifyPhone();
//   }
//
// }

