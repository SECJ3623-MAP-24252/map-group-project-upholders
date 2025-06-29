import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

// Optional: Keep this if you want to show Firebase connection status
bool isFirebaseInitialized() {
  return Firebase.apps.isNotEmpty;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _loginError;

  // Hardcoded user data
  final List<Map<String, String>> _users = [
    {
      'email': 'therapist@example.com',
      'password': 'therapist123',
      'role': 'therapist',
    },

    {'email': 'user@example.com', 'password': 'user123', 'role': 'user'},
  ];

  @override
  Widget build(BuildContext context) {
    // Optional: show firebase connection status
    // final firebaseConnected = isFirebaseInitialized();

    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Optional: show firebase status
              // if (!firebaseConnected)
              //   Row(
              //     children: [
              //       Icon(Icons.warning, color: Colors.red),
              //       SizedBox(width: 8),
              //       Text(
              //         'Firebase not connected!',
              //         style: TextStyle(color: Colors.red),
              //       ),
              //     ],
              //   ),
              if (_loginError != null)
                Text(_loginError!, style: TextStyle(color: Colors.red)),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final email = _emailController.text.trim();
                    final password = _passwordController.text;
                    final user = _users.firstWhere(
                      (u) => u['email'] == email && u['password'] == password,
                      orElse: () => {},
                    );
                    if (user.isNotEmpty) {
                      if (user['role'] == 'therapist') {
                        Navigator.pushReplacementNamed(
                          context,
                          '/dashboard-psychiatrist',
                        );
                      } else if (user['role'] == 'user') {
                        Navigator.pushReplacementNamed(
                          context,
                          '/dashboard-user',
                        );
                      }
                    } else {
                      setState(() {
                        _loginError = 'Invalid email or password!';
                      });
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Login'),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/forgot-password');
                },
                child: Text('Forgot Password?'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
