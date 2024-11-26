import 'package:async_redux/async_redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:scenario_management_tool_for_testers/Actions/mainactions.dart';
import 'package:scenario_management_tool_for_testers/View/Screens/testcasecommentpage.dart';
import 'package:scenario_management_tool_for_testers/appstate.dart';
import 'package:scenario_management_tool_for_testers/main.dart';

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
                        onPressed: () async {
                          final changes =
                              await _fetchChangeHistory(scenario['docId']);
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Edit History"),
                                content: changes.isEmpty
                                    ? const Text("No changes found.")
                                    : SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: changes.map((change) {
                                            final testCaseId =
                                                change['testCaseId'];
                                            final tags =
                                                change['tags'] as List<String>?;
                                            final editedBy =
                                                change['editedBy'] ?? 'Unknown';
                                            final timestamp = change[
                                                        'timestamp'] !=
                                                    null
                                                ? DateFormat(
                                                        "dd-MM-yyyy hh:mm a")
                                                    .format((change['timestamp']
                                                            as Timestamp)
                                                        .toDate())
                                                : null;

                                            // return Column(
                                            //   crossAxisAlignment:
                                            //       CrossAxisAlignment.start,
                                            //   children: [
                                            //     if (testCaseId != null)
                                            //       Text(
                                            //           "Test Case ID: $testCaseId"), // Conditionally show testCaseId
                                            //     if (tags != null)
                                            //       Text(
                                            //         "Tags: ${tags.join(', ')}",
                                            //         style: TextStyle(
                                            //           color: _getTagColor(tags),
                                            //         ),
                                            //       ), // Conditionally show tags
                                            //     if (testCaseId != null ||
                                            //         tags != null) ...[
                                            //       if (editedBy.isNotEmpty)
                                            //         Text(
                                            //           "Edited By: $editedBy",
                                            //           style: TextStyle(
                                            //               fontSize: 10),
                                            //         ), // Conditionally show editedBy
                                            //       if (timestamp != null)
                                            //         Text(
                                            //           "Timestamp: $timestamp",
                                            //           style: TextStyle(
                                            //               fontSize: 10),
                                            //         ), // Conditionally show timestamp
                                            //     ],
                                            //     Divider(),
                                            //   ],
                                            // );
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (testCaseId != null)
                                                  _buildInfoRow(
                                                    icon: Icons.assignment,
                                                    label: "Test Case ID",
                                                    value: testCaseId,
                                                    valueStyle: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                if (tags != null)
                                                  _buildInfoRow(
                                                    icon: Icons.label,
                                                    label: "Tags",
                                                    value: tags.join(', '),
                                                    valueStyle: TextStyle(
                                                        color:
                                                            _getTagColor(tags)),
                                                  ),
                                                if (testCaseId != null ||
                                                    tags != null) ...[
                                                  if (editedBy.isNotEmpty)
                                                    _buildInfoRow(
                                                      icon: Icons.edit,
                                                      label: "Edited By",
                                                      value: editedBy,
                                                      valueStyle: TextStyle(
                                                          fontSize: 12,
                                                          fontStyle:
                                                              FontStyle.italic),
                                                    ),
                                                  if (timestamp != null)
                                                    _buildInfoRow(
                                                      icon: Icons.access_time,
                                                      label: "Timestamp",
                                                      value: timestamp,
                                                      valueStyle: TextStyle(
                                                          fontSize: 12,
                                                          fontStyle:
                                                              FontStyle.italic),
                                                    ),
                                                ],
                                                Divider(
                                                    thickness: 1,
                                                    color: Colors.black),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text("Close"),
                                  ),
                                ],
                              );
                            },
                          );
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
                        // Text(
                        //   "Scenario Details",
                        //   style: TextStyle(
                        //     fontSize: 16,
                        //     fontWeight: FontWeight.bold,
                        //     color: Colors.blueAccent,
                        //   ),
                        // ),
                        // Divider(thickness: 1.5),
                        // SizedBox(height: 8),
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
                        final createdAt = testCase['createdAt'] as Timestamp?;
                        final formattedDate = createdAt != null
                            ? DateFormat("dd-MM-yyyy. hh:mm a")
                                .format(createdAt.toDate())
                            : 'N/A';

                        /// Controllers for the editable fields
                        final descriptionController = TextEditingController(
                            text: testCase['description'] ?? '');
                        final commentsController = TextEditingController(
                            text: testCase['comments'] ?? '');
                        String? selectedTag =
                            testCase['tags']?.isNotEmpty ?? false
                                ? (testCase['tags'] is List
                                    ? testCase['tags'][0]
                                    : testCase['tags'])
                                : null;

                        // Dropdown options for tags
                        final tagsOptions = designation == 'Junior Tester'
                            ? ["Passed", "Failed", "In Review"]
                            : ["Passed", "Failed", "In Review", "Completed"];

                        if (selectedTag != null &&
                            !tagsOptions.contains(selectedTag)) {
                          selectedTag =
                              tagsOptions.isNotEmpty ? tagsOptions[0] : null;
                        }

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Row with save, edit, and delete icons
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        testCase['name'] ?? 'N/A',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TestCaseCommentsPage(
                                              scenarioId: scenario['docId'],
                                              testCaseId: testCase['docId'],
                                              roleColor: roleColor,
                                              designation: designation,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.add_comment),
                                    ),
                                    IconButton(
                                      color: Colors.blue,
                                      icon: const Icon(Icons.save),
                                      onPressed: () async {
                                        final description =
                                            descriptionController.text;
                                        final comments =
                                            commentsController.text;
                                        final tags = selectedTag != null
                                            ? [selectedTag]
                                            : [];

                                        if (description.isEmpty) {
                                          Fluttertoast.showToast(
                                            msg: "Description cannot be empty!",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                            fontSize: 16.0,
                                          );
                                          return;
                                        }

                                        try {
                                          // Update the test case document
                                          await FirebaseFirestore.instance
                                              .collection('scenarios')
                                              .doc(scenario['docId'])
                                              .collection('testCases')
                                              .doc(testCase['docId'])
                                              .update({
                                            'description': description,
                                            'comments': comments,
                                            'tags': tags,
                                            'updatedAt':
                                                FieldValue.serverTimestamp(),
                                          });

                                          // Add the change to the changes collection
                                          await FirebaseFirestore.instance
                                              .collection('scenarios')
                                              .doc(scenario['docId'])
                                              .collection('changes')
                                              .add({
                                            'timestamp':
                                                FieldValue.serverTimestamp(),
                                            'editedBy': FirebaseAuth.instance
                                                    .currentUser?.email ??
                                                'unknown_user',
                                            'testCaseId': testCase['bugId'],
                                            'tags': tags,
                                          });

                                          Fluttertoast.showToast(
                                            msg:
                                                "Test case saved successfully!",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            backgroundColor: Colors.green,
                                            textColor: Colors.white,
                                            fontSize: 16.0,
                                          );
                                          store.dispatch(FetchTestCasesAction(
                                              scenario['docId']));
                                        } catch (e) {
                                          Fluttertoast.showToast(
                                            msg: "Failed to save changes: $e",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                            fontSize: 16.0,
                                          );
                                        }
                                      },
                                    ),
                                    if (designation != 'Junior Tester')
                                      IconButton(
                                        color: Colors.red,
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => _deleteTestCase(
                                            testCase['docId'], testCase),
                                      ),
                                  ],
                                ),

                                /// Editable fields
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    controller: descriptionController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.description),
                                      labelText: "Description",
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    controller: commentsController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.comment),
                                      labelText: "Comments",
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: DropdownButtonFormField<String>(
                                    value: selectedTag,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Tags",
                                    ),
                                    items: tagsOptions
                                        .map((tag) => DropdownMenuItem(
                                            value: tag, child: Text(tag)))
                                        .toList(),
                                    onChanged: (value) => selectedTag = value,
                                  ),
                                ),

                                /// Non-editable fields
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Test Case ID",
                                      prefixIcon: Icon(Icons.description),
                                      hintText: testCase['bugId'] ?? 'N/A',
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Created At",
                                      prefixIcon:
                                          Icon(Icons.calendar_today_sharp),
                                      hintText: formattedDate,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Created By",
                                      prefixIcon: Icon(Icons.email),
                                      hintText: testCase['createdBy'] ?? 'N/A',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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

