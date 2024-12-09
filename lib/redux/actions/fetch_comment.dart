import 'package:async_redux/async_redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scenario_management_tool_for_testers/model/comments_model.dart';
import 'package:scenario_management_tool_for_testers/appstate.dart';

class FetchTestCaseCommentsAction extends ReduxAction<AppState> {
  final String scenarioId;
  final String testCaseId;

  FetchTestCaseCommentsAction({
    required this.scenarioId,
    required this.testCaseId,
  });

  @override
  Future<AppState?> reduce() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('scenarios')
          .doc(scenarioId)
          .collection('testCases')
          .doc(testCaseId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .get();

      List<Comment> comments =
          snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();

      return state.copy(comments: comments);
    } catch (e) {
      print("Error fetching comments: $e");
      Fluttertoast.showToast(
        msg: "Failed to fetch comments.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return null;
    }
  }
}
