import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> signOut(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
    SystemNavigator.pop(); // Close the app or pop to the previous screen
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Error signing out")));
  }
}
