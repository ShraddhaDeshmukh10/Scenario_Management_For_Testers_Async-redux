import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:scenario_management_tool_for_testers/helper/tag_helper.dart';
import 'package:scenario_management_tool_for_testers/redux/actions/fetch_change_history.dart';
import 'package:scenario_management_tool_for_testers/redux/actions/testcase.dart';
import 'package:scenario_management_tool_for_testers/main.dart';
import 'package:scenario_management_tool_for_testers/screens/comment_screen/comment_page_connector.dart';

class ExpandableTestCaseCard extends StatefulWidget {
  final Map<String, dynamic> testCase;
  final String scenarioId;
  final Color roleColor;
  final String designation;

  const ExpandableTestCaseCard({
    Key? key,
    required this.testCase,
    required this.scenarioId,
    required this.roleColor,
    required this.designation,
  }) : super(key: key);

  @override
  _ExpandableTestCaseCardState createState() => _ExpandableTestCaseCardState();
}

class _ExpandableTestCaseCardState extends State<ExpandableTestCaseCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final testCase = widget.testCase;

    final designation = widget.designation;
    final tagColor = Helper.getTagColor(testCase['tags']);

    final createdAt = testCase['createdAt'];
    final formattedDate = createdAt != null
        ? DateFormat("dd-MM-yyyy, hh:mm a").format(createdAt)
        : 'N/A';

    final descriptionController =
        TextEditingController(text: testCase['description'] ?? '');
    final commentsController =
        TextEditingController(text: testCase['comments'] ?? '');
    String? selectedTag =
        (testCase['tags'] is List && testCase['tags'].isNotEmpty)
            ? testCase['tags'][0]
            : null;

    final tagsOptions = ["Passed", "Failed", "In Review", "Completed"];
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Card border radius
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0), // Match Card radius
              border: Border(
                top: BorderSide(
                  color: tagColor,
                  width: 3.0,
                  style: BorderStyle.solid,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: tagColor.withOpacity(0.2),
                  offset: const Offset(0.1, 0.0),
                  blurRadius: 1.0,
                  spreadRadius: 1.0,
                ),
              ],
            ),
            child: ListTile(
              title: Text(
                testCase['name'] ?? 'N/A',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              trailing: IconButton(
                tooltip: "Tap to see Details",
                icon: Icon(
                  isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                ),
                onPressed: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          tooltip: "Add Comment",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TestCaseCommentsConnector(
                                  scenarioId: widget.scenarioId,
                                  testCaseId: testCase[
                                      'docId'], // Ensure 'docId' is correct key
                                  roleColor: widget.roleColor,
                                  designation: designation,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_comment),
                        ),
                        if (designation != 'Junior Tester')
                          IconButton(
                            tooltip: "Delete",
                            color: Colors.red,
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                _deleteTestCase(testCase['docId'], testCase),
                          ),
                        IconButton(
                          color: Colors.blue,
                          tooltip: "Save",
                          icon: const Icon(Icons.save),
                          onPressed: () async {
                            final description = descriptionController.text;
                            final comments = commentsController.text;
                            final tags =
                                selectedTag != null ? [selectedTag] : [];

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

                            if (designation == 'Junior Tester' &&
                                selectedTag == "Completed") {
                              Fluttertoast.showToast(
                                msg:
                                    "Junior Tester cannot save 'Completed' tag!",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                              return;
                            }

                            if (testCase['docId'] == null) {
                              Fluttertoast.showToast(
                                msg: "Test case ID is missing!",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                              return;
                            }

                            try {
                              // Fetch current user's email
                              final user = FirebaseAuth.instance.currentUser;
                              final userEmail = user?.email ?? "Unknown User";

                              final testCaseId = testCase['docId'];

                              print(
                                  "Attempting to save test case with ID: $testCaseId");

                              // Update test case data
                              await FirebaseFirestore.instance
                                  .collection('scenarios')
                                  .doc(widget.scenarioId)
                                  .collection('testCases')
                                  .doc(testCaseId)
                                  .update({
                                'description': description,
                                'comments': comments,
                                'tags': tags,
                                'updatedAt': FieldValue.serverTimestamp(),
                              });
                              await FirebaseFirestore.instance
                                  .collection('scenarios')
                                  .doc(widget.scenarioId)
                                  .collection('changes')
                                  .add({
                                'testCaseId': testCase['bugId'],
                                'description': description,
                                'tags': tags,
                                'editedBy': userEmail,
                                'timestamp': FieldValue.serverTimestamp(),
                              });
                              store.dispatch(
                                  FetchTestCasesAction(widget.scenarioId));
                              store.dispatch(
                                  FetchChangeHistoryAction(widget.scenarioId));

                              Fluttertoast.showToast(
                                msg: "Test case saved successfully!",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.green,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            } catch (e) {
                              print("Failed to save changes: $e");

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
                      ],
                    ),
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
                            .map((tag) =>
                                DropdownMenuItem(value: tag, child: Text(tag)))
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
                          prefixIcon: Icon(Icons.calendar_today_sharp),
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
                  ]),
            ),
        ],
      ),
    );
  }

  Future<void> _deleteTestCase(
      String testCaseId, Map<String, dynamic> testCase) async {
    try {
      await FirebaseFirestore.instance
          .collection('scenarios')
          .doc(widget.scenarioId)
          .collection('testCases')
          .doc(testCaseId)
          .delete();

      store.dispatch(FetchTestCasesAction(widget.scenarioId));
      Fluttertoast.showToast(
        msg: "Test case deleted successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      print("Failed to delete test case: $e");
      Fluttertoast.showToast(
        msg: "Failed to delete test case: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}
