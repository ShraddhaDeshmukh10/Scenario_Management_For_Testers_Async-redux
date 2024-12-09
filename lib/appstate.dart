import 'package:firebase_auth/firebase_auth.dart';
import 'package:scenario_management_tool_for_testers/constants/enum_status.dart';
import 'package:scenario_management_tool_for_testers/constants/response.dart';
import 'package:scenario_management_tool_for_testers/model/comments_model.dart';
import 'package:scenario_management_tool_for_testers/model/change_history.dart';
import 'package:scenario_management_tool_for_testers/model/scenario_model.dart';
import 'package:scenario_management_tool_for_testers/model/testcase_model.dart';

// enum RegistrationStatus { idle, success, failure }

// enum LoginStatus { idle, success, failure, loading }

// class AppState {
//   final List<Scenario> scenarios;
//   final List<Scenario>? filteredScenarios;
//   final User? user;
//   final String? designation;
//   final RegistrationStatus registrationStatus;
//   final LoginStatus loginStatus;
//   final List<Comment> comments;
//   final List<TestCase> testCases;
//   final List<ChangeHistory> changeHistory;
//   final DataResponse? response;

//   AppState({
//     this.registrationStatus = RegistrationStatus.idle,
//     this.loginStatus = LoginStatus.idle,
//     this.response,
//     this.user,
//     this.filteredScenarios,
//     this.designation,
//     this.scenarios = const [],
//     this.comments = const [],
//     required this.testCases,
//     required this.changeHistory,
//   });

//   AppState copy({
//     List<Scenario>? scenarios,
//     List<Scenario>? filteredScenarios,
//     RegistrationStatus? registrationStatus,
//     LoginStatus? loginStatus,
//     DataResponse? response,
//     User? user,
//     String? designation,
//     final List<TestCase>? testCases,
//     List<ChangeHistory>? changeHistory,
//     List<Comment>? comments,
//   }) =>
//       AppState(
//         registrationStatus: registrationStatus ?? this.registrationStatus,
//         loginStatus: loginStatus ?? this.loginStatus,
//         response: response ?? this.response,
//         user: user,
//         designation: designation ?? this.designation,
//         scenarios: scenarios ?? this.scenarios,
//         filteredScenarios: filteredScenarios ?? this.filteredScenarios,
//         comments: comments ?? this.comments,
//         testCases: testCases ?? this.testCases,
//         changeHistory: changeHistory ?? this.changeHistory,
//       );

//   static AppState initialState() => AppState(
//         response: DataResponse(),
//         user: null,
//         designation: null,
//         scenarios: [],
//         filteredScenarios: null,
//         changeHistory: [],
//         comments: [],
//         testCases: [],
//       );
// }

class AppState {
  final List<Scenario> scenarios;
  final List<Scenario>? filteredScenarios;
  final User? user;
  final String? designation;
  final RegistrationStatus registrationStatus;
  final LoginStatus loginStatus;
  final List<Comment> comments;
  final List<TestCase> testCases;
  final List<ChangeHistory> changeHistory;
  final DataResponse? response;
  final String? email; // Add email
  final String? password; // Add password
  final bool isLoading;

  AppState({
    this.registrationStatus = RegistrationStatus.idle,
    this.loginStatus = LoginStatus.idle,
    this.response,
    this.user,
    this.filteredScenarios,
    this.designation,
    this.scenarios = const [],
    this.comments = const [],
    required this.testCases,
    required this.changeHistory,
    this.email, // Add email to constructor
    this.password, // Add password to constructor
    this.isLoading = false,
  });

  AppState copy({
    List<Scenario>? scenarios,
    List<Scenario>? filteredScenarios,
    RegistrationStatus? registrationStatus,
    LoginStatus? loginStatus,
    DataResponse? response,
    User? user,
    String? designation,
    final List<TestCase>? testCases,
    List<ChangeHistory>? changeHistory,
    List<Comment>? comments,
    String? email, // Add email parameter to copy method
    String? password, // Add password parameter to copy method
    bool? isLoading,
  }) =>
      AppState(
        registrationStatus: registrationStatus ?? this.registrationStatus,
        loginStatus: loginStatus ?? this.loginStatus,
        response: response ?? this.response,
        user: user,
        designation: designation ?? this.designation,
        scenarios: scenarios ?? this.scenarios,
        filteredScenarios: filteredScenarios ?? this.filteredScenarios,
        comments: comments ?? this.comments,
        testCases: testCases ?? this.testCases,
        changeHistory: changeHistory ?? this.changeHistory,
        email: email ?? this.email, // Update email
        password: password ?? this.password, // Update password
        isLoading: isLoading ?? this.isLoading,
      );

  static AppState initialState() => AppState(
        response: DataResponse(),
        user: null,
        designation: null,
        scenarios: [],
        filteredScenarios: null,
        changeHistory: [],
        comments: [],
        testCases: [],
        email: null, // Initialize email as null
        password: null, // Initialize password as null
        isLoading: false,
      );
}
