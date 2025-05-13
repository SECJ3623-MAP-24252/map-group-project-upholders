import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../model/user_model.dart';
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
  
  // Verify password reset code & reset password
  Future<bool> verifyPasswordResetCode(String code) async {
    try {
      await _auth.verifyPasswordResetCode(code);
      return true;
    } catch (e) {
      print("Error verifying password reset code: $e");
      return false;
    }
  }
  
  Future<bool> confirmPasswordReset(String code, String newPassword) async {
    try {
      await _auth.confirmPasswordReset(code: code, newPassword: newPassword);
      return true;
    } catch (e) {
      print("Error confirming password reset: $e");
      return false;
    }
  }
  
  // Sign in with Google (alternative recovery)
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user?.email != null) {
        return await _userService.getUserByEmail(userCredential.user!.email!);
      }
      return null;
    } catch (e) {
      print("Error signing in with Google: $e");
      return null;
    }
  }
  
  // Check security questions
  Future<bool> checkSecurityQuestion(String email, String question, String answer) async {
    try {
      final user = await _userService.getUserByEmail(email);
      if (user == null) return false;
      // In a real app, fetch and verify security questions from Firestore
      return answer.toLowerCase() == "example answer";
    } catch (e) {
      print("Error checking security question: $e");
      return false;
    }
  }
}

// Helper for recovery dialogs
class RecoveryDialogs {
  static Future<String?> showEmailInputDialog(BuildContext context) {
    final emailController = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Account Recovery'),
        content: TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Enter your account email',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, emailController.text),
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }
  
  static void showRecoverySuccess(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Recovery Email Sent'),
        content: Text('Please check your email for password reset instructions.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('OK')),
        ],
      ),
    );
  }
  
  static void showRecoveryError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Recovery Failed'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('OK')),
        ],
      ),
    );
  }
}