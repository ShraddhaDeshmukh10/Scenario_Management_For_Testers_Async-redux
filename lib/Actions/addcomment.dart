import 'package:async_redux/async_redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scenario_management_tool_for_testers/appstate.dart';

class AddCommentToTestCaseAction extends ReduxAction<AppState> {
  final String scenarioId;
  final String testCaseId;
  final String content;
  final String attachment;

  AddCommentToTestCaseAction({
    required this.scenarioId,
    required this.testCaseId,
    required this.content,
    required this.attachment,
  });

  @override
  Future<AppState?> reduce() async {
    try {
      await FirebaseFirestore.instance
          .collection('scenarios')
          .doc(scenarioId)
          .collection('testCases')
          .doc(testCaseId)
          .collection('comments')
          .add({
        'content': content,
        'attachment': attachment,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': FirebaseAuth.instance.currentUser?.email,
      });
      print(
          "Adding comment to: scenarios/$scenarioId/testCases/$testCaseId/comments");

      dispatch(FetchTestCaseCommentsAction(
        scenarioId: scenarioId,
        testCaseId: testCaseId,
      ));

      return state.copy();
    } catch (e) {
      print("Error adding comment: $e");
      Fluttertoast.showToast(
        msg: "Error adding comment. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return state.copy(); // Return current state on error
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
      // Ensure the user is authenticated
      FirebaseAuth auth = FirebaseAuth.instance;
      if (auth.currentUser == null) {
        throw Exception("User is not authenticated");
      }

      // Fetch comments from Firestore
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('scenarios')
          .doc(scenarioId)
          .collection('testCases')
          .doc(testCaseId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .get();

      print(
          "Fetched comments from: scenarios/$scenarioId/testCases/$testCaseId/comments");
      print("Data: ${snapshot.docs.map((e) => e.data())}");

      List<Map<String, dynamic>> comments = snapshot.docs.map((doc) {
        return {
          'text': doc['text'] ?? '', // Ensure the correct field name 'text'
          'createdBy': doc['createdBy'] ?? '',
          'timestamp': doc['timestamp'], // Correct field 'timestamp'
          'attachment': doc['attachment'] ?? '',
        };
      }).toList();

      print("Fetched comments: $comments");

      return state.copy(comments: comments);
    } catch (e) {
      print("Error fetching comments: $e");
      Fluttertoast.showToast(
        msg: "Error fetching comments. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return null;
    }
  }
}
