// lib/screens/dashboard/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider

import 'dashboard_viewmodel.dart';

class DashboardView extends StatefulWidget {
  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  // ViewModel will be provided

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DashboardViewModel>(context);

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
            _buildWelcomeCard(viewModel.userName),
            SizedBox(height: 16),
            _buildQuickActions(),
            SizedBox(height: 16),
            _buildMoodSummary(viewModel),
            SizedBox(height: 16),
            _buildRecentEntries(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildWelcomeCard(String userName) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello $userName! How are you feeling today?',
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

  Widget _buildMoodSummary(DashboardViewModel viewModel) {
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
                _buildMoodIndicator('Happy', Colors.green, viewModel.happyCount),
                _buildMoodIndicator('Neutral', Colors.orange, viewModel.neutralCount),
                _buildMoodIndicator('Sad', Colors.red, viewModel.sadCount),
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

  Widget _buildRecentEntries() { // Assuming viewModel.recentEntries is available
    final viewModel = Provider.of<DashboardViewModel>(context, listen: false); // Or pass viewModel as param
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
            ...viewModel.recentEntries.map((entry) => ListTile(
              leading: Icon(entry['icon'], color: entry['color']),
              title: Text(entry['title']),
              subtitle: Text(entry['subtitle']),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final viewModel = Provider.of<DashboardViewModel>(context);
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: viewModel.currentIndex,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.mood), label: 'Mood'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Journal'),
        BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
      ],
      onTap: (index) {
        switch (index) {
          case 0: // Dashboard is current view, handle if needed or do nothing
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
        viewModel.onNavigationTapped(index); // Update ViewModel's current index
      },
    );
  }
}