import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:scenario_management_tool_for_testers/helper/tag_helper.dart';
import 'package:scenario_management_tool_for_testers/redux/actions/main_actions.dart';
import 'package:scenario_management_tool_for_testers/view/screens/test_comment_page.dart';
import 'package:scenario_management_tool_for_testers/main.dart';

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
  Future<void> _deleteTestCase(
      String testCaseId, Map<String, dynamic> testCase) async {
    try {
      // Check if the testCaseId is not null and correct
      print("Deleting test case with ID: $testCaseId");

      // Attempt to delete the test case from Firestore
      await FirebaseFirestore.instance
          .collection('scenarios')
          .doc(widget.scenarioId)
          .collection('testCases')
          .doc(testCaseId)
          .delete();

      // Optionally, trigger a fetch to refresh the list
      store.dispatch(FetchTestCasesAction(widget.scenarioId));

      // Provide feedback to the user
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

      // Provide feedback if deletion fails
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

  @override
  Widget build(BuildContext context) {
    final testCase = widget.testCase;

    final designation = widget.designation;
    final tagColor = getTagColor(testCase['tags']);

    final createdAt = testCase['createdAt']; // Assume it's a DateTime
    final formattedDate = createdAt != null
        ? DateFormat("dd-MM-yyyy, hh:mm a").format(createdAt) // Format DateTime
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
                                builder: (context) => TestCaseCommentsPage(
                                  scenarioId: widget.scenarioId,
                                  testCaseId: testCase['docId'],
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
                            final testCaseId = testCase['docId'] ??
                                ''; // Provide a default empty string if null

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

                            // Ensure docId is not null before updating
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
                              print(
                                  "Attempting to save test case with ID: ${testCase['docId']}");

                              await FirebaseFirestore.instance
                                  .collection('scenarios')
                                  .doc(widget.scenarioId)
                                  .collection('testCases')
                                  .doc(testCase['docId'])
                                  .update({
                                'description': description,
                                'comments': comments,
                                'tags': tags,
                                'updatedAt': FieldValue.serverTimestamp(),
                              });

                              print("Test case saved successfully!");

                              store.dispatch(
                                  FetchTestCasesAction(widget.scenarioId));

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
                        )
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
}
