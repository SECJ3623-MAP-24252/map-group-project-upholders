import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart'; // Adjust path as needed

class MoodScaleViewerPage extends StatelessWidget {
  const MoodScaleViewerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Scale Viewer', style: TextStyle(color: Colors.brown)),
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
          'Mood Scale Viewer feature coming soon!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
