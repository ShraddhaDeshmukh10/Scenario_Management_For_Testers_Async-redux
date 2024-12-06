import 'package:async_redux/async_redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scenario_management_tool_for_testers/appstate.dart';
import 'package:scenario_management_tool_for_testers/model/comments_model.dart';

///The action verifies that the commentText is not empty,
///then uses Firebase Authentication to retrieve the current user’s email
///and adds a comment with a server timestamp.
class AddCommentToTestCaseAction extends ReduxAction<AppState> {
  final String scenarioId;
  final String testCaseId;
  final String text;
  final String? attachment;

  AddCommentToTestCaseAction({
    required this.scenarioId,
    required this.testCaseId,
    required this.text,
    this.attachment,
  });

  @override
  Future<AppState?> reduce() async {
    try {
      final commentData = {
        'text': text,
        'createdBy': FirebaseAuth.instance.currentUser?.email ?? 'unknown_user',
        'timestamp': FieldValue.serverTimestamp(),
        'attachment': attachment,
      };

      await FirebaseFirestore.instance
          .collection('scenarios')
          .doc(scenarioId)
          .collection('testCases')
          .doc(testCaseId)
          .collection('comments')
          .add(commentData);

      dispatch(FetchTestCaseCommentsAction(
        scenarioId: scenarioId,
        testCaseId: testCaseId,
      ));

      return null;
    } catch (e) {
      print("Error adding comment: $e");
      Fluttertoast.showToast(
        msg: "Failed to add comment.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return state;
    }
  }
}

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
