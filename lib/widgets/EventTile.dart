import 'package:flutter/material.dart';

class EventTile extends StatelessWidget {
  final String? eventTitle;

  EventTile({this.eventTitle});

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

            },
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                eventTitle!,
              ),
            ),
          ),
        ),
        Divider(),
      ],
    );
  }
}
