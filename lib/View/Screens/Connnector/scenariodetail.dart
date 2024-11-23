import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:async_redux/async_redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:scenario_management_tool_for_testers/Actions/mainactions.dart';
import 'package:scenario_management_tool_for_testers/Services/dataservice.dart';
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
    final w = MediaQuery.of(context).size.width;
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

                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (testCaseId != null)
                                                  Text(
                                                      "Test Case ID: $testCaseId"), // Conditionally show testCaseId
                                                if (tags != null)
                                                  Text(
                                                    "Tags: ${tags.join(', ')}",
                                                    style: TextStyle(
                                                      color: _getTagColor(tags),
                                                    ),
                                                  ), // Conditionally show tags
                                                if (testCaseId != null ||
                                                    tags != null) ...[
                                                  if (editedBy.isNotEmpty)
                                                    Text(
                                                      "Edited By: $editedBy",
                                                      style: TextStyle(
                                                          fontSize: 10),
                                                    ), // Conditionally show editedBy
                                                  if (timestamp != null)
                                                    Text(
                                                      "Timestamp: $timestamp",
                                                      style: TextStyle(
                                                          fontSize: 10),
                                                    ), // Conditionally show timestamp
                                                ],
                                                Divider(),
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
                  child: Column(
                    children: [
                      Text("Scenario Name: ${scenario['name'] ?? 'N/A'}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          )),
                      Text(
                        "Assigned User: ${scenario['assignedToEmail'] ?? 'N/A'}",
                        style: TextStyle(color: Colors.blue),
                      ),
                      Text(
                        "Description: ${scenario['shortDescription'] ?? 'N/A'}",
                      ),
                      Text(
                        "Created At: ${scenario['createdAt'] != null ? DateFormat("dd-MM-yyyy. hh:mm a").format((scenario['createdAt'] as Timestamp).toDate()) : 'N/A'}",
                        style: TextStyle(fontSize: 10),
                      ),
                      Text("Created By: ${scenario['createdByEmail'] ?? 'N/A'}",
                          style: TextStyle(fontSize: 10)),
                    ],
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
                    height: 0.33 * h,
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
                                        "Test Case Name: ${testCase['name'] ?? 'N/A'}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
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
                                Text(
                                    "Test Case ID: ${testCase['bugId'] ?? 'N/A'}"),
                                Text("Created At: $formattedDate",
                                    style: const TextStyle(fontSize: 10)),
                                Text(
                                  "Created By: ${testCase['createdBy'] ?? 'N/A'}",
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                const Divider(),
                Row(
                  children: [
                    const Text(
                      "Comment List",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    TextButton(
                      onPressed: () {
                        _addComment(context, scenario['docId']);
                      },
                      child: const Text("Add Comment"),
                    ),
                  ],
                ),
                // Row(
                //   children: [
                //     // const TextField(
                //     //   decoration: InputDecoration(
                //     //       border: OutlineInputBorder(),
                //     //       labelText: "Add Comment......"),
                //     // ),
                //     // IconButton(
                //     //     onPressed: () {}, icon: const Icon(Icons.attachment)),
                //     IconButton(
                //       onPressed: () {
                //         _addComment(context, scenario['docId']);
                //       },
                //       icon: const Icon(Icons.send),
                //     ),
                //   ],
                // ),
                const Divider(),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchComments(scenario['docId']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No comments found"));
                    }
                    final comments = snapshot.data!;
                    return Container(
                      height: h * 0.3,
                      child: ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          final imageUrl = comment['attachment'] as String?;
                          final timestamp = comment['timestamp'] as Timestamp;
                          final formattedDate =
                              DateFormat("dd-MM-yyyy. hh:mm a")
                                  .format(timestamp.toDate());
                          final createdBy =
                              comment['createdBy'] ?? 'unknown_user';
                          final currentUserEmail =
                              FirebaseAuth.instance.currentUser?.email;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            child: Row(
                              mainAxisAlignment: createdBy == currentUserEmail
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                if (createdBy != currentUserEmail) ...[
                                  _buildAvatar(imageUrl),
                                  const SizedBox(width: 8),
                                ],
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: createdBy == currentUserEmail
                                          ? Colors.blue.shade100
                                          : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment['text'] ?? 'N/A',
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          "By: $createdBy",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          formattedDate,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (createdBy == currentUserEmail) ...[
                                  const SizedBox(width: 8),
                                  _buildAvatar(imageUrl),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

//// used to fetch testcases from firestore

  Future<List<Map<String, dynamic>>> _fetchComments(String scenarioId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('scenarios')
          .doc(scenarioId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return {'docId': doc.id, ...?doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      print("Error fetching comments: $e");
      return [];
    }
  }

  void _addComment(BuildContext context, String scenarioId) {
    final TextEditingController commentController = TextEditingController();
    String? imageUrl;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add Comment"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        labelText: "Enter your comment",
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(context, (url) {
                        setState(() {
                          imageUrl = url;
                        });
                      }),
                      icon: const Icon(Icons.upload),
                      label: const Text("Upload Image"),
                    ),
                    if (imageUrl != null) ...[
                      const SizedBox(height: 10),
                      Text("Uploaded Image URL: $imageUrl"),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.network(
                          imageUrl!,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Text(
                              'Failed to load image',
                              style: TextStyle(color: Colors.red),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    final commentText = commentController.text.trim();
                    if (commentText.isNotEmpty) {
                      try {
                        final commentData = {
                          'text': commentText,
                          'createdBy':
                              FirebaseAuth.instance.currentUser?.email ??
                                  'unknown_user',
                          'timestamp': FieldValue.serverTimestamp(),
                          'attachment': imageUrl ?? '',
                        };

                        await FirebaseFirestore.instance
                            .collection('scenarios')
                            .doc(scenarioId)
                            .collection('comments')
                            .add(commentData);

                        Fluttertoast.showToast(
                          msg: "Comment added successfully!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );

                        store.dispatch(FetchTestCasesAction(scenarioId));

                        Navigator.of(context).pop();
                      } catch (e) {
                        print("Error saving comment: $e");
                        Fluttertoast.showToast(
                          msg: "Error Adding Comment",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      }
                    } else {
                      Fluttertoast.showToast(
                        msg: "Comment cannot be Empty!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _pickImage(
      BuildContext context, Function(String) onImageUploaded) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null) {
      File file = File(result.files.single.path!);

      // Check file size
      if (result.files.single.size <= 200 * 1024) {
        String? imageUrl = await _uploadImage(file);
        if (imageUrl != null) {
          onImageUploaded(imageUrl);
        } else {
          Fluttertoast.showToast(
            msg: "Image Upload Failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Please select an image below 200KB",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }

  Future<String?> _uploadImage(File file) async {
    try {
      Uint8List fileBytes = await file.readAsBytes();
      String fileName = file.uri.pathSegments.last;

      print("Uploading file: $fileName");
      print("File size: ${fileBytes.length} bytes");

      final dataService = GetIt.instance<DataService>();
      // Directly get the response from uploadFile
      final http.Response response =
          await dataService.uploadFile(fileBytes, fileName);

      // Check the response status code
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Image uploaded successfully: ${response.body}");
        // Assuming the response body contains the relative URL
        final responseData = jsonDecode(response.body);
        String relativeImageUrl = responseData['data'];

        // Concatenate base URL with the relative path to get the full image URL
        String fullImageUrl = "https://dev.orderbookings.com$relativeImageUrl";

        return fullImageUrl; // Return the full image URL
      } else {
        print("Error uploading image: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error during image upload: $e");
      return null;
    }
  }

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
