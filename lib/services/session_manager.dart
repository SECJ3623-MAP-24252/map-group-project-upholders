import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionManager {
  // Constants and singleton setup
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _expiryKey = 'token_expiry';
  
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Get auth token
  Future<String?> getToken() async => await _secureStorage.read(key: _tokenKey);
  
  // Get user ID
  Future<String?> getUserId() async => await _secureStorage.read(key: _userIdKey);

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
  }

  // Check if token is expired
  Future<bool> isTokenExpired() async {
    final expiryString = await _secureStorage.read(key: _expiryKey);
    if (expiryString == null) return true;
    return DateTime.now().isAfter(DateTime.parse(expiryString));
  }

  // Clear session
  Future<void> clearSession() async {
    await Future.wait([
      _secureStorage.delete(key: _tokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
      _secureStorage.delete(key: _userIdKey),
      _secureStorage.delete(key: _expiryKey),
    ]);
  }
}