import 'package:flutter/material.dart';

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

  final List<Map<String, String>> _users = [
    {
      'email': 'therapist@example.com',
      'password': 'therapist123',
      'role': 'therapist',
    },
    {
      'email': 'user@example.com',
      'password': 'user123',
      'role': 'user',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove default appbar, use custom layout instead
      backgroundColor: const Color(0xFFF8F5FF),
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFEF6E6), // Soft orange
                  Color(0xFFE2E6FC), // Soft blue/lilac
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App logo (Replace this with your SVG, PNG or asset)
                  Container(
                    width: 90,
                    height: 90,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFA7B77A),
                          Color(0xFF6EC4E3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "🧠",
                        style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  // App name
                  Text(
                    'Upholder Mood Tracker',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.brown[700],
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your daily mental health companion',
                    style: TextStyle(
                      color: Colors.brown[300],
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            if (_loginError != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  _loginError!,
                                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                              ),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.email, color: Colors.brown[200]),
                                labelText: 'Email',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.lock, color: Colors.brown[200]),
                                labelText: 'Password',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 26),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
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
                                  backgroundColor: const Color(0xFFA7B77A),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  elevation: 2,
                                ),
                                child: const Text('Login'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/forgot-password');
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(color: Color(0xFFA7B77A), fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
