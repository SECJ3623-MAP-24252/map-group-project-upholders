import 'package:flutter/material.dart';

import '../services/session_service.dart';

class SessionViewModel extends ChangeNotifier {
  final SessionService _sessionService;
  
  bool _isSessionActive = false;
  String? _userId;

  SessionViewModel(this._sessionService);

  bool get isSessionActive => _isSessionActive;
  String? get userId => _userId;

  // Check if session is active
  Future<bool> isSessionActive() async {
    _isSessionActive = await _sessionService.isSessionActive();
    if (_isSessionActive) _userId = await _sessionService.getSessionUserId();
    notifyListeners();
    return _isSessionActive;
  }

  // Create new session
  Future<void> createSession(String userId) async {
    await _sessionService.createSession(userId);
    _isSessionActive = true;
    _userId = userId;
    notifyListeners();
  }

  // End session
  Future<void> endSession() async {
    await _sessionService.clearSession();
    _isSessionActive = false;
    _userId = null;
    notifyListeners();
  }
}