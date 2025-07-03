// lib/viewmodels/mood_viewmodel.dart
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/mood_model.dart';
import '../services/audio/audio_service.dart';
import '../services/emotion/deepai_service.dart';
import '../services/mood/mood_service.dart';
import '../utils/emotion_to_emoji_mapper.dart';

class MoodViewModel extends ChangeNotifier {
  final MoodService _moodService = MoodService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AudioService _audioService = AudioService();

  List<MoodModel> _moods = [];
  List<MoodModel> get moods => _moods;

  // For voice record feature state
  String? _voicePath;
  bool _isRecording = false;
  String? get voicePath => _voicePath;
  bool get isRecording => _isRecording;

  // DEEPAI summary state
  String? _deepaiMoodSummary;
  String? _deepaiJournalSummary;
  String? get deepaiMoodSummary => _deepaiMoodSummary;
  String? get deepaiJournalSummary => _deepaiJournalSummary;

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

  // PHOTO FEATURE
  Future<Map<String, dynamic>> addMoodFromPhoto(
    File photo,
  ) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    // AI emotion detection removed. Default to 'neutral' or prompt user for mood.
    final mapped = mapEmotionToEmojiOption('neutral');

    final newMood = MoodModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      emoji: mapped['emoji'],
      label: mapped['label'],
      color: mapped['color'],
      note: "Photo mood (manual)",
      date: DateTime.now(),
      imagePath: photo.path,
    );

    await _moodService.addMoodEntry(user.uid, newMood);

    return {
      'label': mapped['label'],
      'emoji': mapped['emoji'],
      'photoPath': photo.path,
    };
  }

  // VOICE RECORD FEATURE
  Future<void> startVoiceRecording() async {
    _isRecording = true;
    notifyListeners();
    await _audioService.startRecording();
  }

  Future<Map<String, dynamic>> stopVoiceRecordingAndAddMood() async {
    _isRecording = false;
    notifyListeners();
    final path = await _audioService.stopRecording();
    _voicePath = path;
    if (_voicePath == null) throw Exception("Voice file not found!");

    // AI voice emotion detection removed. Default to 'neutral' or prompt user for mood.
    final mapped = mapEmotionToEmojiOption('neutral');

    final user = _auth.currentUser;
    if (user == null) throw Exception('Not logged in');
    final mood = MoodModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      emoji: mapped['emoji'],
      label: mapped['label'],
      color: mapped['color'],
      note: "Voice mood (manual)",
      date: DateTime.now(),
      voicePath: _voicePath,
    );

    await _moodService.addMoodEntry(user.uid, mood);

    return {
      'label': mapped['label'],
      'emoji': mapped['emoji'],
      'voicePath': _voicePath,
    };
  }

  Future<void> playVoice(String? path) async {
    if (path == null) return;
    await _audioService.playRecording(path);
  }

  void resetVoice() {
    _voicePath = null;
    _isRecording = false;
    notifyListeners();
  }

  List<MoodModel> getMoodsForDay(DateTime day) {
    return _moods
        .where(
          (m) =>
              m.date.year == day.year &&
              m.date.month == day.month &&
              m.date.day == day.day,
        )
        .toList();
  }

  MoodModel? getAverageMoodForDay(DateTime day) {
    final moodsOfDay = getMoodsForDay(day);
    if (moodsOfDay.isEmpty) return null;
    final counts = <String, int>{};
    for (var m in moodsOfDay) {
      counts[m.emoji] = (counts[m.emoji] ?? 0) + 1;
    }
    final most = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return moodsOfDay.firstWhere((m) => m.emoji == most.key);
  }

  // Fetch DEEPAI mood analysis (simulate)
  Future<void> fetchDeepAIMoodSummary(String text) async {
    _deepaiMoodSummary = await DeepAIService.analyzeMood(text);
    notifyListeners();
  }

  // Fetch DEEPAI journal analysis (simulate)
  Future<void> fetchDeepAIJournalSummary(String text) async {
    _deepaiJournalSummary = await DeepAIService.analyzeJournal(text);
    notifyListeners();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
