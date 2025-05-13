import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'lib/model/user_model.dart';
import 'lib/screens/dashboard_screen.dart';
import 'lib/screens/forgot_password_screen.dart';
import 'lib/screens/login_screen.dart';
import 'lib/services/auth_service.dart';
import 'lib/services/session_service.dart';
import 'lib/viewmodels/auth_viewmodel.dart';
import 'lib/viewmodels/session_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<SessionService>(create: (_) => SessionService()),
        ChangeNotifierProxyProvider<AuthService, AuthViewModel>(
          create: (context) => AuthViewModel(Provider.of<AuthService>(context, listen: false)),
          update: (context, authService, previous) => 
              previous ?? AuthViewModel(authService),
        ),
        ChangeNotifierProxyProvider<SessionService, SessionViewModel>(
          create: (context) => SessionViewModel(Provider.of<SessionService>(context, listen: false)),
          update: (context, sessionService, previous) => 
              previous ?? SessionViewModel(sessionService),
        ),
      ],
      child: MaterialApp(
        title: 'Mood Tracker App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/login': (context) => LoginScreen(),
          '/forgot-password': (context) => ForgotPasswordScreen(),
          '/dashboard': (context) => DashboardScreen(),
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkSession();
  }

  void checkSession() async {
    final sessionViewModel = Provider.of<SessionViewModel>(context, listen: false);
    await Future.delayed(Duration(seconds: 2)); // Simulating loading time
    
    if (await sessionViewModel.isSessionActive()) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Mood Tracker',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}