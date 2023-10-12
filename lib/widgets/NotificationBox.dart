import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/screens/BrowseTab.dart';
import 'package:kaliallendatingapp/screens/ChatScreen.dart';
import 'package:kaliallendatingapp/screens/ProfilePage.dart';
import 'package:kaliallendatingapp/widgets/SquarePhotoImageUrl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';

import '../models/userData.dart';
import '../screens/Home.dart';

String userId = FirebaseAuth.instance.currentUser!.uid;

class NotificationBox extends StatelessWidget {
  final String? notificationId;
  final String? matchImageUrl;
  final String? matchId; //might not need
  final String? name;
  final DateTime? time;
  final String? type; //might not need
  final String? message;
  final String? userId;
  final bool? swipedLeft;

  NotificationBox(
      {this.userId,
      this.message,
      this.notificationId,
      this.matchImageUrl,
      this.matchId,
      this.name,
      this.time,
      this.type,
      this.swipedLeft});

  @override
  Widget build(BuildContext context) {
    // sendChat(){
    //   var uuid = Uuid();
    //   // //Create a new match for the SENDER of the notification
    //   // final doc = await usersRef.doc('sdlfksdjf').get();
    //   // if (doc.exists) {
    //   //   doc.reference.update({'firstname': 'Annemarie', 'lastName': 'Allen'});
    //   // }
    //   //
    //   //     matchesRef
    //   //         .doc(userId).collection('matches').doc(senderId)
    //   //         .set({
    //   //       'time': Timestamp.fromDate(DateTime.now()),
    //   //       'date': date,
    //   //
    //   //     });
    //
    //   // //TODO: Make a match under the userId
    //   // print('userId: $userId');
    //   //
    //   //   //TODO: Make sure a chat doesn't already exist
    //   // final doc = await matchesRef.doc(userId).collection('matches').doc(senderId).get();
    //   // if (doc.exists){
    //   //   print('The chat already exists!');
    //   //
    //   //   //If the chat already exists, update the chat
    //   //   doc.reference.update({
    //   //     'activeMatch': true,
    //   //     'lastMessage':
    //   //
    //   //   });
    //   // } else {
    //   // This is where to create a new match
    //   matchesRef.doc(userId).collection('matches').doc(senderId).set({
    //     'activeMatch': true,
    //     'dateId': 'test',
    //     'lastMessage':
    //     'INSERT NAME has matched with you! Make a lasting impression so you guys can go on the date at INSERT TIME...!',
    //     'lastMessageSender': userId,
    //     'lastMessageTime': Timestamp.now(),
    //     'matchImageUrl': matchImageUrl,
    //     'matchName': name,
    //     'messageUnread': false,
    //     'messagesId': uuid.v4(),
    //     //TODO: Fix
    //     'availability': availability
    //   });
    //   //
    //   // }
    //
    //   //TODO: Make a match under the senderId
    //   print('senderId: $senderId');
    //
    //   //TODO: Once all that is complete, go to the chat screen....?? Somehow?
    // }

    sendChat() async {
      TextEditingController sendMessageController = TextEditingController();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Match with $name'),
            content: Column(
              children: [
                Text('This is a Flutter popup.'),
                SquareImageFromUrl(
                  imageUrl: matchImageUrl!,
                  size: MediaQuery.of(context).size.height *
                      0.3, // 75% of screen height
                ),
                Text('$message'),
                TextField(
                  controller: sendMessageController,
                  maxLines: 10,
                  minLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Type your message here...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Close'),
                onPressed: () {
                  sendMessageController.dispose();
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Match with $name'),
                onPressed: () async {
                  var messageId = Uuid().v4();

                  // //Get matchUser's profile info/make sure the profile exists still
                  UserData matchUser = UserData();
                  DocumentSnapshot matchDoc = await usersRef.doc(matchId).get();

                  if (matchDoc.exists) {
                    matchUser = UserData.fromDocument(matchDoc);
                    print('Match Users firstname: ${matchUser.firstName}');
                    print(sendMessageController.text);

                    print('matchAvailability: ${matchUser.availability}');
                    print('match Memo: ${matchUser.memo}');

                    //Create a new match for user's pool
                    matchesRef
                        .doc(userId)
                        .collection('matches')
                        .doc(matchId)
                        .set({
                          'activeMatch': true,
                          'dateId': 'test',
                          'lastMessage': sendMessageController.text.isEmpty
                              ? 'New Bond :)'
                              : sendMessageController.text.toString().trim(),
                          'lastMessageSender': userId,
                          'lastMessageTime': Timestamp.now(),
                          'matchImageUrl': matchUser.picture1,
                          'matchName': matchUser.firstName,
                          'memo': matchUser.memo,
                          'messageUnread':
                              sendMessageController.text.isEmpty ? true : false,
                          'messagesId': messageId,
                          //TODO: If you have bugs check here lol
                          'availability': [matchUser.availability![0], matchUser.availability![1]]
                          // {
                          //   matchUser.uid: matchUser.availability?[1]
                          //       ? matchUser.availability![0]
                          //       : null,
                          //   userId: currentUser?.availability?[1]
                          //       ? currentUser?.availability![0]
                          //       : null,
                          // }
                        })
                        .then((value) =>
                            print('Successfully added match to user\'s pool!'))
                        .catchError((onError) => print(
                            'There was an error adding match to user\'s pool: $onError'));
                  }

                  //Create a new match for other user's pool
                  matchesRef
                      .doc(matchId)
                      .collection('matches')
                      .doc(userId)
                      .set({
                        'activeMatch': true,
                        'dateId': 'test',
                        'lastMessage': 'New Match!',
                        // sendMessageController.text.isEmpty
                        //     ? message
                        //     : sendMessageController.text.toString().trim(),
                        'lastMessageSender': userId,
                        'lastMessageTime': Timestamp.now(),
                        'matchImageUrl': matchUser.picture1,
                        'matchName': matchUser.firstName,
                        'memo': matchUser.memo,
                        'messageUnread': true,
                        'messagesId': messageId,
                        //TODO: If you have bugs check here lol
                        'availability': [matchUser.availability![0], matchUser.availability![1]]
                        // {
                        //   matchUser.uid: matchUser.availability?[1]
                        //       ? matchUser.availability![0]
                        //       : null,
                        //   userId: currentUser?.availability?[1]
                        //       ? currentUser?.availability![0]
                        //       : null,
                        // }
                      })
                      .then((value) =>
                          print('Successfully added match to match\'s pool!'))
                      .catchError((onError) => print(
                          'There was an error adding match to match\'s pool: $onError'));

                  //Populate chat with first message
                  messagesRef.doc(messageId).collection('messages').add({
                    'message': message,
                    'sender': matchId,
                    'time': time,
                  });

                  //Populate chat with responding message
                  if (sendMessageController.text.isNotEmpty) {
                    messagesRef.doc(messageId).collection('messages').add({
                      'message':  sendMessageController.text.toString().trim(),
                      'sender': userId,
                      'time': Timestamp.now(),
                    });
                  }

                  //Delete this notification
                  final doc = await notificationsRef.doc(userId).collection('notifications').doc(matchId).get();
                  if (doc.exists) {
                    notificationsRef.doc(userId).collection('notifications').doc(matchId).delete();
                  }

                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }



    return Column(
      children: [
        type!.contains('match') ?
        SizedBox(height: MediaQuery.of(context).size.height * .02)
        : SizedBox(),
        type!.contains('match') ?
        Text('You\'ve got a bond!') : SizedBox(),
        type!.contains('match') ?
        SizedBox(height: MediaQuery.of(context).size.height * .01) : SizedBox(),
        ListTile(
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
                        backButtonFunction: (){
                          Navigator.pop(context);
                        },
                            profileId: matchId,
                            viewingAsBrowseMode: true,
                            viewAvailabilityInfo: false,
                          )));
            },
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey,
              backgroundImage: CachedNetworkImageProvider(matchImageUrl!),
            ),
          ),
          title: Wrap(
            // mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Text(
                    type!.contains('looking')
                        ? '$name sent: "$message"'
                        : '$name sent you a message! Start a bond with them to reply.',
                    style: TextStyle(
                      // fontSize: 10.0,
                      fontWeight: FontWeight.w400,
                      color: kDarkest,
                    )),
              ),
    Text(
        type!.contains('looking')
            ? ''
            : type!.contains('match')
                ? '"$message"'
                : '$name is going to $message',
        style: TextStyle(
          // fontSize: 10.0,
          fontWeight: FontWeight.w600,
          color: kDarkest,
        )),
             ],
          ),
          subtitle: Text(timeago.format(time!),
              style: TextStyle(
                fontWeight: FontWeight.w100,
                color: kDarkest,
              )),
          trailing:
          TextButton(
            child: Text(
              type!.contains('looking')
                  ? 'Reply'
                  : type!.contains('match')
                      ? 'Bond'
                      : 'View Event',
            ),
            onPressed: sendChat,
          ) ,
        ),
        type!.contains('match') ?
        SizedBox(height: MediaQuery.of(context).size.height * .02)
            : SizedBox(),
        SizedBox(height: MediaQuery.of(context).size.height * .01),
      ],
    );
  }
}
