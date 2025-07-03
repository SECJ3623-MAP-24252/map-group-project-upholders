import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../model/mood_model.dart';
import '../../services/audio/audio_service.dart';
import '../../utils/emotion_to_emoji_mapper.dart';
import '../../viewmodels/mood_viewmodel.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/mood_add_bottom_sheet.dart';
import '../../widgets/mood_detail_bottom_sheet.dart';

class DashboardUserPage extends StatelessWidget {
  const DashboardUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MoodViewModel(),
      child: const _DashboardUserPageView(),
    );
  }
}

class _DashboardUserPageView extends StatefulWidget {
  const _DashboardUserPageView();

  @override
  State<_DashboardUserPageView> createState() => _DashboardUserPageViewState();
}

class _DashboardUserPageViewState extends State<_DashboardUserPageView> {
  final TextEditingController _moodNoteController = TextEditingController();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late final AudioService _audioService;

  bool _voiceRecording = false;

  @override
  void dispose() {
    _moodNoteController.dispose();
    _audioService.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _audioService = AudioService();
  }

  // Photo feature (unchanged)
  Future<void> _openCamera(MoodViewModel vm) async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );
    if (file == null) return;

    final imageFile = File(file.path);

    // AI emotion detection removed. Default to 'neutral' or prompt user for mood.
    final moodOption = mapEmotionToEmojiOption('neutral');

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final newId =
        FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('moods')
            .doc()
            .id;

    await vm.addMood(
      MoodModel(
        id: newId,
        emoji: moodOption['emoji'],
        label: moodOption['label'],
        color: moodOption['color'],
        note: "Photo mood (manual)",
        date: DateTime.now(),
        imagePath: file.path,
      ),
    );

    if (!mounted) return;
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Picture Taken'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.file(
                  File(file.path),
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 8),
                Text('Detected: ${moodOption['label']} ${moodOption['emoji']}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (!mounted) return;
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  // Voice feature
  Future<void> _startVoiceRecord(MoodViewModel vm) async {
    setState(() {
      _voiceRecording = true;
    });
    await vm.startVoiceRecording();
  }

  Future<void> _stopVoiceRecord(MoodViewModel vm) async {
    setState(() {
      _voiceRecording = false;
    });
    final result = await vm.stopVoiceRecordingAndAddMood();
    if (!mounted) return;
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Voice Recorded'),
            content: Text('Detected: ${result['label']} ${result['emoji']}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodViewModel>(
      builder: (_, vm, __) {
        return Scaffold(
          backgroundColor: const Color(0xFFFAF3E3),
          appBar: AppBar(
            title: const Text('Home', style: TextStyle(color: Colors.brown)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.brown),
          ),
          drawer: const AppDrawer(currentRoute: '/dashboard-user'),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 100),
            children: [
              Text(
                'Tap a day to view/add your mood',
                style: TextStyle(
                  color: Colors.brown[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2100, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
                    onDaySelected: (sel, foc) {
                      setState(() {
                        _selectedDay = sel;
                        _focusedDay = foc;
                      });
                      showMoodDetailBottomSheet(context, vm, sel);
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.green.shade100,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.deepOrange.shade200,
                        shape: BoxShape.circle,
                      ),
                      markersMaxCount: 1,
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (ctx, day, _) {
                        final m = vm.getAverageMoodForDay(day);
                        return Center(
                          child: Text(
                            m?.emoji ?? "🙂",
                            style: TextStyle(
                              fontSize: 24,
                              color: m?.color ?? Colors.grey[350],
                            ),
                          ),
                        );
                      },
                      todayBuilder: (ctx, day, _) {
                        final m = vm.getAverageMoodForDay(day);
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            m?.emoji ?? "🙂",
                            style: TextStyle(
                              fontSize: 24,
                              color: m?.color ?? Colors.grey[350],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      selectedBuilder: (ctx, day, _) {
                        final m = vm.getAverageMoodForDay(day);
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.deepOrange.shade200,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            m?.emoji ?? "🙂",
                            style: TextStyle(
                              fontSize: 24,
                              color: m?.color ?? Colors.grey[350],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Recent History",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              ...vm.moods.map((e) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading:
                        e.imagePath != null
                            ? CircleAvatar(
                              backgroundImage: FileImage(File(e.imagePath!)),
                            )
                            : CircleAvatar(
                              backgroundColor: e.color,
                              child: Text(e.emoji),
                            ),
                    title: Text(e.label),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat.yMMMd().add_jm().format(e.date)),
                        if (e.note != null && e.note!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              e.note!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        if (e.voicePath != null)
                          Row(
                            children: [
                              Icon(Icons.mic, size: 16, color: Colors.blueGrey),
                              TextButton(
                                onPressed: () async {
                                  await vm.playVoice(e.voicePath);
                                },
                                child: const Text('Play Voice'),
                              ),
                            ],
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => vm.deleteMood(e.id),
                    ),
                  ),
                );
              }),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: "fab_add",
                  backgroundColor: const Color(0xFFA7B77A),
                  onPressed: () => showMoodAddBottomSheet(context, vm),
                  child: const Icon(Icons.add, size: 28, color: Colors.white),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: "fab_cam",
                  backgroundColor: Colors.deepOrange.shade200,
                  onPressed: () => _openCamera(vm),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 26,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                // VOICE FAB: Press to record, again to stop & save
                FloatingActionButton(
                  heroTag: "fab_voice",
                  backgroundColor: Colors.blueAccent,
                  onPressed:
                      _voiceRecording
                          ? () => _stopVoiceRecord(vm)
                          : () => _startVoiceRecord(vm),
                  child: Icon(
                    _voiceRecording ? Icons.stop : Icons.mic,
                    size: 26,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }
}
