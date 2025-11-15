import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';
import '../core/exceptions/app_exceptions.dart';
import '../core/services/logger_service.dart';
import '../core/services/error_handler.dart';
import '../core/utils/result.dart';

class FirebaseService {
  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  FirebaseService({
    firebase_auth.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  // Auth Methods
  Future<Result<firebase_auth.UserCredential>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      LoggerService.info('Attempting to sign up user: $email');

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(displayName);

      // Create user document in Firestore
      if (userCredential.user != null) {
        await _createUserDocument(userCredential.user!);
        LoggerService.info('User signed up successfully: ${userCredential.user!.uid}');
      }

      return Result.success(userCredential);
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      final error = ErrorHandler.convertFirebaseException(e);
      LoggerService.error('Sign up failed', e, stackTrace);
      return Result.failure(error);
    } catch (e, stackTrace) {
      final error = AuthException(
        'Sign up failed: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
      LoggerService.error('Unexpected error during sign up', e, stackTrace);
      return Result.failure(error);
    }
  }

  Future<Result<firebase_auth.UserCredential>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      LoggerService.info('Attempting to sign in user: $email');

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      LoggerService.info('User signed in successfully: ${userCredential.user?.uid}');
      return Result.success(userCredential);
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      final error = ErrorHandler.convertFirebaseException(e);
      LoggerService.error('Sign in failed', e, stackTrace);
      return Result.failure(error);
    } catch (e, stackTrace) {
      final error = AuthException(
        'Sign in failed: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
      LoggerService.error('Unexpected error during sign in', e, stackTrace);
      return Result.failure(error);
    }
  }

  Future<Result<void>> signOut() async {
    try {
      LoggerService.info('Signing out user');
      await _auth.signOut();
      await _googleSignIn.signOut();
      LoggerService.info('User signed out successfully');
      return Result.success(null);
    } catch (e, stackTrace) {
      final error = AuthException(
        'Sign out failed',
        originalError: e,
        stackTrace: stackTrace,
      );
      LoggerService.error('Sign out failed', e, stackTrace);
      return Result.failure(error);
    }
  }

