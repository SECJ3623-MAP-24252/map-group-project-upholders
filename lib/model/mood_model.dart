import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MoodModel {
  final String id;
  final String emoji;
  final String label;
  final Color color;
  final String note;
  final DateTime date;
  final String? imagePath;

  MoodModel({
    required this.id,
    required this.emoji,
    required this.label,
    required this.color,
    required this.note,
    required this.date,
    this.imagePath,
  });

  Map<String, dynamic> toMap() => {
    'emoji': emoji,
    'label': label,
    'color': color.value,
    'note': note,
    'date': Timestamp.fromDate(date),
    'imagePath': imagePath,
  };

  factory MoodModel.fromMap(Map<String, dynamic> map, String docId) {
    return MoodModel(
      id: docId,
      emoji: map['emoji'] as String,
      label: map['label'] as String,
      color: Color(map['color'] as int),
      note: map['note'] as String,
      date: (map['date'] as Timestamp).toDate(),
      imagePath: map['imagePath'] as String?,
    );
  }
}