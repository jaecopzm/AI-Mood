import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/cloudflare_config.dart';
import '../models/cloudflare_request.dart';

class CloudflareAIService {
  static const String _baseUrl =
      'https://api.cloudflare.com/client/v4/accounts';

  /// Generate a message using Cloudflare AI
  ///
  /// [recipientType] - Type of recipient (crush, girlfriend, friend, etc.)
  /// [tone] - Tone of the message (romantic, funny, apologetic, etc.)
  /// [context] - Additional context about what the message should convey
  /// [wordLimit] - Maximum words for the message
  ///
  /// Returns the generated message text
  static Future<String> generateMessage({
    required String recipientType,
    required String tone,
    required String context,
    required int wordLimit,
    String? additionalContext,
  }) async {
    try {
      // Build the system prompt
      final systemPrompt = _buildSystemPrompt(recipientType, tone, wordLimit);

      // Build the user message
      final userMessage = _buildUserMessage(context, additionalContext);

      // Create the request
      final messages = [
        CloudflareMessage(role: 'system', content: systemPrompt),
        CloudflareMessage(role: 'user', content: userMessage),
      ];

      final request = CloudflareAIRequest(messages: messages);

      // Make the API call
      final response = await http
          .post(
            Uri.parse(
              '$_baseUrl/${CloudflareConfig.accountId}/ai/run/${CloudflareConfig.defaultModel}',
            ),
            headers: CloudflareConfig.getHeaders(),
            body: request.toJsonString(),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final aiResponse = CloudflareAIResponse.fromJson(jsonResponse);

        if (aiResponse.success && aiResponse.result.isNotEmpty) {
          return aiResponse.result;
        } else {
          throw Exception('AI generation failed: ${aiResponse.error}');
        }
      } else {
        throw Exception(
          'Failed to generate message: ${response.statusCode}\n${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error generating message: $e');
    }
  }

  /// Build system prompt for the AI
  static String _buildSystemPrompt(
    String recipientType,
    String tone,
    int wordLimit,
  ) {
    return '''You are an expert message writer who creates personalized, engaging, and authentic messages. 
Your messages are NOT generic or boring - they are:
- Contextually relevant and personal
- Written in a $tone tone
- Tailored for a $recipientType
- Maximum $wordLimit words
- Natural and conversational
- Emotionally resonant

Generate ONLY the message itself, no explanations or meta-text.''';
  }

  /// Build user message with context
  static String _buildUserMessage(String context, String? additionalContext) {
    String message = 'Write a $context message';
    if (additionalContext != null && additionalContext.isNotEmpty) {
      message += '. Additional details: $additionalContext';
    }
    return message;
  }

  /// Generate multiple message variations
  static Future<List<String>> generateMessageVariations({
    required String recipientType,
    required String tone,
    required String context,
    required int wordLimit,
    String? additionalContext,
    int count = 3,
  }) async {
    final variations = <String>[];

    // Generate variations in parallel for speed
    final futures = List.generate(count, (i) {
      return generateMessage(
        recipientType: recipientType,
        tone: tone,
        context: '$context (Variation ${i + 1}: Make this unique and different from others)',
        wordLimit: wordLimit,
        additionalContext: additionalContext,
      ).catchError((e) => '');
    });

    final results = await Future.wait(futures);
    
    // Filter out empty results
    for (final result in results) {
      if (result.isNotEmpty) {
        variations.add(result);
      }
    }

    // Ensure we have at least one variation
    if (variations.isEmpty) {
      throw Exception('Failed to generate any message variations');
    }

    return variations;
  }
}
