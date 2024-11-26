// import 'package:async_redux/async_redux.dart';
// import 'package:flutter/material.dart';
// import 'package:scenario_management_tool_for_testers/Actions/addcomment.dart';
// import 'package:scenario_management_tool_for_testers/Actions/fetchaction.dart';
// import 'package:scenario_management_tool_for_testers/Actions/fetchsenario.dart';
// import 'package:scenario_management_tool_for_testers/View/Screens/Connnector/dashboard.dart';
// import 'package:scenario_management_tool_for_testers/appstate.dart';
// import 'package:scenario_management_tool_for_testers/viewmodel/dashviewmodel.dart';

// class DashboardPageConnector extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return StoreConnector<AppState, ViewModel>(
//       onInit: (store) {
//         store.dispatch(FetchAssignmentsAction());
//         store.dispatch(FetchScenariosAction());
//         store.dispatch(FetchCommentsAction());
//       },
//       vm: () => Factory(this),
//       builder: (context, vm) => DashboardPage(vm: vm),
//     );
//   }
// }
