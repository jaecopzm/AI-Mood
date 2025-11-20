import 'package:cloud_firestore/cloud_firestore.dart';

/// Scheduled message model
class ScheduledMessage {
  final String id;
  final String userId;
  final String messageText;
  final String recipientType;
  final String tone;
  final DateTime scheduledFor;
  final String? platform; // 'whatsapp', 'sms', 'email', null for reminder only
  final String? recipientContact; // Phone number or email
  final bool isCompleted;
  final bool isCancelled;
  final DateTime createdAt;
  final DateTime? completedAt;

  const ScheduledMessage({
    required this.id,
    required this.userId,
    required this.messageText,
    required this.recipientType,
    required this.tone,
    required this.scheduledFor,
    this.platform,
    this.recipientContact,
    this.isCompleted = false,
    this.isCancelled = false,
    required this.createdAt,
    this.completedAt,
  });

  bool get isPending => !isCompleted && !isCancelled;
  bool get isOverdue => isPending && DateTime.now().isAfter(scheduledFor);

  factory ScheduledMessage.fromJson(Map<String, dynamic> json) {
    return ScheduledMessage(
      id: json['id'] as String,
      userId: json['userId'] as String,
      messageText: json['messageText'] as String,
      recipientType: json['recipientType'] as String,
      tone: json['tone'] as String,
      scheduledFor: (json['scheduledFor'] as Timestamp).toDate(),
      platform: json['platform'] as String?,
      recipientContact: json['recipientContact'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isCancelled: json['isCancelled'] as bool? ?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'messageText': messageText,
      'recipientType': recipientType,
      'tone': tone,
      'scheduledFor': Timestamp.fromDate(scheduledFor),
      'platform': platform,
      'recipientContact': recipientContact,
      'isCompleted': isCompleted,
      'isCancelled': isCancelled,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
    };
  }

  ScheduledMessage copyWith({
    String? id,
    String? userId,
    String? messageText,
    String? recipientType,
    String? tone,
    DateTime? scheduledFor,
    String? platform,
    String? recipientContact,
    bool? isCompleted,
    bool? isCancelled,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return ScheduledMessage(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      messageText: messageText ?? this.messageText,
      recipientType: recipientType ?? this.recipientType,
      tone: tone ?? this.tone,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      platform: platform ?? this.platform,
      recipientContact: recipientContact ?? this.recipientContact,
      isCompleted: isCompleted ?? this.isCompleted,
      isCancelled: isCancelled ?? this.isCancelled,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
