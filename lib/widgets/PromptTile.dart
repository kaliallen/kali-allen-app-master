import 'package:flutter/material.dart';

class PromptTile extends StatelessWidget {
  final String promptTitle;

  PromptTile({this.promptTitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: (){
              print('pressed');
              Navigator.pop(context, promptTitle);
            },
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                promptTitle,
              ),
            ),
          ),
        ),
        Divider(),
      ],
    );
  }
}
