import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scenario_management_tool_for_testers/widgets/sign_out.dart';

class CustomDrawer extends StatelessWidget {
  final String designation;
  final Color roleColor;

  CustomDrawer({required this.designation, required this.roleColor});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text("User: $designation"),
            accountEmail: Text(
                FirebaseAuth.instance.currentUser?.email ?? 'Not logged in'),
            currentAccountPicture: CircleAvatar(child: Icon(Icons.person)),
            decoration: BoxDecoration(color: roleColor),
            otherAccountsPictures: [
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: () => signOut(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
