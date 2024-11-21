import 'package:flutter/material.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onSignOut;
  final VoidCallback onMusicTap;
  final VoidCallback onGridViewTap;
  final VoidCallback onChatbotTap;
  final VoidCallback onTFLiteTap;

  const TopBar({
    super.key,
    required this.title,
    required this.onSignOut,
    required this.onMusicTap,
    required this.onGridViewTap,
    required this.onChatbotTap,
    required this.onTFLiteTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.black87,
      actions: [
        IconButton(
          icon: const Icon(Icons.grid_view),
          onPressed: onGridViewTap,
        ),
        IconButton(
          icon: const Icon(Icons.chat_bubble),
          onPressed: onChatbotTap,
        ),
        IconButton(
          icon: const Icon(Icons.music_note),
          onPressed: onMusicTap,
        ),
        IconButton(
          icon: const Icon(Icons.science),
          onPressed: onTFLiteTap,
        ),
        IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: onSignOut,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
