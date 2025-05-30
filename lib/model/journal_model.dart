class JournalEntry {
  String? id; // Nullable, as new entries won't have an ID until saved
  String title;
  String content;
  DateTime date;

  JournalEntry({
    this.id,
    required this.title,
    required this.content,
    required this.date,
  });
}