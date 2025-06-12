// lib/services/mood_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/mood_model.dart';

class MoodService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addMoodEntry(String userId, MoodModel mood) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('moods')
        .doc(mood.id)
        .set(mood.toMap());
  }

  Stream<List<MoodModel>> moodHistory(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('moods')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => MoodModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  Future<void> deleteMoodEntry(String userId, String entryId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('moods')
        .doc(entryId)
        .delete();
  }
}
