import 'package:async_redux/async_redux.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scenario_management_tool_for_testers/redux/app_state.dart';

class RegisterAction extends ReduxAction<AppState> {
  final String email;
  final String password;
  final String designation;

  RegisterAction({
    required this.email,
    required this.password,
    required this.designation,
  });

  @override
  Future<AppState?> reduce() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': email,
        'role': designation,
      });

      return state.copy(
        user: userCredential.user,
        designation: designation,
        registrationStatus: RegistrationStatus.success,
      );
    } catch (e) {
      return state.copy(
        registrationStatus: RegistrationStatus.failure,
      );
    }
  }
}
