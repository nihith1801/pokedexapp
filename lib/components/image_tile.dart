import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ImageTile extends StatelessWidget {
  final String imagePath;

  ImageTile({
    Key? key,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Lottie.asset(
        imagePath,
        height: 100,
        width: 100,
      ),
    );
  }
}