  Future<Result<void>> resetPassword(String email) async {
    try {
      LoggerService.info('Sending password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email);
      LoggerService.info('Password reset email sent successfully');
      return Result.success(null);
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      final error = ErrorHandler.convertFirebaseException(e);
      LoggerService.error('Password reset failed', e, stackTrace);
      return Result.failure(error);
    } catch (e, stackTrace) {
      final error = AuthException(
        'Password reset failed',
        originalError: e,
        stackTrace: stackTrace,
      );
      LoggerService.error('Unexpected error during password reset', e, stackTrace);
      return Result.failure(error);
    }
  }

  Future<Result<firebase_auth.UserCredential>> signInWithGoogle() async {
    try {
      LoggerService.info('Attempting Google sign-in');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        final error = AuthException('Google sign-in was cancelled by user');
        LoggerService.warning('Google sign-in cancelled');
        return Result.failure(error);
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final firebase_auth.AuthCredential credential =
          firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Create user document in Firestore if new user
      if (userCredential.user != null) {
        await _createUserDocument(userCredential.user!);
        LoggerService.info('Google sign-in successful: ${userCredential.user!.uid}');
      }

      return Result.success(userCredential);
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      final error = ErrorHandler.convertFirebaseException(e);
      LoggerService.error('Google sign-in failed', e, stackTrace);
      return Result.failure(error);
    } catch (e, stackTrace) {
      final error = AuthException(
        'Google sign-in failed',
        originalError: e,
        stackTrace: stackTrace,
      );
      LoggerService.error('Unexpected error during Google sign-in', e, stackTrace);
      return Result.failure(error);
    }
  }

  // User Document Methods
  Future<void> _createUserDocument(firebase_auth.User firebaseUser) async {
    try {
      // Check if user document already exists
      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (doc.exists) {
        LoggerService.info('User document already exists for: ${firebaseUser.uid}');
        return;
      }

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

      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(user.toJson());

      LoggerService.info('User document created: ${firebaseUser.uid}');
    } on FirebaseException catch (e, stackTrace) {
      LoggerService.error('Failed to create user document', e, stackTrace);
      throw DatabaseException(
        'Failed to create user profile',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      LoggerService.error('Unexpected error creating user document', e, stackTrace);
      throw DatabaseException(
        'Failed to create user profile',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<Result<User>> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        return Result.failure(AuthException('No user is currently signed in'));
      }

      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final user = User.fromJson(doc.data()!);
        return Result.success(user);
      }

      return Result.failure(NotFoundException('User profile not found'));
    } on FirebaseException catch (e, stackTrace) {
      LoggerService.error('Failed to get current user', e, stackTrace);
      return Result.failure(DatabaseException(
        'Failed to retrieve user profile',
        originalError: e,
        stackTrace: stackTrace,
      ));
    } catch (e, stackTrace) {
      LoggerService.error('Unexpected error getting current user', e, stackTrace);
      return Result.failure(DatabaseException(
        'Failed to retrieve user profile',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  Future<Result<User>> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        final user = User.fromJson(doc.data()!);
        return Result.success(user);
      }

      return Result.failure(NotFoundException('User not found'));
    } on FirebaseException catch (e, stackTrace) {
      LoggerService.error('Failed to get user by ID', e, stackTrace);
      return Result.failure(DatabaseException(
        'Failed to retrieve user',
        originalError: e,
        stackTrace: stackTrace,
      ));
    } catch (e, stackTrace) {
      LoggerService.error('Unexpected error getting user by ID', e, stackTrace);
      return Result.failure(DatabaseException(
        'Failed to retrieve user',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  // Message Methods
  Future<Result<void>> saveMessage(MessageModel message) async {
    try {
      LoggerService.info('Saving message: ${message.id}');

      await _firestore
          .collection('messages')
          .doc(message.id)
          .set(message.toJson());

      // Update user message count
      await _updateUserMessageCount(message.userId);

      LoggerService.info('Message saved successfully: ${message.id}');
      return Result.success(null);
    } on FirebaseException catch (e, stackTrace) {
      LoggerService.error('Failed to save message', e, stackTrace);
      return Result.failure(DatabaseException(
        'Failed to save message',
        originalError: e,
        stackTrace: stackTrace,
      ));
    } catch (e, stackTrace) {
      LoggerService.error('Unexpected error saving message', e, stackTrace);
      return Result.failure(DatabaseException(
        'Failed to save message',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  Future<Result<List<MessageModel>>> getUserMessages(
    String userId, {
    int limit = 50,
  }) async {
    try {
      LoggerService.info('Fetching messages for user: $userId');

      final snapshot = await _firestore
          .collection('messages')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final messages = snapshot.docs
          .map((doc) => MessageModel.fromJson(doc.data()))
          .toList();

      LoggerService.info('Fetched ${messages.length} messages');
      return Result.success(messages);
    } on FirebaseException catch (e, stackTrace) {
      LoggerService.error('Failed to get user messages', e, stackTrace);
      return Result.failure(DatabaseException(
        'Failed to retrieve messages',
        originalError: e,
        stackTrace: stackTrace,
      ));
    } catch (e, stackTrace) {
      LoggerService.error('Unexpected error getting user messages', e, stackTrace);
      return Result.failure(DatabaseException(
        'Failed to retrieve messages',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  Future<Result<void>> updateMessage(
    String messageId,
    Map<String, dynamic> updates,
  ) async {
    try {
      LoggerService.info('Updating message: $messageId');

      await _firestore.collection('messages').doc(messageId).update(updates);

      LoggerService.info('Message updated successfully: $messageId');
      return Result.success(null);
    } on FirebaseException catch (e, stackTrace) {
      LoggerService.error('Failed to update message', e, stackTrace);
      return Result.failure(DatabaseException(
        'Failed to update message',
        originalError: e,
        stackTrace: stackTrace,
      ));
    } catch (e, stackTrace) {
      LoggerService.error('Unexpected error updating message', e, stackTrace);
      return Result.failure(DatabaseException(
        'Failed to update message',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  Future<Result<void>> deleteMessage(String messageId) async {
    try {
      LoggerService.info('Deleting message: $messageId');

      await _firestore.collection('messages').doc(messageId).delete();

      LoggerService.info('Message deleted successfully: $messageId');
      return Result.success(null);
    } on FirebaseException catch (e, stackTrace) {
      LoggerService.error('Failed to delete message', e, stackTrace);
      return Result.failure(DatabaseException(
        'Failed to delete message',
        originalError: e,
        stackTrace: stackTrace,
      ));
    } catch (e, stackTrace) {
      LoggerService.error('Unexpected error deleting message', e, stackTrace);
      return Result.failure(DatabaseException(
        'Failed to delete message',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  // Subscription Methods
  Future<Subscription?> getUserSubscription(String userId) async {
    try {
      final doc = await _firestore
          .collection('subscriptions')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (doc.docs.isNotEmpty) {
        return Subscription.fromJson(doc.docs.first.data());
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get subscription: $e');
    }
  }

  Future<void> updateSubscription({
    required String userId,
    required String planType,
  }) async {
    try {
      final subscriptionId = _firestore.collection('subscriptions').doc().id;
      final subscription = Subscription(
        subscriptionId: subscriptionId,
        userId: userId,
        planType: planType,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        isActive: true,
        paymentMethod: 'stripe', // Update as needed
      );

      await _firestore
          .collection('subscriptions')
          .doc(subscriptionId)
          .set(subscription.toJson());

      // Update user subscription tier
      await _firestore.collection('users').doc(userId).update({
        'subscriptionTier': planType,
      });
    } catch (e) {
      throw Exception('Failed to update subscription: $e');
    }
  }

  // Usage Tracking Methods
  Future<void> logUsage({
    required String userId,
    required int creditsUsed,
  }) async {
    try {
      await _firestore.collection('usage_logs').add({
        'userId': userId,
        'creditsUsed': creditsUsed,
        'date': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to log usage: $e');
    }
  }

  Future<int> getMonthlyCreditUsage(String userId) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final snapshot = await _firestore
          .collection('usage_logs')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .get();

      int totalUsed = 0;
      for (var doc in snapshot.docs) {
        totalUsed += (doc.data()['creditsUsed'] as int?) ?? 0;
      }
      return totalUsed;
    } catch (e) {
      throw Exception('Failed to get credit usage: $e');
    }
  }

  // Helper Methods
  Future<void> _updateUserMessageCount(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'totalMessagesGenerated': FieldValue.increment(1),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } on FirebaseException catch (e, stackTrace) {
      LoggerService.warning('Failed to update message count', e, stackTrace);
      // Don't throw - this is a non-critical operation
    } catch (e, stackTrace) {
      LoggerService.warning('Unexpected error updating message count', e, stackTrace);
      // Don't throw - this is a non-critical operation
    }
  }

  // Get current auth user
  firebase_auth.User? get currentFirebaseUser => _auth.currentUser;

  // Stream of auth changes
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();
}
