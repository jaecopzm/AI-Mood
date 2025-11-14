import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

import '../models/message_model.dart';

class FirebaseService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth Methods
  Future<firebase_auth.UserCredential?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(displayName);

      // Create user document in Firestore
      if (userCredential.user != null) {
        await _createUserDocument(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  Future<firebase_auth.UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  Future<firebase_auth.UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign-in cancelled');
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
      }

      return userCredential;
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  // User Document Methods
  Future<void> _createUserDocument(firebase_auth.User firebaseUser) async {
    try {
      final user = User(
        uid: firebaseUser.uid,
        email: firebaseUser.email!,
        displayName: firebaseUser.displayName ?? '',
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
    } catch (e) {
      throw Exception('Failed to create user document: $e');
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (doc.exists) {
        return User.fromJson(doc.data() ?? {});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  Future<User?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        return User.fromJson(doc.data() ?? {});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Message Methods
  Future<void> saveMessage(MessageModel message) async {
    try {
      await _firestore
          .collection('messages')
          .doc(message.id)
          .set(message.toJson());

      // Update user message count
      await _updateUserMessageCount(message.userId);
    } catch (e) {
      throw Exception('Failed to save message: $e');
    }
  }

  Future<List<MessageModel>> getUserMessages(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('messages')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => MessageModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user messages: $e');
    }
  }

  Future<void> updateMessage(String messageId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('messages').doc(messageId).update(updates);
    } catch (e) {
      throw Exception('Failed to update message: $e');
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _firestore.collection('messages').doc(messageId).delete();
    } catch (e) {
      throw Exception('Failed to delete message: $e');
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
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to update message count: $e');
    }
  }

  // Get current auth user
  firebase_auth.User? get currentFirebaseUser => _auth.currentUser;

  // Stream of auth changes
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();
}
