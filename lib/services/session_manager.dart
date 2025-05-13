import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  // Constants and singleton setup
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _expiryKey = 'token_expiry';
  
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  // Properties
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);
  Timer? _sessionExpiryTimer;
  final StreamController<bool> _sessionStatusController = StreamController<bool>.broadcast();
  Stream<bool> get sessionStatus => _sessionStatusController.stream;

  // Initialize the session
  Future<void> init() async {
    final token = await getToken();
    isLoggedIn.value = token != null;
    _sessionStatusController.add(isLoggedIn.value);
    if (isLoggedIn.value) _setupExpiryTimer();
  }

  // Store session data
  Future<void> saveSession({
    required String token,
    required String refreshToken,
    required String userId,
    required DateTime expiry,
  }) async {
    await Future.wait([
      _secureStorage.write(key: _tokenKey, value: token),
      _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
      _secureStorage.write(key: _userIdKey, value: userId),
      _secureStorage.write(key: _expiryKey, value: expiry.toIso8601String()),
    ]);
    
    isLoggedIn.value = true;
    _sessionStatusController.add(true);
    _setupExpiryTimer();
  }

  // Get auth token
  Future<String?> getToken() async => await _secureStorage.read(key: _tokenKey);
  
  // Get user ID
  Future<String?> getUserId() async => await _secureStorage.read(key: _userIdKey);

  // Check if token is expired
  Future<bool> isTokenExpired() async {
    final expiryString = await _secureStorage.read(key: _expiryKey);
    if (expiryString == null) return true;
    return DateTime.now().isAfter(DateTime.parse(expiryString));
  }

  // Refresh token if needed
  Future<bool> refreshTokenIfNeeded() async {
    return await isTokenExpired() ? await _refreshToken() : true;
  }

  // Refresh the auth token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      if (refreshToken == null) {
        await logout();
        return false;
      }

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
          expiry: DateTime.now().add(Duration(hours: 1)),
        );
        return true;
      } else {
        await logout();
        return false;
      }
    } catch (e) {
      if (kDebugMode) print('Error refreshing token: $e');
      await logout();
      return false;
    }
  }

  // Setup expiry timer
  void _setupExpiryTimer() async {
    _sessionExpiryTimer?.cancel();
    final expiryString = await _secureStorage.read(key: _expiryKey);
    if (expiryString == null) return;
    
    final expiry = DateTime.parse(expiryString);
    final now = DateTime.now();
    
    if (expiry.isAfter(now)) {
      final refreshTime = expiry.difference(now) - const Duration(minutes: 5);
      _sessionExpiryTimer = Timer(
        refreshTime.isNegative ? Duration.zero : refreshTime, 
        _refreshToken
      );
    } else {
      _refreshToken();
    }
  }

  // Log user out
  Future<void> logout() async {
    _sessionExpiryTimer?.cancel();
    await Future.wait([
      _secureStorage.delete(key: _tokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
      _secureStorage.delete(key: _userIdKey),
      _secureStorage.delete(key: _expiryKey),
    ]);
    
    isLoggedIn.value = false;
    _sessionStatusController.add(false);
  }

  // Clean up resources
  void dispose() {
    _sessionExpiryTimer?.cancel();
    _sessionStatusController.close();
  }
}