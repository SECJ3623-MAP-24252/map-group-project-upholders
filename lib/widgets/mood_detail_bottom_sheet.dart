import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/mood_model.dart';
import '../viewmodels/mood_viewmodel.dart';
import '../utils/emoji_options.dart';
import './mood_add_bottom_sheet.dart';

void showMoodDetailBottomSheet(
  BuildContext ctx,
  MoodViewModel vm,
  DateTime day,
) {
  final entries = vm.getMoodsForDay(day);

  showModalBottomSheet(
    context: ctx,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (_) => DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.25,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                          leading:
                              e.imagePath != null
                                  ? CircleAvatar(
                                    backgroundImage: FileImage(
                                      File(e.imagePath!),
                                    ),
                                  )
                                  : CircleAvatar(
                                    backgroundColor: e.color,
                                    child: Text(e.emoji),
                                  ),
                          title: Text(e.label),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(DateFormat.jm().format(e.date)),
                              if (e.note != null && e.note!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    e.note!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await vm.deleteMood(e.id);
                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);
                              showMoodDetailBottomSheet(ctx, vm, day);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        showMoodAddBottomSheet(ctx, vm, day);
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
