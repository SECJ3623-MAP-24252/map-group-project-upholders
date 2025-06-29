import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MoodModel {
  final String id;
  final String emoji;
  final String label;
  final Color color;
  final String? note;
  final DateTime date;
  final String? imagePath;
  final String? voicePath;

  MoodModel({
    required this.id,
    required this.emoji,
    required this.label,
    required this.color,
    this.note,
    required this.date,
    this.imagePath,
    this.voicePath,
  });

  Map<String, dynamic> toMap() => {
    'emoji': emoji,
    'label': label,
    'color': color.value,
    if (note != null) 'note': note,
    'date': Timestamp.fromDate(date),
    if (imagePath != null) 'imagePath': imagePath,
    if (voicePath != null) 'voicePath': voicePath,
  };

  factory MoodModel.fromMap(Map<String, dynamic> map, String docId) {
    return MoodModel(
      id: docId,
      emoji: map['emoji'] as String,
      label: map['label'] as String,
      color: Color(map['color'] as int),
      note: map['note'] as String?, // now nullable
      date: (map['date'] as Timestamp).toDate(),
      imagePath: map['imagePath'] as String?,
      voicePath: map['voicePath'] as String?, // new field
    );
  }
}
