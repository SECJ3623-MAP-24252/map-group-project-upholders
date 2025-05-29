// lib/screens/mood_tracking/mood_analytics_viewmodel.dart
import 'package:flutter/material.dart';

class MoodAnalyticsViewModel extends ChangeNotifier {
  String _selectedPeriod = 'Week';
  String get selectedPeriod => _selectedPeriod;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Example data structures - replace with your actual data models
  Map<String, double> _moodDistribution = {};
  Map<String, double> get moodDistribution => _moodDistribution;

  List<Map<String, dynamic>> _moodTrends = []; // e.g., {'date': DateTime, 'mood_score': 7}
  List<Map<String, dynamic>> get moodTrends => _moodTrends;

  List<Map<String, dynamic>> _topTriggers = []; // e.g., {'trigger': 'Work', 'count': 10}
  List<Map<String, dynamic>> get topTriggers => _topTriggers;

  List<Map<String, dynamic>> _insights = []; // e.g., {'icon': Icons.info, 'text': 'Insight text', 'color': Colors.blue}
  List<Map<String, dynamic>> get insights => _insights;

  MoodAnalyticsViewModel() {
    fetchAnalyticsData();
  }

  void selectPeriod(String period) {
    _selectedPeriod = period;
    fetchAnalyticsData(); // Refetch data for the new period
    notifyListeners();
  }

  Future<void> fetchAnalyticsData() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call or data processing based on _selectedPeriod
    await Future.delayed(Duration(seconds: 1));

    // Mock data based on period - replace with actual logic
    if (_selectedPeriod == 'Week') {
      _moodDistribution = {'Happy': 0.6, 'Neutral': 0.3, 'Sad': 0.1, 'Anxious': 0.2, 'Excited': 0.4};
      _topTriggers = [{'trigger': 'Work Stress', 'count': 5}, {'trigger': 'Lack of Sleep', 'count': 3}];
      _insights = [
        {'icon': Icons.trending_up, 'text': 'Your mood has been improving this week!', 'color': Colors.green},
      ];
    } else if (_selectedPeriod == 'Month') {
      _moodDistribution = {'Happy': 0.5, 'Neutral': 0.2, 'Sad': 0.2, 'Anxious': 0.1, 'Excited': 0.3};
      _topTriggers = [{'trigger': 'Social Events', 'count': 10}, {'trigger': 'Exercise', 'count': 8}];
      _insights = [
        {'icon': Icons.calendar_today, 'text': 'You logged moods consistently this month.', 'color': Colors.blue},
      ];
    } else { // Year
      _moodDistribution = {'Happy': 0.55, 'Neutral': 0.25, 'Sad': 0.1, 'Anxious': 0.05, 'Excited': 0.35};
      _topTriggers = [{'trigger': 'Holidays', 'count': 15}, {'trigger': 'Travel', 'count': 12}];
      _insights = [
        {'icon': Icons.star, 'text': 'Overall positive mood trend this year!', 'color': Colors.amber},
      ];
    }

    // Placeholder for mood trends chart data
    _moodTrends = [
      {'date': DateTime.now().subtract(Duration(days: 6)), 'mood_score': 7},
      {'date': DateTime.now().subtract(Duration(days: 3)), 'mood_score': 5},
      {'date': DateTime.now(), 'mood_score': 8},
    ];

    _isLoading = false;
    notifyListeners();
  }
}