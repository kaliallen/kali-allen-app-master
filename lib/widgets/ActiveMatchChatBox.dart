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
  final bool? available;



  ActiveMatchChatBox({this.available, this.dateId, this.matchId, this.activeMatch, this.lastMessage, this.lastMessageSender, this.matchName, this.matchImageUrl, this.messagesId, this.messageUnread, this.lastMessageTime});


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
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
        child: Container(
            width: MediaQuery.of(context).size.width,
                child: Container(
                  width: MediaQuery.of(context).size.width * .85,
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: kWhiteSquareColor,
                    borderRadius: BorderRadius.circular(15.0),
                   border:  available == true ? Border.all(
                      color: Colors.green,
                     width: 1.0
                    ) : Border.all(
                     color: kScaffoldBackgroundColor,
                   ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Container(
                      //   child: Row(
                      //     children: [
                      //       Padding(
                      //         padding: const EdgeInsets.all(5.0),
                      //         child: Icon(
                      //           Icons.access_time,
                      //           color: kMatchBoxTimeFont,
                      //         ),
                      //       ),
                      //       Text(
                      //         'Text here',
                      //         style: TextStyle(
                      //           color: kMatchBoxTimeFont,
                      //           fontWeight: FontWeight.w500,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      //   decoration: BoxDecoration(
                      //     color: kMatchBoxTimeFill,
                      //     borderRadius: BorderRadius.circular(10.0),
                      //   ),
                      // ),

                      Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.grey,
                                    backgroundImage: CachedNetworkImageProvider(matchImageUrl!),
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
                )
            ),
      ),
    );
  }
}
