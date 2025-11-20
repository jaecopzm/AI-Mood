import 'package:cloud_firestore/cloud_firestore.dart';

/// Subscription tiers
enum SubscriptionTier {
  free,
  pro,
  premium;

  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.pro:
        return 'Pro';
      case SubscriptionTier.premium:
        return 'Premium';
    }
  }

  String get description {
    switch (this) {
      case SubscriptionTier.free:
        return 'Perfect for trying out';
      case SubscriptionTier.pro:
        return 'Most Popular';
      case SubscriptionTier.premium:
        return 'Best Value';
    }
  }
}

/// Subscription plan details
class SubscriptionPlan {
  final SubscriptionTier tier;
  final String name;
  final double monthlyPrice;
  final double annualPrice;
  final int messageLimit; // -1 for unlimited
  final List<String> features;
  final bool hasVoiceFeatures;
  final bool hasAdvancedAnalytics;
  final bool hasPremiumTemplates;
  final bool hasMessageScheduling;
  final bool hasMultiPlatformExport;
  final bool hasAdFree;
  final int historyDays; // -1 for unlimited
  final bool hasMLPersonalization;

  const SubscriptionPlan({
    required this.tier,
    required this.name,
    required this.monthlyPrice,
    required this.annualPrice,
    required this.messageLimit,
    required this.features,
    this.hasVoiceFeatures = false,
    this.hasAdvancedAnalytics = false,
    this.hasPremiumTemplates = false,
    this.hasMessageScheduling = false,
    this.hasMultiPlatformExport = false,
    this.hasAdFree = false,
    this.historyDays = 0,
    this.hasMLPersonalization = false,
  });

  double get annualSavings => (monthlyPrice * 12) - annualPrice;
  double get annualSavingsPercentage =>
      (annualSavings / (monthlyPrice * 12)) * 100;

  static const SubscriptionPlan free = SubscriptionPlan(
    tier: SubscriptionTier.free,
    name: 'Free',
    monthlyPrice: 0,
    annualPrice: 0,
    messageLimit: 5,
    features: [
      '5 messages per month',
      '3 basic tones',
      '3 basic recipients',
      'Standard templates',
      'Community support',
    ],
    historyDays: 7,
  );

  static const SubscriptionPlan pro = SubscriptionPlan(
    tier: SubscriptionTier.pro,
    name: 'Pro',
    monthlyPrice: 4.99,
    annualPrice: 47.99, // Save 20%
    messageLimit: 100,
    features: [
      '100 messages per month',
      'All tones & recipients',
      'Voice input & output',
      'Message history (30 days)',
      'Basic analytics',
      'No ads',
      'Priority support',
    ],
    hasVoiceFeatures: true,
    hasAdvancedAnalytics: false,
    hasPremiumTemplates: false,
    hasMessageScheduling: false,
    hasMultiPlatformExport: true,
    hasAdFree: true,
    historyDays: 30,
    hasMLPersonalization: false,
  );

  static const SubscriptionPlan premium = SubscriptionPlan(
    tier: SubscriptionTier.premium,
    name: 'Premium',
    monthlyPrice: 9.99,
    annualPrice: 95.99, // Save 20%
    messageLimit: -1, // Unlimited
    features: [
      'Unlimited messages',
      'Everything in Pro',
      'Premium templates',
      'Message scheduling',
      'AI learns your style',
      'Advanced analytics',
      'Unlimited history',
      'Multi-platform export',
      'Priority support',
    ],
    hasVoiceFeatures: true,
    hasAdvancedAnalytics: true,
    hasPremiumTemplates: true,
    hasMessageScheduling: true,
    hasMultiPlatformExport: true,
    hasAdFree: true,
    historyDays: -1, // Unlimited
    hasMLPersonalization: true,
  );

  static List<SubscriptionPlan> get allPlans => [free, pro, premium];

  static SubscriptionPlan fromTier(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return free;
      case SubscriptionTier.pro:
        return pro;
      case SubscriptionTier.premium:
        return premium;
    }
  }

  static SubscriptionPlan fromString(String tierString) {
    switch (tierString.toLowerCase()) {
      case 'pro':
        return pro;
      case 'premium':
        return premium;
      default:
        return free;
    }
  }
}

/// User subscription status
class UserSubscription {
  final String userId;
  final SubscriptionTier tier;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final bool isAnnual;
  final String? paymentMethod;
  final String? subscriptionId;

  const UserSubscription({
    required this.userId,
    required this.tier,
    this.startDate,
    this.endDate,
    this.isActive = false,
    this.isAnnual = false,
    this.paymentMethod,
    this.subscriptionId,
  });

  bool get isExpired {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  int get daysRemaining {
    if (endDate == null) return 0;
    return endDate!.difference(DateTime.now()).inDays;
  }

  SubscriptionPlan get plan => SubscriptionPlan.fromTier(tier);

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      userId: json['userId'] as String,
      tier: SubscriptionTier.values.firstWhere(
        (e) => e.name == json['tier'],
        orElse: () => SubscriptionTier.free,
      ),
      startDate: json['startDate'] != null
          ? (json['startDate'] as Timestamp).toDate()
          : null,
      endDate: json['endDate'] != null
          ? (json['endDate'] as Timestamp).toDate()
          : null,
      isActive: json['isActive'] as bool? ?? false,
      isAnnual: json['isAnnual'] as bool? ?? false,
      paymentMethod: json['paymentMethod'] as String?,
      subscriptionId: json['subscriptionId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'tier': tier.name,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'isActive': isActive,
      'isAnnual': isAnnual,
      'paymentMethod': paymentMethod,
      'subscriptionId': subscriptionId,
    };
  }

  UserSubscription copyWith({
    String? userId,
    SubscriptionTier? tier,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    bool? isAnnual,
    String? paymentMethod,
    String? subscriptionId,
  }) {
    return UserSubscription(
      userId: userId ?? this.userId,
      tier: tier ?? this.tier,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      isAnnual: isAnnual ?? this.isAnnual,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      subscriptionId: subscriptionId ?? this.subscriptionId,
    );
  }
}
