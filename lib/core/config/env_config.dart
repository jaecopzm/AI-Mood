import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration manager
class EnvConfig {
  /// Initialize environment configuration
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
  }

  /// Get Cloudflare Account ID
  static String get cloudflareAccountId {
    final value = dotenv.env['CLOUDFLARE_ACCOUNT_ID'];
    if (value == null || value.isEmpty) {
      throw Exception('CLOUDFLARE_ACCOUNT_ID not found in environment');
    }
    return value;
  }

  /// Get Cloudflare API Token
  static String get cloudflareApiToken {
    final value = dotenv.env['CLOUDFLARE_API_TOKEN'];
    if (value == null || value.isEmpty) {
      throw Exception('CLOUDFLARE_API_TOKEN not found in environment');
    }
    return value;
  }

  /// Get environment name (development, staging, production)
  static String get environment {
    return dotenv.env['ENVIRONMENT'] ?? 'development';
  }

  /// Check if running in development mode
  static bool get isDevelopment => environment == 'development';

  /// Check if running in production mode
  static bool get isProduction => environment == 'production';

  /// Check if running in staging mode
  static bool get isStaging => environment == 'staging';
}
