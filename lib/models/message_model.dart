class MessageModel {
  final String id;
  final String userId;
  final String recipientType;
  final String tone;
  final String context;
  final String generatedText;
  final List<String> variations;
  final int wordLimit;
  final DateTime createdAt;
  final bool isSaved;

  MessageModel({
    required this.id,
    required this.userId,
    required this.recipientType,
    required this.tone,
    required this.context,
    required this.generatedText,
    required this.variations,
    required this.wordLimit,
    required this.createdAt,
    this.isSaved = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'recipientType': recipientType,
      'tone': tone,
      'context': context,
      'generatedText': generatedText,
      'variations': variations,
      'wordLimit': wordLimit,
      'createdAt': createdAt.toIso8601String(),
      'isSaved': isSaved,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      recipientType: json['recipientType'] as String,
      tone: json['tone'] as String,
      context: json['context'] as String,
      generatedText: json['generatedText'] as String,
      variations: List<String>.from(json['variations'] ?? []),
      wordLimit: json['wordLimit'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isSaved: json['isSaved'] as bool? ?? false,
    );
  }
}
