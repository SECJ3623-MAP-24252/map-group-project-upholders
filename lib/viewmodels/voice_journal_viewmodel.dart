import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../model/voice_journal_entry.dart';

class VoiceJournalViewModel extends ChangeNotifier {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  bool _isRecording = false;
  bool _isPlaying = false;
  String? _playingPath;

  final List<VoiceJournalEntry> _history = [];

  List<VoiceJournalEntry> get history => List.unmodifiable(_history);
  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  String? get playingPath => _playingPath;

  Future<void> startRecording() async {
    final micStatus = await Permission.microphone.request();
    if (micStatus != PermissionStatus.granted) {
      // Handle denial gracefully
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final filePath =
        '${dir.path}/journal_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: filePath,
    );

    _isRecording = true;
    notifyListeners();
  }

  Future<void> stopRecording() async {
    final path = await _recorder.stop();
    _isRecording = false;

    if (path != null) {
      _history.insert(
        0,
        VoiceJournalEntry(
          filePath: path,
          date: DateTime.now(),
          emotion: 'Happy', // Placeholder
          transcript: 'Voice-to-text transcript (demo)',
        ),
      );
    }

    notifyListeners();
  }

  Future<void> play(String filePath) async {
    try {
      await _player.setFilePath(filePath);
      _isPlaying = true;
      _playingPath = filePath;
      notifyListeners();

      await _player.play();

      _isPlaying = false;
      _playingPath = null;
      notifyListeners();
    } catch (e) {
      // Handle playback error (e.g., file missing)
    }
  }

  Future<void> stopPlayback() async {
    await _player.stop();
    _isPlaying = false;
    _playingPath = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
