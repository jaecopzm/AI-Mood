import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/cloudflare_config.dart';

class CloudflareAIService {
  // Use credentials from CloudflareConfig
  static final String _accountId = CloudflareConfig.accountId;
  static final String _apiToken = CloudflareConfig.apiToken;
  static final String _baseUrl = CloudflareConfig.baseUrl;

  /// Generate a personalized message using Cloudflare AI
  Future<String> generateMessage({
    required String recipient,
    required String tone,
    required String context,
    required int wordLimit,
  }) async {
    try {
      // Build the prompt based on user input
      final prompt = _buildPrompt(
        recipient: recipient,
        tone: tone,
        context: context,
        wordLimit: wordLimit,
      );

      // Call Cloudflare AI API
      final response = await http.post(
        Uri.parse('$_baseUrl/@cf/meta/llama-3-8b-instruct'),
        headers: {
          'Authorization': 'Bearer $_apiToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a helpful assistant that writes personalized messages. Write messages that are heartfelt, genuine, and appropriate for the context.',
            },
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['result'] != null) {
          final result = data['result'];
          if (result['response'] != null) {
            return result['response'].toString();
          }
        }
        throw Exception('Invalid response from Cloudflare AI');
      } else {
        throw Exception('Failed to generate message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Cloudflare AI Error: $e');
    }
  }

  /// Build a detailed prompt for the AI
  String _buildPrompt({
    required String recipient,
    required String tone,
    required String context,
    required int wordLimit,
  }) {
    return '''
Write a $tone message to my $recipient.

Context: $context

Requirements:
- Keep the message to approximately $wordLimit words
- Be genuine and heartfelt
- Match the requested tone ($tone)
- Make it personal and meaningful
- Do not include excessive formatting or emojis

Generate the message:
''';
  }

  /// Check if credentials are configured
  static bool areCredentialsConfigured() {
    return _accountId != 'YOUR_ACCOUNT_ID' && _apiToken != 'YOUR_API_TOKEN';
  }

  /// Get configuration instructions
  static String getConfigurationInstructions() {
    return '''
To use Cloudflare AI for message generation:

1. Go to: https://dash.cloudflare.com/
2. Select your account
3. Go to: Workers & Pages > AI
4. Copy your Account ID
5. Create an API Token with Workers AI permissions
6. Update CloudflareAIService with:
   - _accountId = your account ID
   - _apiToken = your API token

Or set environment variables:
   - CLOUDFLARE_ACCOUNT_ID
   - CLOUDFLARE_API_TOKEN
''';
  }
}
