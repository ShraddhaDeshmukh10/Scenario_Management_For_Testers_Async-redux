import 'package:async_redux/async_redux.dart';
import 'package:scenario_management_tool_for_testers/constants/enum_status.dart';
import 'package:scenario_management_tool_for_testers/appstate.dart';

class SetLoginStatusAction extends ReduxAction<AppState> {
  @override
  AppState reduce() {
    return state.copy(loginStatus: LoginStatus.idle);
  }
}
