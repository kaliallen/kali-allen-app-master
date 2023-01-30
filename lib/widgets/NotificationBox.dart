import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/screens/ChatScreen.dart';
import 'package:kaliallendatingapp/screens/ProfilePage.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../screens/Home.dart';

String userId = FirebaseAuth.instance.currentUser.uid;

class NotificationBox extends StatelessWidget {
  final String notificationId;
  final bool dateNotification; //might not need
  final String matchImageUrl;
  final String senderId; //might not need
  final String name;
  final bool poolNotification; //don't need
  final DateTime time;
  final String type; //might not need
  final String message;
  final String date;
  final userId;



  NotificationBox({this.userId, this.date, this.message, this.notificationId, this.dateNotification, this.matchImageUrl, this.senderId, this.name, this.poolNotification, this.time, this.type});


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        leading:  GestureDetector(
          onTap: (){
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ProfilePage(profileId: senderId,
                          viewingAsBrowseMode: false,
                          viewPreferenceInfo: false,
                        )));
          },
          child: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey,
            backgroundImage: CachedNetworkImageProvider(matchImageUrl),
          ),
        ),
        title:  Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                        type.contains('looking') ? '$name, one of your matches, is looking for a date Tonight!' : type.contains('match') ? '$name is available $date.' : 'You have a new date with $name on Thursday!',
                        style: TextStyle(
                          // fontSize: 10.0,
                          fontWeight: FontWeight.w500,
                          color: kDarkest,
                        )
                        ),
            Text(
                message,
                style: TextStyle(
                  // fontSize: 10.0,
                  fontWeight: FontWeight.w700,
                  color: kDarkest,
                )
            ),
          ],
        ),
        subtitle: Text(
                    timeago.format(time),
                      style: TextStyle(
                       fontWeight: FontWeight.w100,
                        color: kDarkest,
                      )
                  ),
        trailing:  Column(
          children: [
            TextButton(
              child: Text('Start a Chat'),
              onPressed: () async {

                //Create a new match for the SENDER of the notification
                final doc = await usersRef.doc('sdlfksdjf').get();
                if (doc.exists) {
                  doc.reference.update({'firstname': 'Annemarie', 'lastName': 'Allen'});
                }

                    matchesRef
                        .doc(userId).collection('matches').doc(senderId)
                        .set({
                      'time': Timestamp.fromDate(DateTime.now()),
                      'date': date,

                    });

              },
            ),

          ],
        ),

        // Container(
        //             decoration: BoxDecoration(
        //                 color: kButtonColor,
        //                 borderRadius: BorderRadius.circular(5.0)
        //             ),
        //             child: Padding(
        //               padding: const EdgeInsets.all(3.0),
        //               child: Text(
        //                   type.contains('looking') ? '   Match   ' : type.contains('match') ? '  Start a chat  ' : '   Send Message   ',
        //                   style: TextStyle(
        //                     color: Colors.white,
        //                     fontSize: 13.0,
        //                   )
        //               ),
        //             ),
        //           ),
      ),

      // Container(
      //   width: MediaQuery.of(context).size.width,
      //     padding: EdgeInsets.all(10.0),
      //     decoration: BoxDecoration(
      //       color: kWhiteSquareColor,
      //       borderRadius: BorderRadius.circular(15.0),
      //     ),
      //     child: Row(
      //       children: [
      //         Container(
      //           width: MediaQuery.of(context).size.width * .7,
      //           child: Row(
      //             children: [
      //               //profile avatar
      //               GestureDetector(
      //                 onTap: (){
      //                   Navigator.push(
      //                       context,
      //                       MaterialPageRoute(
      //                           builder: (context) =>
      //                               ProfilePage(profileId: senderId,
      //                                 viewingAsBrowseMode: false,
      //                                 viewPreferenceInfo: false,
      //                               )));
      //                 },
      //                 child: CircleAvatar(
      //                   radius: 20,
      //                   backgroundColor: Colors.grey,
      //                   backgroundImage: CachedNetworkImageProvider(matchImageUrl),
      //                 ),
      //               ),
      //               //text in a wrap container
      //               Text(
      //                 type.contains('looking') ? '$name, one of your matches, is looking for a date Tonight!' : type.contains('match') ? '$name is available $date. Message: "$message"' : 'You have a new date with $name on Thursday!',
      //                 style: TextStyle(
      //                   fontSize: 10.0,
      //                   fontWeight: FontWeight.w500,
      //                   color: kDarkest,
      //                 )
      //                 ),
      //               Text(
      //                 timeago.format(time),
      //                   style: TextStyle(
      //                     fontSize: 10.0,
      //                    fontWeight: FontWeight.w100,
      //                     color: kDarkest,
      //                   )
      //               ),
      //             ],
      //           ),
      //         ),
      //         Container(
      //           //type.contains('looking') ? MediaQuery.of(context).size.width * .35 : MediaQuery.of(context).size.width * .4,
      //           child: Row(
      //             mainAxisAlignment: MainAxisAlignment.spaceAround,
      //             children: [
      //               type.contains('looking') ? Container(
      //                 decoration: BoxDecoration(
      //                     color: kButtonColor,
      //                     borderRadius: BorderRadius.circular(5.0)
      //                 ),
      //                 child: Padding(
      //                   padding: const EdgeInsets.all(3.0),
      //                   child: Text(
      //                       '  View Details  ',
      //                       style: TextStyle(
      //                         color: Colors.white,
      //                         fontSize: 10.0,
      //                       )
      //                   ),
      //                 ),
      //               ) : SizedBox(),
      //               Container(
      //                 decoration: BoxDecoration(
      //                     color: kButtonColor,
      //                     borderRadius: BorderRadius.circular(5.0)
      //                 ),
      //                 child: Padding(
      //                   padding: const EdgeInsets.all(3.0),
      //                   child: Text(
      //                       type.contains('looking') ? '   Match   ' : type.contains('match') ? '  Start a chat  ' : '   Send Message   ',
      //                       style: TextStyle(
      //                         color: Colors.white,
      //                         fontSize: 10.0,
      //                       )
      //                   ),
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),
      //       ],
      //     )
      // ),
    );
  }
}
