import 'package:async_redux/async_redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scenario_management_tool_for_testers/appstate.dart';
import 'package:scenario_management_tool_for_testers/model/change_history.dart';

class FetchChangeHistoryAction extends ReduxAction<AppState> {
  final String scenarioId;

  FetchChangeHistoryAction(this.scenarioId);

  @override
  Future<AppState?> reduce() async {
    try {
      // Fetch data from Firestore
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('scenarios')
          .doc(scenarioId)
          .collection('changes')
          .orderBy('timestamp', descending: true)
          .get();

      List<ChangeHistory> changes = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print("Fetched change history docId: ${doc.id}");
        print("Data: ${data}");

        return ChangeHistory.fromMap(doc.id, data);
      }).toList();

      return state.copy(changeHistory: changes);
    } catch (e) {
      print("Error fetching change history: $e");
      throw UserException("Error fetching change history: $e");
    }
  }
}
