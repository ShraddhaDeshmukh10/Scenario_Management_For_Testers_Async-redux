import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:scenario_management_tool_for_testers/appstate.dart';
import 'package:scenario_management_tool_for_testers/constants/enum_status.dart';
import 'package:scenario_management_tool_for_testers/redux/actions/register_auth_action.dart';
import 'package:scenario_management_tool_for_testers/redux/actions/reset.dart';
import 'package:scenario_management_tool_for_testers/resources/route.dart';
import 'package:scenario_management_tool_for_testers/screens/register_screen/register_screen.dart';
import 'package:scenario_management_tool_for_testers/screens/register_screen/register_vm.dart';

class RegisterConnector extends StatelessWidget {
  const RegisterConnector({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StoreConnector<AppState, RegisterViewModel>(
        converter: (store) {
          return RegisterViewModel(
            emailController: TextEditingController(),
            passwordController: TextEditingController(),
            confirmPasswordController: TextEditingController(),
            isLoading: store.state.isLoading,
            designation: store.state.designation,
            registrationStatus: store.state.registrationStatus,
            register: (email, password, designation) {
              store.dispatch(RegisterAction(
                email: email,
                password: password,
                designation: designation,
              ));
            },
          );
        },
        onDidChange: (context, store, state) {
          if (context != null) {
            if (state.registrationStatus == RegistrationStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text("Account created successfully! Redirecting...")),
              );
              Future.delayed(const Duration(seconds: 2), () {
                Navigator.pushReplacementNamed(context, Routes.dashboard);
              });
              store.dispatch(ResetRegistrationStatusAction());
            } else if (state.registrationStatus == RegistrationStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text("Failed to create account. Please try again.")),
              );
              store.dispatch(ResetRegistrationStatusAction());
            }
          }
        },
        builder: (context, vm) {
          return RegisterPage(viewModel: vm);
        },
      ),
    );
  }
}
