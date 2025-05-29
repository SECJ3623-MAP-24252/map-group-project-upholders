// In your MoodViewModel (viewmodels/mood_viewmodel.dart)

import '../model/mood_model.dart';
import 'package:flutter/material.dart';

class MoodViewModel extends ChangeNotifier {
  final List<MoodModel> _moods = [];

  List<MoodModel> get moods => _moods;

  void addMood(MoodModel mood) {
    _moods.add(mood);
    notifyListeners();
  }

  // Get all moods for a specific day
  List<MoodModel> getMoodsForDay(DateTime day) {
    return _moods.where((m) =>
    m.date.year == day.year && m.date.month == day.month && m.date.day == day.day
    ).toList();
  }

  // Get the most frequent (average) mood for that day
  MoodModel? getAverageMoodForDay(DateTime day) {
    final moodsOfDay = getMoodsForDay(day);
    if (moodsOfDay.isEmpty) return null;

    final counts = <String, int>{};
    for (var m in moodsOfDay) {
      counts[m.emoji] = (counts[m.emoji] ?? 0) + 1;
    }
    final mostFrequent = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return moodsOfDay.firstWhere((m) => m.emoji == mostFrequent.key);
  }
}
