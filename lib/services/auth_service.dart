import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/firebase_utils.dart';

/// Class that manages authentication related operations like login, signup, etc.
class AuthService {
  final String apiBaseUrl;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  
  final StreamController<AuthStatus> _authStatusController = 
      StreamController<AuthStatus>.broadcast();
  
  Stream<AuthStatus> get authStatus => _authStatusController.stream;
  
  AuthService({required this.apiBaseUrl});
  
  /// Login user with email and password
  Future<AuthResult> loginWithEmailPassword(String email, String password) async {
    try {
      // Validate UTM email
      if (!FirebaseUtils.isValidUtmEmail(email)) {
        return AuthResult(
          success: false,
          message: 'Please use a valid UTM email (@utm.my)',
        );
      }
      
      // Firebase authentication
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        final idToken = await userCredential.user!.getIdToken();
        final refreshToken = await _firebaseAuth.currentUser?.refreshToken;
        
        // Store auth data
        await _secureStorage.write(key: 'auth_token', value: idToken);
        await _secureStorage.write(key: 'refresh_token', value: refreshToken);
        await _secureStorage.write(key: 'user_id', value: userCredential.user!.uid);
        
        // Set expiry time (Firebase tokens typically last 1 hour)
        final expiry = DateTime.now().add(const Duration(hours: 1));
        await _secureStorage.write(
          key: 'token_expiry', 
          value: expiry.toIso8601String()
        );
        
        // Save user info
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', email);
        
        _authStatusController.add(AuthStatus.authenticated);
        
        return AuthResult(
          success: true,
          userId: userCredential.user!.uid,
          message: 'Login successful',
        );
      } else {
        return AuthResult(
          success: false,
          message: 'Invalid email or password',
        );
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase login error: ${e.code}');
      }
      
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'wrong-password':
          message = 'Invalid password.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many login attempts. Please try again later.';
          break;
        default:
          message = 'Login failed. Please try again.';
      }
      
      return AuthResult(
        success: false,
        message: message,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      return AuthResult(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }
  
  /// Register a new user
  Future<AuthResult> register({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    try {
      // Validate UTM email
      if (!FirebaseUtils.isValidUtmEmail(email)) {
        return AuthResult(
          success: false,
          message: 'Please use a valid UTM email (@utm.my)',
        );
      }
      
      // Create user in Firebase
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        // Update display name
        await userCredential.user!.updateDisplayName(name);
        
        // Save additional user info to database if needed
        await _saveUserProfile(
          userId: userCredential.user!.uid,
          email: email,
          name: name,
          phoneNumber: phoneNumber,
        );
        
        // Send verification email
        await userCredential.user!.sendEmailVerification();
        
        return AuthResult(
          success: true,
          userId: userCredential.user!.uid,
          message: 'Registration successful. Please verify your email.',
        );
      } else {
        return AuthResult(
          success: false,
          message: 'Registration failed. Please try again.',
        );
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase registration error: ${e.code}');
      }
      
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Email already exists.';
          break;
        case 'weak-password':
          message = 'Password is too weak.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        default:
          message = 'Registration failed. Please try again.';
      }
      
      return AuthResult(
        success: false,
        message: message,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Registration error: $e');
      }
      return AuthResult(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }
  
  /// Save additional user data to database
  Future<void> _saveUserProfile({
    required String userId,
    required String email,
    required String name,
    String? phoneNumber,
  }) async {
    try {
      // In a real app, you might use Firestore instead of REST API
      await http.post(
        Uri.parse('$apiBaseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'email': email,
          'name': name,
          'phone_number': phoneNumber,
          'created_at': DateTime.now().toIso8601String(),
        }),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user profile: $e');
      }
      // Non-critical error, so we don't need to rethrow
    }
  }
  
  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;
      
      // Get token
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) return false;
      
      // Check token expiry
      final expiryString = await _secureStorage.read(key: 'token_expiry');
      if (expiryString == null) return false;
      
      final expiry = DateTime.parse(expiryString);
      if (DateTime.now().isAfter(expiry)) {
        // Token expired, try to refresh
        return await _refreshToken();
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Refresh the authentication token
  Future<bool> _refreshToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;
      
      // Force token refresh
      await user.getIdToken(true);
      
      // Get new token
      final newToken = await user.getIdToken();
      final refreshToken = user.refreshToken;
      
      if (newToken != null) {
        // Update token in secure storage
        await _secureStorage.write(key: 'auth_token', value: newToken);
        
        if (refreshToken != null) {
          await _secureStorage.write(key: 'refresh_token', value: refreshToken);
        }
        
        // Update expiry time
        final expiry = DateTime.now().add(const Duration(hours: 1));
        await _secureStorage.write(
          key: 'token_expiry', 
          value: expiry.toIso8601String()
        );
        
        return true;
      } else {
        // Token refresh failed, logout
        await logout();
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Refresh token error: $e');
      }
      await logout();
      return false;
    }
  }
  
  /// Logout user
  Future<void> logout() async {
    try {
      // Firebase logout
      await _firebaseAuth.signOut();
      
      // Clear secure storage
      await _secureStorage.delete(key: 'auth_token');
      await _secureStorage.delete(key: 'refresh_token');
      await _secureStorage.delete(key: 'user_id');
      await _secureStorage.delete(key: 'token_expiry');
      
      _authStatusController.add(AuthStatus.unauthenticated);
    } catch (e) {
      if (kDebugMode) {
        print('Logout error: $e');
      }
    }
  }
  
  /// Get current user ID
  Future<String?> getUserId() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return user.uid;
    }
    return await _secureStorage.read(key: 'user_id');
  }
  
  /// Get auth token for API requests
  Future<String?> getAuthToken() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      // Check if token needs refresh
      final expiryString = await _secureStorage.read(key: 'token_expiry');
      if (expiryString != null) {
        final expiry = DateTime.parse(expiryString);
        if (DateTime.now().isAfter(expiry)) {
          // Token expired, refresh
          await _refreshToken();
        }
      }
      
      return await user.getIdToken();
    }
    
    return await _secureStorage.read(key: 'auth_token');
  }
  
  /// Verify email address
  Future<bool> verifyEmail(String oobCode) async {
    try {
      await _firebaseAuth.applyActionCode(oobCode);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Email verification error: $e');
      }
      return false;
    }
  }
  
  /// Resend verification email
  Future<bool> resendVerificationEmail(String email) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        return true;
      } else {
        // Try to get user by email
        try {
          await _firebaseAuth.signInWithEmailAndPassword(
            email: email,
            password: '', // This will fail but we'll catch it
          );
        } catch (e) {
          // User not found or invalid password
          return false;
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Resend verification error: $e');
      }
      return false;
    }
  }
  
  /// Change password when user is logged in
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;
      
      // Verify current password
      final email = user.email;
      if (email == null) return false;
      
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      
      // Reauthenticate
      await user.reauthenticateWithCredential(credential);
      
      // Update password
      await user.updatePassword(newPassword);
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Change password error: $e');
      }
      return false;
    }
  }
  
  /// Check if email is verified
  Future<bool> isEmailVerified() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;
      
      // Reload user to get latest state
      await user.reload();
      return user.emailVerified;
    } catch (e) {
      return false;
    }
  }
  
  /// Cleanup resources
  void dispose() {
    _authStatusController.close();
  }
}

/// Auth result class
class AuthResult {
  final bool success;
  final String? userId;
  final String message;
  
  AuthResult({
    required this.success,
    this.userId,
    required this.message,
  });
}

/// Auth status enum
enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
}