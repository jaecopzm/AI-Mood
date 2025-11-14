// Cloudflare AI Configuration
class CloudflareConfig {
  // Replace with your Cloudflare account details
  static const String accountId = '580289486be253af98dc84ab2653ffab';
  static const String apiToken = 'dXQ6uAwzphRXCIVILqMyzK-ZARZSk9cFMUIOSHP-';

  // Cloudflare AI endpoint
  static const String baseUrl =
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
