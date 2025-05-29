// lib/screens/mood_tracking/mood_tracking_view.dart
import 'package:flutter/material.dart';

import 'mood_tracking_viewmodel.dart';

class MoodTrackingView extends StatefulWidget {
  @override
  _MoodTrackingViewState createState() => _MoodTrackingViewState();
}

class _MoodTrackingViewState extends State<MoodTrackingView> {
  final MoodTrackingViewModel _viewModel = MoodTrackingViewModel();
  String? _selectedMood;
  int _moodIntensity = 5;
  List<String> _selectedTriggers = [];
  final _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Track Your Mood')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMoodSelection(),
            SizedBox(height: 24),
            _buildIntensitySlider(),
            SizedBox(height: 24),
            _buildTriggerSelection(),
            SizedBox(height: 24),
            _buildNotesSection(),
            SizedBox(height: 24),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSelection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How are you feeling right now?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _viewModel.moodOptions.map((mood) {
                final isSelected = _selectedMood == mood['name'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedMood = mood['name']),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? mood['color'].withOpacity(0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? mood['color'] : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          mood['icon'],
                          color: mood['color'],
                          size: 40,
                        ),
                        SizedBox(height: 8),
                        Text(
                          mood['name'],
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntensitySlider() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Intensity Level: $_moodIntensity/10',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Slider(
              value: _moodIntensity.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: _moodIntensity.toString(),
              onChanged: (value) => setState(() => _moodIntensity = value.round()),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Low', style: TextStyle(color: Colors.grey)),
                Text('High', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTriggerSelection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What triggered this mood?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _viewModel.triggerOptions.map((trigger) {
                final isSelected = _selectedTriggers.contains(trigger);
                return FilterChip(
                  label: Text(trigger),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTriggers.add(trigger);
                      } else {
                        _selectedTriggers.remove(trigger);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Notes (Optional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'Add any additional thoughts or context...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _selectedMood != null ? _saveMoodEntry : null,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          'Save Mood Entry',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  void _saveMoodEntry() {
    _viewModel.saveMoodEntry(
      mood: _selectedMood!,
      intensity: _moodIntensity,
      triggers: _selectedTriggers,
      notes: _notesController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mood entry saved successfully!')),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}