import 'package:flutter/material.dart';

import '../../model/journal_model.dart';
import '../../services/journal/journal_service.dart';

class JournalEntryScreen extends StatefulWidget {
  final JournalEntry? journalEntry; // Pass an entry to edit, or null for a new one

  const JournalEntryScreen({super.key, this.journalEntry});

  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late DateTime _selectedDate;
  String? _summary;
  bool _isLoadingSummary = false;
  final JournalService _journalService = JournalService();

  bool get _isEditing => widget.journalEntry != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      // Editing an existing entry
      _titleController = TextEditingController(text: widget.journalEntry!.title);
      _contentController = TextEditingController(text: widget.journalEntry!.content);
      _selectedDate = widget.journalEntry!.date;
      _summary = widget.journalEntry!.summary;
    } else {
      // Creating a new entry
      _titleController = TextEditingController();
      _contentController = TextEditingController();
      _selectedDate = DateTime.now();
      _summary = null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, proceed with saving
      final entryToSave = JournalEntry(
        id: widget.journalEntry?.id, // Preserve ID if editing
        title: _titleController.text,
        content: _contentController.text,
        date: _selectedDate,
        summary: _summary, // Save the summary
      );

      // In a real app, you'd save this to a database or state management solution.
      // For this example, we'll pop the screen and return the saved/updated entry.
      Navigator.of(context).pop(entryToSave);
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000), // Arbitrary start date
      lastDate: DateTime(2101), // Arbitrary end date
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _generateSummary() async {
    setState(() {
      _isLoadingSummary = true;
    });
    final summary = await _journalService.generateSummary(_contentController.text);
    setState(() {
      _summary = summary;
      _isLoadingSummary = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Journal Entry' : 'New Journal Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveEntry,
            tooltip: 'Save Entry',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView( // Use ListView to prevent overflow with soft keyboard
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  hintText: 'Enter the title of your entry',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                  hintText: 'Write your journal thoughts here...',
                  alignLabelWithHint: true, // Good for multiline fields
                ),
                maxLines: 10,
                minLines: 5,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              if (_summary != null)
                Card(
                  color: Colors.blue[50],
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'AI Summary:\n$_summary',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
              ElevatedButton.icon(
                icon: _isLoadingSummary
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: const Text('Generate AI Summary'),
                onPressed: _isLoadingSummary ? null : _generateSummary,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save Entry'),
                onPressed: _saveEntry,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}