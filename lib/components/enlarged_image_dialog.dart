import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EnlargedImageDialog extends StatelessWidget {
  final String imageUrl;

  const EnlargedImageDialog({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 50,
        ),
      ),
    );
  }
}
