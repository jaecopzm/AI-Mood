import 'package:flutter/foundation.dart';

/// Environment configuration manager
class EnvConfig {
  static bool _isInitialized = false;
  
  // Configuration constants - works on all platforms
  static const String _environment = 'development';
  
  /// Initialize environment configuration
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    print('🔧 Environment configuration initialized');
    print('📱 Platform: ${kIsWeb ? "Web" : "Mobile/Desktop"}');
    print('🤖 Using Firebase AI (Gemini) for message generation');
    _isInitialized = true;
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
