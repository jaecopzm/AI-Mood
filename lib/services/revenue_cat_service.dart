import 'dart:io';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../config/revenue_cat_config.dart';
import '../models/subscription_model.dart';
import '../core/services/logger_service.dart';
import '../core/utils/result.dart';

/// Service for managing in-app purchases via RevenueCat
class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  bool _isInitialized = false;

  /// Initialize RevenueCat
  Future<Result<void>> initialize({String? userId}) async {
    try {
      if (_isInitialized) {
        LoggerService.info('RevenueCat already initialized');
        return Result.success(null);
      }

      if (!RevenueCatConfig.isConfigured) {
        LoggerService.warning('RevenueCat not configured - using mock mode');
        return Result.failure(
          Exception(
            'RevenueCat API key not configured. Please update revenue_cat_config.dart',
          ),
        );
      }

      LoggerService.info('Initializing RevenueCat...');

      // Configure RevenueCat
      final configuration = PurchasesConfiguration(
        Platform.isAndroid
            ? RevenueCatConfig.androidApiKey
            : RevenueCatConfig.iosApiKey,
      );

      // Set user ID if provided
      if (userId != null) {
        configuration.appUserID = userId;
      }

      await Purchases.configure(configuration);

      // Set log level for debugging
      await Purchases.setLogLevel(LogLevel.debug);

      _isInitialized = true;
      LoggerService.info('✅ RevenueCat initialized successfully');

      return Result.success(null);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to initialize RevenueCat', e, stackTrace);
      return Result.failure(Exception('Failed to initialize RevenueCat: $e'));
    }
  }

  /// Get available offerings (subscription packages)
  Future<Result<Offerings>> getOfferings() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      LoggerService.info('Fetching offerings from RevenueCat...');
      final offerings = await Purchases.getOfferings();

      if (offerings.current == null) {
        LoggerService.warning('No offerings available');
        return Result.failure(Exception('No subscription packages available'));
      }

      LoggerService.info(
        '✅ Offerings fetched: ${offerings.current?.availablePackages.length} packages',
      );
      return Result.success(offerings);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to get offerings', e, stackTrace);
      return Result.failure(
        Exception('Failed to get subscription packages: $e'),
      );
    }
  }

  /// Purchase a package
  Future<Result<CustomerInfo>> purchasePackage(Package package) async {
    try {
      LoggerService.info('Attempting to purchase: ${package.identifier}');

      final purchaseResult = await Purchases.purchasePackage(package);
      final customerInfo = purchaseResult.customerInfo;

      LoggerService.info('✅ Purchase successful');
      return Result.success(customerInfo);
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      LoggerService.error('Purchase failed with code: $errorCode', e);

      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        return Result.failure(Exception('Purchase cancelled by user'));
      } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
        return Result.failure(Exception('Purchase not allowed'));
      } else if (errorCode == PurchasesErrorCode.paymentPendingError) {
        return Result.failure(Exception('Payment is pending'));
      } else {
        return Result.failure(Exception('Purchase failed: ${e.message}'));
      }
    } catch (e, stackTrace) {
      LoggerService.error('Unexpected purchase error', e, stackTrace);
      return Result.failure(Exception('Purchase failed: $e'));
    }
  }

  /// Restore purchases
  Future<Result<CustomerInfo>> restorePurchases() async {
    try {
      LoggerService.info('Restoring purchases...');

      final customerInfo = await Purchases.restorePurchases();

      LoggerService.info('✅ Purchases restored');
      return Result.success(customerInfo);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to restore purchases', e, stackTrace);
      return Result.failure(Exception('Failed to restore purchases: $e'));
    }
  }

  /// Get customer info (subscription status)
  Future<Result<CustomerInfo>> getCustomerInfo() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final customerInfo = await Purchases.getCustomerInfo();
      return Result.success(customerInfo);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to get customer info', e, stackTrace);
      return Result.failure(Exception('Failed to get subscription status: $e'));
    }
  }

  /// Check if user has active subscription
  Future<bool> hasActiveSubscription() async {
    try {
      final result = await getCustomerInfo();
      if (!result.isSuccess) return false;

      final customerInfo = result.data!;
      return customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      LoggerService.error('Failed to check subscription status', e);
      return false;
    }
  }

  /// Get current subscription tier
  Future<SubscriptionTier> getCurrentTier() async {
    try {
      final result = await getCustomerInfo();
      if (!result.isSuccess) return SubscriptionTier.free;

      final customerInfo = result.data!;

      // Check for premium entitlement first
      if (customerInfo.entitlements.active.containsKey(
        RevenueCatConfig.premiumEntitlementId,
      )) {
        return SubscriptionTier.premium;
      }

      // Check for pro entitlement
      if (customerInfo.entitlements.active.containsKey(
        RevenueCatConfig.proEntitlementId,
      )) {
        return SubscriptionTier.pro;
      }

      // Default to free
      return SubscriptionTier.free;
    } catch (e) {
      LoggerService.error('Failed to get current tier', e);
      return SubscriptionTier.free;
    }
  }

  /// Check if user has specific entitlement
  Future<bool> hasEntitlement(String entitlementId) async {
    try {
      final result = await getCustomerInfo();
      if (!result.isSuccess) return false;

      final customerInfo = result.data!;
      return customerInfo.entitlements.active.containsKey(entitlementId);
    } catch (e) {
      LoggerService.error('Failed to check entitlement', e);
      return false;
    }
  }

  /// Set user ID (for tracking across devices)
  Future<Result<void>> setUserId(String userId) async {
    try {
      if (!_isInitialized) {
        await initialize(userId: userId);
        return Result.success(null);
      }

      await Purchases.logIn(userId);
      LoggerService.info('User ID set: $userId');
      return Result.success(null);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to set user ID', e, stackTrace);
      return Result.failure(Exception('Failed to set user ID: $e'));
    }
  }

  /// Log out user
  Future<Result<void>> logOut() async {
    try {
      await Purchases.logOut();
      LoggerService.info('User logged out from RevenueCat');
      return Result.success(null);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to log out', e, stackTrace);
      return Result.failure(Exception('Failed to log out: $e'));
    }
  }

  /// Get subscription details
  Future<Map<String, dynamic>> getSubscriptionDetails() async {
    try {
      final result = await getCustomerInfo();
      if (!result.isSuccess) return {};

      final customerInfo = result.data!;
      final activeEntitlements = customerInfo.entitlements.active;

      if (activeEntitlements.isEmpty) {
        return {'tier': 'free', 'isActive': false};
      }

      // Get the first active entitlement
      final entitlement = activeEntitlements.values.first;

      return {
        'tier': entitlement.identifier,
        'isActive': entitlement.isActive,
        'willRenew': entitlement.willRenew,
        'periodType': entitlement.periodType.name,
        'expirationDate': entitlement.expirationDate,
        'originalPurchaseDate': entitlement.originalPurchaseDate,
        'productIdentifier': entitlement.productIdentifier,
        'isSandbox': entitlement.isSandbox,
      };
    } catch (e) {
      LoggerService.error('Failed to get subscription details', e);
      return {};
    }
  }

  /// Check if subscription will renew
  Future<bool> willRenew() async {
    try {
      final result = await getCustomerInfo();
      if (!result.isSuccess) return false;

      final customerInfo = result.data!;
      final activeEntitlements = customerInfo.entitlements.active;

      if (activeEntitlements.isEmpty) return false;

      return activeEntitlements.values.first.willRenew;
    } catch (e) {
      LoggerService.error('Failed to check renewal status', e);
      return false;
    }
  }

  /// Get expiration date
  Future<DateTime?> getExpirationDate() async {
    try {
      final result = await getCustomerInfo();
      if (!result.isSuccess) return null;

      final customerInfo = result.data!;
      final activeEntitlements = customerInfo.entitlements.active;

      if (activeEntitlements.isEmpty) return null;

      final expirationDateString =
          activeEntitlements.values.first.expirationDate;
      if (expirationDateString == null) return null;

      return DateTime.tryParse(expirationDateString);
    } catch (e) {
      LoggerService.error('Failed to get expiration date', e);
      return null;
    }
  }

  /// Listen to customer info updates
  /// Note: In newer versions of RevenueCat, use getCustomerInfo() periodically
  /// or implement your own stream if needed
  Stream<CustomerInfo> get customerInfoStream {
    // For now, return an empty stream
    // In production, you might want to poll getCustomerInfo() periodically
    return Stream.empty();
  }

  /// Check if in sandbox mode (for testing)
  Future<bool> isSandbox() async {
    try {
      final result = await getCustomerInfo();
      if (!result.isSuccess) return false;

      final customerInfo = result.data!;
      final activeEntitlements = customerInfo.entitlements.active;

      if (activeEntitlements.isEmpty) return false;

      return activeEntitlements.values.first.isSandbox;
    } catch (e) {
      return false;
    }
  }
}
