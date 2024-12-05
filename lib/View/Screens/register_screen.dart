import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';
import 'package:scenario_management_tool_for_testers/Resources/route.dart';
import 'package:scenario_management_tool_for_testers/appstate.dart';
import 'package:scenario_management_tool_for_testers/main.dart';
import 'package:scenario_management_tool_for_testers/redux/actions/register_auth_action.dart';
import 'package:scenario_management_tool_for_testers/redux/actions/reset.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;
  String? _designation;
  bool isLoading = false;

  void _register() {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    if (_designation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a designation")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    store.dispatch(
      RegisterAction(
        email: _emailController.text,
        password: _passwordController.text,
        designation: _designation!, // Use the selected designation
      ),
    );

    store.onChange.listen((state) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      onDidChange: (context, store, state) {
        if (state.registrationStatus == RegistrationStatus.success) {
          ScaffoldMessenger.of(context!).showSnackBar(
            const SnackBar(
                content: Text("Account created successfully! Redirecting...")),
          );
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pushReplacementNamed(context, Routes.dashboard);
          });
          store.dispatch(ResetRegistrationStatusAction());
        } else if (state.registrationStatus == RegistrationStatus.failure) {
          ScaffoldMessenger.of(context!).showSnackBar(
            const SnackBar(
                content: Text("Failed to create account. Please try again.")),
          );
          store.dispatch(ResetRegistrationStatusAction());
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Register Your Account",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      maxLength: 10,
                      obscureText: !passwordVisible,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              passwordVisible = !passwordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      maxLength: 10,
                      controller: _confirmPasswordController,
                      obscureText: !confirmPasswordVisible,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Confirm Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            confirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              confirmPasswordVisible = !confirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _designation,
                      hint: const Text('Select Designation'),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items:
                          <String>['Junior Tester', 'Tester Lead', 'Developer']
                              .map((String value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  ))
                              .toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _designation = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: isLoading ? null : _register,
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ),
              // Loading Indicator Overlay
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}