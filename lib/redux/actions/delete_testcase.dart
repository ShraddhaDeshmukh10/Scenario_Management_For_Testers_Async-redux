import 'package:async_redux/async_redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scenario_management_tool_for_testers/appstate.dart';

///Accesses the test case by its testCaseId
/// and removes it from the Firestore database.
class DeleteTestCaseAction extends ReduxAction<AppState> {
  final String scenarioId;
  final String testCaseId;

  DeleteTestCaseAction({required this.scenarioId, required this.testCaseId});

  @override
  Future<AppState?> reduce() async {
    try {
      await FirebaseFirestore.instance
          .collection('scenarios')
          .doc(scenarioId)
          .collection('testCases')
          .doc(testCaseId)
          .delete();
      final updatedTestCases = state.testCases
          .where((testCase) => testCase.docId != testCaseId)
          .toList();

      return state.copy(testCases: updatedTestCases);
    } catch (e) {
      throw UserException("Failed to delete test case: $e");
    }
  }
}
