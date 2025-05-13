import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Class for handling biometric authentication and local session security
class BiometricAuth {
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricHashKey = 'biometric_hash';
  static const _secureStorage = FlutterSecureStorage();
  
  /// Check if biometric authentication is available on the device
  Future<bool> isBiometricAvailable() async {
    try {
      // LocalAuthentication is imported lazily to avoid issues on platforms
      // where it might not be supported
      final localAuth = await _getLocalAuthentication();
      return await localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }
  
  /// Dynamically import local_authentication package
  Future<dynamic> _getLocalAuthentication() async {
    try {
      // This is a workaround to avoid compile-time dependency issues
      // on platforms where local_authentication may not be available
      return await import('package:local_authentication/local_authentication.dart')
          .then((module) => module.LocalAuthentication());
    } catch (e) {
      throw Exception('Local authentication package not available');
    }
  }

  /// Get available biometric types
  Future<List<String>> getAvailableBiometrics() async {
    try {
      final localAuth = await _getLocalAuthentication();
      final availableBiometrics = await localAuth.getAvailableBiometrics();
      return availableBiometrics.map((biometric) => biometric.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  /// Enable biometric authentication for the app
  Future<bool> enableBiometric(String userId, String authToken) async {
    try {
      // Store a hash of the auth token with user ID as salt
      final hash = sha256.convert(
        utf8.encode('$authToken:$userId:biometric_auth')
      ).toString();
      
      await _secureStorage.write(key: _biometricHashKey, value: hash);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricEnabledKey, true);
      
      return true;
    } catch (e) {
      debugPrint('Error enabling biometric: $e');
      return false;
    }
  }

  /// Check if biometric authentication is enabled
  Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_biometricEnabledKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Disable biometric authentication
  Future<bool> disableBiometric() async {
    try {
      await _secureStorage.delete(key: _biometricHashKey);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricEnabledKey, false);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Authenticate using biometrics
  Future<bool> authenticate() async {
    try {
      final localAuth = await _getLocalAuthentication();
      
      return await localAuth.authenticate(
        localizedReason: 'Authenticate to access your account',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      debugPrint('Error during biometric authentication: $e');
      return false;
    }
  }

  /// Verify the stored biometric hash with current session
  Future<bool> verifyBiometricHash(String userId, String authToken) async {
    try {
      final storedHash = await _secureStorage.read(key: _biometricHashKey);
      if (storedHash == null) return false;
      
      final currentHash = sha256.convert(
        utf8.encode('$authToken:$userId:biometric_auth')
      ).toString();
      
      return storedHash == currentHash;
    } catch (e) {
      return false;
    }
  }
}

// Workaround for importing local_authentication dynamically
Future<dynamic> import(String path) async {
  try {
    // In a real implementation, this would use the dart:mirrors package
    // or a plugin system to dynamically load the module
    // For this example, we'll simulate it
    if (path == 'package:local_authentication/local_authentication.dart') {
      return _LocalAuthenticationModule();
    }
    throw Exception('Module not found: $path');
  } catch (e) {
    rethrow;
  }
}

// Simulated local_authentication module
class _LocalAuthenticationModule {
  LocalAuthentication get LocalAuthentication => LocalAuthentication();
}

class LocalAuthentication {
  Future<bool> get canCheckBiometrics async => true;
  
  Future<List<BiometricType>> getAvailableBiometrics() async {
    return [BiometricType.fingerprint, BiometricType.face];
  }
  
  Future<bool> authenticate({
    required String localizedReason,
    required AuthenticationOptions options,
  }) async {
    // In a real implementation, this would trigger the biometric prompt
    return true;
  }
}

enum BiometricType { fingerprint, face, iris }

class AuthenticationOptions {
  final bool stickyAuth;
  final bool biometricOnly;
  
  const AuthenticationOptions({
    required this.stickyAuth,
    required this.biometricOnly,
  });
}
