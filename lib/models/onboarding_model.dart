/// Onboarding page model
class OnboardingPage {
  final String title;
  final String description;
  final String icon;
  final List<String> features;
  final String? gradient1;
  final String? gradient2;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    this.features = const [],
    this.gradient1,
    this.gradient2,
  });
}

/// Onboarding data
class OnboardingData {
  static final List<OnboardingPage> pages = [
    const OnboardingPage(
      title: 'Welcome to AI Mood',
      description:
          'Create perfect messages for any occasion with the power of AI',
      icon: '💝',
      features: [
        'AI-powered message generation',
        'Multiple tones and styles',
        'Voice input & output',
        'Save and schedule messages',
      ],
    ),
    const OnboardingPage(
      title: 'Express Yourself Perfectly',
      description:
          'Whether it\'s romantic, professional, or casual - we\'ve got you covered',
      icon: '✨',
      features: [
        'Romantic messages for your crush',
        'Professional emails for work',
        'Apologies that truly matter',
        'Gratitude from the heart',
      ],
    ),
    const OnboardingPage(
      title: 'Smart & Personalized',
      description: 'AI learns your style and gets better with every message',
      icon: '🧠',
      features: [
        'Learns your writing style',
        'Personalized suggestions',
        'Context-aware generation',
        'Premium templates',
      ],
    ),
    const OnboardingPage(
      title: 'Start Free Today',
      description:
          'Get 5 free messages to try it out. No credit card required!',
      icon: '🎁',
      features: [
        '5 free messages per month',
        'All basic features',
        'No credit card needed',
        'Upgrade anytime',
      ],
    ),
  ];
}

/// User preferences from onboarding
class OnboardingPreferences {
  final List<String> favoriteRecipients;
  final List<String> favoriteTones;
  final bool enableVoice;
  final bool enableNotifications;

  const OnboardingPreferences({
    this.favoriteRecipients = const [],
    this.favoriteTones = const [],
    this.enableVoice = false,
    this.enableNotifications = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'favoriteRecipients': favoriteRecipients,
      'favoriteTones': favoriteTones,
      'enableVoice': enableVoice,
      'enableNotifications': enableNotifications,
    };
  }

  factory OnboardingPreferences.fromJson(Map<String, dynamic> json) {
    return OnboardingPreferences(
      favoriteRecipients: List<String>.from(json['favoriteRecipients'] ?? []),
      favoriteTones: List<String>.from(json['favoriteTones'] ?? []),
      enableVoice: json['enableVoice'] as bool? ?? false,
      enableNotifications: json['enableNotifications'] as bool? ?? false,
    );
  }
}
