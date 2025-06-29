import 'dart:io';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  String? _recordedFilePath;

  Future<void> startRecording() async {
    final micStatus = await Permission.microphone.request();
    if (micStatus != PermissionStatus.granted) {
      throw Exception('Microphone permission not granted');
    }

    final dir = await getApplicationDocumentsDirectory();
    final filePath =
        '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(const RecordConfig(), path: filePath);
    _recordedFilePath = filePath;
  }

  Future<String?> stopRecording() async {
    await _recorder.stop();
    return _recordedFilePath;
  }

  Future<void> playRecording(String path) async {
    await _player.play(DeviceFileSource(path));
  }

  void dispose() {
    _player.dispose();
  }
}
