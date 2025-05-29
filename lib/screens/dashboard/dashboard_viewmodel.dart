// lib/screens/dashboard/dashboard_viewmodel.dart
import 'package:flutter/material.dart';

class DashboardViewModel extends ChangeNotifier {
  String _userName = "User"; // Default or fetched name
  String get userName => _userName;

  // Example data - in a real app, this would be fetched from a service
  int _happyCount = 5;
  int get happyCount => _happyCount;

  int _neutralCount = 2;
  int get neutralCount => _neutralCount;

  int _sadCount = 0;
  int get sadCount => _sadCount;

  List<Map<String, dynamic>> _recentEntries = [
    {'icon': Icons.mood, 'color': Colors.green, 'title': 'Great day!', 'subtitle': 'Today, 2:30 PM'},
    {'icon': Icons.mood_bad, 'color': Colors.orange, 'title': 'Feeling stressed', 'subtitle': 'Yesterday, 6:15 PM'},
  ];
  List<Map<String, dynamic>> get recentEntries => _recentEntries;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  DashboardViewModel() {
    // Fetch initial data if needed
    // fetchDashboardData();
  }

  // Future<void> fetchDashboardData() async {
  //   // Simulate fetching data
  //   await Future.delayed(Duration(seconds: 1));
  //   _userName = "Jane Doe"; // Fetched name
  //   // Update other data properties
  //   notifyListeners();
  // }

  void onNavigationTapped(int index) {
    _currentIndex = index;
    notifyListeners();
    // Handle navigation based on index, potentially using a callback or directly in the view
  }
}