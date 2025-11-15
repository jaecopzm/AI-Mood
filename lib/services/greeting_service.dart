import '../models/user_model.dart';

/// Service for generating personalized greetings
class GreetingService {
  /// Get time-based greeting
  static String getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 22) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  /// Get personalized greeting with user name
  static String getPersonalizedGreeting(User? user) {
    final timeGreeting = getTimeBasedGreeting();
    final name = user?.displayName ?? 'there';
    
    return '$timeGreeting, $name! 👋';
  }

  /// Get motivational message based on time
  static String getMotivationalMessage() {
    final hour = DateTime.now().hour;
    final day = DateTime.now().weekday;
    
    final messages = <String>[];
    
    // Time-based messages
    if (hour >= 5 && hour < 12) {
      messages.addAll([
        'Start your day with a heartfelt message! 💝',
        'Make someone smile this morning! ☀️',
        'A kind word can brighten someone\'s day! ✨',
        'Express your feelings with AI-powered words! 🚀',
      ]);
    } else if (hour >= 12 && hour < 17) {
      messages.addAll([
        'Perfect time to send a thoughtful message! 💬',
        'Spread some love this afternoon! 💕',
        'Let your words create magic! ✨',
        'Make connections that matter! 🌟',
      ]);
    } else if (hour >= 17 && hour < 22) {
      messages.addAll([
        'End the day with a sweet message! 🌙',
        'Make this evening special for someone! 💫',
        'Perfect time to express your thoughts! 💭',
        'Create beautiful moments with words! 🎨',
      ]);
    } else {
      messages.addAll([
        'Even at night, love finds a way! 🌃',
        'Midnight messages hit different! 🌙',
        'Late night feelings need words too! 💫',
        'Express yourself, even in the quiet hours! ⭐',
      ]);
    }
    
    // Day-specific additions
    if (day == DateTime.monday) {
      messages.add('Start the week with positive vibes! 💪');
    } else if (day == DateTime.friday) {
      messages.add('Friday feels deserve special messages! 🎉');
    } else if (day == DateTime.saturday || day == DateTime.sunday) {
      messages.add('Weekend is perfect for heartfelt messages! 🎊');
    }
    
    // Random selection
    messages.shuffle();
    return messages.first;
  }

  /// Get quick action suggestion
  static String getQuickActionSuggestion() {
    final suggestions = [
      'Send a romantic message to your crush 💘',
      'Apologize and make things right 🙏',
      'Wish someone a happy birthday 🎂',
      'Express gratitude to a friend 🙌',
      'Congratulate someone on their success 🎉',
      'Send motivation to someone special 💪',
      'Share your feelings honestly 💝',
      'Brighten someone\'s day with kindness ☀️',
    ];
    
    suggestions.shuffle();
    return suggestions.first;
  }

  /// Get stats-based encouragement
  static String getStatsEncouragement(int messageCount) {
    if (messageCount == 0) {
      return '🎯 Ready to create your first message? Let\'s make it special!';
    } else if (messageCount < 5) {
      return '🌱 You\'ve generated $messageCount ${messageCount == 1 ? 'message' : 'messages'}! Keep going!';
    } else if (messageCount < 10) {
      return '🚀 $messageCount messages created! You\'re on fire!';
    } else if (messageCount < 25) {
      return '⭐ Wow! $messageCount messages! You\'re a communication pro!';
    } else if (messageCount < 50) {
      return '🏆 $messageCount messages! You\'re spreading so much love!';
    } else if (messageCount < 100) {
      return '💎 $messageCount messages! You\'re a messaging legend!';
    } else {
      return '👑 $messageCount+ messages! You\'re a true wordsmith!';
    }
  }

  /// Get random fun fact about messaging
  static String getFunFact() {
    final facts = [
      '💡 Did you know? A heartfelt message can improve someone\'s mood instantly!',
      '📱 Messages are 10x more likely to be read than emails!',
      '💝 Expressing gratitude strengthens relationships by 25%!',
      '✨ The average person sends 50+ messages per day!',
      '🎯 Personalized messages have 5x higher impact!',
      '💬 Text messages have a 98% open rate!',
      '🌟 Sending kind messages boosts your own happiness too!',
      '💕 Love messages activate the same brain regions as physical touch!',
    ];
    
    facts.shuffle();
    return facts.first;
  }

  /// Get contextual tip
  static String getContextualTip() {
    final tips = [
      '💡 Tip: Be specific about what you appreciate in someone!',
      '💡 Tip: Timing matters - send messages when they\'re most receptive!',
      '💡 Tip: Add emojis to make your messages more expressive! 😊',
      '💡 Tip: Personal touches make messages more meaningful!',
      '💡 Tip: Don\'t overthink - genuine feelings shine through!',
      '💡 Tip: Follow up important messages with a call!',
      '💡 Tip: Save your favorite messages for future inspiration!',
      '💡 Tip: Customize generated messages to add your voice!',
    ];
    
    tips.shuffle();
    return tips.first;
  }
}
