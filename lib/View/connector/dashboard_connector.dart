import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:scenario_management_tool_for_testers/redux/actions/fetch_senario.dart';
import 'package:scenario_management_tool_for_testers/redux/view_model.dart';
import 'package:scenario_management_tool_for_testers/view/screens/dashboard_page.dart';
import 'package:scenario_management_tool_for_testers/appstate.dart';

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
