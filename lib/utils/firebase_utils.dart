import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseUtils {
  static FirebaseUtils? _instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  
  // Singleton pattern
  static FirebaseUtils get instance {
    _instance ??= FirebaseUtils._internal();
    return _instance!;
  }
  
  FirebaseUtils._internal();
  
  /// Initialize Firebase
  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      if (kDebugMode) {
        print('Firebase initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize Firebase: $e');
      }
      rethrow;
    }
  }
  
  /// Validate UTM email
  static bool isValidUtmEmail(String email) {
    if (email.isEmpty) return false;
    
    // Check basic email format first
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(email)) return false;
    
    // Validate it's a UTM email (@utm.my)
    return email.toLowerCase().endsWith('@utm.my');
  }
  
  /// Get current user
  User? get currentUser => _firebaseAuth.currentUser;
  
  /// Get current user token
  Future<String?> getUserToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;
      return await user.getIdToken();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user token: $e');
      }
      return null;
    }
  }
}