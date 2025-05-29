// lib/screens/auth/login_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:map_group_project_upholders/model/auth_models.dart'; // Adjust path as needed
// import 'package:map_group_project_upholders/auth/auth_service.dart'; // Example: Your auth service
// import 'package:map_group_project_upholders/auth/login_handler.dart'; // Example: Your login handler

class LoginViewModel extends ChangeNotifier {
  // Example: If you have an AuthService or LoginHandler
  // final AuthService _authService;
  // LoginViewModel(this._authService);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> login(String email, String password, BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate API call or use your actual LoginHandler/AuthService
    // final result = await _loginHandler.performLogin(email, password);
    await Future.delayed(Duration(seconds: 2)); // Simulate network delay
    AuthResult result = AuthResult(success: email == "test@example.com" && password == "password"); // Mock result

    if (result.success) {
      Navigator.pushReplacementNamed(context, '/dashboard'); // Navigate on success
    } else {
      _errorMessage = result.message ?? 'Login failed. Please try again.';
    }
    _isLoading = false;
    notifyListeners();
  }
}