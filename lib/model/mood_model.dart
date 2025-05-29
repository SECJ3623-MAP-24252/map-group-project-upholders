// model/mood_model.dart

import 'package:flutter/material.dart';

class MoodModel {
  final String emoji;
  final String label;
  final Color color;
  final String note;
  final DateTime date;
  final String? imagePath;

  MoodModel({
    required this.emoji,
    required this.label,
    required this.color,
    required this.note,
    required this.date,
    this.imagePath,
  });
}

