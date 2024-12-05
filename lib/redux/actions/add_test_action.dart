import 'package:async_redux/async_redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scenario_management_tool_for_testers/model/testcase_model.dart';
import 'package:scenario_management_tool_for_testers/appstate.dart';

class AddTestCaseAction extends ReduxAction<AppState> {
  final String project;
  final String bugId;
  final String shortDescription;
  final String testCaseName;
  final String scenarioId;
  final String comments;
  final String description;
  final String attachment;
  final String? tag;

  AddTestCaseAction({
    required this.project,
    required this.bugId,
    required this.shortDescription,
    required this.testCaseName,
    required this.scenarioId,
    required this.comments,
    required this.description,
    required this.attachment,
    this.tag,
  });

  @override
  Future<AppState?> reduce() async {
    final userEmail =
        FirebaseAuth.instance.currentUser?.email ?? 'unknown_user';
    try {
      // Add the test case to Firestore
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('scenarios')
          .doc(scenarioId)
          .collection('testCases')
          .add({
        'project': project,
        'bugId': bugId,
        'shortDescription': shortDescription,
        'testCaseName': testCaseName,
        'comments': comments,
        'description': description,
        'attachment': attachment,
        'tags': [tag ?? 'Unspecified'], // Store as an array
        'createdBy': userEmail,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Create a local TestCase instance
      final newTestCase = TestCase(
        docId: docRef.id,
        name: testCaseName,
        bugId: bugId,
        tags: [tag ?? 'Unspecified'],
        comments: comments,
        description: description,
        createdBy: userEmail,
        createdAt: DateTime.now(), // Assume `serverTimestamp` gets synced later
      );

      // Update the state with the new test case
      final updatedTestCases = [...state.testCases, newTestCase];
      return state.copy(testCases: updatedTestCases);
    } catch (e) {
      print("Error adding test case: $e");
      throw UserException("Failed to add test case.");
    }
  }
}
