// lib/screens/mood_tracking/mood_analytics_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'mood_analytics_viewmodel.dart';

class MoodAnalyticsView extends StatefulWidget {
  @override
  _MoodAnalyticsViewState createState() => _MoodAnalyticsViewState();
}

class _MoodAnalyticsViewState extends State<MoodAnalyticsView> {
  // ViewModel will be provided

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MoodAnalyticsViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Mood Analytics'),
        actions: [
          PopupMenuButton<String>(
            initialValue: viewModel.selectedPeriod,
            onSelected: (value) => viewModel.selectPeriod(value),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'Week', child: Text('This Week')),
              PopupMenuItem(value: 'Month', child: Text('This Month')),
              PopupMenuItem(value: 'Year', child: Text('This Year')),
            ],
            tooltip: "Select Period",
          ),
        ],
      ),
      body: viewModel.isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodSelector(viewModel.selectedPeriod),
                  SizedBox(height: 16),
                  _buildMoodDistribution(viewModel.moodDistribution),
                  SizedBox(height: 16),
                  _buildMoodTrends(viewModel.moodTrends),
                  SizedBox(height: 16),
                  _buildTopTriggers(viewModel.topTriggers),
                  SizedBox(height: 16),
                  _buildInsights(viewModel.insights),
                ],
              ),
            ),
    );
  }

  Widget _buildPeriodSelector(String selectedPeriod) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Viewing: $selectedPeriod',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodDistribution(Map<String, double> moodDistribution) {
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
            if (moodDistribution.isEmpty) Text("No distribution data available."),
            ...moodDistribution.entries.map((entry) =>
                _buildMoodBar(entry.key, entry.value, _getColorForMood(entry.key))),
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

  Color _getColorForMood(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy': return Colors.green;
      case 'neutral': return Colors.orange;
      case 'sad': return Colors.red;
      case 'anxious': return Colors.purple;
      case 'excited': return Colors.blue;
      default: return Colors.grey;
    }
  }

  Widget _buildMoodTrends(List<Map<String, dynamic>> moodTrends) {
    // In a real app, you'd use a charting library like 'fl_chart' here
    // to display the moodTrends data.
    // For this example, we'll keep the placeholder.

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

  Widget _buildTopTriggers(List<Map<String, dynamic>> topTriggers) {
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
            if (topTriggers.isEmpty) Text("No trigger data available."),
            ...topTriggers.map((triggerData) =>
                _buildTriggerItem(triggerData['trigger'], triggerData['count'])),
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

  Widget _buildInsights(List<Map<String, dynamic>> insights) {
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
            if (insights.isEmpty) Text("No insights available yet."),
            ...insights.map((insight) =>
                _buildInsightItem(insight['icon'], insight['text'], insight['color'])),
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