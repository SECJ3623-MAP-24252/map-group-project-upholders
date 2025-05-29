// lib/screens/mood_tracking/mood_history_view.dart
import 'package:flutter/material.dart';

class MoodHistoryView extends StatefulWidget {
  @override
  _MoodHistoryViewState createState() => _MoodHistoryViewState();
}

class _MoodHistoryViewState extends State<MoodHistoryView> {
  final List<Map<String, dynamic>> _moodHistory = [
    {
      'date': '2024-01-15 14:30',
      'mood': 'Happy',
      'intensity': 8,
      'triggers': ['Exercise', 'Good Weather'],
      'notes': 'Had a great workout session today!'
    },
    {
      'date': '2024-01-14 09:15',
      'mood': 'Anxious',
      'intensity': 6,
      'triggers': ['Work Stress', 'Deadline'],
      'notes': 'Feeling overwhelmed with project deadlines.'
    },
    {
      'date': '2024-01-13 18:45',
      'mood': 'Neutral',
      'intensity': 5,
      'triggers': ['Regular Day'],
      'notes': 'Nothing special happened today.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mood History')),
      body: ListView.builder(
        padding: EdgeInsets.all(8.0),
        itemCount: _moodHistory.length,
        itemBuilder: (context, index) {
          final entry = _moodHistory[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 4.0),
            child: ExpansionTile(
              leading: _getMoodIcon(entry['mood']),
              title: Text(
                entry['mood'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(entry['date']),
              trailing: Text('${entry['intensity']}/10'),
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (entry['triggers'].isNotEmpty) ...[
                        Text(
                          'Triggers:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          children: entry['triggers'].map<Widget>((trigger) {
                            return Chip(
                              label: Text(trigger),
                              backgroundColor: Colors.grey.shade200,
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 8),
                      ],
                      if (entry['notes'].isNotEmpty) ...[
                        Text(
                          'Notes:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(entry['notes']),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _getMoodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Icon(Icons.sentiment_very_satisfied, color: Colors.green);
      case 'sad':
        return Icon(Icons.sentiment_very_dissatisfied, color: Colors.red);
      case 'anxious':
        return Icon(Icons.sentiment_dissatisfied, color: Colors.purple);
      case 'excited':
        return Icon(Icons.sentiment_very_satisfied, color: Colors.blue);
      case 'neutral':
      default:
        return Icon(Icons.sentiment_neutral, color: Colors.orange);
    }
  }