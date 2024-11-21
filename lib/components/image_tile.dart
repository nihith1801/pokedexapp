import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ImageTile extends StatelessWidget {
  final String imagePath;

  const ImageTile({
    super.key,
    required this.imagePath,
  });

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
