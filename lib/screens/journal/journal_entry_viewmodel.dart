// lib/screens/journal/journal_entry_viewmodel.dart
import 'package:flutter/material.dart';

class JournalEntryViewModel extends ChangeNotifier {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  String _selectedMood = 'neutral';
  String get selectedMood => _selectedMood;

  bool _isEditing = false;
  bool get isEditing => _isEditing;

  String? _entryId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void initializeEntry(Map<String, dynamic>? entryData) {
    if (entryData != null) {
      _isEditing = true;
      _entryId = entryData['id'] as String?;
      titleController.text = entryData['title'] as String? ?? '';
      contentController.text = entryData['content'] as String? ?? '';
      _selectedMood = entryData['mood'] as String? ?? 'neutral';
    } else {
      _isEditing = false;
      _entryId = null;
      titleController.clear();
      contentController.clear();
      _selectedMood = 'neutral';
    }
    notifyListeners();
  }

  void selectMood(String mood) {
    _selectedMood = mood;
    notifyListeners();
  }

  Future<bool> saveEntry() async {
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      // Optionally, set an error message state here to show in UI
      return false;
    }

    _isLoading = true;
    notifyListeners();

    // Simulate saving to a service
    await Future.delayed(Duration(seconds: 1));

    print('Saving Entry:');
    print('ID: $_entryId (null if new)');
    print('Title: ${titleController.text}');
    print('Content: ${contentController.text}');
    print('Mood: $_selectedMood');

    _isLoading = false;
    notifyListeners();
    return true; // Indicate success
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }
}