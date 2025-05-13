import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../utils/firebase_utils.dart';

/// A class handling account recovery functionality
class AccountRecovery {
  final String apiBaseUrl;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AccountRecovery({required this.apiBaseUrl});

  /// Request password reset via email
  Future<bool> requestPasswordResetEmail(String email) async {
    try {
      // Validate UTM email
      if (!FirebaseUtils.isValidUtmEmail(email)) {
        if (kDebugMode) {
          print('Invalid UTM email address');
        }
        return false;
      }
      
      // Firebase password reset
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      // If Firebase fails, fall back to custom API
      try {
        final response = await http.post(
          Uri.parse('$apiBaseUrl/request-password-reset'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email}),
        );

        if (response.statusCode == 200) {
          return true;
        } else {
          if (kDebugMode) {
            print('Password reset request failed: ${response.body}');
          }
          return false;
        }
      } catch (apiError) {
        if (kDebugMode) {
          print('Error requesting password reset: $apiError');
        }
        return false;
      }
    }
  }

  /// Verify password reset token from email link
  Future<bool> verifyPasswordResetToken(String oobCode) async {
    try {
      // Check if code is valid
      await _firebaseAuth.verifyPasswordResetCode(oobCode);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error verifying reset token: $e');
      }
      return false;
    }
  }

  /// Reset password with token
  Future<bool> resetPassword(String oobCode, String newPassword) async {
    try {
      // Firebase password reset
      await _firebaseAuth.confirmPasswordReset(
        code: oobCode,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error resetting password: $e');
      }
      
      // If Firebase fails, try API
      try {
        final response = await http.post(
          Uri.parse('$apiBaseUrl/reset-password'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'token': oobCode,
            'password': newPassword,
          }),
        );

        return response.statusCode == 200;
      } catch (apiError) {
        if (kDebugMode) {
          print('Error with backup API password reset: $apiError');
        }
        return false;
      }
    }
  }

  /// Request account recovery via SMS
  Future<bool> requestSmsRecovery(String phoneNumber) async {
    try {
      // This is a simplified version
      // In a real app, you would use Firebase Phone Authentication
      
      final response = await http.post(
        Uri.parse('$apiBaseUrl/request-sms-recovery'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': phoneNumber}),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting SMS recovery: $e');
      }
      return false;
    }
  }

  /// Verify SMS recovery code
  Future<bool> verifySmsRecoveryCode(String phoneNumber, String code) async {
    try {
      // This is a simplified version
      // In a real app, you would use Firebase Phone Authentication
      
      final response = await http.post(
        Uri.parse('$apiBaseUrl/verify-sms-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': phoneNumber,
          'code': code,
        }),
      );

      if (response.statusCode == 200) {
        // Store temporary recovery token if provided by API
        final data = jsonDecode(response.body);
        if (data.containsKey('recovery_token')) {
          await _secureStorage.write(
            key: 'temp_recovery_token',
            value: data['recovery_token'],
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error verifying SMS code: $e');
      }
      return false;
    }
  }

  /// Setup or update recovery email
  Future<bool> setupRecoveryEmail(String email, String currentPassword) async {
    try {
      // Get current user
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;
      
      // Validate UTM email
      if (!FirebaseUtils.isValidUtmEmail(email)) {
        if (kDebugMode) {
          print('Invalid UTM email address');
        }
        return false;
      }
      
      // Reauthenticate user for security
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Update email in Firebase
      await user.updateEmail(email);
      
      // Send verification email to new email
      await user.sendEmailVerification();
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error setting up recovery email: $e');
      }
      return false;
    }
  }

  /// Setup or update recovery phone number
  Future<bool> setupRecoveryPhone(String phoneNumber, String currentPassword) async {
    try {
      // Get current user
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;
      
      // Reauthenticate user for security
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Store phone number in user profile
      // Note: Firebase Auth doesn't directly store phone as a field
      // You would typically store this in Firestore or your backend
      
      final idToken = await user.getIdToken();
      
      final response = await http.post(
        Uri.parse('$apiBaseUrl/setup-recovery-phone'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error setting up recovery phone: $e');
      }
      return false;
    }
  }

  /// Get account recovery options for the user
  Future<Map<String, dynamic>?> getRecoveryOptions(String identifier) async {
    try {
      // For security, we don't return too much information
      // Just check if the email exists
      
      final methods = await _firebaseAuth.fetchSignInMethodsForEmail(identifier);
      
      if (methods.isEmpty) {
        return null; // No account found
      }
      
      // Get recovery options from backend (which would have more detailed info)
      final response = await http.get(
        Uri.parse('$apiBaseUrl/recovery-options?identifier=$identifier'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Augment with what we know from Firebase
        data['has_password'] = methods.contains('password');
        data['has_google'] = methods.contains('google.com');
        
        return data;
      }
      
      // Return basic info if API fails
      return {
        'has_password': methods.contains('password'),
        'has_google': methods.contains('google.com'),
        'has_recovery_email': false, // Default, would come from backend
        'has_recovery_phone': false, // Default, would come from backend
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting recovery options: $e');
      }
      return null;
    }
  }
}