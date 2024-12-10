import 'package:flutter/material.dart';
import 'package:scenario_management_tool_for_testers/resources/route.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final Function(String, String) onLogin;

  const LoginPage({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onLogin,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late bool passwordVisible;
  late bool isLoading;

  @override
  void initState() {
    super.initState();
    passwordVisible = false;
    isLoading = widget.isLoading;
  }

  void togglePasswordVisibility() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  Future<void> _handleLogin() async {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    try {
      await widget.onLogin(
        widget.emailController.text,
        widget.passwordController.text,
      );

      await _saveLoginInfo(
        widget.emailController.text,
        widget.passwordController.text,
      );
    } finally {
      setState(() {
        isLoading = false; // Hide loading indicator
      });
    }
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
                  "Welcome, log in to your account",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: widget.emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: widget.passwordController,
                  obscureText: !passwordVisible,
                  maxLength: 10,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: togglePasswordVisibility,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          await _handleLogin();
                        },
                  child: const Text('Login'),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, Routes.register),
                  child: const Text(
                    "Don't have an account? Register here",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
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
  }

  // Save login info to SharedPreferences
  Future<void> _saveLoginInfo(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', email);
    await prefs.setString('password', password);
  }
}
