import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String SESSION_KEY = 'session_active';
  static const String USER_ID_KEY = 'user_id';
  static const String SESSION_EXPIRY_KEY = 'session_expiry';
  static const int SESSION_DURATION = 7; // days

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create session
  Future<void> createSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final expiryDate = DateTime.now().add(Duration(days: SESSION_DURATION));
    
    await prefs.setBool(SESSION_KEY, true);
    await prefs.setString(USER_ID_KEY, userId);
    await prefs.setString(SESSION_EXPIRY_KEY, expiryDate.toIso8601String());
  }

  // Check if session is active
  Future<bool> isSessionActive() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionActive = prefs.getBool(SESSION_KEY) ?? false;
    if (!sessionActive) return false;
    
    final expiryDateStr = prefs.getString(SESSION_EXPIRY_KEY);
    if (expiryDateStr == null) return false;
    
    return DateTime.parse(expiryDateStr).isAfter(DateTime.now()) && 
           _auth.currentUser != null;
  }

  // Get session user ID
  Future<String?> getSessionUserId() async {
    return (await SharedPreferences.getInstance()).getString(USER_ID_KEY);
  }

  // Clear session
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(SESSION_KEY),
      prefs.remove(USER_ID_KEY),
      prefs.remove(SESSION_EXPIRY_KEY),
    ]);
  }
}