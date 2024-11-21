import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

/// A stateless widget that displays a Rive animation as the background.
///
/// The animation is loaded from a `.riv` asset file and fills the entire screen.
class RiveBackground extends StatelessWidget {
  /// Creates a [RiveBackground] widget.
  ///
  /// This widget has no parameters.
  const RiveBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: const RiveAnimation.asset(
          'assets/pokedexapp.riv',
        ),
      ),
    );
  }
}
