import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scenario_management_tool_for_testers/main.dart';
import 'package:scenario_management_tool_for_testers/model/change_history.dart';
import 'package:scenario_management_tool_for_testers/model/comments_model.dart';
import 'package:scenario_management_tool_for_testers/redux/actions/add_test_action.dart';
import 'package:scenario_management_tool_for_testers/redux/actions/filter_scenario.dart';
import 'package:scenario_management_tool_for_testers/redux/actions/upload_image.dart';
import 'package:scenario_management_tool_for_testers/constants/response.dart';
import 'package:scenario_management_tool_for_testers/model/scenario_model.dart';
import 'package:scenario_management_tool_for_testers/model/testcase_model.dart';
import 'package:scenario_management_tool_for_testers/appstate.dart';
import 'package:scenario_management_tool_for_testers/redux/actions/fetch_senario.dart';
import 'package:scenario_management_tool_for_testers/redux/actions/update_senario.dart';
import 'package:scenario_management_tool_for_testers/redux/actions/delete_senario.dart';
import 'package:scenario_management_tool_for_testers/view/screens/dashboard_page/dashboard_page.dart';

class ViewModel extends Vm {
  final String? designation;
  final List<Scenario> scenarios;
  final List<Scenario> filteredScenarios;
  final void Function(String filter) filterScenarios;
  final void Function() clearFilters;
  final Color roleColor;
  final List<Comment> comments;
  final VoidCallback fetchScenarios;
  final void Function(String, Map<String, dynamic>) updateScenario;
  final Function(String?) searchScenarios;
  final void Function(String docId) deleteScenario;
  final List<TestCase> testCases; // Change this to List<TestCase>
  final List<ChangeHistory> changeHistory;
  final DataResponse? response;
  final void Function(Uint8List fileBytes, String fileName) onUploadImage;
  final void Function(
    String project,
    String bugId,
    String shortDescription,
    String testCaseName,
    String scenario,
    String comments,
    String description,
    String attachment,
    String? tag,
  ) addtestcase;

  ViewModel({
    required this.response,
    required this.onUploadImage,
    required this.addtestcase,
    required this.testCases,
    required this.changeHistory,
    required this.deleteScenario,
    required this.scenarios,
    required this.filteredScenarios,
    required this.filterScenarios,
    required this.clearFilters,
    required this.designation,
    required this.roleColor,
    required this.comments,
    required this.fetchScenarios,
    required this.updateScenario,
    required this.searchScenarios,
  }) : super(equals: [
          scenarios,
          comments,
          filteredScenarios,
          response,
          testCases
        ]);

  static ViewModel fromStore(Store<AppState> store) {
    String designation = store.state.designation ?? '';
    Color getRoleColor() {
      switch (designation) {
        case 'Junior Tester':
          return Colors.red;
        case 'Tester Lead':
          return Colors.green;
        case 'Developer':
          return Colors.blue;
        default:
          return Colors.grey;
      }
    }

    return ViewModel(
      response: store.state.response,
      changeHistory: store.state.changeHistory,
      testCases: store.state.testCases,
      scenarios: store.state.scenarios,
      filteredScenarios: store.state.filteredScenarios ?? store.state.scenarios,
      filterScenarios: (String filter) {
        store.dispatch(FilterScenariosAction(filter));
      },
      clearFilters: () {
        store.dispatch(ClearFiltersAction());
      },
      onUploadImage: (fileBytes, fileName) =>
          store.dispatch(UploadImageAction(fileBytes, fileName)),
      designation: store.state.designation,
      comments: store.state.comments,
      roleColor: getRoleColor(),
      deleteScenario: (docId) => store.dispatch(DeleteScenarioAction(docId)),
      fetchScenarios: () => store.dispatch(FetchScenariosAction()),
      searchScenarios: (projectName) =>
          store.dispatch(FetchScenariosAction(projectName: projectName)),
      updateScenario: (docId, data) =>
          store.dispatch(UpdateScenarioAction(docId: docId, updatedData: data)),
      addtestcase: (project, bugId, shortDescription, testCaseName, scenario,
              comments, description, attachment, tag) =>
          store.dispatch(AddTestCaseAction(
        project: project,
        bugId: bugId,
        shortDescription: shortDescription,
        testCaseName: testCaseName,
        scenarioId: scenario,
        comments: comments,
        description: description,
        attachment: attachment,
        tag: tag, // Ensure you're passing tag here
      )),
    );
  }
}

class Factory extends VmFactory<AppState, DashboardPage, ViewModel> {
  Factory() : super();

  @override
  ViewModel fromStore() {
    return ViewModel.fromStore(store);
  }
}
