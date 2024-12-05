import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:scenario_management_tool_for_testers/Actions/fetchsenario.dart';
import 'package:scenario_management_tool_for_testers/View/Screens/dashboard_page.dart';
import 'package:scenario_management_tool_for_testers/state/appstate.dart';
import 'package:scenario_management_tool_for_testers/state/dashviewmodel.dart';
import 'package:scenario_management_tool_for_testers/state/factort.dart';

class DashboardConnector extends StatelessWidget {
  const DashboardConnector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      onInit: (store) {
        store.dispatch(FetchScenariosAction());
      },
      vm: () => Factory(),
      builder: (context, vm) {
        return DashboardPage(vm: vm);
      },
    );
  }
}
