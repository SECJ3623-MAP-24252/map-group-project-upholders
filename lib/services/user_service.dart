import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get current user document
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (userDoc.exists) {
        return UserModel.fromMap(userDoc.data() as Map<String, dynamic>, user.uid);
      }
      
      return null;
    } catch (e) {
      print("Error getting current user: $e");
      return null;
    }
  }
  
  // Update last login timestamp
  Future<void> updateLastLogin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error updating last login: $e");
    }
  }
  
  // Log user activity
  Future<void> logUserActivity(String userId, String activity) async {
    try {
      await _firestore.collection('users').doc(userId).collection('activities').add({
        'activity': activity,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error logging user activity: $e");
    }
  }
  
  // Get user by email (for password recovery)
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        final userId = querySnapshot.docs.first.id;
        return UserModel.fromMap(userData, userId);
      }
      
      return null;
    } catch (e) {
      print("Error getting user by email: $e");
      return null;
    }
  }
}