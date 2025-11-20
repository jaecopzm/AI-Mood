import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../models/subscription_model.dart';
import '../models/usage_tracking_model.dart';
import '../services/revenue_cat_service.dart';
import '../services/subscription_service.dart';
import '../core/services/logger_service.dart';

/// Subscription state
class SubscriptionState {
  final SubscriptionTier currentTier;
  final UserSubscription? subscription;
  final UsageTracking? usage;
  final bool isLoading;
  final String? error;
  final Offerings? offerings;
  final bool hasActiveSubscription;
  final DateTime? expirationDate;
  final bool willRenew;

  const SubscriptionState({
    this.currentTier = SubscriptionTier.free,
    this.subscription,
    this.usage,
    this.isLoading = false,
    this.error,
    this.offerings,
    this.hasActiveSubscription = false,
    this.expirationDate,
    this.willRenew = false,
  });

  SubscriptionState copyWith({
    SubscriptionTier? currentTier,
    UserSubscription? subscription,
    UsageTracking? usage,
    bool? isLoading,
    String? error,
    Offerings? offerings,
    bool? hasActiveSubscription,
    DateTime? expirationDate,
    bool? willRenew,
    bool clearError = false,
  }) {
    return SubscriptionState(
      currentTier: currentTier ?? this.currentTier,
      subscription: subscription ?? this.subscription,
      usage: usage ?? this.usage,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      offerings: offerings ?? this.offerings,
      hasActiveSubscription:
          hasActiveSubscription ?? this.hasActiveSubscription,
      expirationDate: expirationDate ?? this.expirationDate,
      willRenew: willRenew ?? this.willRenew,
    );
  }

  SubscriptionPlan get plan => SubscriptionPlan.fromTier(currentTier);

  bool get canGenerateMessage => usage?.canGenerateMessage ?? false;
  int get messagesRemaining => usage?.messagesRemaining ?? 0;
  int get messagesUsed => usage?.messagesUsedThisMonth ?? 0;
  double get usagePercentage => usage?.usagePercentage ?? 0;
}

/// Subscription provider
final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
      return SubscriptionNotifier();
    });

/// Subscription notifier
class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier() : super(const SubscriptionState());

  final RevenueCatService _revenueCat = RevenueCatService();
  final SubscriptionService _subscriptionService = SubscriptionService();

  /// Initialize subscription system
  Future<void> initialize(String userId) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      // Initialize RevenueCat
      final initResult = await _revenueCat.initialize(userId: userId);
      if (!initResult.isSuccess) {
        state = state.copyWith(
          isLoading: false,
          error: initResult.error?.toString(),
        );
        return;
      }

      // Load subscription status
      await loadSubscriptionStatus(userId);

      // Listen to subscription changes
      _revenueCat.customerInfoStream.listen((customerInfo) {
        _handleCustomerInfoUpdate(customerInfo, userId);
      });

      LoggerService.info('Subscription system initialized');
    } catch (e, stackTrace) {
      LoggerService.error(
        'Failed to initialize subscription system',
        e,
        stackTrace,
      );
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize: $e',
      );
    }
  }

  /// Load subscription status
  Future<void> loadSubscriptionStatus(String userId) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      // Get current tier from RevenueCat
      final tier = await _revenueCat.getCurrentTier();

      // Get usage tracking
      final usageResult = await _subscriptionService.getUsageTracking(userId);
      final usage = usageResult.isSuccess ? usageResult.data : null;

      // Get subscription details
      final hasActive = await _revenueCat.hasActiveSubscription();
      final expirationDate = await _revenueCat.getExpirationDate();
      final willRenew = await _revenueCat.willRenew();

      state = state.copyWith(
        currentTier: tier,
        usage: usage,
        hasActiveSubscription: hasActive,
        expirationDate: expirationDate,
        willRenew: willRenew,
        isLoading: false,
      );

      LoggerService.info('Subscription status loaded: $tier');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load subscription status', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load subscription: $e',
      );
    }
  }

  /// Load offerings
  Future<void> loadOfferings() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final result = await _revenueCat.getOfferings();

      if (result.isSuccess) {
        state = state.copyWith(offerings: result.data, isLoading: false);
        LoggerService.info('Offerings loaded successfully');
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.error?.toString(),
        );
      }
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load offerings', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load subscription plans: $e',
      );
    }
  }

  /// Purchase subscription
  Future<bool> purchaseSubscription(Package package, String userId) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final result = await _revenueCat.purchasePackage(package);

      if (result.isSuccess) {
        // Update local subscription status
        await loadSubscriptionStatus(userId);

        LoggerService.info('Purchase successful');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.error?.toString(),
        );
        return false;
      }
    } catch (e, stackTrace) {
      LoggerService.error('Purchase failed', e, stackTrace);
      state = state.copyWith(isLoading: false, error: 'Purchase failed: $e');
      return false;
    }
  }

  /// Restore purchases
  Future<bool> restorePurchases(String userId) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final result = await _revenueCat.restorePurchases();

      if (result.isSuccess) {
        await loadSubscriptionStatus(userId);
        LoggerService.info('Purchases restored');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.error?.toString(),
        );
        return false;
      }
    } catch (e, stackTrace) {
      LoggerService.error('Failed to restore purchases', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to restore purchases: $e',
      );
      return false;
    }
  }

  /// Check if user can generate message
  Future<bool> canGenerateMessage(String userId) async {
    try {
      // Premium users have unlimited messages
      if (state.currentTier == SubscriptionTier.premium) {
        return true;
      }

      // Check usage limits
      final usageResult = await _subscriptionService.getUsageTracking(userId);
      if (!usageResult.isSuccess) return false;

      return usageResult.data!.canGenerateMessage;
    } catch (e) {
      LoggerService.error('Failed to check message generation permission', e);
      return false;
    }
  }

  /// Increment message usage
  Future<bool> incrementMessageUsage(String userId) async {
    try {
      // Premium users don't have limits
      if (state.currentTier == SubscriptionTier.premium) {
        return true;
      }

      final result = await _subscriptionService.incrementMessageUsage(userId);

      if (result.isSuccess) {
        state = state.copyWith(usage: result.data);
        return true;
      } else {
        state = state.copyWith(error: result.error?.toString());
        return false;
      }
    } catch (e, stackTrace) {
      LoggerService.error('Failed to increment usage', e, stackTrace);
      return false;
    }
  }

  /// Handle customer info updates from RevenueCat
  void _handleCustomerInfoUpdate(CustomerInfo customerInfo, String userId) {
    try {
      // Determine tier from entitlements
      SubscriptionTier tier = SubscriptionTier.free;

      if (customerInfo.entitlements.active.containsKey('premium')) {
        tier = SubscriptionTier.premium;
      } else if (customerInfo.entitlements.active.containsKey('pro')) {
        tier = SubscriptionTier.pro;
      }

      // Update state
      state = state.copyWith(
        currentTier: tier,
        hasActiveSubscription: customerInfo.entitlements.active.isNotEmpty,
      );

      LoggerService.info('Subscription updated: $tier');
    } catch (e) {
      LoggerService.error('Failed to handle customer info update', e);
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Get subscription statistics
  Future<Map<String, dynamic>> getStats(String userId) async {
    return await _subscriptionService.getSubscriptionStats(userId);
  }
}
