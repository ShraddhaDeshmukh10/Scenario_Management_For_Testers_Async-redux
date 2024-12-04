import 'package:flutter/material.dart';

Widget buildAvatar(String? imageUrl) {
  return CircleAvatar(
    radius: 25,
    backgroundImage:
        imageUrl != null && imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
    backgroundColor: Colors.grey.shade300,
    child: imageUrl == null || imageUrl.isEmpty
        ? const Icon(Icons.person, color: Colors.white)
        : null,
  );
}
