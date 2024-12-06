import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scenario_management_tool_for_testers/widgets/show_dialog.dart';

void addTestCaseDialog(BuildContext context, String scenarioId, vm) {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bugIdController = TextEditingController();
  final TextEditingController commentsController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final String createdBy =
      FirebaseAuth.instance.currentUser?.email ?? 'unknown_user';
  String? selectedTag;

  final tagsOptions = vm.designation == 'Junior Tester'
      ? ["Passed", "Failed", "In Review"]
      : ["Passed", "Failed", "In Review", "Completed"];

  DialogUtils.showInputDialog(
    context: context,
    title: "Add Test Case",
    children: [
      TextFormField(
        controller: bugIdController,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          labelText: "Test Case ID",
          hintText: "Digits only",
        ),
      ),
      TextFormField(
        controller: nameController,
        decoration: const InputDecoration(labelText: "Test Case Name"),
      ),
      DropdownButtonFormField<String>(
        value: selectedTag,
        decoration: const InputDecoration(labelText: "Tags"),
        items: tagsOptions
            .map((tag) => DropdownMenuItem(value: tag, child: Text(tag)))
            .toList(),
        onChanged: (value) => selectedTag = value,
      ),
      TextFormField(
        controller: commentsController,
        decoration: const InputDecoration(labelText: "Comments"),
      ),
      TextFormField(
        controller: descriptionController,
        decoration: const InputDecoration(labelText: "Description"),
      ),
    ],
    onSubmit: () async {
      if (bugIdController.text.isNotEmpty &&
          nameController.text.isNotEmpty &&
          selectedTag != null) {
        try {
          // Check if the Test Case ID (bugId) already exists.
          final querySnapshot = await FirebaseFirestore.instance
              .collection('scenarios')
              .doc(scenarioId)
              .collection('testCases')
              .where('bugId', isEqualTo: bugIdController.text)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            Fluttertoast.showToast(
              msg: "Test Case ID already exists!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          } else {
            // Create the new test case.
            final testCase = {
              'name': nameController.text,
              'bugId': bugIdController.text,
              'tags': selectedTag,
              'comments': commentsController.text,
              'description': descriptionController.text,
              'scenarioId': scenarioId,
              'createdAt': FieldValue.serverTimestamp(),
              'createdBy': createdBy,
            };

            // Save to Firestore.
            await FirebaseFirestore.instance
                .collection('scenarios')
                .doc(scenarioId)
                .collection('testCases')
                .add(testCase);

            Navigator.of(context).pop();
            Fluttertoast.showToast(
              msg: "Test Case Added Successfully",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0,
            );

            // Refresh the UI.
            vm.fetchScenarios();
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to add test case: $e")),
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Please fill all required details!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    },
  );
}
