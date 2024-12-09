import 'package:async_redux/async_redux.dart';
import 'package:scenario_management_tool_for_testers/appstate.dart';

class ClearFiltersAction extends ReduxAction<AppState> {
  @override
  AppState reduce() {
    return state.copy(filteredScenarios: state.scenarios);
  }
}
