import 'dart:math' as math;

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:map_upholders/screens/journal/journal_list_screen.dart';
import 'package:map_upholders/screens/journal/journal_reminder_page.dart';
import 'package:map_upholders/screens/journal/voice_journal_page.dart';
import 'package:map_upholders/screens/mood_tracking/mood_chart_page.dart';
import 'package:map_upholders/screens/mood_tracking/mood_scale_viewer_page.dart';

import 'package:provider/provider.dart';
import './model/auth_models.dart'; // For UserRole enum
import './viewmodels/auth_viewmodel.dart';
import './viewmodels/session_viewmodel.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart'; // <-- Add this import
import 'screens/dashboard/dashboard_therapist_page.dart';
import 'screens/dashboard/dashboard_user_page.dart';
import 'services/auth/auth_service.dart';
import 'services/sessions/session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
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
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register':
              (context) =>
                  const RegisterScreen(), // <-- Added registration route
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/dashboard-user': (context) => const DashboardUserPage(),
          '/dashboard-therapist': (context) => const DashboardTherapistPage(),
          '/mood-scale-viewer': (context) => const MoodScaleViewerPage(),
          '/voice-journal': (context) => const VoiceJournalPage(),
          '/mood-chart': (context) => const MoodChartPage(),
          '/journal-reminder': (context) => const JournalReminderPage(),
          '/journal-list': (context) => const JournalListScreen(),
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

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _emojiController;

  @override
  void initState() {
    super.initState();
    _emojiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    checkSession();
  }

  @override
  void dispose() {
    _emojiController.dispose();
    super.dispose();
  }

  void checkSession() async {
    final sessionViewModel = Provider.of<SessionViewModel>(
      context,
      listen: false,
    );
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    await Future.delayed(const Duration(seconds: 2)); // Simulate loading

    if (!mounted) return;

    if (await sessionViewModel.isSessionActive()) {
      final userModel = authViewModel.currentUser;

      if (userModel != null) {
        final userRole = UserRole.fromString(userModel.userType);
        switch (userRole) {
          case UserRole.therapist:
            Navigator.of(context).pushReplacementNamed('/dashboard-therapist');
            break;
          case UserRole.student:
            Navigator.of(context).pushReplacementNamed('/dashboard-user');
            break;
          default:
            print(
              "User role '${userModel.userType}' (parsed as $userRole) not explicitly handled for dashboard, defaulting to /dashboard-user.",
            );
            Navigator.of(context).pushReplacementNamed('/dashboard-user');
        }
      } else {
        print(
          "Session active but user profile (UserModel from AuthViewModel) is null. Navigating to login.",
        );
        Navigator.of(context).pushReplacementNamed('/register');
      }
    } else {
      Navigator.of(context).pushReplacementNamed('/register');
    }
  }

  @override
  Widget build(BuildContext context) {
    final emojis = ["😀", "😊", "😞", "😐", "😡", "😲", "😴"];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFA7B77A),
                  Color(0xFFE6E1C5),
                  Color(0xFFFFDF7F),
                  Color(0xFFD6E4FF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          ...List.generate(emojis.length, (i) {
            final angle = i * 2 * math.pi / emojis.length;
            return AnimatedBuilder(
              animation: _emojiController,
              builder: (context, child) {
                final radius =
                    110.0 +
                    25 * math.sin(_emojiController.value * 2 * math.pi + angle);
                final dx = 0.45 + 0.45 * math.cos(angle);
                final dy = 0.45 + 0.35 * math.sin(angle);
                return Positioned(
                  left: MediaQuery.of(context).size.width * dx - 30,
                  top: MediaQuery.of(context).size.height * dy - 30,
                  child: Opacity(
                    opacity: 0.8,
                    child: Text(
                      emojis[i],
                      style: TextStyle(
                        fontSize:
                            48 +
                            12 *
                                math.sin(
                                  _emojiController.value * 2 * math.pi + angle,
                                ),
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.brown.withOpacity(0.15),
                            offset: const Offset(3, 6),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB0E57C), Color(0xFF6EC4E3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.brown.withOpacity(0.13),
                        blurRadius: 30,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: const [
                      Text("😊", style: TextStyle(fontSize: 54)),
                      SizedBox(height: 5),
                      Text(
                        "🎤",
                        style: TextStyle(fontSize: 24, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Text(
                  'Mood Tracker',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nunito',
                    letterSpacing: 1,
                    color: Colors.brown[800],
                    shadows: [
                      Shadow(
                        blurRadius: 8,
                        color: Colors.brown.withOpacity(0.13),
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Your Mood, Your Journey",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.brown[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 44),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA7B77A)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
