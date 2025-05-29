// lib/screens/mood_tracking/mood_history_viewmodel.dart
import 'package:flutter/material.dart';

class MoodHistoryViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _moodHistory = [];
  List<Map<String, dynamic>> get moodHistory => _moodHistory;

  MoodHistoryViewModel() {
    fetchMoodHistory();
  }

  Future<void> fetchMoodHistory() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(Duration(seconds: 1));
    _moodHistory = [
      {
        'date': '2024-07-29 14:30',
        'mood': 'Happy',
        'intensity': 8,
        'triggers': ['Exercise', 'Good Weather'],
        'notes': 'Had a great workout session today!'
      },
      // Add more mock entries or fetch from a service
    ];

    _isLoading = false;
    notifyListeners();
  }

  // Add methods for filtering, searching history if needed
}