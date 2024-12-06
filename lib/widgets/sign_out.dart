import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scenario_management_tool_for_testers/Resources/route.dart';

Future<void> signOut(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
    //SystemNavigator.pop(); // Close the app or pop to the previous screen
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Error signing out")));
  }
}
