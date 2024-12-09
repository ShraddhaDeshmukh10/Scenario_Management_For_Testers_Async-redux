import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scenario_management_tool_for_testers/Resources/route.dart';
import 'package:scenario_management_tool_for_testers/widgets/card_decoration.dart';
import 'package:scenario_management_tool_for_testers/widgets/expanded_widget.dart';

///This class takes scenario, roleColor, and designation as inputs, with scenario details rendered across various sections (Scenario Details, Test Cases, Comments, etc.).
///Conditional rendering using if allows certain actions only for lead tester and developer, such as viewing change history or deleting test cases.
class ScenarioDetailPage extends StatelessWidget {
  final Map<String, dynamic> scenario;
  final Color roleColor;
  final String designation;
  final List<Map<String, dynamic>> testCases;

  const ScenarioDetailPage({
    super.key,
    required this.scenario,
    required this.roleColor,
    required this.designation,
    required this.testCases,
  });

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(scenario['projectName'] ?? 'Scenario Detail'),
        backgroundColor: roleColor,
        actions: List<Widget>.of([
          if (designation != 'Junior Tester')
            ElevatedButton(
              child: const Text(
                "Show Edit History",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.pushNamed(context, Routes.editpagedetail, arguments: {
                  'scenarioId': scenario['docId'],
                  'roleColor': roleColor,
                  'designation': designation
                });
              },
            ),
        ]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Scenario Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
            const Divider(),
            Card(
              elevation: 8,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border(
                    top: BorderSide(
                      color: roleColor,
                      width: 1.0,
                      style: BorderStyle.solid,
                    ),
                    left: BorderSide(
                      color: roleColor,
                      width: 2.0,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomWidgets.buildInfoRow(
                        icon: Icons.text_snippet,
                        label: "Scenario Name",
                        value: scenario['name'] ?? 'N/A',
                        valueStyle:
                            const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      CustomWidgets.buildInfoRow(
                        icon: Icons.person,
                        label: "Assigned User",
                        value: scenario['assignedToEmail'] ?? 'N/A',
                        valueStyle: const TextStyle(color: Colors.blue),
                      ),
                      const SizedBox(height: 8),
                      CustomWidgets.buildInfoRow(
                        icon: Icons.description,
                        label: "Description",
                        value: scenario['shortDescription'] ?? 'N/A',
                      ),
                      const SizedBox(height: 8),
                      CustomWidgets.buildInfoRow(
                        icon: Icons.calendar_today,
                        label: "Created At",
                        value: scenario['createdAt'] != null
                            ? DateFormat("dd-MM-yyyy, hh:mm a")
                                .format(scenario['createdAt'])
                            : 'N/A',
                        valueStyle: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      CustomWidgets.buildInfoRow(
                        icon: Icons.email,
                        label: "Created By",
                        value: scenario['createdByEmail'] ?? 'N/A',
                        valueStyle: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(),
            const Text(
              'Test Cases',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Divider(),
            if (testCases.isEmpty)
              const Text("No test cases found")
            else
              Container(
                height: 0.58 * h,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: testCases.length,
                  itemBuilder: (context, index) {
                    final testCase = testCases[index];
                    return ExpandableTestCaseCard(
                      testCase: testCase,
                      scenarioId: scenario['docId'],
                      roleColor: roleColor,
                      designation: designation,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
