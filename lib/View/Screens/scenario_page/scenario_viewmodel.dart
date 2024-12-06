import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:scenario_management_tool_for_testers/redux/appstate.dart';
import 'package:scenario_management_tool_for_testers/constants/enum_role.dart';
import 'package:scenario_management_tool_for_testers/model/scenario_model.dart';
import 'package:scenario_management_tool_for_testers/model/testcase_model.dart';

class ScenarioDetailViewModel extends Vm {
  final Scenario scenario;
  final Color roleColor;
  final String designation;
  final List<TestCase> testCases;

  ScenarioDetailViewModel({
    required this.scenario,
    required this.roleColor,
    required this.designation,
    required this.testCases,
  }) : super(equals: [scenario, testCases]);

  static ScenarioDetailViewModel fromStore(
      Store<AppState> store, Scenario scenario) {
    final designation = store.state.designation ?? 'undefined';
    final roleColor = Role.fromString(designation).roleColor;

    return ScenarioDetailViewModel(
      scenario: scenario,
      roleColor: roleColor,
      designation: designation,
      testCases: store.state.testCases,
    );
  }
}
