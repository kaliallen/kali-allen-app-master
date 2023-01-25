import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class SubmitFeedback extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.all(8),
                child:  IconButton(icon: Icon(Icons.close,
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
              maxLines: 10,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
          OutlinedButton(
            child: Text('Submit'),
            onPressed: (){
              print('submit clicked');
            },
          ),
        ],
      )),
    );
  }
}
