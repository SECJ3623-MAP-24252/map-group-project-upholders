

class VoiceJournalEntry {
  final String filePath;
  final DateTime date;
  final String emotion; // Dummy value for now
  final String? transcript;

  VoiceJournalEntry({
    required this.filePath,
    required this.date,
    required this.emotion,
    this.transcript,
  });
}
