// lib/viewmodels/mood_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/mood_model.dart';
import '../services/mood/mood_service.dart';

class MoodViewModel extends ChangeNotifier {
  final MoodService _moodService = MoodService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<MoodModel> _moods = [];
  List<MoodModel> get moods => _moods;

  MoodViewModel() {
    final user = _auth.currentUser;
    if (user != null) {
      _moodService.moodHistory(user.uid).listen((list) {
        _moods = list;
        notifyListeners();
      });
    }
  }

  Future<void> addMood(MoodModel mood) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not logged in');
    await _moodService.addMoodEntry(user.uid, mood);
  }

  Future<void> deleteMood(String entryId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not logged in');
    await _moodService.deleteMoodEntry(user.uid, entryId);
  }

  List<MoodModel> getMoodsForDay(DateTime day) {
    return _moods.where((m) =>
    m.date.year == day.year &&
        m.date.month == day.month &&
        m.date.day == day.day
    ).toList();
  }

  MoodModel? getAverageMoodForDay(DateTime day) {
    final moodsOfDay = getMoodsForDay(day);
    if (moodsOfDay.isEmpty) return null;
    final counts = <String,int>{};
    for (var m in moodsOfDay) {
      counts[m.emoji] = (counts[m.emoji] ?? 0) + 1;
    }
    final most = counts.entries.reduce((a,b) => a.value>=b.value ? a : b);
    return moodsOfDay.firstWhere((m)=>m.emoji==most.key);
  }
}

