import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Service to track and manage multiple devices that may be logged into a single account
class DeviceSessionManager {
  final String apiBaseUrl;
  final String sessionKey = 'active_sessions';
  
  DeviceSessionManager({required this.apiBaseUrl});
  
  /// Get all active sessions for the current user
  Future<List<DeviceSession>> getActiveSessions(String authToken) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/active-sessions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['sessions'];
        return data.map((session) => DeviceSession.fromJson(session)).toList();
      } else {
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting active sessions: $e');
      }
      return [];
    }
  }
  
  /// Log out from a specific device/session
  Future<bool> logoutDevice(String authToken, String sessionId) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/logout-device'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'session_id': sessionId}),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error logging out device: $e');
      }
      return false;
    }
  }
  
  /// Log out from all devices except the current one
  Future<bool> logoutAllOtherDevices(String authToken) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/logout-all-other-devices'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error logging out other devices: $e');
      }
      return false;
    }
  }
  
  /// Register the current device
  Future<bool> registerCurrentDevice(String authToken) async {
    try {
      // Get device info
      final deviceInfo = await _getDeviceInfo();
      
      final response = await http.post(
        Uri.parse('$apiBaseUrl/register-device'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(deviceInfo),
      );
      
      if (response.statusCode == 200) {
        // Save the session ID locally
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_session_id', data['session_id']);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error registering device: $e');
      }
      return false;
    }
  }
  
  /// Get the current device/browser information
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    // This is a simplified version. In a real app, you would use
    // packages like device_info_plus, platform_device_id, etc.
    return {
      'device_name': 'Mobile Device', // Would be replaced with actual device name
      'device_type': 'mobile',        // Would be replaced based on platform detection
      'app_version': '1.0.0',         // Would be replaced with app version
      'os_version': 'Unknown',        // Would be replaced with OS version
      'last_login_time': DateTime.now().toIso8601String(),
    };
  }
  
  /// Get the current session ID
  Future<String?> getCurrentSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('current_session_id');
  }
  
  /// Create a timed session with auto-logout after inactivity
  Future<bool> createTimedSession(String authToken, int durationMinutes) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/create-timed-session'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'duration_minutes': durationMinutes}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Save timed session info
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('timed_session_id', data['session_id']);
        await prefs.setInt('session_duration_minutes', durationMinutes);
        await prefs.setString(
          'session_expiry',
          DateTime.now().add(Duration(minutes: durationMinutes)).toIso8601String()
        );
        
        return true;
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating timed session: $e');
      }
      return false;
    }
  }
  
  /// Check if the timed session is still valid
  Future<bool> isTimedSessionValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryString = prefs.getString('session_expiry');
      
      if (expiryString == null) return false;
      
      final expiry = DateTime.parse(expiryString);
      return DateTime.now().isBefore(expiry);
    } catch (e) {
      return false;
    }
  }
  
  /// Extend the timed session
  Future<bool> extendTimedSession(String authToken, int additionalMinutes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('timed_session_id');
      
      if (sessionId == null) return false;
      
      final response = await http.post(
        Uri.parse('$apiBaseUrl/extend-timed-session'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'session_id': sessionId,
          'additional_minutes': additionalMinutes,
        }),
      );
      
      if (response.statusCode == 200) {
        // Update local expiry
        final expiryString = prefs.getString('session_expiry');
        if (expiryString != null) {
          final currentExpiry = DateTime.parse(expiryString);
          final newExpiry = currentExpiry.add(Duration(minutes: additionalMinutes));
          await prefs.setString('session_expiry', newExpiry.toIso8601String());
        } else {
          // If there's no expiry stored, create a new one
          await prefs.setString(
            'session_expiry',
            DateTime.now().add(Duration(minutes: additionalMinutes)).toIso8601String()
          );
        }
        return true;
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error extending timed session: $e');
      }
      return false;
    }
  }
}

/// Model class for device session information
class DeviceSession {
  final String sessionId;
  final String deviceName;
  final String deviceType;
  final String ipAddress;
  final String location;
  final DateTime lastActive;
  final bool isCurrent;
  
  DeviceSession({
    required this.sessionId,
    required this.deviceName,
    required this.deviceType,
    required this.ipAddress,
    required this.location,
    required this.lastActive,
    required this.isCurrent,
  });
  
  factory DeviceSession.fromJson(Map<String, dynamic> json) {
    return DeviceSession(
      sessionId: json['session_id'],
      deviceName: json['device_name'],
      deviceType: json['device_type'],
      ipAddress: json['ip_address'],
      location: json['location'],
      lastActive: DateTime.parse(json['last_active']),
      isCurrent: json['is_current'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'device_name': deviceName,
      'device_type': deviceType,
      'ip_address': ipAddress,
      'location': location,
      'last_active': lastActive.toIso8601String(),
      'is_current': isCurrent,
    };
  }
}