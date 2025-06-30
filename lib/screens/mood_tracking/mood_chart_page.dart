// lib/screens/mood_tracking/mood_chart_page.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../viewmodels/mood_viewmodel.dart';
import '../../widgets/app_drawer.dart';

enum _ChartRange { week, month, year }

class MoodChartPage extends StatelessWidget {
  const MoodChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _ChartRange.values.length,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF3E3),
        appBar: AppBar(
          title: const Text("Mood Trends"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          foregroundColor: Colors.brown,
          bottom: TabBar(
            labelColor: Colors.brown,
            unselectedLabelColor: Colors.brown.shade300,
            indicatorColor: Colors.brown[300],
            tabs: const [
              Tab(text: "Week"),
              Tab(text: "Month"),
              Tab(text: "Year"),
            ],
          ),
        ),
        drawer: const AppDrawer(currentRoute: "/mood-chart"),
        body: TabBarView(
          children:
              _ChartRange.values.map((range) {
                return _MoodChartRange(range: range);
              }).toList(),
        ),
      ),
    );
  }
}

class _MoodChartRange extends StatelessWidget {
  final _ChartRange range;
  const _MoodChartRange({required this.range});

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodViewModel>(
      builder: (_, vm, __) {
        final now = DateTime.now();
        final all = vm.moods;

        // 1) Build buckets & labels
        late List<DateTime> buckets;
        late List<String> labels;
        switch (range) {
          case _ChartRange.week:
            buckets = List.generate(
              7,
              (i) => DateTime(
                now.year,
                now.month,
                now.day,
              ).subtract(Duration(days: 6 - i)),
            );
            labels = buckets.map((d) => d.day.toString()).toList();
            break;
          case _ChartRange.month:
            buckets = List.generate(
              30,
              (i) => DateTime(
                now.year,
                now.month,
                now.day,
              ).subtract(Duration(days: 29 - i)),
            );
            labels = List.generate(30, (i) {
              final d = buckets[i];
              return (i % 5 == 0) ? d.day.toString() : "";
            });
            break;
          case _ChartRange.year:
            buckets = List.generate(12, (i) {
              final m = now.month - 11 + i;
              final y = now.year + (m <= 0 ? -1 : 0);
              final mm = (m - 1) % 12 + 1;
              return DateTime(y, mm, 1);
            });
            labels =
                buckets
                    .map(
                      (d) =>
                          [
                            "Jan",
                            "Feb",
                            "Mar",
                            "Apr",
                            "May",
                            "Jun",
                            "Jul",
                            "Aug",
                            "Sep",
                            "Oct",
                            "Nov",
                            "Dec",
                          ][d.month - 1],
                    )
                    .toList();
            break;
        }

        // 2) Helper to map label → numeric score
        int _scoreOf(String label) {
          switch (label.toLowerCase()) {
            case "angry":
              return 1;
            case "sad":
              return 2;
            case "neutral":
              return 3;
            case "happy":
              return 4;
            case "grateful":
            case "very happy":
              return 5;
            default:
              return 3;
          }
        }

        // 3) Compute averages for each bucket
        final spots = <FlSpot>[];
        final barData = <double>[];
        for (var i = 0; i < buckets.length; i++) {
          final start = buckets[i];
          final end =
              range == _ChartRange.year
                  ? DateTime(start.year, start.month + 1, 1)
                  : start.add(const Duration(days: 1));
          final slice =
              all.where((m) {
                final d = m.date;
                return !d.isBefore(start) && d.isBefore(end);
              }).toList();

          double avg = 0;
          if (slice.isNotEmpty) {
            avg =
                slice
                    .map((m) => _scoreOf(m.label).toDouble())
                    .reduce((a, b) => a + b) /
                slice.length;
          }
          spots.add(FlSpot(i.toDouble(), avg));
          barData.add(avg);
        }

        // 4) Summary data
        final double avgAll =
            barData.isEmpty
                ? 0
                : barData.reduce((a, b) => a + b) / barData.length;
        final double highAll = barData.isEmpty ? 0 : barData.reduce(max);
        final double lowAll = barData.isEmpty ? 0 : barData.reduce(min);

        // 5) Build
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          children: [
            // SUMMARY BOX
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              color: const Color(0xFFECF7E6),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 28,
                  horizontal: 18,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _summaryItem(
                      "Average",
                      avgAll.toStringAsFixed(2),
                      Icons.emoji_emotions,
                      Colors.brown[600]!,
                    ),
                    _summaryItem(
                      "Highest",
                      highAll.toStringAsFixed(2),
                      Icons.trending_up,
                      Colors.green[400]!,
                    ),
                    _summaryItem(
                      "Lowest",
                      lowAll.toStringAsFixed(2),
                      Icons.trending_down,
                      Colors.red[300]!,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 26),

            // TABS SELECTED (already above), just spacing
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Chip(
                  label: Text(
                    range == _ChartRange.week
                        ? "Week"
                        : range == _ChartRange.month
                        ? "Month"
                        : "Year",
                    style: const TextStyle(
                      color: Colors.brown,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: const Color(0xFFE6E1C5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 3,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ANIMATED BAR CHART
            _AnimatedMoodBarChart(data: barData, maxScore: 5, labels: labels),

            const SizedBox(height: 34),

            // ANIMATED LINE CHART
            _AnimatedMoodLineChart(spots: spots, labels: labels, range: range),

            const SizedBox(height: 30),

            // --- Summarize AI section placeholder ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Summarize AI",
                    style: TextStyle(
                      color: Colors.blueGrey[900],
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.blueGrey[50],
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Text(
                      "AI-generated mood summary coming soon...",
                      style: TextStyle(
                        color: Colors.blueGrey[300],
                        fontStyle: FontStyle.italic,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _summaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Colors.brown[800],
            letterSpacing: 1.0,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.brown, fontSize: 14)),
      ],
    );
  }
}

// ────────────── Animated Bar Chart Widget ──────────────
class _AnimatedMoodBarChart extends StatelessWidget {
  final List<double> data;
  final int maxScore;
  final List<String> labels;

  const _AnimatedMoodBarChart({
    required this.data,
    required this.maxScore,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    const double maxBarHeight = 110;
    return SizedBox(
      height: maxBarHeight + 42,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(data.length, (i) {
          final score = data[i];
          final barHeight = (score / maxScore) * maxBarHeight;
          final color = _barColor(score);
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 700 + Random().nextInt(250)),
                  curve: Curves.easeInOutCubic,
                  height: barHeight,
                  constraints: const BoxConstraints(maxHeight: maxBarHeight),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.22),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      score > 0 ? score.toStringAsFixed(1) : "",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  labels[i],
                  style: TextStyle(
                    color: Colors.brown[300],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Color _barColor(double score) {
    if (score <= 1) return Colors.red[200]!;
    if (score <= 2) return Colors.orange[200]!;
    if (score <= 3) return Colors.yellow[300]!;
    if (score <= 4) return Colors.lightGreen[300]!;
    return Colors.blue[200]!;
  }
}

// ────────────── Animated Line Chart Widget ──────────────
class _AnimatedMoodLineChart extends StatelessWidget {
  final List<FlSpot> spots;
  final List<String> labels;
  final _ChartRange range;

  const _AnimatedMoodLineChart({
    required this.spots,
    required this.labels,
    required this.range,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minX: 0.0,
          maxX: (spots.length - 1).toDouble(),
          minY: 0.0,
          maxY: 5.0,
          gridData: FlGridData(
            show: true,
            horizontalInterval: 1.0,
            getDrawingHorizontalLine:
                (y) => FlLine(color: Colors.grey.shade300, strokeWidth: 1.0),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1.0,
                reservedSize: 30.0,
                getTitlesWidget:
                    (v, _) => Text(
                      v.toInt().toString(),
                      style: TextStyle(
                        color: Colors.brown.shade400,
                        fontSize: 12.0,
                      ),
                    ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1.0,
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= labels.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      labels[idx],
                      style: TextStyle(
                        color: Colors.brown.shade400,
                        fontSize: 12.0,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 4.0,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blueAccent.withOpacity(0.3),
              ),
              color: Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
  }
}
