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
      // Correct the use of the Factory and ViewModel
      vm: () => Factory(),
      builder: (context, vm) {
        return DashboardPage(vm: vm);
      },
    );
  }
}

// class DashboardPage extends StatelessWidget {
//   const DashboardPage({Key? key, required this.vm}) : super(key: key);

//   final ViewModel vm;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: "Welcome, ${vm.designation}",
//         backgroundColor: vm.roleColor,
//       ),
//       drawer: CustomDrawer(
//         designation: vm.designation ?? '',
//         roleColor: vm.roleColor,
//       ),
//       body: Column(
//         children: [
//           DropdownButtonFormField<String>(
//             items: [
//               DropdownMenuItem(value: 'OBA', child: Text('OBA')),
//               DropdownMenuItem(value: 'HR Portal', child: Text('HR Portal')),
//               DropdownMenuItem(value: 'All', child: Text('All')),
//             ],
//             onChanged: (String? value) {
//               if (value == 'All') {
//                 vm.clearFilters();
//               } else if (value != null) {
//                 vm.filterScenarios(value);
//               }
//             },
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: vm.filteredScenarios.length,
//               itemBuilder: (context, index) {
//                 final scenario = vm.filteredScenarios[index];
//                 return Card(
//                   child: ListTile(
//                     title: Text(scenario['name'] ?? 'Unnamed Scenario'),
//                     subtitle:
//                         Text(scenario['shortDescription'] ?? 'No description'),
//                     onTap: () {
//                       // Handle onTap for scenario detail
//                     },
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => addScenarioDialog(context, vm),
//         //onPressed: () => addTestCaseDialog(context, 'scenarioId', vm),
//         child: Icon(Icons.add),
//         backgroundColor: vm.roleColor,
//         tooltip: 'Add Scenario',
//       ),
//     );
//   }
// }
