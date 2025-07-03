class JournalEntry {
  String? id; // Nullable, as new entries won't have an ID until saved
  String title;
  String content;
  DateTime date;
  String? summary; // Nullable summary field for AI-generated summary

  JournalEntry({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    this.summary,
  });
}