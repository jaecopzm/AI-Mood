/// RevenueCat Configuration
///
/// Setup Instructions:
/// 1. Go to https://app.revenuecat.com/
/// 2. Create a new project
/// 3. Get your API keys from Settings > API Keys
/// 4. Replace the placeholder keys below
///
/// Product IDs must match what you create in Google Play Console:
/// - pro_monthly: $4.99/month
/// - pro_annual: $47.99/year
/// - premium_monthly: $9.99/month
/// - premium_annual: $95.99/year
library;

class RevenueCatConfig {
  // TODO: Replace with your actual RevenueCat API keys
  // Get these from: https://app.revenuecat.com/settings/api-keys

  /// Android API Key (Google Play)
  static const String androidApiKey = 'test_PPUVnPFrKAqLfexTSslFaYMErmN';

  /// iOS API Key (App Store) - Add this when you expand to iOS
  static const String iosApiKey = 'test_PPUVnPFrKAqLfexTSslFaYMErmN';

  /// Entitlement IDs (these identify what features users get)
  /// Configure these in RevenueCat Dashboard > Entitlements
  static const String proEntitlementId = 'pro';
  static const String premiumEntitlementId = 'premium';

  /// Product IDs (must match Google Play Console product IDs)
  static const String proMonthlyProductId = 'pro_monthly';
  static const String proAnnualProductId = 'pro_annual';
  static const String premiumMonthlyProductId = 'premium_monthly';
  static const String premiumAnnualProductId = 'premium_annual';

  /// Offering IDs (optional - for A/B testing different paywalls)
  static const String defaultOfferingId = 'default';

  /// Check if RevenueCat is configured
  static bool get isConfigured {
    return androidApiKey != 'YOUR_ANDROID_API_KEY_HERE' &&
        androidApiKey.isNotEmpty;
  }
}
