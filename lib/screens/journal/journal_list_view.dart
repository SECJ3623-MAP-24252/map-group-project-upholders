// lib/screens/journal/journal_list_view.dart
import 'package:flutter/material.dart';

import 'journal_list_viewmodel.dart';

class JournalListView extends StatefulWidget {
  @override
  _JournalListViewState createState() => _JournalListViewState();
}

class _JournalListViewState extends State<JournalListView> {
  final JournalListViewModel _viewModel = JournalListViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Journal Entries'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implement search
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(8.0),
        itemCount: _viewModel.journalEntries.length,
        itemBuilder: (context, index) {
          final entry = _viewModel.journalEntries[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 4.0),
            child: ListTile(
              leading: _buildMoodIcon(entry['mood']),
              title: Text(
                entry['title'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry['content'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    entry['date'],
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Text('Edit'),
                    value: 'edit',
                  ),
                  PopupMenuItem(
                    child: Text('Delete'),
                    value: 'delete',
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.pushNamed(context, '/journal_entry', arguments: entry);
                  } else if (value == 'delete') {
                    _showDeleteDialog(context, entry);
                  }
                },
              ),
              onTap: () => Navigator.pushNamed(context, '/journal_entry', arguments: entry),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/journal_entry'),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildMoodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Icon(Icons.sentiment_very_satisfied, color: Colors.green);
      case 'sad':
        return Icon(Icons.sentiment_very_dissatisfied, color: Colors.red);
      case 'neutral':
        return Icon(Icons.sentiment_neutral, color: Colors.orange);
      default:
        return Icon(Icons.sentiment_neutral, color: Colors.grey);
    }
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Entry'),
        content: Text('Are you sure you want to delete this journal entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _viewModel.deleteEntry(entry['id']);
              Navigator.pop(context);
              setState(() {});
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}