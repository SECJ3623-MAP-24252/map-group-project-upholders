import '../../model/journal_model.dart';
// For a more robust unique ID, consider the 'uuid' package
// import 'package:uuid/uuid.dart';

class JournalService {
  // In-memory store for journal entries.
  // In a real app, this would be replaced by database calls.
  final List<JournalEntry> _journalEntries = [];
  // final _uuid = Uuid(); // If using the uuid package

  // Initialize with some sample data (optional)
  JournalService() {
    _addSampleEntries();
  }

  void _addSampleEntries() {
    // Only add if the list is empty to avoid duplicates on hot reload/restart
    // if (_journalEntries.isEmpty) {
      _journalEntries.addAll([
        JournalEntry(
            id: DateTime.now().subtract(const Duration(days: 2)).millisecondsSinceEpoch.toString(),
            title: 'First Day Reflections',
            content: 'Today was an interesting day. I learned a lot about Flutter and state management.',
            date: DateTime.now().subtract(const Duration(days: 2))),
        JournalEntry(
            id: DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch.toString(),
            title: 'App Ideas Brainstorm',
            content: 'Thinking about some cool project ideas for the future. Maybe a habit tracker or a recipe app.',
            date: DateTime.now().subtract(const Duration(days: 1))),
      ]);
    // }
  }

  // Get all journal entries
  Future<List<JournalEntry>> getJournalEntries() async {
    // Simulate a network delay or database query
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_journalEntries); // Return a copy to prevent direct modification
  }

  // Add a new journal entry or update an existing one
  Future<JournalEntry> saveJournalEntry(JournalEntry entry) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (entry.id == null || entry.id!.isEmpty) {
      // New entry: assign an ID and add to the list
      final newId = DateTime.now().millisecondsSinceEpoch.toString(); // Simple ID generation
      // final newId = _uuid.v4(); // Using uuid package
      final newEntry = JournalEntry(
        id: newId,
        title: entry.title,
        content: entry.content,
        date: entry.date,
      );
      _journalEntries.add(newEntry);
      return newEntry;
    } else {
      // Existing entry: find and update
      final index = _journalEntries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        _journalEntries[index] = entry;
        return entry;
      } else {
        // Should not happen if IDs are managed correctly, but handle defensively
        throw Exception('Journal entry with id ${entry.id} not found for update.');
      }
    }
  }

  // Delete a journal entry
  Future<void> deleteJournalEntry(String entryId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _journalEntries.removeWhere((entry) => entry.id == entryId);
  }
}