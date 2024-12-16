import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scenario_management_tool_for_testers/appstate.dart';
import 'package:scenario_management_tool_for_testers/constants/enum_status.dart';
import 'package:scenario_management_tool_for_testers/redux/actions/login_actions.dart';
import 'package:scenario_management_tool_for_testers/redux/actions/login_status.dart';
import 'package:scenario_management_tool_for_testers/resources/route.dart';
import 'package:scenario_management_tool_for_testers/screens/login_screen/login.dart';
import 'package:scenario_management_tool_for_testers/screens/login_screen/login_vm.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginConnector extends StatefulWidget {
  const LoginConnector({super.key});

  @override
  _LoginConnectorState createState() => _LoginConnectorState();
}

class _LoginConnectorState extends State<LoginConnector> {
  bool _hasAttemptedLogin = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StoreConnector<AppState, LoginViewModel>(
        converter: (store) {
          return LoginViewModel(
            email: store.state.email ?? '',
            password: store.state.password ?? '',
            isLoading: store.state.isLoading,
            login: (String email, String password) {
              store.dispatch(LoginAction(email: email, password: password));
            },
          );
        },
        onDidChange: (context, store, vm) {
          if (store.state.loginStatus == LoginStatus.success) {
            store.dispatch(SetLoginStatusAction());
            Fluttertoast.showToast(msg: "Login Successful! Welcome");
            Navigator.pushNamedAndRemoveUntil(
                context!, Routes.dashboard, (route) => false);
          } else if (store.state.loginStatus == LoginStatus.failure) {
            store.dispatch(SetLoginStatusAction());
            Fluttertoast.showToast(
                msg: "Login Failed! Please recheck email and password.");
          }
        },
        builder: (context, viewModel) {
          return FutureBuilder<LoginViewModel>(
            future: _loadLoginViewModel(viewModel),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error loading login info.'));
              }

              final loginViewModel = snapshot.data!;

              if (!_hasAttemptedLogin &&
                  loginViewModel.email.isNotEmpty &&
                  loginViewModel.password.isNotEmpty) {
                _hasAttemptedLogin = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  viewModel.login(
                      loginViewModel.email, loginViewModel.password);
                });
              }

              return LoginPage(
                emailController:
                    TextEditingController(text: loginViewModel.email),
                passwordController:
                    TextEditingController(text: loginViewModel.password),
                isLoading: viewModel.isLoading,
                onLogin: viewModel.login,
              );
            },
          );
        },
      ),
    );
  }

  Future<LoginViewModel> _loadLoginViewModel(LoginViewModel vm) async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('username') ?? '';
    final savedPassword = prefs.getString('password') ?? '';

    return LoginViewModel(
      email: savedEmail,
      password: savedPassword,
      isLoading: vm.isLoading,
      login: vm.login,
    );
  }
}
