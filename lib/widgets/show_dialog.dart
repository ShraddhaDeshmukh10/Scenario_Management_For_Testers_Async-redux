import 'package:flutter/material.dart';

class DialogUtils {
  /// Displays a customizable input dialog.
  static Future<void> showInputDialog({
    required BuildContext context,
    required String title,
    required List<Widget> children,
    required VoidCallback onSubmit,
  }) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                onSubmit();
                Navigator.of(context).pop();
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }
}
