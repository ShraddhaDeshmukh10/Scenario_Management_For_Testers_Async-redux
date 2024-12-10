import 'package:flutter/material.dart';
import 'package:scenario_management_tool_for_testers/screens/register_screen/register_vm.dart';

class RegisterPage extends StatefulWidget {
  final RegisterViewModel viewModel;

  const RegisterPage({super.key, required this.viewModel});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late bool passwordVisible;
  late bool confirmPasswordVisible;

  @override
  void initState() {
    super.initState();
    passwordVisible = false;
    confirmPasswordVisible = false;
  }

  void _register() {
    if (!widget.viewModel.isPasswordValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    if (widget.viewModel.designation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a designation")),
      );
      return;
    }

    setState(() {
      widget.viewModel.isLoading = true;
    });

    widget.viewModel.register(
      widget.viewModel.emailController.text,
      widget.viewModel.passwordController.text,
      widget.viewModel.designation!, // Safe after validation
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: widget.viewModel.emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  maxLength: 10,
                  controller: widget.viewModel.passwordController,
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
                  controller: widget.viewModel.confirmPasswordController,
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
                  value: widget.viewModel.designation,
                  hint: const Text('Select Designation'),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: <String>['Junior Tester', 'Tester Lead', 'Developer']
                      .map((String value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      widget.viewModel.designation = newValue;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: widget.viewModel.isLoading ||
                          !widget.viewModel.isPasswordValid() ||
                          widget.viewModel.designation == null
                      ? null
                      : _register,
                  child: const Text('Register'),
                ),
              ],
            ),
          ),
          if (widget.viewModel.isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
