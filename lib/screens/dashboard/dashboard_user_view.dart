// lib/screens/dashboard/dashboard_user_view.dart
import 'package:flutter/material.dart';

class DashboardUserView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Dashboard')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text('John Doe'),
                subtitle: Text('john.doe@example.com'),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                    onTap: () => Navigator.pushNamed(context, '/notification_setting'),
                  ),
                  ListTile(
                    leading: Icon(Icons.analytics),
                    title: Text('My Statistics'),
                    onTap: () => Navigator.pushNamed(context, '/mood_analytics'),
                  ),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Logout'),
                    onTap: () {
                      // Handle logout
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}