import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:scenario_management_tool_for_testers/model/testcase_model.dart';
import 'package:scenario_management_tool_for_testers/redux/actions/testcase.dart';
import 'package:scenario_management_tool_for_testers/view/screens/scenario_page/scenario_detail.dart';
import 'package:scenario_management_tool_for_testers/model/scenario_model.dart';
import 'package:scenario_management_tool_for_testers/redux/appstate.dart';

class ScenarioDetailConnector extends StatelessWidget {
  final Scenario scenario;
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
    return StoreConnector<AppState, List<TestCase>>(
      converter: (store) => store.state.testCases,
      onInit: (store) {
        store.dispatch(FetchTestCasesAction(scenario.docId));
      },
      builder: (context, testCases) {
        return ScenarioDetailPage(
          scenario: scenario.toMap(),
          roleColor: roleColor,
          designation: designation,
          testCases: testCases.map((testCase) => testCase.toMap()).toList(),
        );
      },
    );
  }
}
