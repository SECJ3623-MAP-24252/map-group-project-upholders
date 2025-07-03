import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/mood_model.dart';
import '../viewmodels/mood_viewmodel.dart';
import '../utils/emoji_options.dart';

void showMoodAddBottomSheet(
  BuildContext ctx,
  MoodViewModel vm, [
  DateTime? preset,
]) {
  final TextEditingController _moodNoteController = TextEditingController();

  showModalBottomSheet(
    context: ctx,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (_) => DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.25,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            int? selected;
            return StatefulBuilder(
              builder: (c, setModalState) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
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
                        const Text(
                          "How do you feel?",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: List.generate(emojiOptions.length, (i) {
                            final opt = emojiOptions[i];
                            final isSel = selected == i;
                            return GestureDetector(
                              onTap: () => setModalState(() => selected = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      isSel
                                          ? (opt['color'] as Color).withOpacity(
                                            .3,
                                          )
                                          : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      isSel
                                          ? Border.all(
                                            color: opt['color'] as Color,
                                            width: 2,
                                          )
                                          : null,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      opt['emoji'],
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                    Text(
                                      opt['label'],
                                      style: const TextStyle(fontSize: 12),
                                    ),
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
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed:
                              selected == null
                                  ? null
                                  : () async {
                                    final opt = emojiOptions[selected!];
                                    final now = preset ?? DateTime.now();
                                    final uid =
                                        FirebaseAuth.instance.currentUser!.uid;
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
                                        emoji: opt['emoji'],
                                        label: opt['label'],
                                        color: opt['color'],
                                        note: _moodNoteController.text.trim(),
                                        date: now,
                                        imagePath: null,
                                      ),
                                    );
                                    if (!ctx.mounted) return;
                                    Navigator.pop(ctx);
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA7B77A),
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: const Text("Add Mood"),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
  );
}
