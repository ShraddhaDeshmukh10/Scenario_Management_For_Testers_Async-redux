import 'package:firebase_auth/firebase_auth.dart';
import 'package:scenario_management_tool_for_testers/constants/enum_status.dart';
import 'package:scenario_management_tool_for_testers/constants/response.dart';
import 'package:scenario_management_tool_for_testers/model/comments_model.dart';
import 'package:scenario_management_tool_for_testers/model/change_history.dart';
import 'package:scenario_management_tool_for_testers/model/scenario_model.dart';
import 'package:scenario_management_tool_for_testers/model/testcase_model.dart';

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
  final String? email;
  final String? password;
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
    this.email,
    this.password,
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
    String? email,
    String? password,
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
        email: email ?? this.email,
        password: password ?? this.password,
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
        email: null,
        password: null,
        isLoading: false,
      );
}
