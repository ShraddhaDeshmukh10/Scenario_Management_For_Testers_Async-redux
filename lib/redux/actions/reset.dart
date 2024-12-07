import 'package:async_redux/async_redux.dart';
import 'package:scenario_management_tool_for_testers/redux/app_state.dart';

class ResetRegistrationStatusAction extends ReduxAction<AppState> {
  @override
  AppState reduce() {
    return state.copy(registrationStatus: RegistrationStatus.idle);
  }
}
