// lib/screens/viewmodel.dart
import 'package:flutter/material.dart';

/// A general-purpose ViewModel.
/// Consider renaming this to something more specific if it represents a particular screen,
/// or making it an abstract base class if it's intended for inheritance.
class ViewModel extends ChangeNotifier {
  String _pageTitle = "General Screen";
  String get pageTitle => _pageTitle;

  int _counter = 0;
  int get counter => _counter;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void incrementCounter() {
    _counter++;
    notifyListeners();
  }

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate a network call or data loading process
    await Future.delayed(const Duration(seconds: 2));

    _pageTitle = "Data Loaded for General Screen";
    _counter = 42; // Example of loaded data
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}