import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/screens/ChatScreen.dart';
import 'package:page_transition/page_transition.dart';

String userId = FirebaseAuth.instance.currentUser!.uid;

class ActiveMatchChatBox extends StatelessWidget {
  final String? matchId;
  final bool? activeMatch;
  final String? lastMessage;
  final String? lastMessageSender;
  final DateTime? lastMessageTime;
  final String? matchImageUrl;
  final String? matchName;
  final bool? messageUnread;
  final String? messagesId;
  final String? dateId;
  final List? available;



  ActiveMatchChatBox({this.available, this.dateId, this.matchId, this.activeMatch, this.lastMessage, this.lastMessageSender, this.matchName, this.matchImageUrl, this.messagesId, this.messageUnread, this.lastMessageTime});


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.rightToLeft,
                child: ChatScreen(
                  activeMatch: activeMatch,
                  matchId: matchId,
                  messageId: messagesId.toString(),
                  matchName:   matchName.toString(),
                  matchImageUrl: matchImageUrl.toString(),

                )));
      },
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * .01),
          Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: kWhiteSquareColor,
              borderRadius: BorderRadius.circular(15.0),

            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 70.0,
                              height: 70.0,
                              decoration: BoxDecoration(
                                color: kScaffoldBackgroundColor,
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(matchImageUrl!),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.all( Radius.circular(50.0)),
                                border: Border.all(
                                  color: Colors.green,
                                  width: 3.0,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                     matchName!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: kDarkest,
                                      )
                                  ),
                                 // activeMatch?
                                  Text(
                                      lastMessage!,
                                      style: TextStyle(
                                        fontWeight: messageUnread! ? FontWeight.w700 : FontWeight.w300,
                                      )
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Text(
                            "${DateFormat.jm().format(lastMessageTime!)}"
                        )
                      ],
                    )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
