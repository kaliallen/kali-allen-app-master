import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/screens/ChatScreen.dart';
import 'package:kaliallendatingapp/screens/ProfilePage.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';

import '../screens/Home.dart';

String userId = FirebaseAuth.instance.currentUser!.uid;

class NotificationBox extends StatelessWidget {
  final String? notificationId;
  final bool? dateNotification; //might not need
  final String? matchImageUrl;
  final String? senderId; //might not need
  final String? name;
  final bool? poolNotification; //don't need
  final DateTime? time;
  final String? type; //might not need
  final String? message;

  final userId;

  NotificationBox(
      {this.userId,

      this.message,
      this.notificationId,
      this.dateNotification,
      this.matchImageUrl,
      this.senderId,
      this.name,
      this.poolNotification,
      this.time,
      this.type});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfilePage(
                          profileId: senderId,
                          viewingAsBrowseMode: true,
                          viewPreferenceInfo: false,
                        )));
          },
          child: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey,
            backgroundImage: CachedNetworkImageProvider(matchImageUrl!),
          ),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                type!.contains('looking')
                    ? '$name is free tonight!'
                    : type!.contains('match')
                        ? '$name sent you a message!'
                        : '$name is going to $message',
                style: TextStyle(
                  // fontSize: 10.0,
                  fontWeight: FontWeight.w600,
                  color: kDarkest,
                )),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Text('"${message!}"',
                  style: TextStyle(
                    // fontSize: 10.0,
                    fontWeight: FontWeight.w400,
                    color: kDarkest,
                  )),
            ),
          ],
        ),
        subtitle: Text(timeago.format(time!),
            style: TextStyle(
              fontWeight: FontWeight.w100,
              color: kDarkest,
            )),
        trailing: Column(
          children: [
            TextButton(
              child: Text(
                type!.contains('looking')
                    ? 'Message'
                    : type!.contains('match')
                    ? 'Start a Chat'
                    : 'View Event',


              ),
              onPressed: () async {
                var uuid = Uuid();

                // //Create a new match for the SENDER of the notification
                // final doc = await usersRef.doc('sdlfksdjf').get();
                // if (doc.exists) {
                //   doc.reference.update({'firstname': 'Annemarie', 'lastName': 'Allen'});
                // }
                //
                //     matchesRef
                //         .doc(userId).collection('matches').doc(senderId)
                //         .set({
                //       'time': Timestamp.fromDate(DateTime.now()),
                //       'date': date,
                //
                //     });

                // //TODO: Make a match under the userId
                // print('userId: $userId');
                //
                //   //TODO: Make sure a chat doesn't already exist
                // final doc = await matchesRef.doc(userId).collection('matches').doc(senderId).get();
                // if (doc.exists){
                //   print('The chat already exists!');
                //
                //   //If the chat already exists, update the chat
                //   doc.reference.update({
                //     'activeMatch': true,
                //     'lastMessage':
                //
                //   });
                // } else {
                // This is where to create a new match
                matchesRef.doc(userId).collection('matches').doc(senderId).set({
                  'activeMatch': true,
                  'dateId': 'test',
                  'lastMessage':
                      'INSERT NAME has matched with you! Make a lasting impression so you guys can go on the date at INSERT TIME...!',
                  'lastMessageSender': userId,
                  'lastMessageTime': Timestamp.now(),
                  'matchImageUrl': matchImageUrl,
                  'matchName': name,
                  'messageUnread': false,
                  'messagesId': uuid.v4(),
                });
                //
                // }

                //TODO: Make a match under the senderId
                print('senderId: $senderId');

                //TODO: Once all that is complete, go to the chat screen....?? Somehow?
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
