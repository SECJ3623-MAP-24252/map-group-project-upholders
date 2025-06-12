// lib/services/auth/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Registers a user in Firebase Auth **and** writes their profile to Firestore.
  Future<UserModel?> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String userType,
  }) async {
    try {
      // 1. Create the Auth user
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user!;
      final now = DateTime.now();

      // 2. Build your UserModel
      final newUser = UserModel(
        id:           user.uid,
        email:        user.email ?? '',
        name:         name.trim(),
        userType:     userType,
        profilePicUrl: null,
        createdAt:    now,
        lastLogin:    now,
      );

      // 3. Persist to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(newUser.toMap());

      return newUser;
    } on FirebaseAuthException catch (e) {
      print('AuthService.register error [${e.code}]: ${e.message}');
      return null;
    } catch (e) {
      print('AuthService.register unknown error: $e');
      return null;
    }
  }

  /// Signs in an existing user and returns their profile from Firestore.
  Future<UserModel?> signInWithEmailPassword(
      String email, String password) async {
    try {
      // 1. Sign in to Firebase Auth
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user;
      if (user == null) return null;

      // 2. Fetch their Firestore profile
      final snap = await _firestore.collection('users').doc(user.uid).get();
      if (!snap.exists) return null;

      // 3. Map into your UserModel
      return UserModel.fromMap(
        snap.data() as Map<String, dynamic>,
        user.uid,
      );
    } on FirebaseAuthException catch (e) {
      print('AuthService.signIn error [${e.code}]: ${e.message}');
      return null;
    } catch (e) {
      print('AuthService.signIn unknown error: $e');
      return null;
    }
  }

  /// Sends a password reset email.
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } catch (e) {
      print('AuthService.resetPassword error: $e');
      return false;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
