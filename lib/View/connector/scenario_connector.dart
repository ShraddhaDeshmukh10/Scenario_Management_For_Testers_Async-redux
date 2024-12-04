import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:scenario_management_tool_for_testers/Actions/mainactions.dart';
import 'package:scenario_management_tool_for_testers/View/Screens/scenariodetail.dart';
import 'package:scenario_management_tool_for_testers/state/appstate.dart';

class ScenarioDetailConnector extends StatelessWidget {
  final Map<String, dynamic> scenario;
  final Color roleColor;
  final String designation;

  const ScenarioDetailConnector({
    super.key,
    required this.scenario,
    required this.roleColor,
    required this.designation,
  });

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<Map<String, dynamic>>>(
      converter: (store) => store.state.testCases,
      onInit: (store) =>
          store.dispatch(FetchTestCasesAction(scenario['docId'])),
      builder: (context, testCases) {
        return ScenarioDetailPage(
          scenario: scenario,
          roleColor: roleColor,
          designation: designation,
          testCases: testCases,
        );
      },
    );
  }
}
