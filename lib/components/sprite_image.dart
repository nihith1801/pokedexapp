import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// A stateless widget that displays an image from a network URL along with a label.
///
/// The image is fetched from the provided [url] and displayed within an 80x80 box.
/// If the image is loading, a [CircularProgressIndicator] is shown.
/// If there is an error loading the image, an error icon is displayed.
///
/// The [label] is displayed below the image in a text widget with a font size of 12.
class SpriteImage extends StatelessWidget {
  /// The URL of the image to display.
  final String url;

  /// The label to display below the image.
  final String label;

  /// Creates a [SpriteImage] widget.
  ///
  /// Both [url] and [label] are required and must not be null.
  const SpriteImage({
    super.key,
    required this.url,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CachedNetworkImage(
          imageUrl: url,
          placeholder: (BuildContext context, String url) =>
              const CircularProgressIndicator(),
          errorWidget: (BuildContext context, String url, dynamic error) =>
              const Icon(Icons.error),
          width: 80,
          height: 80,
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
