import 'package:flutter/material.dart';

/// Returns the appropriate color for a given tag or list of tags.
Color getTagColor(dynamic tags) {
  if (tags == null)
    return Colors.black; // Default color when no tags are present

  // Check if tags is a String
  if (tags is String) {
    return getColorFromTag(tags);
  }

  // Check if tags is a List
  if (tags is List && tags.isNotEmpty) {
    final tag = tags[0] as String?; // Get the first tag
    return getColorFromTag(tag);
  }

  return Colors.black; // Default color for unknown or empty tags
}

/// Returns the color for a specific tag.
Color getColorFromTag(String? tag) {
  switch (tag) {
    case "Passed":
      return Colors.green; // Green for "Passed"
    case "Failed":
      return Colors.red; // Red for "Failed"
    case "In Review":
      return Color.fromARGB(255, 190, 175, 6); // Yellow for "In Review"
    case "Completed":
      return Colors.orange; // Orange for "Completed"
    default:
      return Colors.black; // Default color for unknown tags
  }
}
