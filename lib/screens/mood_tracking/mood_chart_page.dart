import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:map_upholders/widgets/app_drawer.dart';

class MoodChartPage extends StatelessWidget {
  const MoodChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF3E3),
      appBar: AppBar(
        title: const Text("Mood Fluctuation Chart"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: const _MoodChartBody(),
      drawer: AppDrawer(currentRoute: "/mood-chart"),
    );
  }
}

class _MoodChartBody extends StatelessWidget {
  const _MoodChartBody();

  // Dummy mood data (0=sad, 10=super happy)
  List<double> get moodPoints => [4, 6, 5, 8, 3, 9, 7, 5, 6, 8, 6, 10, 7, 5, 4];

  List<String> get dateLabels => [
    "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26"
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: _AnimatedHeadline(),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
            child: _MoodCard(
              child: _buildChart(context),
            ),
          ),
        ),
        const _MotivationalBanner(),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildChart(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 10,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                );
              },
              interval: 2,
              reservedSize: 30,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              getTitlesWidget: (value, _) {
                int idx = value.toInt();
                if (idx < 0 || idx >= dateLabels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    dateLabels[idx],
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          horizontalInterval: 2,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white24,
            strokeWidth: 1,
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              moodPoints.length,
                  (index) => FlSpot(index.toDouble(), moodPoints[index]),
            ),
            isCurved: true,
            color: const Color(0xFF9D4EDD),
            barWidth: 4,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  // Replacing withOpacity with fromRGBO for future-proofing
                  const Color.fromRGBO(157, 78, 221, 0.35),
                  const Color.fromRGBO(34, 34, 59, 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        borderData: FlBorderData(show: false),
      ),
      // Remove swapAnimationDuration and swapAnimationCurve
    );
  }

}

class _MoodCard extends StatelessWidget {
  final Widget child;
  const _MoodCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFAF3E3), Color(0xFFFAF3E3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.23),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: child,
    );
  }
}

class _AnimatedHeadline extends StatefulWidget {
  const _AnimatedHeadline();

  @override
  State<_AnimatedHeadline> createState() => _AnimatedHeadlineState();
}

class _AnimatedHeadlineState extends State<_AnimatedHeadline>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Mood Trends",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "See how your emotions have fluctuated over the last 2 weeks.",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _MotivationalBanner extends StatelessWidget {
  const _MotivationalBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_emotions, color: Colors.yellow, size: 28),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                "No matter how you feel, remember: every emotion is valid. Track your journey and celebrate your progress!",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
