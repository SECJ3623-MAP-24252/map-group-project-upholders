import 'package:flutter/material.dart';

import '../model/user_model.dart';
import '../services/auth/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthViewModel(this._authService);

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithEmailPassword(email, password);
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return user != null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final result = await _authService.resetPassword(email);
      _isLoading = false;
      if (!result) _errorMessage = "Failed to send password reset email";
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    await _authService.signOut();
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }
}