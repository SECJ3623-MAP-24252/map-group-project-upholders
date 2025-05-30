import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/journal_model.dart'; // Added for JournalEntry
import '../../services/journal/journal_service.dart'; // Added for JournalService
import '../../widgets/app_drawer.dart';

class JournalReminderPage extends StatefulWidget {
  const JournalReminderPage({Key? key}) : super(key: key);

  @override
  State<JournalReminderPage> createState() => _JournalReminderPageState();
}

class _JournalReminderPageState extends State<JournalReminderPage> {
  late DateTime _now;
  late final _timer;
  final JournalService _journalService = JournalService();
  List<JournalEntry> _journalEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now())
        .listen((now) {
      if (mounted) { // Check if widget is still in the tree
        setState(() => _now = now);
      }
    });
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final entries = await _journalService.getJournalEntries();
      if (mounted) {
        setState(() {
          // Sort entries by date, newest first, and take top 3-5 for reminder page
          _journalEntries = entries..sort((a, b) => b.date.compareTo(a.date));
          // _journalEntries = _journalEntries.take(5).toList(); // Optionally limit displayed entries
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading entries: $e')));
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
    titleController.dispose(); // Dispose controller
    contentController.dispose(); // Dispose controller
  }

  // Define controllers at the class level to dispose them properly
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  void _openWriteJournalModal(BuildContext context) {
    // Clear controllers when modal opens for a new entry
    titleController.clear();
    contentController.clear();

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
                controller: contentController,
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
                    final String title = titleController.text.trim(); // Title from modal
                    final String content = contentController.text.trim(); // Content from modal

                    if (title.isNotEmpty && content.isNotEmpty) {
                      final newEntry = JournalEntry(
                        // id will be generated by service/backend or null if not needed before save
                        title: title,
                        content: content,
                        date: DateTime.now(),
                      );

                      _journalService.saveJournalEntry(newEntry).then((_) {
                        _loadEntries(); // Refresh the list from the service
                        Navigator.pop(context); // Close the modal
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Journal entry saved!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }).catchError((error) {
                        Navigator.pop(context); // Close the modal
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to save entry: $error'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      });
                    } else { // If fields are empty
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in both title and content.'),
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
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF9D4EDD)))
                    : _journalEntries.isEmpty
                        ? _emptyJournalPlaceholder()
                        : ListView.separated(
                            itemCount: _journalEntries.length,
                            // itemCount: _journalEntries.take(5).length, // Optionally limit displayed entries
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, idx) {
                              final entry = _journalEntries[idx];
                              return _JournalEntryCard(
                                // Pass data from JournalEntry object
                                date: entry.date.toIso8601String(), // Card expects a parseable date string
                                title: entry.title,
                                excerpt: entry.content,
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
          Icon(Icons.menu_book_rounded, color: Colors.grey.shade400, size: 60),
          const SizedBox(height: 8),
          Text(
            "No journal entries yet.\nStart writing to track your mood journey!",
            style: TextStyle(
              color: Colors.grey.shade600,
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
