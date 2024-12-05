import 'package:async_redux/async_redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scenario_management_tool_for_testers/appstate.dart';

class LoginAction extends ReduxAction<AppState> {
  final String email;
  final String password;

  LoginAction({required this.email, required this.password});

  @override
  Future<AppState> reduce() async {
    User? user = await authenticateUser(email, password);
    String? designation;
    if (user != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      designation = userDoc['role'] ?? 'Junior Tester';

      // Login successful
      return state.copy(
        user: user,
        designation: designation,
        loginStatus: LoginStatus.success,
      );
    }
    return state.copy(loginStatus: LoginStatus.failure);
  }

  Future<User?> authenticateUser(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      return null;
    }
  }
}

class SetLoginStatusAction extends ReduxAction<AppState> {
  @override
  AppState reduce() {
    return state.copy(loginStatus: LoginStatus.idle);
  }
}
