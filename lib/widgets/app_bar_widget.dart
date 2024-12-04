import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;

  CustomAppBar({required this.title, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      backgroundColor: backgroundColor,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
