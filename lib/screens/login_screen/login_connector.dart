import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';
import 'package:scenario_management_tool_for_testers/appstate.dart';
import 'package:scenario_management_tool_for_testers/constants/enum_status.dart';
import 'package:scenario_management_tool_for_testers/redux/actions/login_actions.dart';
import 'package:scenario_management_tool_for_testers/redux/actions/login_status.dart';
import 'package:scenario_management_tool_for_testers/resources/route.dart';
import 'package:scenario_management_tool_for_testers/screens/login_screen/login.dart';
import 'package:scenario_management_tool_for_testers/screens/login_screen/login_vm.dart';
import 'package:shared_preferences/shared_preferences.dart';

// class LoginConnector extends StatelessWidget {
//   const LoginConnector({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StoreConnector<AppState, LoginViewModel>(
//       converter: (store) => LoginViewModel.fromStore(store),
//       onDidChange: (context, store, vm) {
//         if (context != null && store.state.loginStatus == LoginStatus.success) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Login successful! Redirecting...")),
//           );
//           Future.delayed(const Duration(seconds: 2), () {
//             Navigator.pushNamedAndRemoveUntil(
//                 context, Routes.dashboard, (route) => false);
//             store.dispatch(SetLoginStatusAction());
//           });
//         } else if (context != null &&
//             store.state.loginStatus == LoginStatus.failure) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Login failed! Please try again.")),
//           );
//           store.dispatch(SetLoginStatusAction());
//         }
//       },
//       builder: (context, vm) {
//         return LoginPage(
//           emailController: TextEditingController(text: vm.email),
//           passwordController: TextEditingController(text: vm.password),
//           isLoading: vm.isLoading,
//           onLogin: vm.login,
//         );
//       },
//     );
//   }
// }

class LoginConnector extends StatelessWidget {
  const LoginConnector({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Wrapping your entire screen with a Scaffold to ensure ScaffoldMessenger can work
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
          // Ensure context is not null by checking it before use
          if (context != null) {
            if (store.state.loginStatus == LoginStatus.success) {
              // Safely use ScaffoldMessenger with non-null context
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Login successful! Redirecting...")),
              );
              Future.delayed(const Duration(seconds: 2), () {
                Navigator.pushNamedAndRemoveUntil(
                    context, Routes.dashboard, (route) => false);
                store.dispatch(SetLoginStatusAction());
              });
            } else if (store.state.loginStatus == LoginStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Login failed! Please try again.")),
              );
              store.dispatch(SetLoginStatusAction());
            }
          }
        },
        builder: (context, vm) {
          return FutureBuilder<LoginViewModel>(
            future: _loadLoginViewModel(vm),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error loading login info.'));
              }

              final viewModel = snapshot.data!;

              return LoginPage(
                emailController: TextEditingController(text: viewModel.email),
                passwordController:
                    TextEditingController(text: viewModel.password),
                isLoading: viewModel.isLoading,
                onLogin: viewModel.login,
              );
            },
          );
        },
      ),
    );
  }

  // Load the LoginViewModel asynchronously
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
