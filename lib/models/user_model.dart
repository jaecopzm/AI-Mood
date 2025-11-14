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
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      subscriptionTier: json['subscriptionTier'] ?? 'free',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toString()),
      monthlyCreditsUsed: json['monthlyCreditsUsed'] ?? 0,
      totalMessagesGenerated: json['totalMessagesGenerated'] ?? 0,
    );
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
      subscriptionId: json['subscriptionId'] ?? '',
      userId: json['userId'] ?? '',
      planType: json['planType'] ?? 'free',
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toString()),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isActive: json['isActive'] ?? false,
      paymentMethod: json['paymentMethod'] ?? '',
    );
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
      messageId: json['messageId'] ?? '',
      userId: json['userId'] ?? '',
      recipientType: json['recipientType'] ?? '',
      tone: json['tone'] ?? '',
      content: json['content'] ?? '',
      context: json['context'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      isSaved: json['isSaved'] ?? false,
      rating: json['rating'] ?? 0,
    );
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
