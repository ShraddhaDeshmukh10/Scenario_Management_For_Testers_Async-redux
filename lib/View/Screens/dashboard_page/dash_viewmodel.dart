import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:scenario_management_tool_for_testers/redux/app_state.dart';
import 'package:scenario_management_tool_for_testers/constants/enum_role.dart';
import 'package:scenario_management_tool_for_testers/constants/response.dart';
import 'package:scenario_management_tool_for_testers/model/comments_model.dart';
import 'package:scenario_management_tool_for_testers/model/scenario_model.dart';
import 'package:scenario_management_tool_for_testers/redux/actions/delete_senario.dart';
import 'package:scenario_management_tool_for_testers/redux/actions/fetch_senario.dart';
import 'package:scenario_management_tool_for_testers/redux/actions/filter_scenario.dart';

class DashboardViewModel extends Vm {
  final String? designation;
  final Color roleColor;
  final List<Scenario> scenarios;
  final List<Scenario> filteredScenarios;
  final void Function(String filter) filterScenarios;
  final void Function() clearFilters;

  final VoidCallback fetchScenarios;
  final void Function(String docId) deleteScenario;
  final List<Comment> comments;
  final DataResponse? response;

  DashboardViewModel({
    required this.designation,
    required this.roleColor,
    required this.scenarios,
    required this.filteredScenarios,
    required this.filterScenarios,
    required this.clearFilters,
    required this.fetchScenarios,
    required this.deleteScenario,
    required this.comments,
    required this.response,
  }) : super(equals: [scenarios, filteredScenarios, comments, response]);

  static DashboardViewModel fromStore(Store<AppState> store) {
    final designation = store.state.designation ?? 'undefined';
    final roleColor = Role.fromString(designation).roleColor;

    return DashboardViewModel(
      designation: store.state.designation,
      response: store.state.response,
      scenarios: store.state.scenarios,
      filteredScenarios: store.state.filteredScenarios ?? store.state.scenarios,
      filterScenarios: (String filter) {
        store.dispatch(FilterScenariosAction(filter));
      },
      clearFilters: () {
        store.dispatch(ClearFiltersAction());
      },
      roleColor: roleColor,
      comments: store.state.comments,
      fetchScenarios: () => store.dispatch(FetchScenariosAction()),
      deleteScenario: (docId) => store.dispatch(DeleteScenarioAction(docId)),
    );
  }
}
