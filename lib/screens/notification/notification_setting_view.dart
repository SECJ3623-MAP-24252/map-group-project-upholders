// lib/screens/notification/notification_setting_view.dart
import 'package:flutter/material.dart';

import 'notification_setting_viewmodel.dart';

class NotificationSettingView extends StatefulWidget {
  @override
  _NotificationSettingViewState createState() => _NotificationSettingViewState();
}

class _NotificationSettingViewState extends State<NotificationSettingView> {
  final NotificationSettingViewModel _viewModel = NotificationSettingViewModel();
  
  bool _dailyReminders = true;
  bool _moodCheckIns = true;
  bool _weeklyReports = false;
  bool _motivationalQuotes = true;
  TimeOfDay _reminderTime = TimeOfDay(hour: 20, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notification Settings')),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Reminders',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  SwitchListTile(
                    title: Text('Enable Daily Mood Check-ins'),
                    subtitle: Text('Get reminded to log your mood daily'),
                    value: _dailyReminders,
                    onChanged: (value) => setState(() => _dailyReminders = value),
                  ),
                  if (_dailyReminders) ...[
                    ListTile(
                      title: Text('Reminder Time'),
                      subtitle: Text(_reminderTime.format(context)),
                      trailing: Icon(Icons.access_time),
                      onTap: _selectTime,
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mood Tracking',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  SwitchListTile(
                    title: Text('Mood Check-in Reminders'),
                    subtitle: Text('Remind me to track my mood'),
                    value: _moodCheckIns,
                    onChanged: (value) => setState(() => _moodCheckIns = value),
                  ),
                  SwitchListTile(
                    title: Text('Weekly Progress Reports'),
                    subtitle: Text('Get weekly mood analysis'),
                    value: _weeklyReports,
                    onChanged: (value) => setState(() => _weeklyReports = value),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wellness Content',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  SwitchListTile(
                    title: Text('Motivational Quotes'),
                    subtitle: Text('Receive daily inspiration'),
                    value: _motivationalQuotes,
                    onChanged: (value) => setState(() => _motivationalQuotes = value),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saveSettings,
            child: Text('Save Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null && picked != _reminderTime) {
      setState(() => _reminderTime = picked);
    }
  }

  void _saveSettings() {
    _viewModel.saveSettings(
      dailyReminders: _dailyReminders,
      moodCheckIns: _moodCheckIns,
      weeklyReports: _weeklyReports,
      motivationalQuotes: _motivationalQuotes,
      reminderTime: _reminderTime,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Settings saved successfully!')),
    );
  }
}
