import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

// Auth state provider
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((
  ref,
) {
  return AuthStateNotifier();
});

// Firebase service provider
final firebaseServiceProvider = Provider((ref) => FirebaseService());

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
  final FirebaseService _firebaseService = FirebaseService();

  AuthStateNotifier() : super(AuthState());

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userCredential = await _firebaseService.signIn(
        email: email,
        password: password,
      );

      if (userCredential?.user != null) {
        final firebaseUser = userCredential!.user!;
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
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userCredential = await _firebaseService.signUp(
        email: email,
        password: password,
        displayName: name,
      );

      if (userCredential?.user != null) {
        final firebaseUser = userCredential!.user!;
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
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseService.signOut();
      state = AuthState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userCredential = await _firebaseService.signInWithGoogle();

      if (userCredential?.user != null) {
        final firebaseUser = userCredential!.user!;
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
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
