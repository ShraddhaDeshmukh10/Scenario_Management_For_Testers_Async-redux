import 'package:flutter/material.dart';
import 'package:scenario_management_tool_for_testers/Resources/route.dart';
import 'package:scenario_management_tool_for_testers/model/scenario_model.dart';
import 'package:scenario_management_tool_for_testers/screens/dashboard_screen/dash_viewmodel.dart';
import 'package:scenario_management_tool_for_testers/widgets/app_bar_widget.dart';
import 'package:scenario_management_tool_for_testers/widgets/drawer_widget.dart';
import 'package:scenario_management_tool_for_testers/widgets/scenario_dialog.dart';
import 'package:scenario_management_tool_for_testers/widgets/test_case_dialog.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key, required this.vm}) : super(key: key);

  final DashboardViewModel vm;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool isDeleting = false;

  void setDeleting(bool value) {
    setState(() {
      isDeleting = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    String? selectedFilter;
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomAppBar(
        title: "Welcome, ${widget.vm.designation}",
        backgroundColor: widget.vm.roleColor,
      ),
      drawer: CustomDrawer(
        designation: widget.vm.designation ?? '',
        roleColor: widget.vm.roleColor,
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
                      labelText: "Filter by Project Name",
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
                          widget.vm.clearFilters();
                        } else {
                          widget.vm.filterScenarios(value!);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ),
          Card(
            child: Container(
              width: w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                    color: widget.vm.roleColor,
                    width: 2.0,
                    style: BorderStyle.solid),
                boxShadow: [
                  BoxShadow(
                    color: widget.vm.roleColor.withOpacity(0.1),
                    offset: const Offset(0.1, 0.0),
                    blurRadius: 1.0,
                    spreadRadius: 1.0,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Scenario List....",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
          if (widget.vm.filteredScenarios.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: h * 0.2,
                    ),
                    const Text(
                      'No scenarios found . Add Scenarios.....',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: FloatingActionButton.large(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        onPressed: () => ScenarioDialogs.addScenarioDialog(
                            context, widget.vm),
                        backgroundColor: widget.vm.roleColor,
                        tooltip: 'Add Scenario',
                        child: const Icon(
                          Icons.add,
                          size: 40,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Click Here",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    )
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: widget.vm.filteredScenarios.length,
                itemBuilder: (context, index) {
                  final Scenario scenario = widget.vm.filteredScenarios[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border(
                          top: BorderSide(
                            color: widget.vm.roleColor,
                            width: 1.0,
                            style: BorderStyle.solid,
                          ),
                          left: BorderSide(
                            color: widget.vm.roleColor,
                            width: 2.0,
                            style: BorderStyle.solid,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.vm.roleColor.withOpacity(0.1),
                            offset: const Offset(0.1, 0.0),
                            blurRadius: 1.0,
                            spreadRadius: 1.0,
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          scenario.name ?? 'Unnamed Scenario',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.scenariodetailconnector,
                            arguments: {
                              'scenario': scenario,
                              'roleColor': widget.vm.roleColor,
                              'designation': widget.vm.designation ?? '',
                            },
                          );
                        },
                        subtitle: Text(
                          scenario.projectName ?? 'Unnamed Project',
                          style: TextStyle(fontSize: 11),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                addTestCaseDialog(
                                    context, scenario.docId, widget.vm);
                              },
                              child: Text(
                                "Add Test Case",
                                style: TextStyle(
                                    color: widget.vm.roleColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (widget.vm.designation != 'Junior Tester')
                              IconButton(
                                onPressed: () {
                                  deleteScenarioDialog(context, scenario);
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
      floatingActionButton: widget.vm.filteredScenarios.isNotEmpty
          ? FloatingActionButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              onPressed: () =>
                  ScenarioDialogs.addScenarioDialog(context, widget.vm),
              child: Icon(Icons.add),
              backgroundColor: widget.vm.roleColor,
              tooltip: 'Add Scenario',
            )
          : null,
    );
  }
}
