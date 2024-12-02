import 'package:async_redux/async_redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scenario_management_tool_for_testers/Actions/mainactions.dart';
import 'package:scenario_management_tool_for_testers/Resources/route.dart';
import 'package:scenario_management_tool_for_testers/View/Screens/expandalble.dart';
import 'package:scenario_management_tool_for_testers/appstate.dart';

///This class takes scenario, roleColor, and designation as inputs, with scenario details rendered across various sections (Scenario Details, Test Cases, Comments, etc.).
///Conditional rendering using if allows certain actions only for lead tester and developer, such as viewing change history or deleting test cases.
class ScenarioDetailPage extends StatelessWidget {
  final Map<String, dynamic> scenario;
  final Color roleColor;
  final String designation;

  const ScenarioDetailPage({
    super.key,
    required this.scenario,
    required this.roleColor,
    required this.designation,
  });

  @override
  Widget build(BuildContext context) {
    Color _getTagColor(List<dynamic>? tags) {
      // Ensure there is at least one tag
      if (tags != null && tags.isNotEmpty) {
        // Cast the first tag to String if it's dynamic
        final tag =
            tags[0] as String; // Ensure that the tag is treated as a String

        switch (tag) {
          case "Passed":
            return Colors.green; // Green for "Passed"
          case "Failed":
            return Colors.red; // Red for "Failed"
          case "In Review":
            return Color.fromARGB(255, 189, 173, 22); // Yellow for "In Review"
          case "Completed":
            return Colors.orange; // Orange for "Completed"
          default:
            return Colors.black; // Default color for unknown tags
        }
      }
      return Colors.black; // Default color when no tags are present
    }

    final h = MediaQuery.of(context).size.height;
    return StoreConnector<AppState, List<Map<String, dynamic>>>(
      converter: (store) => store.state.testCases,
      onInit: (store) =>
          store.dispatch(FetchTestCasesAction(scenario['docId'])),
      builder: (context, testCases) {
        return Scaffold(
          appBar: AppBar(
            title: Text(scenario['projectName'] ?? 'Scenario Detail'),
            backgroundColor: roleColor,
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),

                    /// this option is only available to developer and lead tester to track the changes in scenario tastcases.
                    if (designation != 'Junior Tester') ...[
                      // Change history button code
                      TextButton(
                        child: const Text("Show Edit History"),
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.editpagedetail,
                              arguments: {
                                'scenarioId': scenario['docId'],
                                'roleColor': roleColor,
                                'designation': designation
                              });
                        },
                      ),
                    ],
                  ],
                ),
                const Divider(),

                Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          icon: Icons.text_snippet,
                          label: "Scenario Name",
                          value: scenario['name'] ?? 'N/A',
                          valueStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        _buildInfoRow(
                          icon: Icons.person,
                          label: "Assigned User",
                          value: scenario['assignedToEmail'] ?? 'N/A',
                          valueStyle: TextStyle(color: Colors.blue),
                        ),
                        SizedBox(height: 8),
                        _buildInfoRow(
                          icon: Icons.description,
                          label: "Description",
                          value: scenario['shortDescription'] ?? 'N/A',
                        ),
                        SizedBox(height: 8),
                        _buildInfoRow(
                          icon: Icons.calendar_today,
                          label: "Created At",
                          value: scenario['createdAt'] != null
                              ? DateFormat("dd-MM-yyyy, hh:mm a").format(
                                  (scenario['createdAt'] as Timestamp).toDate())
                              : 'N/A',
                          valueStyle: TextStyle(fontSize: 12),
                        ),
                        SizedBox(height: 8),
                        _buildInfoRow(
                          icon: Icons.email,
                          label: "Created By",
                          value: scenario['createdByEmail'] ?? 'N/A',
                          valueStyle: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),

                const Divider(),
                //  Test Cases...............
                const Text(
                  'Test Cases',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
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
      },
    );
  }
}

Widget _buildInfoRow({
  required IconData icon,
  required String label,
  required String value,
  TextStyle? valueStyle,
}) {
  return Row(
    children: [
      Icon(icon, size: 20, color: Colors.grey),
      SizedBox(width: 8),
      Text(
        "$label: ",
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: valueStyle ??
              TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

Widget _buildAvatar(String? imageUrl) {
  return CircleAvatar(
    radius: 25,
    backgroundImage:
        imageUrl != null && imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
    backgroundColor: Colors.grey.shade300,
    child: imageUrl == null || imageUrl.isEmpty
        ? const Icon(Icons.person, color: Colors.white)
        : null,
  );
}
