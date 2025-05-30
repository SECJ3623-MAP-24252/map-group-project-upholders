import 'package:flutter/material.dart';

import '../../model/journal_model.dart';
import '../../services/journal/journal_service.dart'; // <-- ADD THIS IMPORT
// Assuming journal_entry_screen.dart is in the same directory or imported correctly
import './journal_entry_screen.dart'; // Or your actual path

class JournalListScreen extends StatefulWidget {
  const JournalListScreen({super.key});

  @override
  State<JournalListScreen> createState() => _JournalListScreenState();
}

class _JournalListScreenState extends State<JournalListScreen> {
  final JournalService _journalService = JournalService();
  List<JournalEntry> _journalEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final entries = await _journalService.getJournalEntries();
      if (mounted) { // Check if the widget is still in the tree
        setState(() {
          _journalEntries = entries;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading entries: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _navigateToEntryScreen({JournalEntry? entry, int? index}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => JournalEntryScreen(journalEntry: entry),
      ),
    );

    if (result != null && result is JournalEntry) {
      try {
        await _journalService.saveJournalEntry(result);
        _loadEntries(); // Refresh the list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving entry: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteEntry(int index, JournalEntry entryToDelete) async {
    // Optimistically remove from UI
    final String entryId = entryToDelete.id!;
    setState(() {
      _journalEntries.removeAt(index);
    });

    try {
      await _journalService.deleteJournalEntry(entryId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${entryToDelete.title} deleted'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () async {
              // Add back to service and refresh
              try {
                await _journalService.saveJournalEntry(entryToDelete); // Re-save the entry
                _loadEntries(); // Refresh the list
              } catch (e) {
                 ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error undoing delete: ${e.toString()}')),
                );
              }
            },
          ),
        ),
      );
    } catch (e) {
      // If delete failed, reload to revert optimistic UI update
      _loadEntries();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting entry: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Journal'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _journalEntries.isEmpty
          ? const Center(
              child: Text(
                'No journal entries yet.\nTap the "+" button to add one!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _journalEntries.length,
              itemBuilder: (context, index) {
                final entry = _journalEntries[index];
                return Dismissible(
                  key: ValueKey(entry.id ?? entry.hashCode), // Unique key for Dismissible
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deleteEntry(index, entry);
                  },
                  background: Container(
                    color: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerRight,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: ListTile(
                      title: Text(entry.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        '${entry.date.toLocal().toString().split(' ')[0]}\n${entry.content.length > 100 ? '${entry.content.substring(0, 100)}...' : entry.content}',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      isThreeLine: true,
                      onTap: () => _navigateToEntryScreen(entry: entry, index: index),
                      trailing: const Icon(Icons.edit_note), // Optional: explicit edit icon
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEntryScreen(), // No entry and no index means new entry
        tooltip: 'Add New Entry',
        child: const Icon(Icons.add),
      ),
    );
  }
}