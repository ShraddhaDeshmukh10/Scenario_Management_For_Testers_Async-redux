import 'package:flutter/material.dart';

class Helper {
  static Color getTagColor(dynamic tags) {
    if (tags == null) {
      return Colors.black;
    }
    if (tags is String) {
      return getColorFromTag(tags);
    }
    if (tags is List && tags.isNotEmpty) {
      final tag = tags[0] as String?;
      return getColorFromTag(tag);
    }

    return Colors.black;
  }

  static Color getColorFromTag(String? tag) {
    switch (tag) {
      case "Passed":
        return Colors.green;
      case "Failed":
        return Colors.red;
      case "In Review":
        return Color.fromARGB(255, 190, 175, 6);
      case "Completed":
        return Colors.orange;
      default:
        return Colors.black;
    }
  }
}
