import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import 'Home.dart';

class SubmitFeedback extends StatelessWidget {
  final String? uid;


  SubmitFeedback({this.uid});


  @override
  Widget build(BuildContext context) {
    TextEditingController reportController = TextEditingController();
    String? message;

    return Scaffold(
      body: SafeArea(child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: IconButton(icon: Icon(Icons.close,
                  color: kLightDark,
                ), onPressed: () {
                  Navigator.pop(context);
                }),
              ),
            ],
          ),
          Text('All Feedback is Welcome'),
          Text('Submit feedback to help improve the app!'),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              controller: reportController,
              maxLines: 10,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
          OutlinedButton(
            child: Text('Submit'),
            onPressed: () async {
              print('submit clicked');

              await reportsRef.add({
                'report': 'general',
                'userid': uid,
                'message': reportController.text.trim(),
                'time': DateTime.now(),
              }).then((value) {
                message = 'Report Sent!';
              }).catchError((error) =>
              message = 'Report could not send: $error');


              reportController.clear();
              // reportController.dispose();


              SnackBar snackBar = SnackBar(content: Text(message!));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);

              Future.delayed(Duration(seconds: 0), (){Navigator.pop(context);});
            },
          ),
        ],
      )),
    );
  }

}
