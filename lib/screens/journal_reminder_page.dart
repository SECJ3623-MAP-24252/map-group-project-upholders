import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/app_drawer.dart';

class JournalReminderPage extends StatefulWidget {
  const JournalReminderPage({Key? key}) : super(key: key);

  @override
  State<JournalReminderPage> createState() => _JournalReminderPageState();
}

class _JournalReminderPageState extends State<JournalReminderPage> {
  late DateTime _now;
  late final _timer;

  // Now mutable, not final!
  List<Map<String, String>> _journalEntries = [
    {
      'date': '2024-05-29',
      'title': 'Feeling Grateful',
      'excerpt': 'Today I felt grateful for the small wins and support from my friends.'
    },
    {
      'date': '2024-05-28',
      'title': 'Challenging Day',
      'excerpt': 'Work was tough, but I managed my stress by taking a long walk.'
    },
    {
      'date': '2024-05-27',
      'title': 'New Achievements',
      'excerpt': 'Tried something new and succeeded—felt proud and motivated!'
    },
  ];

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now())
        .listen((now) {
      setState(() => _now = now);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _openWriteJournalModal(BuildContext context) {
    final titleController = TextEditingController();
    final excerptController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF22223B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 32,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Write Your Journal",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Title",
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF4EA8DE)),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: excerptController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "What's on your mind?",
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF4EA8DE)),
                  ),
                ),
                minLines: 2,
                maxLines: 5,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4EA8DE),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Save Entry",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    final String title = titleController.text.trim();
                    final String excerpt = excerptController.text.trim();
                    if (title.isNotEmpty && excerpt.isNotEmpty) {
                      setState(() {
                        _journalEntries.insert(0, {
                          'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                          'title': title,
                          'excerpt': excerpt,
                        });
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Journal entry saved!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      // Show error if fields are empty
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in all fields.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF3E3),
      drawer: AppDrawer(currentRoute: "/journal-reminder"),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildHeader(),
            const SizedBox(height: 18),
            _buildMotivationCard(),
            const SizedBox(height: 18),
            // Write Now Button is here, above the entries list!
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: ElevatedButton.icon(
                onPressed: () => _openWriteJournalModal(context),
                icon: const Icon(Icons.edit_rounded, size: 22),
                label: const Text(
                  "Write Now",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 5,
                  backgroundColor: const Color(0xFF9D4EDD),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Journal Entries Section with unlimited scroll
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: _journalEntries.isEmpty
                    ? _emptyJournalPlaceholder()
                    : ListView.separated(
                  itemCount: _journalEntries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final entry = _journalEntries[idx];
                    return _JournalEntryCard(
                      date: entry['date']!,
                      title: entry['title']!,
                      excerpt: entry['excerpt']!,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, size: 28, color: Color(0xFF4EA8DE)),
              onPressed: () => Scaffold.of(context).openDrawer(),
              tooltip: 'Menu',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, d MMMM yyyy').format(_now),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('HH:mm:ss').format(_now),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Icon(
            Icons.book_rounded,
            size: 32,
            color: Color(0xFF4EA8DE),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
        child: Row(
          children: [
            const Icon(Icons.lightbulb_rounded, color: Colors.white, size: 32),
            const SizedBox(width: 18),
            const Expanded(
              child: Text(
                '"Writing even a short journal each day can change your mindset. Small steps, big changes!"',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  height: 1.32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyJournalPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.menu_book_rounded, color: Colors.white24, size: 60),
          const SizedBox(height: 8),
          const Text(
            "No journal entries yet.\nStart writing to track your mood journey!",
            style: TextStyle(
              color: Colors.white38,
              fontSize: 15,
              fontStyle: FontStyle.italic,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _JournalEntryCard extends StatelessWidget {
  final String date;
  final String title;
  final String excerpt;

  const _JournalEntryCard({
    required this.date,
    required this.title,
    required this.excerpt,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF4EA8DE), Color(0xFF9D4EDD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.13),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.fiber_manual_record, color: Colors.white.withOpacity(0.85), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMM d, yyyy').format(DateTime.parse(date)),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  excerpt,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
