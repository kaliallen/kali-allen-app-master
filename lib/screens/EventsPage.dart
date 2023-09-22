import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kaliallendatingapp/widgets/PromptTile.dart';

import '../constants.dart';
import '../widgets/EventTile.dart';

class EventsPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Events',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_sharp, color: kDarkish),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add,
            color: Colors.black,),
            onPressed: (){

            }
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
              children: [
                EventTile(eventTitle: 'Ketamma at Culture',),
                EventTile(eventTitle: 'Yoga at Malcolm X Park',),
              ]
          ),
            ),
            Container(
              child: Row(
                children: [
                  Expanded(
                    child: TextField()
                  ),
                  TextButton(
                    child: Text('Add Event'),
                    onPressed: (){},
                  )
                ],
              )
            )
          ]
        ),
      )
    );
  }
}

