import 'package:flutter/cupertino.dart';
import 'package:kaliallendatingapp/constants.dart';

class DateButton extends StatelessWidget {
  DateButton(
      {this.text,
        this.text2,
        this.onTap,
        this.color,
        this.dateDay,
        this.border,
        this.fontColor});

  final DateDay? dateDay;
  final String? text;
  final String? text2;
  final VoidCallback? onTap;
  final Color? color;
  final Color? fontColor;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 5.0),
            height: 55.0,
            width: MediaQuery.of(context).size.width * .26,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment(-20.51, 133.59),
                colors: [color!, color!],
              ),
              borderRadius: BorderRadius.circular(10.0),
              border: border,
            ),
            child: Center(
                child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        text!,
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          color: fontColor,
                        ),
                      ),
                      Text(
                        text2!,
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 12.0,
                          color: fontColor,
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ));
  }
}