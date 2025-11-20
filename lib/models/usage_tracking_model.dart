import 'package:cloud_firestore/cloud_firestore.dart';

/// Usage tracking for subscription limits
class UsageTracking {
  final String userId;
  final int messagesUsedThisMonth;
  final int messagesLimit;
  final DateTime monthStartDate;
  final DateTime lastResetDate;
  final Map<String, int> featureUsage;
  final List<DateTime> messageTimestamps;

  const UsageTracking({
    required this.userId,
    required this.messagesUsedThisMonth,
    required this.messagesLimit,
    required this.monthStartDate,
    required this.lastResetDate,
    this.featureUsage = const {},
    this.messageTimestamps = const [],
  });

  int get messagesRemaining {
    if (messagesLimit == -1) return -1; // Unlimited
    return messagesLimit - messagesUsedThisMonth;
  }

  bool get canGenerateMessage {
    if (messagesLimit == -1) return true; // Unlimited
    return messagesUsedThisMonth < messagesLimit;
  }

  double get usagePercentage {
    if (messagesLimit == -1) return 0; // Unlimited
    return (messagesUsedThisMonth / messagesLimit * 100).clamp(0, 100);
  }

  bool get isNearLimit {
    if (messagesLimit == -1) return false;
    return usagePercentage >= 80;
  }

  bool get hasReachedLimit {
    if (messagesLimit == -1) return false;
    return messagesUsedThisMonth >= messagesLimit;
  }

  DateTime get nextResetDate {
    return DateTime(monthStartDate.year, monthStartDate.month + 1, 1);
  }

  int get daysUntilReset {
    return nextResetDate.difference(DateTime.now()).inDays;
  }

  factory UsageTracking.fromJson(Map<String, dynamic> json) {
    return UsageTracking(
      userId: json['userId'] as String,
      messagesUsedThisMonth: json['messagesUsedThisMonth'] as int? ?? 0,
      messagesLimit: json['messagesLimit'] as int? ?? 5,
      monthStartDate: json['monthStartDate'] != null
          ? (json['monthStartDate'] as Timestamp).toDate()
          : DateTime.now(),
      lastResetDate: json['lastResetDate'] != null
          ? (json['lastResetDate'] as Timestamp).toDate()
          : DateTime.now(),
      featureUsage: Map<String, int>.from(json['featureUsage'] ?? {}),
      messageTimestamps:
          (json['messageTimestamps'] as List?)
              ?.map((e) => (e as Timestamp).toDate())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'messagesUsedThisMonth': messagesUsedThisMonth,
      'messagesLimit': messagesLimit,
      'monthStartDate': Timestamp.fromDate(monthStartDate),
      'lastResetDate': Timestamp.fromDate(lastResetDate),
      'featureUsage': featureUsage,
      'messageTimestamps': messageTimestamps
          .map((e) => Timestamp.fromDate(e))
          .toList(),
    };
  }

  UsageTracking copyWith({
    String? userId,
    int? messagesUsedThisMonth,
    int? messagesLimit,
    DateTime? monthStartDate,
    DateTime? lastResetDate,
    Map<String, int>? featureUsage,
    List<DateTime>? messageTimestamps,
  }) {
    return UsageTracking(
      userId: userId ?? this.userId,
      messagesUsedThisMonth:
          messagesUsedThisMonth ?? this.messagesUsedThisMonth,
      messagesLimit: messagesLimit ?? this.messagesLimit,
      monthStartDate: monthStartDate ?? this.monthStartDate,
      lastResetDate: lastResetDate ?? this.lastResetDate,
      featureUsage: featureUsage ?? this.featureUsage,
      messageTimestamps: messageTimestamps ?? this.messageTimestamps,
    );
  }

  UsageTracking incrementUsage() {
    return copyWith(
      messagesUsedThisMonth: messagesUsedThisMonth + 1,
      messageTimestamps: [...messageTimestamps, DateTime.now()],
    );
  }

  UsageTracking reset() {
    final now = DateTime.now();
    return copyWith(
      messagesUsedThisMonth: 0,
      monthStartDate: DateTime(now.year, now.month, 1),
      lastResetDate: now,
      messageTimestamps: [],
    );
  }
}

/// Feature usage analytics
class FeatureUsageStats {
  final Map<String, int> toneUsage;
  final Map<String, int> recipientUsage;
  final int voiceInputCount;
  final int voiceOutputCount;
  final int templatesUsed;
  final int scheduledMessages;
  final int sharedMessages;
  final int exportedMessages;

  const FeatureUsageStats({
    this.toneUsage = const {},
    this.recipientUsage = const {},
    this.voiceInputCount = 0,
    this.voiceOutputCount = 0,
    this.templatesUsed = 0,
    this.scheduledMessages = 0,
    this.sharedMessages = 0,
    this.exportedMessages = 0,
  });

  factory FeatureUsageStats.fromJson(Map<String, dynamic> json) {
    return FeatureUsageStats(
      toneUsage: Map<String, int>.from(json['toneUsage'] ?? {}),
      recipientUsage: Map<String, int>.from(json['recipientUsage'] ?? {}),
      voiceInputCount: json['voiceInputCount'] as int? ?? 0,
      voiceOutputCount: json['voiceOutputCount'] as int? ?? 0,
      templatesUsed: json['templatesUsed'] as int? ?? 0,
      scheduledMessages: json['scheduledMessages'] as int? ?? 0,
      sharedMessages: json['sharedMessages'] as int? ?? 0,
      exportedMessages: json['exportedMessages'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'toneUsage': toneUsage,
      'recipientUsage': recipientUsage,
      'voiceInputCount': voiceInputCount,
      'voiceOutputCount': voiceOutputCount,
      'templatesUsed': templatesUsed,
      'scheduledMessages': scheduledMessages,
      'sharedMessages': sharedMessages,
      'exportedMessages': exportedMessages,
    };
  }
}
