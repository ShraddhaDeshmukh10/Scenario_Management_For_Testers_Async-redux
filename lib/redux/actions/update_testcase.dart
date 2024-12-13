import 'package:async_redux/async_redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scenario_management_tool_for_testers/appstate.dart';
import 'package:scenario_management_tool_for_testers/model/testcase_model.dart';

class UpdateTestCaseAction extends ReduxAction<AppState> {
  final String scenarioId;
  final String testCaseId;
  final String description;
  final String comments;
  final List<String> tags;

  UpdateTestCaseAction({
    required this.scenarioId,
    required this.testCaseId,
    required this.description,
    required this.comments,
    required this.tags,
  });
  @override
  Future<AppState?> reduce() async {
    try {
      // Ensure the tags are cast to List<String>
      final updatedTags = List<String>.from(tags);

      // Update test case in Firestore
      await FirebaseFirestore.instance
          .collection('scenarios')
          .doc(scenarioId)
          .collection('testCases')
          .doc(testCaseId)
          .update({
        'description': description,
        'comments': comments,
        'tags': updatedTags, // Ensure it's a List<String>
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Add to the 'changes' collection for audit
      final userEmail =
          FirebaseAuth.instance.currentUser?.email ?? "unknown_user";
      await FirebaseFirestore.instance
          .collection('scenarios')
          .doc(scenarioId)
          .collection('changes')
          .add({
        'testCaseId': testCaseId,
        'description': description,
        'tags': updatedTags, // Ensure it's a List<String>
        'editedBy': userEmail,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update the local state with the updated tags
      final updatedTestCases = state.testCases.map((testCase) {
        if (testCase.docId == testCaseId) {
          return TestCase(
            docId: testCase.docId,
            name: testCase.name,
            bugId: testCase.bugId,
            tags: updatedTags,
            comments: comments,
            description: description,
            createdBy: testCase.createdBy,
            createdAt: testCase.createdAt,
            updatedAt: DateTime.now(),
          );
        }
        return testCase;
      }).toList();

      // Return the updated state
      return AppState(
          testCases: updatedTestCases, changeHistory: state.changeHistory);
    } catch (e) {
      throw UserException("Failed to update test case: $e");
    }
  }
}
