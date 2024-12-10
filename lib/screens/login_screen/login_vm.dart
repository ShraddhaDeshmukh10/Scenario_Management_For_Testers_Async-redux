import 'package:async_redux/async_redux.dart';
import 'package:scenario_management_tool_for_testers/redux/actions/login_actions.dart';
import 'package:scenario_management_tool_for_testers/appstate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginViewModel {
  final String email;
  final String password;
  final bool isLoading;
  final Function(String, String) login;

  LoginViewModel({
    required this.email,
    required this.password,
    required this.isLoading,
    required this.login,
  });

  static Future<LoginViewModel> fromStore(Store<AppState> store) async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('username') ?? '';
    final savedPassword = prefs.getString('password') ?? '';

    return LoginViewModel(
      email: savedEmail,
      password: savedPassword,
      isLoading: store.state.isLoading,
      login: (String email, String password) {
        store.dispatch(LoginAction(email: email, password: password));
      },
    );
  }
}
