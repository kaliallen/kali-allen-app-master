import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/screens/Home.dart';
import 'package:kaliallendatingapp/screens/ProfilePage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:timeago/timeago.dart' as timeago;

User? loggedInUser;

class ChatScreen extends StatefulWidget {
  final String? matchId;
  final String? messageId;
  final String? matchName;
  final String? matchImageUrl;
  final bool? activeMatch;


  ChatScreen({
    this.matchId,
    this.messageId,
    this.matchName,
    this.matchImageUrl,
    this.activeMatch,

  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  String? messageText;

  viewProfile() {
    //TODO: When pressed, a drop down menu appears with two options: view profile, report profile, unmatch, cancel.
    // showModalBottomSheet(
    //     context: context,
    //     builder: (context){
    //       return Center(
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             Text('View Profile'),
    //           ],
    //         )
    //       );
    //     });
    // Navigator.push(context, MaterialPageRoute(builder: (context)=>
    //     ProfilePage(profileId: widget.matchId, viewPreferenceInfo: true, viewingAsBrowseMode: false)));
  }

  void getCurrentUser() async {
    try {
      final user = await FirebaseAuth.instance.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_sharp, color: kDarkish),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          // Text('Hide Availability'),
          IconButton(
            icon: Icon(
              Icons.cloud,
              color: kDarkish,),
            //TODO: Implement 3 button functionality
            onPressed: (){

            },
          ),
          PopupMenuButton(
            onSelected: (result){
              if (result==2){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePage(profileId: widget.matchId, viewingAsBrowseMode: false, viewAvailabilityInfo: false, backButtonFunction: (){},)));
              }
            },
            elevation: 20,
            icon: Icon(Icons.more_vert, color: kDarkish),
            itemBuilder: (context) => <PopupMenuEntry>[
              PopupMenuItem(

                child: Text(
                  'Report',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              PopupMenuItem(
                child: Text('Unmatch'),
              ),
              PopupMenuItem(
                value: 2,
                   child: Text('View Profile')),
              const PopupMenuDivider(),
              PopupMenuItem(child: Text('Cancel'))
            ],
          ),

        ],
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    right: 10.0,
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey,
                    backgroundImage:
                        CachedNetworkImageProvider(widget.matchImageUrl!),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //TODO: Make it so text resizes when name is too long and then test it
                    Text(widget.matchName!,
                        style: TextStyle(
                          color: kDarkest,
                          fontWeight: FontWeight.w700,
                          fontSize: 18.0,
                        )),

                    Text('You have mutual availabilities!',
                        //TODO: Figure out how to make a countdown timer
                        // '${DateFormat().format(widget.endTime.toDate())}',
                        style: TextStyle(
                          color: kLightDark,
                          fontSize: 13.0,
                        ))
                  ],
                ),
              ],
            ),
          ],

        ),
        backgroundColor: Colors.white,
        shadowColor: kScaffoldBackgroundColor,
        foregroundColor: kScaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(
              messageId: widget.messageId,
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      messageTextController.clear();
                      messagesRef
                          .doc(widget.messageId)
                          .collection('messages')
                          .add({
                        'message': messageText,
                        'sender': loggedInUser!.uid,
                        'time': Timestamp.now(),
                      });

                      //TODO: This is inefficient--change later
                      //Adds last message and message time to Matches Collection
                      final doc = await matchesRef
                          .doc(loggedInUser!.uid)
                          .collection('matches')
                          .doc(widget.matchId)
                          .get();
                      if (doc.exists) {
                        doc.reference.update({
                          'lastMessage': messageText,
                          'lastMessageSender': loggedInUser!.uid,
                          'lastMessageTime': DateTime.now(),
                          'messageUnread': false,
                        });
                      }
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  String? messageId;

  MessagesStream({this.messageId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: messagesRef
            .doc(messageId)
            .collection('messages')
            .orderBy('time', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          final messages = snapshot.data!.docs;
          List<MessageBubble> messageBubbles = [];
          for (var message in messages) {
            final messageText = message['message'];
            final messageSender = message['sender'];
            final messageTime = message['time'];

            final String currentUser = loggedInUser!.uid;

            if (currentUser == messageSender) {
              //The message is from the logged in user
            }

            final messageBubble = MessageBubble(
              sender: messageSender,
              text: messageText,
              time: messageTime,
              isMe: currentUser == messageSender,
            );
            messageBubbles.add(messageBubble);
          }
          return Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              children: messageBubbles,
            ),
          );
        });
  }
}

class MessageBubble extends StatelessWidget {
  final String? sender;
  final String? text;
  final Timestamp? time;
  final bool? isMe;

  MessageBubble({this.sender, this.text, this.time, this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe != null ? isMe == true ? CrossAxisAlignment.end : CrossAxisAlignment.start : CrossAxisAlignment.start,
        children: [
          Material(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
              elevation: 5.0,
              color: isMe! ? Color(0xff393D49) : Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Text(
                  text!,
                  style: TextStyle(
                    color: isMe! ? Colors.white : Color(0xff3B4351),
                    fontSize: 15.0,
                  ),
                ),
              )),
          //TODO: Make it so timeago only shows after a whole day
          Text(
            timeago.format(time!.toDate()),
            style: TextStyle(
              fontSize: 13.0,
            ),
          ),
        ],
      ),
    );
  }
}
