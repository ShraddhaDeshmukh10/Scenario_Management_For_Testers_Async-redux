import 'package:async_redux/async_redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scenario_management_tool_for_testers/model/testcase_model.dart';
import 'package:scenario_management_tool_for_testers/redux/appstate.dart';

///Queries the 'testCases' subcollection under a particular scenario document
/// and maps each document containing test case details.
class FetchTestCasesAction extends ReduxAction<AppState> {
  final String scenarioId;

  FetchTestCasesAction(this.scenarioId);
  @override
  Future<AppState?> reduce() async {
    try {
      // Debugging: Print before fetching data
      print("Fetching test cases for scenario: $scenarioId");

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('scenarios')
          .doc(scenarioId)
          .collection('testCases')
          .get();

      List<TestCase> testCases = snapshot.docs.map((doc) {
        return TestCase.fromFirestore(doc);
      }).toList();

      // Debugging: Check if testCases list is populated
      print("Fetched ${testCases.length} test cases");

      return state.copy(testCases: testCases);
    } catch (e) {
      print("Error fetching test cases: $e");
      throw UserException("Error fetching test cases: $e");
    }
  }
}

///Accesses the test case by its testCaseId
/// and removes it from the Firestore database.
class DeleteTestCaseAction extends ReduxAction<AppState> {
  final String scenarioId;
  final String testCaseId;

  DeleteTestCaseAction({required this.scenarioId, required this.testCaseId});

  @override
  Future<AppState?> reduce() async {
    try {
      // Delete the test case from Firestore
      await FirebaseFirestore.instance
          .collection('scenarios')
          .doc(scenarioId)
          .collection('testCases')
          .doc(testCaseId)
          .delete();

      // Update local state
      final updatedTestCases = state.testCases
          .where((testCase) => testCase.docId != testCaseId)
          .toList();

      return state.copy(testCases: updatedTestCases);
    } catch (e) {
      throw UserException("Failed to delete test case: $e");
    }
  }
}
