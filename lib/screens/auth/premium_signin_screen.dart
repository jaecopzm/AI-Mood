import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/premium_theme.dart';
import '../../widgets/premium_widgets.dart';
import '../../core/services/logger_service.dart';
import '../../providers/auth_provider.dart';

class PremiumSignInScreen extends ConsumerStatefulWidget {
  final VoidCallback onSignInSuccess;
  final VoidCallback onNavigateToSignUp;

  const PremiumSignInScreen({
    super.key,
    required this.onSignInSuccess,
    required this.onNavigateToSignUp,
  });

  @override
  ConsumerState<PremiumSignInScreen> createState() =>
      _PremiumSignInScreenState();
}

class _PremiumSignInScreenState extends ConsumerState<PremiumSignInScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      LoggerService.info('🔐 Attempting email/password sign-in');

      // Use Firebase Auth via provider
      await ref
          .read(authStateProvider.notifier)
          .signIn(_emailController.text.trim(), _passwordController.text);

      // Check if sign-in was successful
      final authState = ref.read(authStateProvider);
      if (authState.isAuthenticated) {
        LoggerService.info('✅ Email sign-in successful');
        widget.onSignInSuccess();
      } else if (authState.error != null) {
        throw Exception(authState.error);
      }
    } catch (e) {
      LoggerService.error('❌ Email sign-in failed', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      LoggerService.info('🔐 Attempting Google Sign-In');

      // Use Firebase Google Auth via provider
      await ref.read(authStateProvider.notifier).signInWithGoogle();

      // Check if sign-in was successful
      final authState = ref.read(authStateProvider);
      if (authState.isAuthenticated) {
        LoggerService.info('✅ Google Sign-In successful');
        widget.onSignInSuccess();
      } else if (authState.error != null) {
        throw Exception(authState.error);
      }
    } catch (e) {
      LoggerService.error('❌ Google Sign-In failed', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              PremiumTheme.primary,
              PremiumTheme.secondary,
              PremiumTheme.accent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(PremiumTheme.spaceLg),
              child: Column(
                children: [
                  const SizedBox(height: PremiumTheme.spaceLg),
                  _buildHeader(),
                  const SizedBox(height: PremiumTheme.spaceLg),
                  _buildSignInForm(),
                  const SizedBox(height: PremiumTheme.spaceLg),
                  _buildSignUpPrompt(),
                  const SizedBox(height: PremiumTheme.spaceLg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(PremiumTheme.spaceLg),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ShaderMask(
                shaderCallback: (bounds) =>
                    PremiumTheme.premiumGradient.createShader(bounds),
                child: const Icon(Icons.diamond, size: 64, color: Colors.white),
              ),
            ),
            const SizedBox(height: PremiumTheme.spaceLg),
            const Text(
              'AI Mood',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: PremiumTheme.spaceXs),
            Text(
              'Craft the perfect message',
              style: PremiumTheme.bodyLarge.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInForm() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(PremiumTheme.spaceLg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(PremiumTheme.radiusXl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back',
                style: PremiumTheme.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: PremiumTheme.spaceXs),
              Text(
                'Sign in to continue',
                style: PremiumTheme.bodyMedium.copyWith(
                  color: PremiumTheme.textSecondary,
                ),
              ),
              const SizedBox(height: PremiumTheme.spaceLg),
              PremiumTextField(
                label: 'Email',
                hint: 'your.email@example.com',
                icon: Icons.email_outlined,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: PremiumTheme.spaceMd),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password',
                    style: PremiumTheme.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: PremiumTheme.spaceSm),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        PremiumTheme.radiusMd,
                      ),
                      border: Border.all(color: PremiumTheme.border),
                      color: PremiumTheme.surfaceVariant,
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: PremiumTheme.bodyLarge,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: PremiumTheme.bodyMedium.copyWith(
                          color: PremiumTheme.textTertiary,
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: PremiumTheme.primary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: PremiumTheme.textSecondary,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: PremiumTheme.spaceMd,
                          vertical: PremiumTheme.spaceMd,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PremiumTheme.spaceSm),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Forgot password logic
                  },
                  child: Text(
                    'Forgot Password?',
                    style: PremiumTheme.labelMedium.copyWith(
                      color: PremiumTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: PremiumTheme.spaceMd),
              PremiumButton(
                text: 'Sign In',
                onPressed: _handleSignIn,
                isLoading: _isLoading,
                gradient: PremiumTheme.premiumGradient,
                icon: Icons.login,
              ),
              const SizedBox(height: PremiumTheme.spaceLg),
              Row(
                children: [
                  Expanded(child: Divider(color: PremiumTheme.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PremiumTheme.spaceMd,
                    ),
                    child: Text(
                      'OR',
                      style: PremiumTheme.bodySmall.copyWith(
                        color: PremiumTheme.textTertiary,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: PremiumTheme.border)),
                ],
              ),
              const SizedBox(height: PremiumTheme.spaceLg),
              _buildGoogleSignInButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return GestureDetector(
      onTap: _handleGoogleSignIn,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: PremiumTheme.spaceMd),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: PremiumTheme.border, width: 2),
          borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
          boxShadow: [PremiumTheme.shadowSm],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/google.png', width: 24, height: 24),
            const SizedBox(width: PremiumTheme.spaceMd),
            Text(
              'Continue with Google',
              style: PremiumTheme.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: PremiumTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpPrompt() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Don\'t have an account? ',
            style: PremiumTheme.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          GestureDetector(
            onTap: widget.onNavigateToSignUp,
            child: Text(
              'Sign Up',
              style: PremiumTheme.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
