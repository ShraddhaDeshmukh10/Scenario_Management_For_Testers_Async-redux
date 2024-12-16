import 'package:async_redux/async_redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scenario_management_tool_for_testers/constants/enum_role.dart';
import 'package:scenario_management_tool_for_testers/model/scenario_model.dart';
import 'package:scenario_management_tool_for_testers/redux/actions/delete_senario.dart';
import 'package:scenario_management_tool_for_testers/appstate.dart';
import 'package:scenario_management_tool_for_testers/redux/actions/fetch_senario.dart';

class ScenarioDialogs {
  static void addScenarioDialog(BuildContext context, dynamic vm) {
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

    final Role userRole = Role.fromString(vm.designation);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            "Add Scenario",
            style: TextStyle(color: userRole.roleColor),
          ),
          content: FutureBuilder<List<String>>(
            future: fetchUserEmails(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return const Text(
                  "Error loading user emails. Please try again later.",
                );
              }

              final userEmails = snapshot.data ?? [];

              return StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp("[A-Za-z ]"))
                        ],
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Scenario Name",
                          hintText: "Alphabets Only",
                        ),
                      ),
                      TextField(
                        controller: shortDescriptionController,
                        decoration: const InputDecoration(
                          labelText: "Short Description",
                        ),
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
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.red),
              ),
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

                    await FirebaseFirestore.instance
                        .collection('scenarios')
                        .add({
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
              child: const Text(
                "Add",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }
}

void deleteScenarioDialog(BuildContext context, Scenario scenario) {
  bool isDeleting = false;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Delete Scenario'),
            content: isDeleting
                ? Row(
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text(
                        "Please wait, deleting...",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                : Text(
                    'Are you sure you want to delete the scenario "${scenario.name}"?',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
            actions: isDeleting
                ? []
                : [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        setState(() {
                          isDeleting = true;
                        });

                        try {
                          await StoreProvider.dispatchAndWait<AppState>(
                            context,
                            DeleteScenarioAction(scenario.docId),
                          );

                          Fluttertoast.showToast(
                            msg:
                                "Scenario '${scenario.name}' deleted successfully!",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            backgroundColor: Colors.black,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                          StoreProvider.dispatch<AppState>(
                            context,
                            FetchScenariosAction(),
                          );

                          Navigator.of(context).pop();
                        } catch (e) {
                          Fluttertoast.showToast(
                            msg:
                                "Failed to delete scenario '${scenario.name}'!",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.black,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        } finally {
                          setState(() {
                            isDeleting = false;
                          });
                        }
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
          );
        },
      );
    },
  );
}
