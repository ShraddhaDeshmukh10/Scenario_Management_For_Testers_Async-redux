import 'package:firebase_auth/firebase_auth.dart';
import 'package:scenario_management_tool_for_testers/Services/response.dart';

class AppState {
  final User? user;
  final String? designation;
  final List<Map<String, dynamic>> scenarios;
  final List<Map<String, dynamic>> assignments;
  final List<Map<String, dynamic>> comments;
  final List<Map<String, dynamic>> addtestcase;
  final List<Map<String, dynamic>> testCases;
  final List<Map<String, dynamic>> changeHistory;
  final List<Map<String, dynamic>>? filteredScenarios;
  final DataResponse? response;

  AppState({
    this.response,
    this.user,
    this.filteredScenarios,
    this.designation,
    this.scenarios = const [],
    this.assignments = const [],
    this.comments = const [],
    this.addtestcase = const [],
    required this.testCases,
    required this.changeHistory,
  });

  AppState copy({
    DataResponse? response,
    User? user,
    String? designation,
    List<Map<String, dynamic>>? filteredScenarios,
    List<Map<String, dynamic>>? scenarios,
    List<Map<String, dynamic>>? assignments,
    List<Map<String, dynamic>>? addtestcase,
    List<Map<String, dynamic>>? testCases,
    List<Map<String, dynamic>>? changeHistory,
    List<Map<String, dynamic>>? comments,
  }) =>
      AppState(
        response: response ?? this.response,
        user: user,
        designation: designation ?? this.designation,
        scenarios: scenarios ?? this.scenarios,
        filteredScenarios: filteredScenarios ?? this.filteredScenarios,
        assignments: assignments ?? this.assignments,
        comments: comments ?? this.comments,
        testCases: testCases ?? this.testCases,
        changeHistory: changeHistory ?? this.changeHistory,
        addtestcase: addtestcase ?? this.addtestcase,
      );

  static AppState initialState() => AppState(
        response: DataResponse(),
        user: null,
        designation: null,
        scenarios: [],
        filteredScenarios: null,
        assignments: [],
        changeHistory: [],
        comments: [],
        testCases: [],
        addtestcase: [],
      );

  // final User? user;
  // final String? designation;
  // final List<Map<String, dynamic>> scenarios;
  // final List<Map<String, dynamic>> assignments;
  // final List<Map<String, dynamic>> comments;
  // final List<Map<String, dynamic>> addtestcase;
  // final List<Map<String, dynamic>> testCases;
  // final List<Map<String, dynamic>> changeHistory;
  // final List<Map<String, dynamic>>? filteredScenarios;
  // final DataResponse? response;

  // AppState({
  //   this.user,
  //   this.designation,
  //   this.response,
  //   this.scenarios = const [],
  //   this.assignments = const [],
  //   this.comments = const [],
  //   this.addtestcase = const [],
  //    required this.testCases,
  //   required this.changeHistory,
  //   this.response,
  //   this.filteredScenarios,
  // });

  // AppState copy(
  //         {
  //           DataResponse? response,
  //           User? user,
  //         String? designation,
  //         List<Map<String, dynamic>>? scenarios,
  //         List<Map<String, dynamic>>? assignments,
  //         List<Map<String, dynamic>>? addtestcase,
  //           List<Map<String, dynamic>>? testCases,
  //   List<Map<String, dynamic>>? changeHistory,
  //          List<Map<String, dynamic>>? filteredScenarios,
  //         List<Map<String, dynamic>>? comments}) =>
  //     AppState(
  //         user: user,
  //         designation: designation ?? this.designation,
  //         scenarios: scenarios ?? this.scenarios,
  //         assignments: assignments ?? this.assignments,
  //         comments: comments ?? this.comments,
  //         response: response ?? this.response,
  //         changeHistory: changeHistory?? this.changeHistory,
  //         testCases: testCases?? this.testCases,
  //         filteredScenarios: filteredScenarios?? this.filteredScenarios,
  //         addtestcase: addtestcase ?? this.addtestcase);

  // static AppState initialState() => AppState(
  //       user: null,
  //        response: DataResponse(),
  //       designation: null,
  //       scenarios: [],
  //       assignments: [],
  //       comments: [],
  //       addtestcase: [],
  //       testCases: [],
  //       changeHistory: [],
  //      filteredScenarios: null,
  //     );
}
