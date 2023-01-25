import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kaliallendatingapp/widgets/PromptTile.dart';

class Prompts extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Prompts',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close,
            color: Colors.black,),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: ListView(
        children: [
          PromptTile(promptTitle: 'What do you hate most about dating apps?',),
          PromptTile(promptTitle: 'What do you want to do on your next date?',),
        ]
      )
    );
  }
}

