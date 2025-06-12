// lib/screens/dashboard_user.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  State<_DashboardUserPageView> createState() =>
      _DashboardUserPageViewState();
}

class _DashboardUserPageViewState extends State<_DashboardUserPageView> {
  final TextEditingController _moodNoteController = TextEditingController();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final List<Map<String, dynamic>> _emojiOptions = [
    {"emoji": "😀", "label": "Happy",   "color": const Color(0xFF72BF69)},
    {"emoji": "😊", "label": "Grateful","color": const Color(0xFF6EC4E3)},
    {"emoji": "😐", "label": "Neutral", "color": const Color(0xFFB7B77B)},
    {"emoji": "😞", "label": "Sad",     "color": const Color(0xFFFFB24A)},
    {"emoji": "😡", "label": "Angry",   "color": const Color(0xFFD64550)},
  ];

  @override
  void dispose() {
    _moodNoteController.dispose();
    super.dispose();
  }

  Future<void> _openCamera(MoodViewModel vm) async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );
    if (file != null) {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final newId = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('moods')
          .doc()
          .id;

      await vm.addMood(MoodModel(
        id:        newId,
        emoji:     "😀",
        label:     "Happy",
        color:     const Color(0xFF72BF69),
        note:      "Photo mood detected: Happy",
        date:      DateTime.now(),
        imagePath: file.path,
      ));

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Picture Taken'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(File(file.path),
                  height: 120, width: 120, fit: BoxFit.cover),
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

  void _showDayDetailDialog(
      BuildContext ctx, MoodViewModel vm, DateTime day) {
    final entries = vm.getMoodsForDay(day);

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.25,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  "History for ${DateFormat.yMMMd().format(day)}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: entries.length,
                    itemBuilder: (_, i) {
                      final e = entries[i];
                      return ListTile(
                        leading: e.imagePath != null
                            ? CircleAvatar(
                            backgroundImage:
                            FileImage(File(e.imagePath!)))
                            : CircleAvatar(
                          backgroundColor: e.color,
                          child: Text(e.emoji),
                        ),
                        title: Text(e.label),
                        subtitle: Text(DateFormat.jm().format(e.date)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red),
                          onPressed: () async {
                            await vm.deleteMood(e.id);
                            Navigator.pop(ctx);
                            _showDayDetailDialog(ctx, vm, day);
                          },
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showAddMoodDialog(ctx, vm, day);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add Mood"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA7B77A),
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddMoodDialog(
      BuildContext ctx, MoodViewModel vm, [DateTime? preset]) {
    int? selected;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.25,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text("How do you feel?",
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: List.generate(_emojiOptions.length, (i) {
                      final opt = _emojiOptions[i];
                      final sel = selected == i;
                      return GestureDetector(
                        onTap: () => setState(() => selected = i),
                        child: AnimatedContainer(
                          duration:
                          const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: sel
                                ? (opt['color'] as Color)
                                .withOpacity(.3)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: sel
                                ? Border.all(
                                color: opt['color'], width: 2)
                                : null,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(opt['emoji'],
                                  style:
                                  const TextStyle(fontSize: 28)),
                              Text(opt['label'],
                                  style:
                                  const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _moodNoteController,
                    decoration: InputDecoration(
                      labelText: "Note (optional)",
                      border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(8)),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: selected == null
                        ? null
                        : () async {
                      final opt = _emojiOptions[selected!];
                      final now =
                          preset ?? DateTime.now();
                      final uid = FirebaseAuth
                          .instance.currentUser!.uid;
                      final newId = FirebaseFirestore
                          .instance
                          .collection('users')
                          .doc(uid)
                          .collection('moods')
                          .doc()
                          .id;

                      await vm.addMood(MoodModel(
                        id: newId,
                        emoji: opt['emoji'],
                        label: opt['label'],
                        color: opt['color'],
                        note: _moodNoteController.text
                            .trim(),
                        date: now,
                        imagePath: null,
                      ));

                      _moodNoteController.clear();
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFFA7B77A),
                      minimumSize:
                      const Size.fromHeight(48),
                    ),
                    child: const Text("Add Mood"),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodViewModel>(builder: (_, vm, __) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAF3E3),
        appBar: AppBar(
          title: const Text('Home',
              style: TextStyle(color: Colors.brown)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.brown),
        ),
        drawer: const AppDrawer(currentRoute: '/dashboard-user'),

        // Entire page scrolls as a ListView
        body: ListView(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 100),
          children: [
            Text(
              'Tap a day to view/add your mood',
              style: TextStyle(
                  color: Colors.brown[600],
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Calendar in white Card
            Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(
                  horizontal: 4, vertical: 8),
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2100, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (d) =>
                      isSameDay(_selectedDay, d),
                  onDaySelected: (sel, foc) {
                    setState(() {
                      _selectedDay = sel;
                      _focusedDay = foc;
                    });
                    _showDayDetailDialog(context, vm, sel);
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                        color: Colors.green.shade100,
                        shape: BoxShape.circle),
                    selectedDecoration: BoxDecoration(
                        color: Colors.deepOrange.shade200,
                        shape: BoxShape.circle),
                    markersMaxCount: 1,
                  ),
                  headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (ctx, day, _) {
                      final m = vm.getAverageMoodForDay(day);
                      return Center(
                        child: Text(
                          m?.emoji ?? "🙂",
                          style: TextStyle(
                              fontSize: 24,
                              color: m?.color ??
                                  Colors.grey[350]),
                        ),
                      );
                    },
                    todayBuilder: (ctx, day, _) {
                      final m = vm.getAverageMoodForDay(day);
                      return Container(
                        decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Text(
                          m?.emoji ?? "🙂",
                          style: TextStyle(
                              fontSize: 24,
                              color: m?.color ??
                                  Colors.grey[350],
                              fontWeight:
                              FontWeight.bold),
                        ),
                      );
                    },
                    selectedBuilder: (ctx, day, _) {
                      final m = vm.getAverageMoodForDay(day);
                      return Container(
                        decoration: BoxDecoration(
                            color:
                            Colors.deepOrange.shade200,
                            shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Text(
                          m?.emoji ?? "🙂",
                          style: TextStyle(
                              fontSize: 24,
                              color: m?.color ??
                                  Colors.grey[350],
                              fontWeight:
                              FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),
            const Text("Recent History",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),

            // Show all entries in a single scrollable list
            ...vm.moods.map((e) {
              return Card(
                margin: const EdgeInsets.symmetric(
                    vertical: 4),
                child: ListTile(
                  leading: e.imagePath != null
                      ? CircleAvatar(
                      backgroundImage:
                      FileImage(File(e.imagePath!)))
                      : CircleAvatar(
                    backgroundColor: e.color,
                    child: Text(e.emoji),
                  ),
                  title: Text(e.label),
                  subtitle: Text(DateFormat.yMMMd()
                      .add_jm()
                      .format(e.date)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete,
                        color: Colors.red),
                    onPressed: () => vm.deleteMood(e.id),
                  ),
                ),
              );
            }).toList(),
          ],
        ),

        // FABs: Add, Camera, Voice
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                heroTag: "fab_add",
                backgroundColor:
                const Color(0xFFA7B77A),
                onPressed: () =>
                    _showAddMoodDialog(context, vm),
                child: const Icon(Icons.add,
                    size: 28, color: Colors.white),
              ),
              const SizedBox(width: 16),
              FloatingActionButton(
                heroTag: "fab_cam",
                backgroundColor:
                Colors.deepOrange.shade200,
                onPressed: () => _openCamera(vm),
                child: const Icon(Icons.camera_alt,
                    size: 26, color: Colors.white),
              ),
              const SizedBox(width: 16),
              FloatingActionButton(
                heroTag: "fab_voice",
                backgroundColor:
                Colors.blueAccent,
                onPressed: () {
                  // TODO: wire up voice feature
                },
                child: const Icon(Icons.mic,
                    size: 26, color: Colors.white),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation:
        FloatingActionButtonLocation.centerFloat,
      );
    });
  }
}
