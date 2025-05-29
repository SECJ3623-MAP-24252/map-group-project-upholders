import 'package:flutter/material.dart';

import '../widgets/app_drawer.dart';

class JournalReminderPage extends StatelessWidget {
  const JournalReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Reminder', style: TextStyle(color: Colors.brown)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.brown),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.brown),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const AppDrawer(currentRoute: '/mood-scale-viewer'),
      body: const Center(
        child: Text(
          'Daily Journal Reminder feature coming soon!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

}
