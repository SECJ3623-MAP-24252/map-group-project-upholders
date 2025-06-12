import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/register_viewmodel.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: const _RegisterScreenView(),
    );
  }
}

class _RegisterScreenView extends StatelessWidget {
  const _RegisterScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<RegisterViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFEF6E6), Color(0xFFE2E6FC)],
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
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFA7B77A), Color(0xFF6EC4E3)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "🧠",
                        style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.brown,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
                      child: Column(
                        children: [
                          if (vm.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                vm.errorMessage!,
                                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                            ),
                          TextFormField(
                            controller: vm.nameController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.person, color: Colors.brown[200]),
                              labelText: 'Full Name',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            keyboardType: TextInputType.name,
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: vm.emailController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email, color: Colors.brown[200]),
                              labelText: 'Email',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: vm.passwordController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock, color: Colors.brown[200]),
                              labelText: 'Password',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            obscureText: true,
                          ),
                          const SizedBox(height: 22),
                          // User type selection (radio buttons)
                          //cancel
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: vm.isLoading
                                  ? null
                                  : () async {
                                final user = await vm.register();
                                if (user != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Registration successful! Please login.'),
                                    ),
                                  );
                                  Navigator.pop(context); // Back to login page
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
                              child: vm.isLoading
                                  ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                                  : const Text('Register'),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                            child: const Text(
                              'Already have an account? Login',
                              style: TextStyle(
                                color: Color(0xFFA7B77A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
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
}
