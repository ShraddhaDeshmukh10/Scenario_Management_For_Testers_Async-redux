import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:scenario_management_tool_for_testers/appstate.dart';
import 'package:scenario_management_tool_for_testers/model/comments_model.dart';
import 'package:scenario_management_tool_for_testers/redux/actions/add_comment.dart';
import 'package:scenario_management_tool_for_testers/view/screens/comment_page/test_comment_page.dart';

class TestCaseCommentsConnector extends StatelessWidget {
  final String scenarioId;
  final String testCaseId;
  final Color roleColor;
  final String designation;

  const TestCaseCommentsConnector({
    Key? key,
    required this.scenarioId,
    required this.testCaseId,
    required this.roleColor,
    required this.designation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (store) => _ViewModel(
        comments: store.state.comments,
        addComment: (commentText) => store.dispatch(AddCommentToTestCaseAction(
          scenarioId: scenarioId,
          testCaseId: testCaseId,
          text: commentText,
        )),
        fetchComments: () => store.dispatch(FetchTestCaseCommentsAction(
          scenarioId: scenarioId,
          testCaseId: testCaseId,
        )),
      ),
      onInit: (store) {
        store.dispatch(FetchTestCaseCommentsAction(
          scenarioId: scenarioId,
          testCaseId: testCaseId,
        ));
      },
      builder: (context, vm) {
        return TestCaseCommentsDisplay(
          comments: vm.comments,
          addComment: vm.addComment,
          roleColor: roleColor,
          designation: designation,
          scenarioId: scenarioId,
        );
      },
    );
  }
}

class _ViewModel {
  final List<Comment> comments;
  final Function(String) addComment;
  final Function fetchComments;

  _ViewModel({
    required this.comments,
    required this.addComment,
    required this.fetchComments,
  });
}
