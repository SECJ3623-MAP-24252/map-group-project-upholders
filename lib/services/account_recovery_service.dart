import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../model/user.dart';
import '../services/user_service.dart';

class AuthRecoveryService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserService _userService = UserService();

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print("Error sending password reset email: $e");
      return false;
    }
  }

  // Sign in with Google (alternative recovery)
  Future<UserModel?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user?.email != null
          ? await _userService.getUserByEmail(userCredential.user!.email!)
          : null;
    } catch (e) {
      print("Error signing in with Google: $e");
      return null;
    }
  }
}
