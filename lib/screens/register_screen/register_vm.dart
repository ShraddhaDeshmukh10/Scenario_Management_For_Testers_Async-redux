import 'package:flutter/material.dart';
import 'package:scenario_management_tool_for_testers/constants/enum_status.dart';

class RegisterViewModel {
  TextEditingController emailController;
  TextEditingController passwordController;
  TextEditingController confirmPasswordController;
  bool isLoading;
  String? designation;
  RegistrationStatus? registrationStatus;
  final Function(String, String, String) register;

  RegisterViewModel({
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    this.isLoading = false,
    this.designation,
    this.registrationStatus,
    required this.register,
  });

  bool isPasswordValid() {
    return passwordController.text == confirmPasswordController.text;
  }

  bool isPasswordComplex() {
    final password = passwordController.text;
    return password.length >= 8;
  }

  bool isDesignationValid() {
    return designation != null && designation!.isNotEmpty;
  }
}
