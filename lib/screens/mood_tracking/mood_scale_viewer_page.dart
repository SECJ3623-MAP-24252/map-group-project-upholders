import 'dart:math';

import 'package:flutter/material.dart';

import '../../widgets/app_drawer.dart'; // Adjust path as needed

class MoodScaleViewerPage extends StatelessWidget {
  const MoodScaleViewerPage({super.key});

  List<Map<String, dynamic>> get _dummyData => [
    {
      "date": DateTime.now().subtract(const Duration(days: 6)),
      "score": 4,
      "emoji": "😀",
    },
    {
      "date": DateTime.now().subtract(const Duration(days: 5)),
      "score": 2,
      "emoji": "😞",
    },
    {
      "date": DateTime.now().subtract(const Duration(days: 4)),
      "score": 5,
      "emoji": "😊",
    },
    {
      "date": DateTime.now().subtract(const Duration(days: 3)),
      "score": 3,
      "emoji": "😐",
    },
    {
      "date": DateTime.now().subtract(const Duration(days: 2)),
      "score": 1,
      "emoji": "😡",
    },
    {
      "date": DateTime.now().subtract(const Duration(days: 1)),
      "score": 4,
      "emoji": "😀",
    },
    {"date": DateTime.now(), "score": 5, "emoji": "😊"},
  ];

  @override
  Widget build(BuildContext context) {
    final data = _dummyData;
    final maxScore = 5;
    final moodLabels = [
      {"label": "Angry", "emoji": "😡", "color": Colors.red[200]},
      {"label": "Sad", "emoji": "😞", "color": Colors.orange[200]},
      {"label": "Neutral", "emoji": "😐", "color": Colors.grey[400]},
      {"label": "Happy", "emoji": "😀", "color": Colors.lightGreen[300]},
      {"label": "Very Happy", "emoji": "😊", "color": Colors.blue[200]},
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Mood Scale Viewer',
          style: TextStyle(color: Colors.brown),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.brown),
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.brown),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
      ),
      drawer: const AppDrawer(currentRoute: '/mood-scale-viewer'),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFAF3E3), Color(0xFFE2F8C2), Color(0xFFD6E4FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 110, 22, 22),
          children: [
            _MoodSummaryCard(data: data),
            const SizedBox(height: 28),
            _MoodLegend(moodLabels: moodLabels), // <--- fixed with Wrap
            const SizedBox(height: 20),
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.white.withOpacity(0.94),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.show_chart, color: Colors.brown, size: 28),
                        SizedBox(width: 8),
                        Text(
                          "Your Mood Scale (7 days)",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.brown,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _AnimatedMoodBarChart(
                      data: data,
                      maxScore: maxScore,
                    ), // <--- fixed
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              "History",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.brown[600],
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 8),
            ...data.reversed.map(
              (e) => Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[100],
                    child: Text(
                      e['emoji'],
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  title: Text("Mood Scale: ${e['score']}/5"),
                  subtitle: Text(
                    "Date: ${_dateString(e['date'])}",
                    style: TextStyle(fontSize: 13, color: Colors.brown[300]),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  String _dateString(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
}

// --- Mood Summary Card ---
class _MoodSummaryCard extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const _MoodSummaryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final double avg =
        data.isEmpty
            ? 0
            : data
                    .map<double>((e) => e['score']!.toDouble())
                    .reduce((a, b) => a + b) /
                data.length;
    final highest =
        data.isNotEmpty
            ? data.reduce((a, b) => a['score'] > b['score'] ? a : b)
            : null;
    final lowest =
        data.isNotEmpty
            ? data.reduce((a, b) => a['score'] < b['score'] ? a : b)
            : null;

    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: const Color(0xFFECF7E6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 26),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.insights, color: Color(0xFFA7B77A), size: 28),
                const SizedBox(width: 10),
                Text(
                  "Weekly Mood Summary",
                  style: TextStyle(
                    color: Colors.brown[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _summaryItem(
                  "Avg",
                  avg.toStringAsFixed(1),
                  Icons.emoji_emotions,
                ),
                _summaryItem(
                  "Highest",
                  highest != null ? highest['score'].toString() : "-",
                  Icons.trending_up,
                ),
                _summaryItem(
                  "Lowest",
                  lowest != null ? lowest['score'].toString() : "-",
                  Icons.trending_down,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String value, IconData icon) => Column(
    children: [
      Icon(icon, color: Colors.brown[400], size: 32),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.brown[800],
        ),
      ),
      Text(label, style: const TextStyle(color: Colors.brown, fontSize: 14)),
    ],
  );
}

// --- Mood Legend ---
class _MoodLegend extends StatelessWidget {
  final List<Map<String, dynamic>> moodLabels;
  const _MoodLegend({required this.moodLabels});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 18,
        runSpacing: 10,
        children:
            moodLabels
                .map(
                  (m) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        backgroundColor: m['color'],
                        radius: 18,
                        child: Text(
                          m['emoji'],
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        m['label'],
                        style: TextStyle(
                          color: Colors.brown[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
      ),
    );
  }
}

// --- Animated Mood Bar Chart ---
class _AnimatedMoodBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final int maxScore;

  const _AnimatedMoodBarChart({required this.data, required this.maxScore});

  @override
  Widget build(BuildContext context) {
    const double maxBarHeight = 90;
    return SizedBox(
      height: maxBarHeight + 32,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children:
            data.map((e) {
              final barHeight = (e['score'] / maxScore) * maxBarHeight;
              final color = _moodColor(e['score']);
              return Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: Duration(
                          milliseconds: 800 + Random().nextInt(300),
                        ),
                        curve: Curves.easeInOutCubic,
                        height: barHeight,
                        constraints: const BoxConstraints(
                          maxHeight: maxBarHeight,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.22),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            e['emoji'],
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        "${e['date'].month}/${e['date'].day}",
                        style: TextStyle(
                          color: Colors.brown[300],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Color _moodColor(int score) {
    switch (score) {
      case 1:
        return Colors.red[200]!;
      case 2:
        return Colors.orange[200]!;
      case 3:
        return Colors.grey[400]!;
      case 4:
        return Colors.lightGreen[300]!;
      case 5:
        return Colors.blue[200]!;
      default:
        return Colors.grey;
    }
  }
}
