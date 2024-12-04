import 'package:firebase_auth/firebase_auth.dart';
import 'package:scenario_management_tool_for_testers/Services/response.dart';

enum RegistrationStatus { idle, success, failure }

class AppState {
  final User? user;
  final String? designation;
  final RegistrationStatus registrationStatus;
  final List<Map<String, dynamic>> scenarios;
  final List<Map<String, dynamic>> comments;
  final List<Map<String, dynamic>> addtestcase;
  final List<Map<String, dynamic>> testCases;
  final List<Map<String, dynamic>> changeHistory;
  final List<Map<String, dynamic>>? filteredScenarios;
  final DataResponse? response;

  AppState({
    this.registrationStatus = RegistrationStatus.idle,
    this.response,
    this.user,
    this.filteredScenarios,
    this.designation,
    this.scenarios = const [],
    this.comments = const [],
    this.addtestcase = const [],
    required this.testCases,
    required this.changeHistory,
  });

  AppState copy({
    RegistrationStatus? registrationStatus,
    DataResponse? response,
    User? user,
    String? designation,
    List<Map<String, dynamic>>? filteredScenarios,
    List<Map<String, dynamic>>? scenarios,
    List<Map<String, dynamic>>? addtestcase,
    List<Map<String, dynamic>>? testCases,
    List<Map<String, dynamic>>? changeHistory,
    List<Map<String, dynamic>>? comments,
  }) =>
      AppState(
        registrationStatus: registrationStatus ?? this.registrationStatus,
        response: response ?? this.response,
        user: user,
        designation: designation ?? this.designation,
        scenarios: scenarios ?? this.scenarios,
        filteredScenarios: filteredScenarios ?? this.filteredScenarios,
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
        changeHistory: [],
        comments: [],
        testCases: [],
        addtestcase: [],
      );
}
