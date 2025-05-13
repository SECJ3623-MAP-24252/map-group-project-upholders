/// Authentication result class
class AuthResult {
  final bool success;
  final String? userId;
  final String message;
  final UserRole? userRole;
  
  AuthResult({
    required this.success,
    this.userId,
    required this.message,
    this.userRole,
  });
}

/// Authentication status enum
enum AuthStatus { initial, authenticated, unauthenticated }

/// User roles
enum UserRole {
  student,
  lecturer,
  therapist,
  admin,
  unknown;
  
  static UserRole fromString(String? value) {
    if (value == null) return UserRole.unknown;
    
    switch (value.toLowerCase()) {
      case 'student': return UserRole.student;
      case 'lecturer': return UserRole.lecturer;
      case 'therapist': return UserRole.therapist;
      case 'admin': return UserRole.admin;
      default: return UserRole.unknown;
    }
  }
  
  String get displayName {
    switch (this) {
      case UserRole.student: return 'Student';
      case UserRole.lecturer: return 'Lecturer';
      case UserRole.therapist: return 'Therapist';
      case UserRole.admin: return 'Administrator';
      case UserRole.unknown: return 'Unknown';
    }
  }
  
  bool get canAccessAdminPanel => this == UserRole.admin;
  
  bool get canViewMoodStatistics => 
      this == UserRole.admin || 
      this == UserRole.therapist || 
      this == UserRole.lecturer;
      
  bool get canProvideCounseling => this == UserRole.therapist;
}

/// User model with mood tracking fields
class UserProfile {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final UserRole role;
  final String? matricNumber;
  final String? staffId;
  final String? department;
  final String? faculty;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? preferences;
  
  UserProfile({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    required this.role,
    this.matricNumber,
    this.staffId,
    this.department,
    this.faculty,
    required this.createdAt,
    this.updatedAt,
    this.preferences,
  });
  
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['user_id'],
      email: json['email'],
      name: json['name'],
      phoneNumber: json['phone_number'],
      role: UserRole.fromString(json['role']),
      matricNumber: json['matric_number'],
      staffId: json['staff_id'],
      department: json['department'],
      faculty: json['faculty'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      preferences: json['preferences'] as Map<String, dynamic>?,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'user_id': id,
    'email': email,
    'name': name,
    'phone_number': phoneNumber,
    'role': role.toString().split('.').last,
    'matric_number': matricNumber,
    'staff_id': staffId,
    'department': department,
    'faculty': faculty,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'preferences': preferences,
  };
  
  /// Check if user can access another user's mood data
  bool canAccessMoodDataOf(UserProfile other) {
    if (role == UserRole.student) return id == other.id;
    if (role == UserRole.therapist && other.role == UserRole.student) return true;
    if (role == UserRole.lecturer && other.role == UserRole.student) {
      return department == other.department;
    }
    return role == UserRole.admin;
  }
}

/// Mood entry model
class MoodEntry {
  final String id;
  final String userId;
  final int moodScore; // 1-5 scale
  final String? notes;
  final List<String>? tags;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  
  MoodEntry({
    required this.id,
    required this.userId,
    required this.moodScore,
    this.notes,
    this.tags,
    required this.timestamp,
    this.metadata,
  });
  
  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
    id: json['id'],
    userId: json['user_id'],
    moodScore: json['mood_score'],
    notes: json['notes'],
    tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    timestamp: DateTime.parse(json['timestamp']),
    metadata: json['metadata'] as Map<String, dynamic>?,
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'mood_score': moodScore,
    'notes': notes,
    'tags': tags,
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata,
  };
}