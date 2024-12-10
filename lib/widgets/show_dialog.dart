import 'package:flutter/material.dart';
import 'package:scenario_management_tool_for_testers/constants/enum_role.dart';

class DialogUtils {
  static Future<void> showInputDialog({
    required BuildContext context,
    required String title,
    required String designation,
    required List<Widget> children,
    required VoidCallback onSubmit,
  }) {
    final Role userRole = Role.fromString(designation);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            title,
            style: TextStyle(color: userRole.roleColor),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                onSubmit();
                Navigator.of(context).pop();
              },
              child: const Text(
                "Submit",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }
}
