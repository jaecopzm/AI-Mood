// App Configuration
enum AppEnvironment { development, staging, production }

class SubscriptionTier {
  final String id;
  final String name;
  final int monthlyCredits;
  final double price;
  final List<String> features;

  const SubscriptionTier({
    required this.id,
    required this.name,
    required this.monthlyCredits,
    required this.price,
    required this.features,
  });
}

class AppConfig {
  static const AppEnvironment environment = AppEnvironment.development;

  // SaaS Subscription Tiers
  static final Map<String, SubscriptionTier> subscriptionTiers = {
    'free': SubscriptionTier(
      id: 'free',
      name: 'Free',
      monthlyCredits: 5,
      price: 0,
      features: ['5 messages/month', 'Basic tones', 'Ad supported'],
    ),
    'pro': SubscriptionTier(
      id: 'pro',
      name: 'Pro',
      monthlyCredits: 100,
      price: 4.99,
      features: [
        '100 messages/month',
        'All tones',
        'No ads',
        'Message history',
      ],
    ),
    'premium': SubscriptionTier(
      id: 'premium',
      name: 'Premium',
      monthlyCredits: -1, // Unlimited
      price: 9.99,
      features: [
        'Unlimited messages',
        'All tones',
        'Priority support',
        'Custom tone creation',
        'Export messages',
      ],
    ),
  };

  // Tones available in the app
  static const List<String> availableTones = [
    'Romantic',
    'Funny',
    'Apologetic',
    'Grateful',
    'Professional',
    'Casual',
    'Mysterious',
    'Flirty',
    'Sincere',
    'Playful',
  ];

  // Recipient categories
  static const List<String> recipientCategories = [
    'Crush',
    'Girlfriend/Boyfriend',
    'Best Friend',
    'Family',
    'Boss',
    'Colleague',
    'Parent',
    'Sibling',
  ];

  // API timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration firebaseAITimeout = Duration(seconds: 60);
}
