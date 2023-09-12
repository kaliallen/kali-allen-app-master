import 'package:flutter/cupertino.dart';

class SquareImageFromUrl extends StatelessWidget {
  final String imageUrl;
  final double size;

  SquareImageFromUrl({required this.imageUrl, this.size = 100.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8.0), // You can adjust the border radius as needed
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(imageUrl),
        ),
      ),
    );
  }
}
