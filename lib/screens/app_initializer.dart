import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/subscription_provider.dart';
import '../providers/auth_provider.dart';
import '../config/premium_theme.dart';
import 'premium_main_screen.dart';

/// Wrapper widget that initializes subscription system after authentication
class AppInitializer extends ConsumerStatefulWidget {
  const AppInitializer({super.key});

  @override
  ConsumerState<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer> {
  bool _isInitializing = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeSubscriptionSystem();
  }

  Future<void> _initializeSubscriptionSystem() async {
    try {
      final authState = ref.read(authStateProvider);
      final userId = authState.user?.uid;

      if (userId != null) {
        // Initialize RevenueCat and load subscription status
        await ref.read(subscriptionProvider.notifier).initialize(userId);
      }

      setState(() {
        _isInitializing = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                SizedBox(height: 24),
                Text(
                  'Loading your subscription...',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      // Show error but still allow app to continue
      // RevenueCat might not be configured yet
      return const PremiumMainScreen();
    }

    return const PremiumMainScreen();
  }
}
