class NotificationPreferences {
  final bool dailyRemindersEnabled;
  final bool insightNotificationsEnabled;
  final bool moodTrendAlertsEnabled;
  final TimeOfDay reminderTime;

  const NotificationPreferences({
    required this.dailyRemindersEnabled,
    required this.insightNotificationsEnabled,
    required this.moodTrendAlertsEnabled,
    required this.reminderTime,
  });

  // Creates a default notification preferences object
  factory NotificationPreferences.defaultSettings() {
    return const NotificationPreferences(
      dailyRemindersEnabled: true,
      insightNotificationsEnabled: true,
      moodTrendAlertsEnabled: false,
      reminderTime: TimeOfDay(hour: 20, minute: 0), // Default to 8 PM
    );
  }

  // Converts the object to a map for storage (e.g., Firebase, SharedPreferences)
  Map<String, dynamic> toMap() {
    return {
      'dailyRemindersEnabled': dailyRemindersEnabled,
      'insightNotificationsEnabled': insightNotificationsEnabled,
      'moodTrendAlertsEnabled': moodTrendAlertsEnabled,
      'reminderHour': reminderTime.hour,
      'reminderMinute': reminderTime.minute,
    };
  }

  // Creates an object from stored map data
  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    return NotificationPreferences(
      dailyRemindersEnabled: map['dailyRemindersEnabled'] as bool,
      insightNotificationsEnabled: map['insightNotificationsEnabled'] as bool,
      moodTrendAlertsEnabled: map['moodTrendAlertsEnabled'] as bool,
      reminderTime: TimeOfDay(
        hour: map['reminderHour'] as int,
        minute: map['reminderMinute'] as int,
      ),
    );
  }

  // Creates a copy of the object with optional changes
  NotificationPreferences copyWith({
    bool? dailyRemindersEnabled,
    bool? insightNotificationsEnabled,
    bool? moodTrendAlertsEnabled,
    TimeOfDay? reminderTime,
  }) {
    return NotificationPreferences(
      dailyRemindersEnabled: dailyRemindersEnabled ?? this.dailyRemindersEnabled,
      insightNotificationsEnabled: insightNotificationsEnabled ?? this.insightNotificationsEnabled,
      moodTrendAlertsEnabled: moodTrendAlertsEnabled ?? this.moodTrendAlertsEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  @override
  String toString() {
    return 'NotificationPreferences(\n'
        '  dailyRemindersEnabled: $dailyRemindersEnabled,\n'
        '  insightNotificationsEnabled: $insightNotificationsEnabled,\n'
        '  moodTrendAlertsEnabled: $moodTrendAlertsEnabled,\n'
        '  reminderTime: ${reminderTime.hour}:${reminderTime.minute.toString().padLeft(2, '0')},\n'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationPreferences &&
        other.dailyRemindersEnabled == dailyRemindersEnabled &&
        other.insightNotificationsEnabled == insightNotificationsEnabled &&
        other.moodTrendAlertsEnabled == moodTrendAlertsEnabled &&
        other.reminderTime.hour == reminderTime.hour &&
        other.reminderTime.minute == reminderTime.minute;
  }

  @override
  int get hashCode {
    return Object.hash(
      dailyRemindersEnabled,
      insightNotificationsEnabled,
      moodTrendAlertsEnabled,
      reminderTime.hour,
      reminderTime.minute,
    );
  }
}
