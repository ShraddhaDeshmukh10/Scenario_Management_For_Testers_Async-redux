import 'package:async_redux/async_redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scenario_management_tool_for_testers/model/testcase_model.dart';
import 'package:scenario_management_tool_for_testers/appstate.dart';

///Queries of 'testCases' subcollection under a particular scenario document
/// and maps each document containing test case details.
class FetchTestCasesAction extends ReduxAction<AppState> {
  final String scenarioId;

  FetchTestCasesAction(this.scenarioId);
  @override
  Future<AppState?> reduce() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('scenarios')
          .doc(scenarioId)
          .collection('testCases')
          .get();

      List<TestCase> testCases = snapshot.docs.map((doc) {
        return TestCase.fromFirestore(doc);
      }).toList();
      print("Fetched ${testCases.length} test cases");

      return state.copy(testCases: testCases);
    } catch (e) {
      print("Error fetching test cases: $e");
      throw UserException("Error fetching test cases: $e");
    }
  }
}
