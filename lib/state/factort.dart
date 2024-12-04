import 'package:async_redux/async_redux.dart';
import 'package:scenario_management_tool_for_testers/View/Screens/dashboard_page.dart';
import 'package:scenario_management_tool_for_testers/main.dart';
import 'package:scenario_management_tool_for_testers/state/appstate.dart';
import 'package:scenario_management_tool_for_testers/state/dashviewmodel.dart';

// class Factory extends VmFactory<AppState, DashboardPage, ViewModel> {
//   Factory(DashboardPage connector) : super(connector);

//   @override
//   ViewModel fromStore() => ViewModel.fromStore(store);
// }

class Factory extends VmFactory<AppState, DashboardPage, ViewModel> {
  Factory() : super();

  @override
  ViewModel fromStore() {
    return ViewModel.fromStore(store);
  }
}
