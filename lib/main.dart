import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
// import './model/user_model.dart';
import 'screens/auth/forgot_password_view.dart';
import 'screens/auth/login_view.dart';
import 'screens/dashboard/dashboard_psychiatrist_view.dart';
import 'screens/dashboard/dashboard_user_view.dart';
import 'services/auth/auth_service.dart';


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
        // Removed SessionService provider as it's not being used
        ChangeNotifierProxyProvider<AuthService, AuthViewModel>(
          create:
              (context) => AuthViewModel(
                Provider.of<AuthService>(context, listen: false),
              ),
          update:
              (context, authService, previousAuthViewModel) => AuthViewModel(authService),
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
    // Capture navigator if you prefer, or use context directly with mounted checks
    final navigator = Navigator.of(context);

    await Future.delayed(const Duration(seconds: 2)); // Added const

    if (!mounted) return;

    bool sessionActive;
    try {
      // Check Firebase Auth directly for an active user session
      final currentUser = FirebaseAuth.instance.currentUser;
      sessionActive = currentUser != null;
    } catch (e) {
      // Log error if any unexpected issue occurs during Firebase check
      print('Error checking Firebase session: $e');
      if (!mounted) return;
      navigator.pushReplacementNamed('/login');
      return;
    }

    if (!mounted) return; // Check after the await

    if (sessionActive) {
      // TODO: Determine which dashboard to navigate to based on user role.
      // If sessionActive is true, FirebaseAuth.instance.currentUser is not null.
      // You might need to fetch user details (like role) from Firestore
      // using FirebaseAuth.instance.currentUser.uid to decide the dashboard.
      // Defaulting to '/dashboard-user' as a placeholder.
      navigator.pushReplacementNamed('/dashboard-user');
    } else {
      if (!mounted) return;
      navigator.pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold( // Added const
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Mood Tracker',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold), // This TextStyle can be const
            ),
            SizedBox(height: 20), // This SizedBox can be const
            CircularProgressIndicator(), // This can be const
          ],
        ),
      ),
    );
  }
}
