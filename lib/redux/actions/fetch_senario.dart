import 'package:async_redux/async_redux.dart';
import 'package:scenario_management_tool_for_testers/firebase/firebase_sevices.dart';
import 'package:scenario_management_tool_for_testers/appstate.dart';

class FetchScenariosAction extends ReduxAction<AppState> {
  final String? projectName;

  FetchScenariosAction({this.projectName});

  @override
  Future<AppState> reduce() async {
    try {
      final firebaseService = FirebaseService();
      final scenarios = await firebaseService.fetchScenariosFromFirebase();

      final filteredScenarios = projectName != null
          ? scenarios
              .where((scenario) => scenario.projectName
                  .toLowerCase()
                  .contains(projectName!.toLowerCase()))
              .toList()
          : scenarios;

      return state.copy(
          scenarios: scenarios, filteredScenarios: filteredScenarios);
    } catch (e) {
      print("Error fetching scenarios: $e");
      throw Exception("Failed to fetch scenarios.");
    }
  }
}
