import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../model/mood_model.dart';
import '../../viewmodels/mood_viewmodel.dart';
import '../../widgets/app_drawer.dart';

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
  final List<Map<String, dynamic>> _emojiOptions = [
    {"emoji": "😀", "label": "Happy", "color": const Color(0xFF72BF69)},
    {"emoji": "😊", "label": "Grateful", "color": const Color(0xFF6EC4E3)},
    {"emoji": "😐", "label": "Neutral", "color": const Color(0xFFB7B77B)},
    {"emoji": "😞", "label": "Sad", "color": const Color(0xFFFFB24A)},
    {"emoji": "😡", "label": "Angry", "color": const Color(0xFFD64550)},
  ];

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final _moodNoteController = TextEditingController();

  @override
  void dispose() {
    _moodNoteController.dispose();
    super.dispose();
  }

  // Open camera and show preview (save dummy mood: happy)
  Future<void> _openCamera(MoodViewModel viewModel) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );
    if (image != null) {
      // Always "Happy" for dummy
      viewModel.addMood(
        MoodModel(
          emoji: "😀",
          label: "Happy",
          color: const Color(0xFF72BF69),
          note: "Photo mood detected: Happy",
          date: DateTime.now(),
          imagePath: image.path,
        ),
      );
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Picture Taken'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(
                File(image.path),
                height: 120,
                width: 120,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 8),
              const Text('Dummy result: Happy 😊'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _showAddMoodDialog(BuildContext context, MoodViewModel viewModel, [DateTime? presetDay]) {
    int? selectedEmojiIndex;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 28,
                top: 28,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("How do you feel?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 18,
                    runSpacing: 8,
                    children: List.generate(_emojiOptions.length, (i) {
                      final selected = selectedEmojiIndex == i;
                      return GestureDetector(
                        onTap: () {
                          setModalState(() => selectedEmojiIndex = i);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: selected
                                ? (_emojiOptions[i]['color'] as Color).withOpacity(0.25)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: selected
                                ? Border.all(color: _emojiOptions[i]['color'], width: 2)
                                : Border.all(color: Colors.transparent),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_emojiOptions[i]['emoji'], style: const TextStyle(fontSize: 28)),
                              const SizedBox(height: 2),
                              Text(_emojiOptions[i]['label'], style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _moodNoteController,
                    decoration: InputDecoration(
                      labelText: "Add a note (optional)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
                    ),
                    minLines: 1,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (selectedEmojiIndex != null)
                          ? () {
                        final option = _emojiOptions[selectedEmojiIndex!];
                        viewModel.addMood(
                          MoodModel(
                            emoji: option['emoji'],
                            label: option['label'],
                            color: option['color'],
                            note: _moodNoteController.text.trim(),
                            date: presetDay ?? DateTime.now(),
                          ),
                        );
                        _moodNoteController.clear();
                        Navigator.pop(context);
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA7B77A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Add Mood", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFAF3E3),
          appBar: AppBar(
            title: const Text('Home', style: TextStyle(color: Colors.brown)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.brown),
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.brown),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
          drawer: const AppDrawer(currentRoute: '/dashboard-user'),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Text('Tap any day to set your mood or add as many as you like!', style: TextStyle(color: Colors.brown[600], fontWeight: FontWeight.bold)),
              ),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2100, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    calendarFormat: CalendarFormat.month,
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
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(color: Colors.black54),
                      weekendStyle: TextStyle(color: Colors.black38),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      _showAddMoodDialog(context, Provider.of<MoodViewModel>(context, listen: false), selectedDay);
                    },
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        final mood = Provider.of<MoodViewModel>(context, listen: false).getAverageMoodForDay(day);
                        return Center(
                          child: Text(
                            mood?.emoji ?? "🙂",
                            style: TextStyle(
                              fontSize: 24,
                              color: mood?.color ?? Colors.grey[350],
                            ),
                          ),
                        );
                      },
                      todayBuilder: (context, day, focusedDay) {
                        final mood = Provider.of<MoodViewModel>(context, listen: false).getAverageMoodForDay(day);
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            mood?.emoji ?? "🙂",
                            style: TextStyle(
                              fontSize: 24,
                              color: mood?.color ?? Colors.grey[350],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      selectedBuilder: (context, day, focusedDay) {
                        final mood = Provider.of<MoodViewModel>(context, listen: false).getAverageMoodForDay(day);
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.deepOrange.shade200,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            mood?.emoji ?? "🙂",
                            style: TextStyle(
                              fontSize: 24,
                              color: mood?.color ?? Colors.grey[350],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Mood History", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              ...viewModel.moods.reversed.map((entry) => Card(
                margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                color: Colors.white,
                child: ListTile(
                  leading: entry.imagePath != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      File(entry.imagePath!),
                      height: 38,
                      width: 38,
                      fit: BoxFit.cover,
                    ),
                  )
                      : CircleAvatar(
                    backgroundColor: entry.color,
                    child: Text(entry.emoji, style: const TextStyle(fontSize: 22)),
                  ),
                  title: Text(entry.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    "${DateFormat('EEEE, MMM d, yyyy').format(entry.date)} at ${DateFormat.jm().format(entry.date)}"
                        "${entry.note.isNotEmpty ? "\n${entry.note}" : ""}",
                  ),
                ),
              )),
              const SizedBox(height: 80),
            ],
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: "fab_add",
                onPressed: () => _showAddMoodDialog(context, viewModel),
                backgroundColor: const Color(0xFFA7B77A),
                child: const Icon(Icons.add, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 18),
              FloatingActionButton(
                heroTag: "fab_camera",
                onPressed: () => _openCamera(viewModel),
                backgroundColor: Colors.deepOrange.shade200,
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
              ),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }
}
