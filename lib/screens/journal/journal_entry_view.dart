// lib/screens/journal/journal_entry_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'journal_entry_viewmodel.dart';

class JournalEntryView extends StatefulWidget {
  @override
  _JournalEntryViewState createState() => _JournalEntryViewState();
}

class _JournalEntryViewState extends State<JournalEntryView> {
  // ViewModel will be provided

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final entry = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    // Initialize ViewModel here, only once
    Provider.of<JournalEntryViewModel>(context, listen: false).initializeEntry(entry);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<JournalEntryViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.isEditing ? 'Edit Entry' : 'New Entry'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveEntry,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: viewModel.titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text('How are you feeling?'),
            SizedBox(height: 8),
            _buildMoodSelector(),
            SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: viewModel.contentController,
                decoration: InputDecoration(
                  labelText: 'Write your thoughts...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: viewModel.isLoading ? null : _saveEntry,
                child: viewModel.isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(viewModel.isEditing ? 'Update Entry' : 'Save Entry'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSelector() {
    final viewModel = Provider.of<JournalEntryViewModel>(context, listen: false); // No need to rebuild for this
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildMoodOption(viewModel, 'happy', Icons.sentiment_very_satisfied, Colors.green),
        _buildMoodOption(viewModel, 'neutral', Icons.sentiment_neutral, Colors.orange),
        _buildMoodOption(viewModel, 'sad', Icons.sentiment_very_dissatisfied, Colors.red),
      ],
    );
  }

  Widget _buildMoodOption(JournalEntryViewModel viewModel, String mood, IconData icon, Color color) {
    final isSelected = viewModel.selectedMood == mood;
    return GestureDetector(
      onTap: () => viewModel.selectMood(mood),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 4),
            Text(mood.toUpperCase()),
          ],
        ),
      ),
    );
  }

  void _saveEntry() async {
    final viewModel = Provider.of<JournalEntryViewModel>(context, listen: false);
    final success = await viewModel.saveEntry();
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Entry saved successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }
}