import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/biometric_auth.dart';
import '../services/session_manager.dart';
import 'forgot_password_screen.dart';

/// Login screen with email, password and biometric authentication options
class LoginScreen extends StatefulWidget {
  final String apiBaseUrl;
  final Function(bool) onLoginResult;
  
  const LoginScreen({
    Key? key,
    required this.apiBaseUrl,
    required this.onLoginResult,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  bool _rememberMe = false;
  bool _biometricAvailable = false;
  
  late final AuthService _authService;
  late final SessionManager _sessionManager;
  late final BiometricAuth _biometricAuth;
  
  @override
  void initState() {
    super.initState();
    _authService = AuthService(apiBaseUrl: widget.apiBaseUrl);
    _sessionManager = SessionManager();
    _biometricAuth = BiometricAuth();
    
    _loadSavedEmail();
    _checkBiometricAvailability();
  }
  
  Future<void> _loadSavedEmail() async {
    // This would typically come from SharedPreferences
    // For simplicity, we're not implementing the full logic here
  }
  
  Future<void> _checkBiometricAvailability() async {
    final isAvailable = await _biometricAuth.isBiometricAvailable();
    final isEnabled = await _biometricAuth.isBiometricEnabled();
    
    setState(() {
      _biometricAvailable = isAvailable && isEnabled;
    });
    
    // If biometric is available and enabled, try auto-login
    if (_biometricAvailable) {
      // Uncomment to enable auto-login with biometrics
      // _authenticateWithBiometric();
    }
  }
  
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final result = await _authService.loginWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (result.success) {
        // If login successful, initialize session
        await _sessionManager.init();
        
        // If remember me is checked, save email for next login
        if (_rememberMe) {
          // Save email to preferences (not implemented for brevity)
        }
        
        // Notify parent widget about successful login
        widget.onLoginResult(true);
      } else {
        setState(() {
          _errorMessage = result.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _authenticateWithBiometric() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final authenticated = await _biometricAuth.authenticate();
      
      if (authenticated) {
        // Biometric authentication successful, get user data
        // This is simplified - in a real app, you'd need to fetch the user's
        // session from secure storage or make an API call
        await _sessionManager.init();
        widget.onLoginResult(true);
      } else {
        setState(() {
          _errorMessage = 'Biometric authentication failed';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Authentication error. Please use email login.';
        _isLoading = false;
      });
    }
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const FlutterLogo(size: 80),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
                    const Text('Remember me'),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotPasswordScreen(
                              apiBaseUrl: widget.apiBaseUrl,
                            ),
                          ),
                        );
                      },
                      child: const Text('Forgot Password?'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Login'),
                ),
                const SizedBox(height: 16),
                if (_biometricAvailable)
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _authenticateWithBiometric,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Login with Biometrics'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        // Navigate to Registration screen
                        // Not implemented for brevity
                      },
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}