// lib/screens/dashboard/dashboard_view.dart
import 'package:flutter/material.dart';

import 'dashboard_viewmodel.dart';

class DashboardView extends StatefulWidget {
  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final DashboardViewModel _viewModel = DashboardViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mood Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/user'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            SizedBox(height: 16),
            _buildQuickActions(),
            SizedBox(height: 16),
            _buildMoodSummary(),
            SizedBox(height: 16),
            _buildRecentEntries(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello! How are you feeling today?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Track your mood and discover patterns'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          'Log Mood',
          Icons.mood,
          () => Navigator.pushNamed(context, '/mood_tracking'),
        ),
        _buildActionButton(
          'Journal',
          Icons.book,
          () => Navigator.pushNamed(context, '/journal'),
        ),
        _buildActionButton(
          'Analytics',
          Icons.analytics,
          () => Navigator.pushNamed(context, '/mood_analytics'),
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(icon, size: 32),
                SizedBox(height: 8),
                Text(title),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodSummary() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Week\'s Overview',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMoodIndicator('Happy', Colors.green, 5),
                _buildMoodIndicator('Neutral', Colors.orange, 2),
                _buildMoodIndicator('Sad', Colors.red, 0),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodIndicator(String mood, Color color, int count) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color,
          child: Text(
            count.toString(),
            style: TextStyle(color: Colors.white),
          ),
        ),
        SizedBox(height: 4),
        Text(mood),
      ],
    );
  }

  Widget _buildRecentEntries() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Entries',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.mood, color: Colors.green),
              title: Text('Great day!'),
              subtitle: Text('Today, 2:30 PM'),
            ),
            ListTile(
              leading: Icon(Icons.mood_bad, color: Colors.orange),
              title: Text('Feeling stressed'),
              subtitle: Text('Yesterday, 6:15 PM'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.mood), label: 'Mood'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Journal'),
        BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
      ],
      onTap: (index) {
        switch (index) {
          case 1:
            Navigator.pushNamed(context, '/mood_tracking');
            break;
          case 2:
            Navigator.pushNamed(context, '/journal');
            break;
          case 3:
            Navigator.pushNamed(context, '/mood_analytics');
            break;
        }
      },
    );
  }
}