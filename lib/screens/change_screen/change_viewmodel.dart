import 'package:async_redux/async_redux.dart';
import 'package:scenario_management_tool_for_testers/appstate.dart';
import 'package:scenario_management_tool_for_testers/model/change_history.dart';

class ChangeHistoryViewModel extends Vm {
  final List<ChangeHistory> changeHistory;

  ChangeHistoryViewModel({required this.changeHistory})
      : super(equals: changeHistory);

  static ChangeHistoryViewModel fromStore(Store<AppState> store) {
    return ChangeHistoryViewModel(
      changeHistory: store.state.changeHistory,
    );
  }
}
