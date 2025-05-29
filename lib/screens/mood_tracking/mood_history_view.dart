// lib/screens/mood_tracking/mood_history_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'mood_history_viewmodel.dart';

class MoodHistoryView extends StatefulWidget {
  @override
  _MoodHistoryViewState createState() => _MoodHistoryViewState();
}

class _MoodHistoryViewState extends State<MoodHistoryView> {
  // ViewModel will be provided

  @override
  void initState() {
    super.initState();
    Provider.of<MoodHistoryViewModel>(context, listen: false).fetchMoodHistory();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MoodHistoryViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Mood History')),
      body: viewModel.isLoading
          ? Center(child: CircularProgressIndicator())
          : viewModel.moodHistory.isEmpty
              ? Center(child: Text('No mood history yet.'))
              : ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  itemCount: viewModel.moodHistory.length,
                  itemBuilder: (context, index) {
                    final entry = viewModel.moodHistory[index];
                    final String mood = entry['mood'] as String? ?? 'Neutral';
                    final String date = entry['date'] as String? ?? 'No date';
                    final int intensity = entry['intensity'] as int? ?? 0;
                    final List<String> triggers = (entry['triggers'] as List<dynamic>?)?.map((t) => t.toString()).toList() ?? [];
                    final String notes = entry['notes'] as String? ?? '';

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 4.0),
                      child: ExpansionTile(
                        leading: _getMoodIcon(mood),
                        title: Text(
                          mood,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(date),
                        trailing: Text('$intensity/10'),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (triggers.isNotEmpty) ...[
                                  Text(
                                    'Triggers:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 4),
                                  Wrap(
                                    spacing: 4,
                                    children: triggers.map<Widget>((trigger) {
                                      return Chip(
                                        label: Text(trigger),
                                        backgroundColor: Colors.grey.shade200,
                                      );
                                    }).toList(),
                                  ),
                                  SizedBox(height: 8),
                                ],
                                if (notes.isNotEmpty) ...[
                                  Text(
                                    'Notes:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 4),
                                  Text(notes),
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

  Widget _getMoodIcon(String? mood) {
    switch (mood?.toLowerCase()) {
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
}