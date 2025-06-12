// lib/viewmodels/register_viewmodel.dart

import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../services/auth/auth_service.dart';

class RegisterViewModel extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  String userType = 'user';
  String? errorMessage;
  bool isLoading = false;

  final AuthService _authService = AuthService();

  void setUserType(String? value) {
    userType = value ?? 'user';
    notifyListeners();
  }

  Future<UserModel?> register() async {
    final name  = nameController.text;
    final email = emailController.text;
    final pass  = passwordController.text;

    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      errorMessage = 'All fields are required.';
      notifyListeners();
      return null;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final user = await _authService.registerWithEmail(
      name: name,
      email: email,
      password: pass,
      userType: userType,
    );

    isLoading = false;
    if (user == null) {
      errorMessage = 'Registration failed. Please try again.';
    }
    notifyListeners();

    return user;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }
}
