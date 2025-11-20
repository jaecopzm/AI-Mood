import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'config/premium_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth/premium_signin_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/app_initializer.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'services/firebase_service.dart';
import 'core/config/env_config.dart';
import 'core/di/service_locator.dart';
import 'core/services/logger_service.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize environment configuration
    print('🔧 Initializing environment configuration...');
    try {
      await EnvConfig.initialize();
      print('✅ Environment configuration loaded');
    } catch (e) {
      print('⚠️ Environment file not found, using defaults');
      // Continue without .env file - app can still work
    }

    // Initialize Firebase
    print('🔧 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized');

    // Initialize Hive for local storage
    print('🔧 Initializing Hive...');
    await Hive.initFlutter();
    print('✅ Hive initialized');

    // Setup dependency injection
    print('🔧 Setting up dependency injection...');
    await setupServiceLocator();
    print('✅ Dependency injection setup complete');

    print('🎉 App initialization completed successfully!');

    // Run the app
    runApp(const ProviderScope(child: MainApp()));
  } catch (e, stackTrace) {
    LoggerService.fatal('Failed to initialize app', e, stackTrace);

    // Show error screen
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 24),
                  const Text(
                    'Failed to Initialize App',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${e.toString()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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
  bool _showOnboarding = false;
  bool _isCheckingStatus = true;
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _checkAppStatus();
  }

  Future<void> _checkAppStatus() async {
    try {
      // Check onboarding status
      final prefs = await SharedPreferences.getInstance();
      final hasCompletedOnboarding =
          prefs.getBool('onboarding_complete') ?? false;

      // Check authentication status using Firebase
      final user = getIt<FirebaseService>().currentFirebaseUser;
      final isAuthenticated = user != null;

      LoggerService.info(
        'App status check: onboarding=$hasCompletedOnboarding, auth=$isAuthenticated',
      );

      setState(() {
        _showOnboarding = !hasCompletedOnboarding;
        _isAuthenticated = isAuthenticated;
        _isCheckingStatus = false;
      });
    } catch (e) {
      LoggerService.error('Failed to check app status', e);
      setState(() {
        _showOnboarding = true; // Show onboarding if check fails
        _isAuthenticated = false;
        _isCheckingStatus = false;
      });
    }
  }

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
    // Show loading while checking app status
    if (_isCheckingStatus) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  PremiumTheme.primary,
                  PremiumTheme.secondary,
                  PremiumTheme.accent,
                ],
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Mood - Premium Experience',
      themeMode: _themeMode,
      theme: PremiumTheme.lightTheme,
      darkTheme: PremiumTheme.darkTheme,
      home: _showOnboarding
          ? const OnboardingScreen()
          : (_isAuthenticated
                ? const AppInitializer()
                : (_isSignUp
                      ? SignUpScreen(
                          onSignUpSuccess: _handleSignUpSuccess,
                          onNavigateToSignIn: _navigateToSignIn,
                        )
                      : PremiumSignInScreen(
                          onSignInSuccess: _handleSignInSuccess,
                          onNavigateToSignUp: _navigateToSignUp,
                        ))),
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
