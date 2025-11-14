import 'dart:convert';

// Cloudflare AI Request/Response Models
class CloudflareMessage {
  final String role; // 'system', 'user', 'assistant'
  final String content;

  CloudflareMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() {
    return {'role': role, 'content': content};
  }
}

class CloudflareAIRequest {
  final List<CloudflareMessage> messages;

  CloudflareAIRequest({required this.messages});

  Map<String, dynamic> toJson() {
    return {'messages': messages.map((m) => m.toJson()).toList()};
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

class CloudflareAIResponse {
  final String result;
  final String? error;
  final bool success;

  CloudflareAIResponse({
    required this.result,
    this.error,
    required this.success,
  });

  factory CloudflareAIResponse.fromJson(Map<String, dynamic> json) {
    return CloudflareAIResponse(
      result: json['result']?['response'] ?? '',
      error: json['errors']?[0]?['message'],
      success: json['success'] ?? false,
    );
  }
}

class MessageGenerationRequest {
  final String recipientType; // 'crush', 'girlfriend', 'friend', etc.
  final String tone; // 'romantic', 'funny', 'apologetic', etc.
  final String context; // Additional context from user
  final int wordLimit; // Max words for the message
  final String? additionalContext;

  MessageGenerationRequest({
    required this.recipientType,
    required this.tone,
    required this.context,
    required this.wordLimit,
    this.additionalContext,
  });

  Map<String, dynamic> toJson() {
    return {
      'recipientType': recipientType,
      'tone': tone,
      'context': context,
      'wordLimit': wordLimit,
      'additionalContext': additionalContext,
    };
  }
}
