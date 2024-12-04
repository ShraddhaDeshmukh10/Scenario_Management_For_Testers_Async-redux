import 'package:async_redux/async_redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scenario_management_tool_for_testers/Actions/fetchsenario.dart';
import 'package:scenario_management_tool_for_testers/state/appstate.dart';
import 'package:scenario_management_tool_for_testers/state/dashviewmodel.dart';

void addScenarioDialog(BuildContext context, ViewModel vm) {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController shortDescriptionController =
      TextEditingController();

  String? selectedEmail;
  String? selectedProjectName;

  Future<List<String>> fetchUserEmails() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      return snapshot.docs.map((doc) => doc['email'] as String).toList();
    } catch (e) {
      print("Error fetching user emails: $e");
      return [];
    }
  }

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Add Scenario"),
        content: StatefulBuilder(
          builder: (context, setState) {
            return FutureBuilder<List<String>>(
              future: fetchUserEmails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Text("Error loading emails.");
                }

                final List<String> userEmails = snapshot.data ?? [];

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp("[A-Z|a-z]"))
                      ],
                      controller: nameController,
                      decoration: const InputDecoration(
                          labelText: "Scenario Name",
                          hintText: "Alphabets Only"),
                    ),
                    TextField(
                      controller: shortDescriptionController,
                      decoration:
                          const InputDecoration(labelText: "Short Description"),
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedProjectName,
                      items: const [
                        DropdownMenuItem(
                            value: 'HR Portal', child: Text('HR Portal')),
                        DropdownMenuItem(value: 'OBA', child: Text('OBA')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedProjectName = value;
                        });
                      },
                      hint: const Text("Select Project Name"),
                    ),
                    if (vm.designation != 'Junior Tester')
                      DropdownButton<String>(
                        hint: const Text("Select User Email"),
                        value: selectedEmail,
                        isExpanded: true,
                        onChanged: (newValue) {
                          setState(() {
                            selectedEmail = newValue;
                          });
                        },
                        items: userEmails.map((email) {
                          return DropdownMenuItem<String>(
                            value: email,
                            child: Text(email),
                          );
                        }).toList(),
                      ),
                  ],
                );
              },
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final String name = nameController.text;
              final String shortDescription = shortDescriptionController.text;

              if (name.isNotEmpty &&
                  shortDescription.isNotEmpty &&
                  selectedProjectName != null &&
                  (vm.designation == 'Junior Tester' ||
                      selectedEmail != null)) {
                try {
                  final user = FirebaseAuth.instance.currentUser;
                  final createdByEmail = user?.email ?? 'Unknown';
                  final assignedEmail = vm.designation == 'Junior Tester'
                      ? createdByEmail
                      : selectedEmail;

                  await FirebaseFirestore.instance.collection('scenarios').add({
                    'name': name,
                    'shortDescription': shortDescription,
                    'projectName': selectedProjectName,
                    'createdAt': FieldValue.serverTimestamp(),
                    'createdByEmail': createdByEmail,
                    'assignedToEmail': assignedEmail,
                  });
                  Fluttertoast.showToast(
                    msg: "Scenario added successfully!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    backgroundColor: vm.roleColor,
                    //backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                  Navigator.of(context).pop();
                  vm.fetchScenarios();
                } catch (e) {
                  Fluttertoast.showToast(
                    msg: "Failed to Add Scenario",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
              } else {
                Fluttertoast.showToast(
                  msg: "Fill in all required fields",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
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
}

void deleteScenarioDialog(BuildContext context, String docId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Scenario'),
        content: const Text('Are you sure you want to delete this scenario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('scenarios')
                    .doc(docId)
                    .delete();
                Navigator.of(context).pop();
                Fluttertoast.showToast(
                  msg: "Scenario Deleted successfully!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
                StoreProvider.dispatch<AppState>(
                    context, FetchScenariosAction());
              } catch (e) {
                Fluttertoast.showToast(
                  msg: "Failed to delete Scenario!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}
