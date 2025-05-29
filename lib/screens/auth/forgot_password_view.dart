// lib/screens/auth/forgot_password_viewmodel.dart
import 'package:flutter/material.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _message;
  String? get message => _message;

  Future<void> sendPasswordResetEmail(String email) async {
    if (email.isEmpty) {
      _message = "Email cannot be empty.";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _message = null;
    notifyListeners();

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));
    // In a real app, call your auth service here
    _message = "Password reset link sent to $email!";
    _isLoading = false;
    notifyListeners();
  }
}