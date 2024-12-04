import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';
import 'package:scenario_management_tool_for_testers/Actions/login_actions.dart';
import 'package:scenario_management_tool_for_testers/Resources/route.dart';
import 'package:scenario_management_tool_for_testers/state/appstate.dart';
import 'package:scenario_management_tool_for_testers/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool passwordVisible = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLoginInfo();
  }

  // Save login info to SharedPreferences
  Future<void> _saveLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _emailController.text);
    await prefs.setString('password', _passwordController.text);
  }

  // Load login info from SharedPreferences
  Future<void> _loadLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = prefs.getString('username') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
    });
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });
    await _saveLoginInfo();

    store.dispatch(
      LoginAction(
        email: _emailController.text,
        password: _passwordController.text,
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
        if (state.loginStatus == LoginStatus.success) {
          ScaffoldMessenger.of(context!).showSnackBar(
            const SnackBar(content: Text("Login successful! Redirecting...")),
          );
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pushNamedAndRemoveUntil(
                context, Routes.dashboard, (route) => false);
            //Navigator.pushReplacementNamed(context, Routes.dashboard);
          });
          store.dispatch(SetLoginStatusAction());
        } else if (state.loginStatus == LoginStatus.failure) {
          ScaffoldMessenger.of(context!).showSnackBar(
            const SnackBar(content: Text("Login failed! Please try again.")),
          );
          store.dispatch(SetLoginStatusAction());
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
                      "Welcome, log in to your account",
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
                      obscureText: !passwordVisible,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              passwordVisible = !passwordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: isLoading ? null : _login,
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