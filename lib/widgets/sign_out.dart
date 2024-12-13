import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scenario_management_tool_for_testers/Resources/route.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> signOut(BuildContext context) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('password');

    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Error signing out")));
  }
}
