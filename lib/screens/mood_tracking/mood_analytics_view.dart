// lib/screens/mood_tracking/mood_analytics_view.dart
import 'package:flutter/material.dart';

class MoodAnalyticsView extends StatefulWidget {
  @override
  _MoodAnalyticsViewState createState() => _MoodAnalyticsViewState();
}

class _MoodAnalyticsViewState extends State<MoodAnalyticsView> {
  String _selectedPeriod = 'Week';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mood Analytics'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) => setState(() => _selectedPeriod = value),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'Week', child: Text('This Week')),
              PopupMenuItem(value: 'Month', child: Text('This Month')),
              PopupMenuItem(value: 'Year', child: Text('This Year')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSelector(),
            SizedBox(height: 16),
            _buildMoodDistribution(),
            SizedBox(height: 16),
            _buildMoodTrends(),
            SizedBox(height: 16),
            _buildTopTriggers(),
            SizedBox(height: 16),
            _buildInsights(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Viewing: $_selectedPeriod',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodDistribution() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildMoodBar('Happy', 0.6, Colors.green),
            _buildMoodBar('Neutral', 0.3, Colors.orange),
            _buildMoodBar('Sad', 0.1, Colors.red),
            _buildMoodBar('Anxious', 0.2, Colors.purple),
            _buildMoodBar('Excited', 0.4, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodBar(String mood, double percentage, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(mood),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          SizedBox(width: 8),
          Text('${(percentage * 100).toInt()}%'),
        ],
      ),
    );
  }

  Widget _buildMoodTrends() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood Trends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Mood Chart Placeholder\n(Line chart showing mood over time)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopTriggers() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Most Common Triggers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _buildTriggerItem('Work Stress', 15),
            _buildTriggerItem('Lack of Sleep', 12),
            _buildTriggerItem('Social Situations', 8),
            _buildTriggerItem('Weather', 6),
            _buildTriggerItem('Exercise', 10),
          ],
        ),
      ),
    );
  }

  Widget _buildTriggerItem(String trigger, int count) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(trigger),
          Chip(
            label: Text(count.toString()),
            backgroundColor: Colors.blue.shade100,
          ),
        ],
      ),
    );
  }

  Widget _buildInsights() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Insights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _buildInsightItem(
              Icons.trending_up,
              'Your mood has been improving over the past week!',
              Colors.green,
            ),
            _buildInsightItem(
              Icons.schedule,
              'You tend to feel better in the morning hours.',
              Colors.blue,
            ),
            _buildInsightItem(
              Icons.warning,
              'Work stress appears to be your main mood trigger.',
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(IconData icon, String text, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}