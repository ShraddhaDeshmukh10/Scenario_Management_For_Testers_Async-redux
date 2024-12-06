import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:scenario_management_tool_for_testers/redux/appstate.dart';
import 'package:scenario_management_tool_for_testers/redux/actions/fetch_change_history.dart';
import 'package:scenario_management_tool_for_testers/view/screens/change_page/change_viewmodel.dart';
import 'package:scenario_management_tool_for_testers/view/screens/change_page/edit_history_page.dart';

class ChangeHistoryConnector extends StatelessWidget {
  final String scenarioId;
  final Color roleColor;
  final String designation;

  const ChangeHistoryConnector({
    super.key,
    required this.scenarioId,
    required this.roleColor,
    required this.designation,
  });

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ChangeHistoryViewModel>(
      converter: (store) => ChangeHistoryViewModel.fromStore(store),
      onInit: (store) {
        store.dispatch(FetchChangeHistoryAction(scenarioId));
      },
      builder: (context, viewModel) {
        print(
            "Changes passed to the UI: ${viewModel.changeHistory.length}"); // Debug log
        return EditHistoryPage(
          scenarioId: scenarioId,
          roleColor: roleColor,
          designation: designation,
          changes: viewModel.changeHistory,
        );
      },
    );
  }
}
