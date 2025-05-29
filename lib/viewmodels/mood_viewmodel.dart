import 'package:flutter/material.dart';
import '../model/mood_model.dart';

class MoodViewModel extends ChangeNotifier {
  final List<MoodModel> _moods = [];

  List<MoodModel> get moods => List.unmodifiable(_moods);

  void addMood(MoodModel entry) {
    // Replace if already exists for this date
    _moods.removeWhere((e) =>
    e.date.year == entry.date.year &&
        e.date.month == entry.date.month &&
        e.date.day == entry.date.day
    );
    _moods.add(entry);
    notifyListeners();
  }

  MoodModel? getMoodForDay(DateTime day) {
    try {
      return _moods.firstWhere((e) =>
      e.date.year == day.year &&
          e.date.month == day.month &&
          e.date.day == day.day
      );
    } catch (_) {
      return null;
    }
  }
}
