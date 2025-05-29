import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationSettingScreen extends StatefulWidget {
  const NotificationSettingScreen({super.key});

  @override
  State<NotificationSettingScreen> createState() => _NotificationSettingScreenState();
}

class _NotificationSettingScreenState extends State<NotificationSettingScreen> {
  bool _dailyRemindersEnabled = true;
  bool _insightNotificationsEnabled = true;
  bool _moodTrendAlertsEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0); // Default to 8 PM

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    // Load saved preferences here in a real app
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      // Add iOS initialization if needed
    );
    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
      // In a real app, you would save this preference and schedule the notification
    }
  }

  Future<void> _scheduleDailyReminder() async {
    if (!_dailyRemindersEnabled) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminders',
      channelDescription: 'Notifications for daily mood logging',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.zonedSchedule(
      0,
      'How are you feeling today?',
      'Take a moment to log your mood and reflect on your day.',
      _nextInstanceOfTime(_reminderTime),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF9C27B0), Color(0xFF3F51B5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notification Preferences',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Daily Reminders Card
                _buildNotificationCard(
                  title: 'Daily Mood Logging Reminders',
                  subtitle: 'Get reminded to log your mood each day',
                  value: _dailyRemindersEnabled,
                  onChanged: (value) {
                    setState(() {
                      _dailyRemindersEnabled = value!;
                      if (value) {
                        _scheduleDailyReminder();
                      } else {
                        _notificationsPlugin.cancel(0);
                      }
                    });
                  },
                  trailing: TextButton(
                    onPressed: () => _selectTime(context),
                    child: Text(
                      _reminderTime.format(context),
                      style: const TextStyle(color: Colors.deepPurple),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Insights Notifications Card
                _buildNotificationCard(
                  title: 'Weekly Insights',
                  subtitle: 'Receive weekly summaries of your mood patterns',
                  value: _insightNotificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _insightNotificationsEnabled = value!;
                    });
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Mood Trend Alerts Card
                _buildNotificationCard(
                  title: 'Mood Trend Alerts',
                  subtitle: 'Get notified when we detect significant changes in your mood patterns',
                  value: _moodTrendAlertsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _moodTrendAlertsEnabled = value!;
                    });
                  },
                ),
                
                const SizedBox(height: 30),
                
                // Save Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Save preferences and schedule notifications
                      _scheduleDailyReminder();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notification preferences saved'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple,
                      minimumSize: const Size(200, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6,
                    ),
                    child: const Text(
                      'Save Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
    Widget? trailing,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.deepPurple,
            ),
          ],
        ),
      ),
    );
  }
}
