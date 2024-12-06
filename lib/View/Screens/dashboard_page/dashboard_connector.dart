import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:scenario_management_tool_for_testers/main.dart';
import 'package:scenario_management_tool_for_testers/redux/actions/fetch_senario.dart';
import 'package:scenario_management_tool_for_testers/redux/appstate.dart';
import 'package:scenario_management_tool_for_testers/view/screens/dashboard_page/dash_viewmodel.dart';
import 'package:scenario_management_tool_for_testers/view/screens/dashboard_page/dashboard_page.dart';

class DashboardConnector extends StatelessWidget {
  final DashboardViewModel vm;

  const DashboardConnector({Key? key, required this.vm}) : super(key: key);
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
    extends VmFactory<AppState, DashboardPage, DashboardViewModel> {
  FactoryDashboard() : super();
  @override
  DashboardViewModel fromStore() {
    return DashboardViewModel.fromStore(store);
  }
}
