import 'package:async_redux/async_redux.dart';
import 'package:scenario_management_tool_for_testers/firebase/firebase_sevices.dart';
import 'package:scenario_management_tool_for_testers/model/scenario_model.dart';
import 'package:scenario_management_tool_for_testers/appstate.dart';

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
