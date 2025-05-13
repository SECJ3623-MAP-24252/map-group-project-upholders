import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/// A class responsible for managing user sessions.
class SessionManager {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _expiryKey = 'token_expiry';

  static final SessionManager _instance = SessionManager._internal();

  factory SessionManager() {
    return _instance;
  }

  SessionManager._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);
  
  Timer? _sessionExpiryTimer;
  final StreamController<bool> _sessionStatusController = StreamController<bool>.broadcast();
  
  /// Stream providing session status updates
  Stream<bool> get sessionStatus => _sessionStatusController.stream;

  /// Initialize the session manager
  Future<void> init() async {
    final token = await getToken();
    isLoggedIn.value = token != null;
    _sessionStatusController.add(isLoggedIn.value);
    
    if (isLoggedIn.value) {
      _setupExpiryTimer();
    }
  }

  /// Store authentication token and related data
  Future<void> saveSession({
    required String token,
    required String refreshToken,
    required String userId,
    required DateTime expiry,
  }) async {
    await _secureStorage.write(key: _tokenKey, value: token);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    await _secureStorage.write(key: _userIdKey, value: userId);
    await _secureStorage.write(key: _expiryKey, value: expiry.toIso8601String());
    
    isLoggedIn.value = true;
    _sessionStatusController.add(true);
    
    _setupExpiryTimer();
  }

  /// Get the current auth token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  /// Get the user ID
  Future<String?> getUserId() async {
    return await _secureStorage.read(key: _userIdKey);
  }

  /// Check if token is expired
  Future<bool> isTokenExpired() async {
    final expiryString = await _secureStorage.read(key: _expiryKey);
    if (expiryString == null) return true;
    
    final expiry = DateTime.parse(expiryString);
    return DateTime.now().isAfter(expiry);
  }

  /// Refresh the token if expired
  Future<bool> refreshTokenIfNeeded() async {
    if (await isTokenExpired()) {
      return await _refreshToken();
    }
    return true;
  }

  /// Refresh the authentication token using the refresh token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      if (refreshToken == null) {
        await logout();
        return false;
      }

      // Make API call to refresh token
      final response = await http.post(
        Uri.parse('YOUR_API_URL/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        await saveSession(
          token: data['token'],
          refreshToken: data['refresh_token'],
          userId: data['user_id'],
          expiry: DateTime.now().add(Duration(hours: 1)), // Adjust based on your token expiry
        );
        return true;
      } else {
        await logout();
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing token: $e');
      }
      await logout();
      return false;
    }
  }

  /// Setup timer to handle token expiry
  void _setupExpiryTimer() async {
    _sessionExpiryTimer?.cancel();
    
    final expiryString = await _secureStorage.read(key: _expiryKey);
    if (expiryString == null) return;
    
    final expiry = DateTime.parse(expiryString);
    final now = DateTime.now();
    
    if (expiry.isAfter(now)) {
      final timeToExpiry = expiry.difference(now);
      // Set timer to refresh token 5 minutes before expiry
      final refreshTime = timeToExpiry - const Duration(minutes: 5);
      
      if (refreshTime.isNegative) {
        // Token is about to expire, refresh now
        _refreshToken();
      } else {
        _sessionExpiryTimer = Timer(refreshTime, () {
          _refreshToken();
        });
      }
    } else {
      // Token already expired, try to refresh
      _refreshToken();
    }
  }

  /// Log user out
  Future<void> logout() async {
    _sessionExpiryTimer?.cancel();
    
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _userIdKey);
    await _secureStorage.delete(key: _expiryKey);
    
    isLoggedIn.value = false;
    _sessionStatusController.add(false);
  }

  /// Clean up resources
  void dispose() {
    _sessionExpiryTimer?.cancel();
    _sessionStatusController.close();
  }
}