import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Mybutton extends StatelessWidget {
  final Function()? onTap;

  const Mybutton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(25),
        margin: EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Lottie.asset(
              'assets/pokeball.json', // Replace with your actual asset path
              width: 50,
              height: 50,
              repeat: true,
              reverse: true,
            ),
            Text(
              'Login',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            Lottie.asset(
              'assets/pokeball.json', // Replace with your actual asset path
              width: 50,
              height: 50,
              repeat: true,
              reverse: true,
            ),
          ],
        ),
      ),
    );
  }
}
