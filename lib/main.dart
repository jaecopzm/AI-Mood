import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'config/premium_theme.dart';
import 'screens/auth/signin_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/premium_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  // App States
  bool _isAuthenticated = false;
  bool _isSignUp = false;
  ThemeMode _themeMode = ThemeMode.light;

  void _handleSignInSuccess() {
    setState(() => _isAuthenticated = true);
  }

  void _handleSignUpSuccess() {
    setState(() {
      _isAuthenticated = true;
      _isSignUp = false;
    });
  }

  void _navigateToSignUp() {
    setState(() => _isSignUp = true);
  }

  void _navigateToSignIn() {
    setState(() => _isSignUp = false);
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Mood - Premium Experience',
      themeMode: _themeMode,
      theme: PremiumTheme.lightTheme,
      darkTheme: PremiumTheme.darkTheme,
      home: _isAuthenticated
          ? const PremiumMainScreen()
          : (_isSignUp
                ? SignUpScreen(
                    onSignUpSuccess: _handleSignUpSuccess,
                    onNavigateToSignIn: _navigateToSignIn,
                  )
                : SignInScreen(
                    onSignInSuccess: _handleSignInSuccess,
                    onNavigateToSignUp: _navigateToSignUp,
                  )),
    );
  }

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }
}
