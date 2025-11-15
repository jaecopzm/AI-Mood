import '../core/config/env_config.dart';

// Cloudflare AI Configuration
class CloudflareConfig {
  // Get account ID from environment
  static String get accountId => EnvConfig.cloudflareAccountId;
  
  // Get API token from environment
  static String get apiToken => EnvConfig.cloudflareApiToken;

  // Cloudflare AI endpoint
  static String get baseUrl =>
      'https://api.cloudflare.com/client/v4/accounts/$accountId/ai/run';

  // Model selection
  static const String defaultModel = '@cf/meta/llama-3-8b-instruct';

  // Request headers
  static Map<String, String> getHeaders() {
    return {
      'Authorization': 'Bearer $apiToken',
      'Content-Type': 'application/json',
    };
  }

  // Cloudflare AI Models available
  static const Map<String, String> availableModels = {
    'llama3': '@cf/meta/llama-3-8b-instruct',
    'llama2': '@cf/meta/llama-2-7b-chat-int8',
    'mistral': '@cf/mistral/mistral-7b-instruct-v0.1',
  };
}
