import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../core/di/service_locator.dart';
import '../core/services/error_handler.dart';
import '../core/services/logger_service.dart';
import '../core/validators/input_validators.dart';

// Export for use in message_provider
export '../services/firebase_service.dart' show FirebaseService;

// Firebase service provider (using DI)
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return getIt<FirebaseService>();
});

// Auth state provider
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier(ref.read(firebaseServiceProvider));
});

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  final FirebaseService _firebaseService;

  AuthStateNotifier(this._firebaseService) : super(AuthState());

  Future<void> signIn(String email, String password) async {
    // Validate inputs
    final emailError = InputValidators.validateEmail(email);
    if (emailError != null) {
      state = state.copyWith(error: emailError, isLoading: false);
      return;
    }

    final passwordError = InputValidators.validatePassword(password, minLength: 6);
    if (passwordError != null) {
      state = state.copyWith(error: passwordError, isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    
    try {
      LoggerService.info('Auth: Attempting sign in');
      
      final result = await _firebaseService.signIn(
        email: email.trim(),
        password: password,
      );

      await result.when(
        success: (userCredential) async {
          final firebaseUser = userCredential.user;
          if (firebaseUser != null) {
            // Fetch user data from Firestore
            final userResult = await _firebaseService.getCurrentUser();
            
            userResult.when(
              success: (user) {
                state = state.copyWith(
                  user: user,
                  isAuthenticated: true,
                  isLoading: false,
                  error: null,
                );
                LoggerService.info('Auth: Sign in successful');
              },
              failure: (error) {
                // If user document doesn't exist, create a basic user object
                final user = User(
                  uid: firebaseUser.uid,
                  email: firebaseUser.email ?? email,
                  displayName: firebaseUser.displayName ?? 'User',
                  subscriptionTier: 'free',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  monthlyCreditsUsed: 0,
                  totalMessagesGenerated: 0,
                );
                
                state = state.copyWith(
                  user: user,
                  isAuthenticated: true,
                  isLoading: false,
                  error: null,
                );
                LoggerService.warning('Auth: User document not found, using basic profile');
              },
            );
          } else {
            state = state.copyWith(
              error: 'Sign in failed: No user data received',
              isLoading: false,
            );
          }
        },
        failure: (error) {
          final message = ErrorHandler.getUserFriendlyMessage(error);
          state = state.copyWith(error: message, isLoading: false);
          LoggerService.error('Auth: Sign in failed', error);
        },
      );
    } catch (e, stackTrace) {
      final message = ErrorHandler.getUserFriendlyMessage(e);
      state = state.copyWith(error: message, isLoading: false);
      LoggerService.error('Auth: Unexpected error during sign in', e, stackTrace);
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    // Validate inputs
    final emailError = InputValidators.validateEmail(email);
    if (emailError != null) {
      state = state.copyWith(error: emailError, isLoading: false);
      return;
    }

    final passwordError = InputValidators.validatePassword(password);
    if (passwordError != null) {
      state = state.copyWith(error: passwordError, isLoading: false);
      return;
    }

    final nameError = InputValidators.validateDisplayName(name);
    if (nameError != null) {
      state = state.copyWith(error: nameError, isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    
    try {
      LoggerService.info('Auth: Attempting sign up');
      
      final result = await _firebaseService.signUp(
        email: email.trim(),
        password: password,
        displayName: name.trim(),
      );

      await result.when(
        success: (userCredential) async {
          final firebaseUser = userCredential.user;
          if (firebaseUser != null) {
            // Fetch user data from Firestore
            final userResult = await _firebaseService.getCurrentUser();
            
            userResult.when(
              success: (user) {
                state = state.copyWith(
                  user: user,
                  isAuthenticated: true,
                  isLoading: false,
                  error: null,
                );
                LoggerService.info('Auth: Sign up successful');
              },
              failure: (error) {
                // Fallback user object
                final user = User(
                  uid: firebaseUser.uid,
                  email: firebaseUser.email ?? email,
                  displayName: firebaseUser.displayName ?? name,
                  subscriptionTier: 'free',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  monthlyCreditsUsed: 0,
                  totalMessagesGenerated: 0,
                );
                
                state = state.copyWith(
                  user: user,
                  isAuthenticated: true,
                  isLoading: false,
                  error: null,
                );
                LoggerService.warning('Auth: Using fallback user profile');
              },
            );
          } else {
            state = state.copyWith(
              error: 'Sign up failed: No user data received',
              isLoading: false,
            );
          }
        },
        failure: (error) {
          final message = ErrorHandler.getUserFriendlyMessage(error);
          state = state.copyWith(error: message, isLoading: false);
          LoggerService.error('Auth: Sign up failed', error);
        },
      );
    } catch (e, stackTrace) {
      final message = ErrorHandler.getUserFriendlyMessage(e);
      state = state.copyWith(error: message, isLoading: false);
      LoggerService.error('Auth: Unexpected error during sign up', e, stackTrace);
    }
  }

  Future<void> logout() async {
    try {
      LoggerService.info('Auth: Attempting logout');
      
      final result = await _firebaseService.signOut();
      
      result.when(
        success: (_) {
          state = AuthState();
          LoggerService.info('Auth: Logout successful');
        },
        failure: (error) {
          final message = ErrorHandler.getUserFriendlyMessage(error);
          state = state.copyWith(error: message);
          LoggerService.error('Auth: Logout failed', error);
        },
      );
    } catch (e, stackTrace) {
      final message = ErrorHandler.getUserFriendlyMessage(e);
      state = state.copyWith(error: message);
      LoggerService.error('Auth: Unexpected error during logout', e, stackTrace);
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      LoggerService.info('Auth: Attempting Google sign in');
      
      final result = await _firebaseService.signInWithGoogle();

      await result.when(
        success: (userCredential) async {
          final firebaseUser = userCredential.user;
          if (firebaseUser != null) {
            // Fetch user data from Firestore
            final userResult = await _firebaseService.getCurrentUser();
            
            userResult.when(
              success: (user) {
                state = state.copyWith(
                  user: user,
                  isAuthenticated: true,
                  isLoading: false,
                  error: null,
                );
                LoggerService.info('Auth: Google sign in successful');
              },
              failure: (error) {
                // Fallback user object
                final user = User(
                  uid: firebaseUser.uid,
                  email: firebaseUser.email ?? '',
                  displayName: firebaseUser.displayName ?? 'User',
                  subscriptionTier: 'free',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  monthlyCreditsUsed: 0,
                  totalMessagesGenerated: 0,
                );
                
                state = state.copyWith(
                  user: user,
                  isAuthenticated: true,
                  isLoading: false,
                  error: null,
                );
                LoggerService.warning('Auth: Using fallback user profile after Google sign in');
              },
            );
          } else {
            state = state.copyWith(
              error: 'Google sign in failed: No user data received',
              isLoading: false,
            );
          }
        },
        failure: (error) {
          final message = ErrorHandler.getUserFriendlyMessage(error);
          state = state.copyWith(error: message, isLoading: false);
          LoggerService.error('Auth: Google sign in failed', error);
        },
      );
    } catch (e, stackTrace) {
      final message = ErrorHandler.getUserFriendlyMessage(e);
      state = state.copyWith(error: message, isLoading: false);
      LoggerService.error('Auth: Unexpected error during Google sign in', e, stackTrace);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
