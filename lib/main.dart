import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './services/auth_service.dart';
import './services/session_service.dart';
import 'firebase_options.dart';
// import './model/user_model.dart';
import 'screens/auth/forgot_password_view.dart';
import 'screens/auth/login_view.dart';
import 'screens/dashboard/dashboard_psychiatrist_view.dart';
import 'screens/dashboard/dashboard_user_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<SessionService>(create: (_) => SessionService()),
        ChangeNotifierProxyProvider<AuthService, AuthViewModel>(
          create:
              (context) => AuthViewModel(
                Provider.of<AuthService>(context, listen: false),
              ),
          update:
              (context, authService, previous) =>
                  previous ?? AuthViewModel(authService),
        ),
        ChangeNotifierProxyProvider<SessionService, SessionViewModel>(
          create:
              (context) => SessionViewModel(
                Provider.of<SessionService>(context, listen: false),
              ),
          update:
              (context, sessionService, previous) =>
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
          '/dashboard-user': (context) => DashboardUserPage(),
          '/dashboard-psychiatrist': (context) => DashboardPsychiatristPage(),
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkSession();
  }

  void checkSession() async {
    final sessionViewModel = Provider.of<SessionViewModel>(
      context,
      listen: false,
    );
    await Future.delayed(Duration(seconds: 2));

    if (!mounted) return;

    if (await sessionViewModel.isSessionActive()) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      if (!mounted) return;
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
