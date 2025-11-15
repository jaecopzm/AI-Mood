// User and Subscription Models
class User {
  final String uid;
  final String email;
  final String displayName;
  final String subscriptionTier; // 'free', 'pro', 'premium'
  final DateTime createdAt;
  final DateTime updatedAt;
  final int monthlyCreditsUsed;
  final int totalMessagesGenerated;

  User({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.subscriptionTier,
    required this.createdAt,
    required this.updatedAt,
    required this.monthlyCreditsUsed,
    required this.totalMessagesGenerated,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      subscriptionTier: json['subscriptionTier'] as String? ?? 'free',
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      monthlyCreditsUsed: json['monthlyCreditsUsed'] as int? ?? 0,
      totalMessagesGenerated: json['totalMessagesGenerated'] as int? ?? 0,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'subscriptionTier': subscriptionTier,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'monthlyCreditsUsed': monthlyCreditsUsed,
      'totalMessagesGenerated': totalMessagesGenerated,
    };
  }
}

class Subscription {
  final String subscriptionId;
  final String userId;
  final String planType; // 'free', 'pro', 'premium'
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final String paymentMethod;

  Subscription({
    required this.subscriptionId,
    required this.userId,
    required this.planType,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.paymentMethod,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      subscriptionId: json['subscriptionId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      planType: json['planType'] as String? ?? 'free',
      startDate: _parseDateTime(json['startDate']),
      endDate: json['endDate'] != null ? _parseDateTime(json['endDate']) : null,
      isActive: json['isActive'] as bool? ?? false,
      paymentMethod: json['paymentMethod'] as String? ?? '',
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'subscriptionId': subscriptionId,
      'userId': userId,
      'planType': planType,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'paymentMethod': paymentMethod,
    };
  }
}

class GeneratedMessage {
  final String messageId;
  final String userId;
  final String recipientType;
  final String tone;
  final String content;
  final String context;
  final DateTime createdAt;
  final bool isSaved;
  final int rating; // 1-5, 0 if not rated

  GeneratedMessage({
    required this.messageId,
    required this.userId,
    required this.recipientType,
    required this.tone,
    required this.content,
    required this.context,
    required this.createdAt,
    required this.isSaved,
    required this.rating,
  });

  factory GeneratedMessage.fromJson(Map<String, dynamic> json) {
    return GeneratedMessage(
      messageId: json['messageId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      recipientType: json['recipientType'] as String? ?? '',
      tone: json['tone'] as String? ?? '',
      content: json['content'] as String? ?? '',
      context: json['context'] as String? ?? '',
      createdAt: _parseDateTime(json['createdAt']),
      isSaved: json['isSaved'] as bool? ?? false,
      rating: json['rating'] as int? ?? 0,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'userId': userId,
      'recipientType': recipientType,
      'tone': tone,
      'content': content,
      'context': context,
      'createdAt': createdAt.toIso8601String(),
      'isSaved': isSaved,
      'rating': rating,
    };
  }
}
