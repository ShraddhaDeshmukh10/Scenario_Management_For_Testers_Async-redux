import 'package:async_redux/async_redux.dart';
import 'package:scenario_management_tool_for_testers/firebase/firebasesevices.dart';
import 'package:scenario_management_tool_for_testers/model/scenario_model.dart';
import 'package:scenario_management_tool_for_testers/state/appstate.dart';

class UpdateScenarioAction extends ReduxAction<AppState> {
  final String docId;
  final Map<String, dynamic> updatedData;

  UpdateScenarioAction({required this.docId, required this.updatedData});

  @override
  Future<AppState> reduce() async {
    final firebaseService = FirebaseService();
    await firebaseService.updateScenarioInFirebase(
        docId, updatedData as Scenario);

    final updatedScenarios = state.scenarios.map((scenario) {
      if (scenario.docId == docId) {
        return Scenario(
          docId: scenario.docId,
          projectName: scenario.projectName,
          shortDescription: scenario.shortDescription,
          assignedToEmail: scenario.assignedToEmail,
          name: scenario.name,
          createdAt: scenario.createdAt,
          createdByEmail: scenario.createdByEmail,
          projectId: scenario.projectId,
        );
      }
      return scenario;
    }).toList();

    return state.copy(scenarios: updatedScenarios);
  }
}
