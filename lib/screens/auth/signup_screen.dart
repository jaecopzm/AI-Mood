import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/premium_theme.dart';
import '../../widgets/premium_widgets.dart';
import '../../core/services/logger_service.dart';
import '../../providers/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  final VoidCallback onSignUpSuccess;
  final VoidCallback onNavigateToSignIn;

  const SignUpScreen({
    super.key,
    required this.onSignUpSuccess,
    required this.onNavigateToSignIn,
  });

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please agree to Terms and Privacy Policy'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      LoggerService.info('🔐 Attempting email/password sign-up');

      // Use Firebase Auth via provider
      await ref
          .read(authStateProvider.notifier)
          .signUp(
            _emailController.text.trim(),
            _passwordController.text,
            _nameController.text.trim(),
          );

      // Check if sign-up was successful
      final authState = ref.read(authStateProvider);
      if (authState.isAuthenticated) {
        LoggerService.info('✅ Email sign-up successful');

        if (mounted) {
          // Show verification message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Account created! Please check your email to verify your account.',
              ),
              backgroundColor: PremiumTheme.success,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
              ),
            ),
          );
        }

        widget.onSignUpSuccess();
      } else if (authState.error != null) {
        throw Exception(authState.error);
      }
    } catch (e) {
      LoggerService.error('❌ Email sign-up failed', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign up failed: ${e.toString()}'),
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

  Future<void> _handleGoogleSignUp() async {
    try {
      LoggerService.info('🔐 Attempting Google Sign-Up');

      // Use Firebase Google Auth via provider
      await ref.read(authStateProvider.notifier).signInWithGoogle();

      // Check if sign-up was successful
      final authState = ref.read(authStateProvider);
      if (authState.isAuthenticated) {
        LoggerService.info('✅ Google Sign-Up successful');
        widget.onSignUpSuccess();
      } else if (authState.error != null) {
        throw Exception(authState.error);
      }
    } catch (e) {
      LoggerService.error('❌ Google Sign-Up failed', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-Up failed: ${e.toString()}'),
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
                  const SizedBox(height: PremiumTheme.space2xl),
                  _buildHeader(),
                  const SizedBox(height: PremiumTheme.space3xl),
                  _buildSignUpForm(),
                  const SizedBox(height: PremiumTheme.spaceLg),
                  _buildSignInPrompt(),
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

  Widget _buildSignUpForm() {
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
                'Create Account',
                style: PremiumTheme.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: PremiumTheme.spaceXs),
              Text(
                'Get started with AI Mood today',
                style: PremiumTheme.bodyMedium.copyWith(
                  color: PremiumTheme.textSecondary,
                ),
              ),
              const SizedBox(height: PremiumTheme.spaceLg),
              PremiumTextField(
                label: 'Full Name',
                hint: 'John Doe',
                icon: Icons.person_outline,
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: PremiumTheme.spaceMd),
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
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Min. 6 characters',
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
              const SizedBox(height: PremiumTheme.spaceMd),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confirm Password',
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
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      style: PremiumTheme.bodyLarge,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Repeat your password',
                        hintStyle: PremiumTheme.bodyMedium.copyWith(
                          color: PremiumTheme.textTertiary,
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: PremiumTheme.primary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: PremiumTheme.textSecondary,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
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
              const SizedBox(height: PremiumTheme.spaceMd),
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) {
                        setState(() => _agreeToTerms = value ?? false);
                      },
                      activeColor: PremiumTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          PremiumTheme.radiusSm,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: PremiumTheme.spaceSm),
                  Expanded(
                    child: Text(
                      'I agree to Terms of Service and Privacy Policy',
                      style: PremiumTheme.bodySmall.copyWith(
                        color: PremiumTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PremiumTheme.spaceLg),
              PremiumButton(
                text: 'Create Account',
                onPressed: _handleSignUp,
                isLoading: _isLoading,
                gradient: PremiumTheme.premiumGradient,
                icon: Icons.check_circle,
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
              _buildGoogleSignUpButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignUpButton() {
    return GestureDetector(
      onTap: _handleGoogleSignUp,
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

  Widget _buildSignInPrompt() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Already have an account? ',
            style: PremiumTheme.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          GestureDetector(
            onTap: widget.onNavigateToSignIn,
            child: Text(
              'Sign In',
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
