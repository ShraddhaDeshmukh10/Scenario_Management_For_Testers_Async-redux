import 'package:flutter/material.dart';

Color getRoleColor(String designation) {
  switch (designation) {
    case 'Junior Tester':
      return Colors.red;
    case 'Tester Lead':
      return Colors.green;
    case 'Developer':
      return Colors.blue;
    default:
      return Colors.grey;
  }
}
