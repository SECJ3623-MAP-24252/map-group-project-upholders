import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;
  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFA7B77A)),
              child: Text(
                'Mood Tracker',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _drawerItem(
              context,
              Icons.home,
              'Home',
              "Add & see mood history",
              '/dashboard-user',
            ),
            // _drawerItem(context, Icons.show_chart, 'Mood Scale Viewer', "Analyze mood scale history", '/mood-scale-viewer'),
            // _drawerItem(context, Icons.mic, 'Voice Journal', "Record and save voice-based journal entries", '/voice-journal'),
            _drawerItem(
              context,
              Icons.auto_graph,
              'Mood Chart',
              "See your mood stats",
              '/mood-chart',
            ),
            _drawerItem(
              context,
              Icons.notifications,
              'Journal Reminder',
              "Set up daily reminders",
              '/journal-reminder',
            ),

            // _drawerItem(context, Icons.transcribe, 'Voice-to-Text', "Transcribe your journal", null),

            // _drawerItem(context, Icons.settings, 'Settings', "App settings", null),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    String? route,
  ) {
    final bool selected = ModalRoute.of(context)?.settings.name == route;
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? Colors.deepOrange : Colors.brown[400],
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      selected: selected,
      selectedTileColor: const Color(0xFFFFF3E0),
      onTap: () {
        Navigator.pop(context);
        if (route != null) {
          if (ModalRoute.of(context)?.settings.name != route) {
            Navigator.pushReplacementNamed(context, route);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title coming soon!'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
    );
  }
}
