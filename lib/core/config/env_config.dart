import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration manager
class EnvConfig {
  static bool _isInitialized = false;
  
  // Configuration constants - works on all platforms
  static const String _cloudflareAccountId = '580289486be253af98dc84ab2653ffab';
  static const String _cloudflareApiToken = 'dXQ6uAwzphRXCIVILqMyzK-ZARZSk9cFMUIOSHP-';
  static const String _environment = 'development';
  
  /// Initialize environment configuration
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    print('🔧 Environment configuration initialized');
    print('📱 Platform: ${kIsWeb ? "Web" : "Mobile/Desktop"}');
    _isInitialized = true;
  }

  /// Get Cloudflare Account ID
  static String get cloudflareAccountId {
    return _cloudflareAccountId;
  }

  /// Get Cloudflare API Token
  static String get cloudflareApiToken {
    return _cloudflareApiToken;
  }
  /// Get environment name (development, staging, production)
  static String get environment {
    return _environment;
  }

  /// Check if running in development mode
  static bool get isDevelopment => environment == 'development';

  /// Check if running in production mode
  static bool get isProduction => environment == 'production';

  /// Check if running in staging mode
  static bool get isStaging => environment == 'staging';
}
