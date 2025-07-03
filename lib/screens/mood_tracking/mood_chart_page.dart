// lib/screens/mood_tracking/mood_chart_page.dart

import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/journal/journal_service.dart'; // Reuse the summary service
import '../../utils/mood_pdf_export.dart'; // <-- adjust if you put it elsewhere
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
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.download_rounded),
                label: const Text('Export to PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                ),
                onPressed: () async {
                  // Use only scores & labels from the current chart period!
                  // (barData and labels already represent what's displayed)
                  final periodLabel =
                      range == _ChartRange.week
                          ? "This Week"
                          : range == _ChartRange.month
                          ? "This Month"
                          : "This Year";
                  final pdf = await MoodPdfExport.generateMoodChartReport(
                    barData,
                    labels: labels,
                    title: "Mood Chart Report",
                    periodLabel: periodLabel,
                  );
                  await MoodPdfExport.saveAndSharePdf(
                    pdf,
                    fileName: "mood_chart_${range.name}.pdf",
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

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

            // --- Summarize AI section ---
            _MoodAISummarySection(
              moodLabels: all.map((m) => m.label).toList(),
              moodDates: all.map((m) => m.date).toList(),
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

class _AnimatedMoodBarChart extends StatefulWidget {
  final List<double> data;
  final int maxScore;
  final List<String> labels;

  const _AnimatedMoodBarChart({
    required this.data,
    required this.maxScore,
    required this.labels,
  });

  @override
  State<_AnimatedMoodBarChart> createState() => _AnimatedMoodBarChartState();
}

class _AnimatedMoodBarChartState extends State<_AnimatedMoodBarChart> {
  @override
  Widget build(BuildContext context) {
    final double chartWidth = min(MediaQuery.of(context).size.width - 40, 350);
    const double maxBarHeight = 110;
    final int n = widget.data.length;
    final double barSpacing = 2.0;
    final double barWidth = (chartWidth - n * barSpacing * 2) / n;

    // Detect if it's the "monthly" range by checking n==30 (or use labels.length==30)
    final bool isMonthly = n == 30;

    return SizedBox(
      width: chartWidth,
      height: maxBarHeight + 42,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(widget.data.length, (i) {
          final score = widget.data[i];
          final barHeight = (score / widget.maxScore) * maxBarHeight;
          final color = _barColor(score);
          return Container(
            width: barWidth,
            margin: EdgeInsets.symmetric(horizontal: barSpacing),
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
                      style: TextStyle(
                        fontSize: isMonthly ? 11 : 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isMonthly ? 2 : 5),
                widget.labels[i].isNotEmpty
                    ? Text(
                      widget.labels[i],
                      style: TextStyle(
                        color: Colors.brown[400],
                        fontWeight: FontWeight.bold,
                        fontSize: isMonthly ? 10 : 12,
                      ),
                    )
                    : const SizedBox.shrink(),
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
    // Fixed chart width as used in bar chart
    final double chartWidth = min(MediaQuery.of(context).size.width - 40, 350);

    // Prevent disappearing if no spots (show placeholder chart)
    final List<FlSpot> chartSpots =
        spots.isEmpty ? [FlSpot(0, 0), FlSpot(1, 0)] : spots;

    return Center(
      child: SizedBox(
        width: chartWidth,
        height: 180,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (chartSpots.length - 1).toDouble(),
              minY: 0,
              maxY: 5,
              gridData: FlGridData(
                show: true,
                horizontalInterval: 1,
                getDrawingHorizontalLine:
                    (y) => FlLine(color: Colors.grey.shade300, strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    reservedSize: 30,
                    getTitlesWidget:
                        (v, _) => Text(
                          v.toInt().toString(),
                          style: TextStyle(
                            color: Colors.brown.shade400,
                            fontSize: 12,
                          ),
                        ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
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
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: chartSpots,
                  isCurved: true,
                  barWidth: 4,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blueAccent.withOpacity(0.3),
                  ),
                  color: Colors.blueAccent,
                ),
              ],
              clipData: FlClipData.none(),
            ),
          ),
        ),
      ),
    );
  }
}

class _MoodAISummarySection extends StatefulWidget {
  final List<String> moodLabels;
  final List<DateTime> moodDates;
  const _MoodAISummarySection({required this.moodLabels, required this.moodDates});

  @override
  State<_MoodAISummarySection> createState() => _MoodAISummarySectionState();
}

class _MoodAISummarySectionState extends State<_MoodAISummarySection> {
  String? _summary;
  bool _isLoading = false;
  final JournalService _journalService = JournalService();

  String _buildMoodText() {
    if (widget.moodLabels.isEmpty) return "No mood data available.";
    // Build a text summary of moods for the AI
    final buffer = StringBuffer();
    for (int i = 0; i < widget.moodLabels.length; i++) {
      buffer.writeln("${widget.moodDates[i].toLocal().toString().split(' ')[0]}: ${widget.moodLabels[i]}");
    }
    return buffer.toString();
  }

  Future<void> _generateSummary() async {
    setState(() { _isLoading = true; });
    final moodText = _buildMoodText();
    final summary = await _journalService.generateSummary(moodText);
    setState(() {
      _summary = summary ?? "Failed to generate summary.";
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          if (_summary != null)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.blueGrey[50],
              ),
              padding: const EdgeInsets.all(18),
              child: Text(
                _summary!,
                style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Colors.black87),
              ),
            )
          else
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
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: _isLoading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.auto_awesome),
            label: Text(_isLoading ? 'Generating...' : 'Generate AI Summary'),
            onPressed: _isLoading ? null : _generateSummary,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
