import 'package:flutter/material.dart';

Future<void> showInputDialog({
  required BuildContext context,
  required String title,
  required List<Widget> children,
  required Function() onSubmit,
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
            onPressed: onSubmit,
            child: const Text("Submit"),
          ),
        ],
      );
    },
  );
}
