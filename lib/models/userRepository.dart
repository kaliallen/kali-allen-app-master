import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kaliallendatingapp/constants.dart';
import 'package:provider/provider.dart';

class UserRepository extends ChangeNotifier {
final FirebaseAuth _firebaseAuth;
final FirebaseFirestore _firestore;

bool isAuth;

String firstName;
String lastName;
DateTime age;
Gender gender;

UserRepository({FirebaseAuth firebaseAuth, FirebaseFirestore firestore})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;


Future<void> signInWithPhone(String email, String password) {
  return _firebaseAuth.signInWithEmailAndPassword(
      email: email, password: password);
}

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

Future<void> signUpWithEmail(String email, String password) async {
  print(_firebaseAuth);
  return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email, password: password);
}

Future<void> signOut() async {
  return await _firebaseAuth.signOut();
}

Future<bool> isSignedIn() async {
  final currentUser = _firebaseAuth.currentUser;
  return currentUser != null;
}

Future<void> isSignedInn() async {
  final currentUser = _firebaseAuth.currentUser;
  if (currentUser !=null){
    isAuth = true;
  } else {
    isAuth = false;
  }
  notifyListeners();
}

Future<String> getUser() async {
  return (await _firebaseAuth.currentUser).uid;
}

Future<bool> loginUserWithPhone(String phoneNumber, BuildContext context, Widget page, TextEditingController codeController) async {
  _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        Navigator.of(context).pop();
         UserCredential result = await _firebaseAuth.signInWithCredential(credential);
         User user = result.user;

         if(user != null){
           Navigator.push(context,
           MaterialPageRoute(builder: (context)=>page));
         } else {
           print("Error");
         }
      },
      verificationFailed: (FirebaseAuthException exception){
        print(exception);
      },
      codeSent: (String verificationId, [int forceResendingToken]){
        showDialog(context: context,
            barrierDismissible: false,
            builder: (context){
          return AlertDialog(
            title: Text("Give the code"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeController,
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Confirm'),
                onPressed: () async {
                  final code = codeController.text.trim();
                  //make auth credential object
                  PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: code);
                 UserCredential result = await _firebaseAuth.signInWithCredential(credential);
                 User user = result.user;
                 if (user != null) {
                   Navigator.push(context, MaterialPageRoute(builder: (context)=>page));
                 } else {
                   print('Error');
                 }
                },
              )
            ],
          );
            });
      },
      codeAutoRetrievalTimeout: null);
}


//TODO: 1) Finish this first... just the ability to save data into firestore under userId.
  //TODO: Track UserID along with userRepository. Do you put userId in the userRepository? Do you make a new User class?
  //TODO: 2) Figure out how to change the state from authenticatedbutnotset to authenticated.
  //TODO: 3) Test the shit out of it

createUserInFirestore({
  String userId,
  String firstName,
  String lastName,
  Gender gender,
  DateTime age,
  //TODO: Add other ones later (after testing)
}) async {
  userId = await getUser();
  await FirebaseFirestore.instance.collection('users').doc(userId).set({
    'uid': userId,
    'firstName' : firstName,
    'lastName' : lastName,
    'gender':gender,
    'age' : age
  });
  
  //currentUser = UserData.fromDocument(doc);
  }

  //1) Check if user exists in users collection in database (according to their id)

  //2) If the user doesn't exist, take them to the profile setup page

  //3) Get username from create account, use it to make new user document in users collection

}


// Future<void> profileSetup(
//     File photo,
//     String userId,
//     String name,
//     String gender,
//     String interestedIn,
//     DateTime age,
//     GeoPoint location) async {
//  FirebaseStorage storage = FirebaseStorage.instance;
//  storage
//       .ref()
//       .child('userPhotos')
//       .child(userId)
//       .child(userId)
//       .putFile(photo);
//
//   return await storageUploadTask.onComplete.then((ref) async {
//     await ref.ref.getDownloadURL().then((url) async {
//       await _firestore.collection('users').doc(userId).set({
//         'uid': userId,
//         'photoUrl': url,
//         'name': name,
//         "location": location,
//         'gender': gender,
//         'interestedIn': interestedIn,
//         'age': age
//       });
//     });
//   });
// }

