import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _resetEmailSent = false;

  Widget _buildInitialState(AuthViewModel authViewModel) {
    return Column(
      children: [
        Text(
          'Enter your email address to receive a password reset link',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 24),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          validator:
              (value) =>
                  (value == null || value.isEmpty)
                      ? 'Please enter your email'
                      : null,
        ),
        SizedBox(height: 16),
        if (authViewModel.errorMessage != null)
          Text(
            authViewModel.errorMessage!,
            style: TextStyle(color: Colors.red),
          ),
        SizedBox(height: 24),
        ElevatedButton(
          onPressed: authViewModel.isLoading ? null : _handleResetRequest,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 50),
          ),
          child:
              authViewModel.isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Send Reset Link'),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      children: [
        Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
        SizedBox(height: 24),
        Text(
          'Password reset email sent!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Text(
          'Please check your email and follow the instructions to reset your password.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 50),
          ),
          child: Text('Back to Login'),
        ),
      ],
    );
  }

  Future<void> _handleResetRequest() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      final success = await authViewModel.resetPassword(_emailController.text);
      if (success) setState(() => _resetEmailSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Forgot Password')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _resetEmailSent
                  ? _buildSuccessState()
                  : _buildInitialState(authViewModel),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