//// used to fetch testcases from firestore
  Future<List<Map<String, dynamic>>> _fetchChangeHistory(
      String scenarioId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('scenarios')
          .doc(scenarioId)
          .collection('changes')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      final changes = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final testCaseId = data['testCaseId']?.toString(); // Ensure string
        final tags = data['tags'] != null
            ? List<String>.from(data['tags'])
            : null; // Ensure tags is a list or null

        return {
          'docId': doc.id,
          ...data,
          'testCaseId': testCaseId?.isEmpty == true ? null : testCaseId,
          'tags': tags?.isEmpty == true ? null : tags,
        };
      }).toList();
      final filteredChanges = changes.where((change) {
        return change['testCaseId'] != null || change['tags'] != null;
      }).toList();
      return filteredChanges;
    } catch (e) {
      print("Error fetching change history: $e");
      return [];
    }
  }

  ///allows delete option to lead tester
  Future<void> _deleteTestCase(
      String testCaseId, Map<String, dynamic> testCase) async {
    try {
      await FirebaseFirestore.instance
          .collection('scenarios')
          .doc(scenario['docId'])
          .collection('testCases')
          .doc(testCaseId)
          .delete();
      store.dispatch(FetchTestCasesAction(scenario['docId']));
    } catch (e) {
      print("Failed to delete test case: $e");
    }
  }

  Future<void> _saveChangeHistory(String scenarioId, String description) async {
    final userEmail =
        FirebaseAuth.instance.currentUser?.email ?? 'unknown_user';
    try {
      await FirebaseFirestore.instance
          .collection('scenarios')
          .doc(scenarioId)
          .collection('changes')
          .add({
        'timestamp': FieldValue.serverTimestamp(),
        'EditedBy': userEmail,
        'description': description,
      });
    } catch (e) {
      print("Error saving change history: $e");
    }
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
