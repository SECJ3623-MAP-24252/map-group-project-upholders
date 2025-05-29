// lib/screens/dashboard/dashboard_psychiatrist_view.dart
import 'package:flutter/material.dart';

class DashboardPsychiatristView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Psychiatrist Dashboard')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Patient Overview',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Total Patients: 25'),
                    Text('Active This Week: 18'),
                    Text('Requiring Attention: 3'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Recent Patient Activity',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          ListTile(
                            leading: CircleAvatar(child: Text('JD')),
                            title: Text('John Doe'),
                            subtitle: Text('Last entry: 2 hours ago'),
                            trailing: Icon(Icons.warning, color: Colors.orange),
                          ),
                          ListTile(
                            leading: CircleAvatar(child: Text('JS')),
                            title: Text('Jane Smith'),
                            subtitle: Text('Last entry: 1 day ago'),
                            trailing: Icon(Icons.check, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}