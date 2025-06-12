import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String userType; // student, lecturer, therapist, admin
  final String? profilePicUrl;
  final DateTime createdAt;
  final DateTime lastLogin;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.userType,
    this.profilePicUrl,
    required this.createdAt,
    required this.lastLogin,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      userType: map['userType'] ?? 'user',
      profilePicUrl: map['profilePicUrl'],
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      lastLogin: map['lastLogin'] is Timestamp 
          ? (map['lastLogin'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'userType': userType,
      'profilePicUrl': profilePicUrl,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
    };
  }
}