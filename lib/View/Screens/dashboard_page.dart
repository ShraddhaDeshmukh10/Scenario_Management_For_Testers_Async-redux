import 'package:flutter/material.dart';
import 'package:scenario_management_tool_for_testers/Resources/route.dart';
import 'package:scenario_management_tool_for_testers/model/scenario_model.dart';
import 'package:scenario_management_tool_for_testers/state/dashviewmodel.dart';
import 'package:scenario_management_tool_for_testers/widgets/app_bar_widget.dart';
import 'package:scenario_management_tool_for_testers/widgets/drawer_widget.dart';
import 'package:scenario_management_tool_for_testers/widgets/scenario_dialog.dart';
import 'package:scenario_management_tool_for_testers/widgets/test_case_dialog.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key, required this.vm}) : super(key: key);

  final ViewModel vm;

  @override
  Widget build(BuildContext context) {
    String? selectedFilter;
    return Scaffold(
      appBar: CustomAppBar(
        title: "Welcome, ${vm.designation}",
        backgroundColor: vm.roleColor,
      ),
      drawer: CustomDrawer(
        designation: vm.designation ?? '',
        roleColor: vm.roleColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: StatefulBuilder(
                builder: (context, setState) {
                  return DropdownButtonFormField<String>(
                    value: selectedFilter,
                    decoration: const InputDecoration(
                      hintText: "Select Project Name",
                      labelText: "Filter by Project Type",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'OBA', child: Text('OBA')),
                      DropdownMenuItem(
                          value: 'HR Portal', child: Text('HR Portal')),
                      DropdownMenuItem(value: 'All', child: Text('All')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedFilter = value;
                        if (value == 'All') {
                          selectedFilter = null;
                          vm.clearFilters();
                        } else {
                          vm.filterScenarios(value!);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ),
          if (vm.filteredScenarios.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No scenarios found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: vm.filteredScenarios.length,
                itemBuilder: (context, index) {
                  final Scenario scenario = vm.filteredScenarios[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10.0), // Card border radius
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(10.0), // Match Card radius
                        border: Border(
                          top: BorderSide(
                            color: vm.roleColor,
                            width: 1.0,
                            style: BorderStyle.solid,
                          ),
                          left: BorderSide(
                            color: vm.roleColor,
                            width: 2.0,
                            style: BorderStyle.solid,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: vm.roleColor.withOpacity(0.1),
                            offset: const Offset(0.1, 0.0),
                            blurRadius: 1.0,
                            spreadRadius: 1.0,
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          scenario.name ?? 'Unamed Scenario',
                          // scenario.projectId ?? 'Not found Scenario ID',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.scenariodetailconnector,
                            arguments: {
                              'scenario': scenario,
                              'roleColor': vm.roleColor,
                              'designation': vm.designation ?? '',
                            },
                          );
                        },
                        subtitle: Text(
                          scenario.shortDescription ?? 'N/A',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                addTestCaseDialog(context, scenario.docId, vm);
                              },
                              child: Text(
                                "Add Test Case",
                                style: TextStyle(
                                    color: vm.roleColor,
                                    //color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (vm.designation != 'Junior Tester')
                              IconButton(
                                onPressed: () {
                                  deleteScenarioDialog(context, scenario.docId);
                                },
                                icon: Icon(Icons.delete),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onPressed: () => addScenarioDialog(context, vm),
        child: Icon(Icons.add),
        backgroundColor: vm.roleColor,
        tooltip: 'Add Scenario',
      ),
    );
  }
}
