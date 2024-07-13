import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class RiveBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: RiveAnimation.asset(
          'assets/pokedexapp.riv',
        ),
      ),
    );
  }
}
