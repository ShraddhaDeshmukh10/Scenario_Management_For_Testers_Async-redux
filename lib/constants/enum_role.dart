import 'package:flutter/material.dart';

enum Role {
  juniorTester(Colors.red),
  testerLead(Colors.green),
  developer(Colors.blue),
  undefined(Colors.grey);

  final Color roleColor;

  const Role(this.roleColor);
  static Role fromString(String designation) {
    switch (designation) {
      case 'Junior Tester':
        return Role.juniorTester;
      case 'Tester Lead':
        return Role.testerLead;
      case 'Developer':
        return Role.developer;
      default:
        return Role.undefined;
    }
  }
}
