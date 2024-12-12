import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:scenario_management_tool_for_testers/redux/actions/clear_filter.dart';
import 'package:scenario_management_tool_for_testers/redux/actions/delete_senario.dart';
import 'package:scenario_management_tool_for_testers/redux/actions/fetch_senario.dart';
import 'package:scenario_management_tool_for_testers/redux/actions/filter_scenario.dart';
import 'package:scenario_management_tool_for_testers/constants/enum_role.dart';
import 'package:scenario_management_tool_for_testers/appstate.dart';
import 'package:scenario_management_tool_for_testers/screens/dashboard_screen/dash_viewmodel.dart';
import 'package:scenario_management_tool_for_testers/screens/dashboard_screen/dashboard_page.dart';

class DashboardConnector extends StatelessWidget {
  const DashboardConnector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, DashboardViewModel>(
      onInit: (store) {
        store.dispatch(FetchScenariosAction());
      },
      vm: () => FactoryDashboard(),
      builder: (context, vm) {
        return DashboardPage(vm: vm);
      },
    );
  }
}

class FactoryDashboard
    extends VmFactory<AppState, DashboardConnector, DashboardViewModel> {
  @override
  DashboardViewModel fromStore() {
    final designation = state.designation ?? 'undefined';
    final roleColor = Role.fromString(designation).roleColor;

    return DashboardViewModel(
      designation: state.designation,
      roleColor: roleColor,
      scenarios: state.scenarios,
      filteredScenarios: state.filteredScenarios ?? state.scenarios,
      filterScenarios: (filter) {
        dispatch(FilterScenariosAction(filter));
      },
      clearFilters: () {
        dispatch(ClearFiltersAction());
      },
      fetchScenarios: () {
        dispatch(FetchScenariosAction());
      },
      deleteScenario: (docId) {
        dispatch(DeleteScenarioAction(docId));
      },
      comments: state.comments,
      response: state.response,
    );
  }
}
