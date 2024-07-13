import 'package:flutter/material.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onSignOut;
  final List<Widget>? actions;

  const TopBar({
    Key? key,
    required this.title,
    required this.onSignOut,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.black87,
      actions: [
        ...?actions,
        IconButton(
          icon: Icon(Icons.exit_to_app),
          onPressed: onSignOut,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
