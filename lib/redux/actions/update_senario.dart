import 'package:async_redux/async_redux.dart';
import 'package:scenario_management_tool_for_testers/firebase/firebasesevices.dart';
import 'package:scenario_management_tool_for_testers/model/scenario_model.dart';
import 'package:scenario_management_tool_for_testers/redux/appstate.dart';

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

class AddScenarioAction extends ReduxAction<AppState> {
  final Scenario newScenario;

  AddScenarioAction(this.newScenario);

  @override
  Future<AppState> reduce() async {
    try {
      await FirebaseService().addScenarioToFirebase(newScenario);
      List<Scenario> updatedScenarios = List.from(state.scenarios)
        ..add(newScenario);
      return state.copy(scenarios: updatedScenarios);
    } catch (e) {
      print("Error adding scenario to Redux store: $e");
      throw Exception("Failed to add scenario");
    }
  }
}
