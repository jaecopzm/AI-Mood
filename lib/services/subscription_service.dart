import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subscription_model.dart';
import '../models/usage_tracking_model.dart';
import '../core/services/logger_service.dart';
import '../core/utils/result.dart';

/// Service for managing subscriptions and usage tracking
class SubscriptionService {
  final FirebaseFirestore _firestore;

  SubscriptionService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get user's subscription
  Future<Result<UserSubscription>> getUserSubscription(String userId) async {
    try {
      final doc = await _firestore
          .collection('subscriptions')
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        final subscription = UserSubscription.fromJson(doc.data()!);
        return Result.success(subscription);
      }

      // Return free tier if no subscription exists
      final freeSubscription = UserSubscription(
        userId: userId,
        tier: SubscriptionTier.free,
        isActive: true,
      );

      return Result.success(freeSubscription);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to get user subscription', e, stackTrace);
      return Result.failure(Exception('Failed to get subscription: $e'));
    }
  }

  /// Update user subscription
  Future<Result<void>> updateSubscription({
    required String userId,
    required SubscriptionTier tier,
    required bool isAnnual,
    String? paymentMethod,
    String? subscriptionId,
  }) async {
    try {
      final now = DateTime.now();
      final endDate = isAnnual
          ? now.add(const Duration(days: 365))
          : now.add(const Duration(days: 30));

      final subscription = UserSubscription(
        userId: userId,
        tier: tier,
        startDate: now,
        endDate: endDate,
        isActive: true,
        isAnnual: isAnnual,
        paymentMethod: paymentMethod,
        subscriptionId: subscriptionId,
      );

      await _firestore
          .collection('subscriptions')
          .doc(userId)
          .set(subscription.toJson());

      // Update usage limits
      await _updateUsageLimits(userId, tier);

      LoggerService.info('Subscription updated for user: $userId to $tier');
      return Result.success(null);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to update subscription', e, stackTrace);
      return Result.failure(Exception('Failed to update subscription: $e'));
    }
  }

  /// Cancel subscription
  Future<Result<void>> cancelSubscription(String userId) async {
    try {
      await _firestore.collection('subscriptions').doc(userId).update({
        'isActive': false,
      });

      LoggerService.info('Subscription cancelled for user: $userId');
      return Result.success(null);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to cancel subscription', e, stackTrace);
      return Result.failure(Exception('Failed to cancel subscription: $e'));
    }
  }

  /// Get usage tracking
  Future<Result<UsageTracking>> getUsageTracking(String userId) async {
    try {
      final doc = await _firestore.collection('usage').doc(userId).get();

      if (doc.exists && doc.data() != null) {
        final usage = UsageTracking.fromJson(doc.data()!);

        // Check if we need to reset monthly usage
        if (_shouldResetUsage(usage)) {
          final resetUsage = usage.reset();
          await _firestore
              .collection('usage')
              .doc(userId)
              .set(resetUsage.toJson());
          return Result.success(resetUsage);
        }

        return Result.success(usage);
      }

      // Create initial usage tracking
      final subscription = await getUserSubscription(userId);
      final plan = subscription.data?.plan ?? SubscriptionPlan.free;

      final usage = UsageTracking(
        userId: userId,
        messagesUsedThisMonth: 0,
        messagesLimit: plan.messageLimit,
        monthStartDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
        lastResetDate: DateTime.now(),
      );

      await _firestore.collection('usage').doc(userId).set(usage.toJson());

      return Result.success(usage);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to get usage tracking', e, stackTrace);
      return Result.failure(Exception('Failed to get usage tracking: $e'));
    }
  }

  /// Increment message usage
  Future<Result<UsageTracking>> incrementMessageUsage(String userId) async {
    try {
      final usageResult = await getUsageTracking(userId);
      if (!usageResult.isSuccess) {
        return Result.failure(usageResult.error!);
      }

      final usage = usageResult.data!;

      if (!usage.canGenerateMessage) {
        return Result.failure(
          Exception('Message limit reached. Please upgrade your plan.'),
        );
      }

      final updatedUsage = usage.incrementUsage();
      await _firestore
          .collection('usage')
          .doc(userId)
          .set(updatedUsage.toJson());

      LoggerService.info('Message usage incremented for user: $userId');
      return Result.success(updatedUsage);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to increment usage', e, stackTrace);
      return Result.failure(Exception('Failed to increment usage: $e'));
    }
  }

  /// Check if user can generate message
  Future<bool> canGenerateMessage(String userId) async {
    try {
      final usageResult = await getUsageTracking(userId);
      if (!usageResult.isSuccess) return false;

      return usageResult.data!.canGenerateMessage;
    } catch (e) {
      LoggerService.error('Failed to check message generation permission', e);
      return false;
    }
  }

  /// Update usage limits based on subscription tier
  Future<void> _updateUsageLimits(String userId, SubscriptionTier tier) async {
    try {
      final plan = SubscriptionPlan.fromTier(tier);
      final usageResult = await getUsageTracking(userId);

      if (usageResult.isSuccess) {
        final usage = usageResult.data!;
        final updatedUsage = usage.copyWith(messagesLimit: plan.messageLimit);

        await _firestore
            .collection('usage')
            .doc(userId)
            .set(updatedUsage.toJson());
      }
    } catch (e) {
      LoggerService.error('Failed to update usage limits', e);
    }
  }

  /// Check if usage should be reset
  bool _shouldResetUsage(UsageTracking usage) {
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    return usage.monthStartDate.isBefore(currentMonthStart);
  }

  /// Get subscription statistics
  Future<Map<String, dynamic>> getSubscriptionStats(String userId) async {
    try {
      final subscriptionResult = await getUserSubscription(userId);
      final usageResult = await getUsageTracking(userId);

      if (!subscriptionResult.isSuccess || !usageResult.isSuccess) {
        return {};
      }

      final subscription = subscriptionResult.data!;
      final usage = usageResult.data!;

      return {
        'tier': subscription.tier.displayName,
        'isActive': subscription.isActive,
        'messagesUsed': usage.messagesUsedThisMonth,
        'messagesLimit': usage.messagesLimit,
        'messagesRemaining': usage.messagesRemaining,
        'usagePercentage': usage.usagePercentage,
        'daysUntilReset': usage.daysUntilReset,
        'daysRemaining': subscription.daysRemaining,
        'isExpired': subscription.isExpired,
      };
    } catch (e) {
      LoggerService.error('Failed to get subscription stats', e);
      return {};
    }
  }
}
