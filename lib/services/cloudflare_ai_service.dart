import 'package:dio/dio.dart';
import '../config/cloudflare_config.dart';
import '../models/cloudflare_request.dart';
import '../core/exceptions/app_exceptions.dart';
import '../core/services/logger_service.dart';
import '../core/utils/result.dart';

class CloudflareAIService {
  final Dio _dio;

  CloudflareAIService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://api.cloudflare.com/client/v4/accounts',
              connectTimeout: const Duration(seconds: 60),
              receiveTimeout: const Duration(seconds: 60),
            ));

  /// Generate a message using Cloudflare AI
  ///
  /// [recipientType] - Type of recipient (crush, girlfriend, friend, etc.)
  /// [tone] - Tone of the message (romantic, funny, apologetic, etc.)
  /// [context] - Additional context about what the message should convey
  /// [wordLimit] - Maximum words for the message
  ///
  /// Returns Result with the generated message text or error
  Future<Result<String>> generateMessage({
    required String recipientType,
    required String tone,
    required String context,
    required int wordLimit,
    String? additionalContext,
  }) async {
    try {
      LoggerService.info('Generating message for $recipientType with $tone tone');

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
      final response = await _dio.post(
        '/${CloudflareConfig.accountId}/ai/run/${CloudflareConfig.defaultModel}',
        data: request.toJson(),
        options: Options(
          headers: CloudflareConfig.getHeaders(),
        ),
      );

      if (response.statusCode == 200) {
        final aiResponse = CloudflareAIResponse.fromJson(response.data);

        if (aiResponse.success && aiResponse.result.isNotEmpty) {
          LoggerService.info('Message generated successfully');
          return Result.success(aiResponse.result);
        } else {
          final error = AIServiceException(
            'AI generation failed: ${aiResponse.error ?? "Unknown error"}',
          );
          LoggerService.error('AI generation failed', error);
          return Result.failure(error);
        }
      } else {
        final error = AIServiceException(
          'Failed to generate message: ${response.statusCode}',
          originalError: response.data,
        );
        LoggerService.error('HTTP error during message generation', error);
        return Result.failure(error);
      }
    } on DioException catch (e, stackTrace) {
      LoggerService.error('DioException during message generation', e, stackTrace);
      LoggerService.info('Error details: ${e.message}, Type: ${e.type}');
      
      // Fallback: Always return a fallback message on any network error
      LoggerService.info('Using fallback message due to network error');
      final fallbackMessage = _generateFallbackMessage(recipientType, tone, context);
      return Result.success(fallbackMessage);
    } catch (e, stackTrace) {
      final error = AIServiceException(
        'Unexpected error generating message',
        originalError: e,
        stackTrace: stackTrace,
      );
      LoggerService.error('Unexpected error during message generation', e, stackTrace);
      return Result.failure(error);
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

  /// Generate a fallback message when API fails
  static String _generateFallbackMessage(
    String recipientType,
    String tone,
    String context,
  ) {
    final toneDescriptions = {
      'romantic': 'I\'ve been thinking about you...',
      'funny': 'So, funny story...',
      'apologetic': 'I want to apologize...',
      'professional': 'I wanted to reach out...',
      'grateful': 'I\'m so grateful for you...',
      'casual': 'Hey! So...',
      'serious': 'We need to talk about...',
      'playful': 'You know what? ...',
    };

    final opening = toneDescriptions[tone.toLowerCase()] ?? 'I wanted to say...';
    return '$opening $context This message was crafted with care just for you.';
  }

  /// Generate multiple message variations
  Future<Result<List<String>>> generateMessageVariations({
    required String recipientType,
    required String tone,
    required String context,
    required int wordLimit,
    String? additionalContext,
    int count = 3,
  }) async {
    try {
      LoggerService.info('Generating $count message variations');

      final variations = <String>[];

      // Generate variations in parallel for speed
      final futures = List.generate(count, (i) {
        return generateMessage(
          recipientType: recipientType,
          tone: tone,
          context: '$context (Variation ${i + 1}: Make this unique and different from others)',
          wordLimit: wordLimit,
          additionalContext: additionalContext,
        );
      });

      final results = await Future.wait(futures);

      // Extract successful results
      for (final result in results) {
        if (result.isSuccess && result.data != null && result.data!.isNotEmpty) {
          variations.add(result.data!);
        }
      }

      // If we got some variations, return them
      if (variations.isNotEmpty) {
        LoggerService.info('Generated ${variations.length} variations successfully');
        return Result.success(variations);
      }

      // If no variations were generated, generate fallback variations
      LoggerService.info('No variations generated, using fallbacks');
      final fallbackVariations = List.generate(
        count,
        (i) => _generateFallbackMessage(recipientType, tone, '$context (Variation ${i + 1})'),
      );
      return Result.success(fallbackVariations);
    } catch (e, stackTrace) {
      LoggerService.error('Error in generateMessageVariations', e, stackTrace);
      
      // Generate fallback variations on any error
      LoggerService.info('Generating fallback variations due to error');
      final fallbackVariations = List.generate(
        count,
        (i) => _generateFallbackMessage(recipientType, tone, '$context (Variation ${i + 1})'),
      );
      return Result.success(fallbackVariations);
    }
  }
}
