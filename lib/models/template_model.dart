/// Message template model
class MessageTemplate {
  final String id;
  final String name;
  final String description;
  final String category;
  final String tone;
  final String recipientType;
  final String templateText;
  final List<String> tags;
  final bool isPremium;
  final int usageCount;
  final double rating;
  final String? previewImage;
  final DateTime createdAt;

  const MessageTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.tone,
    required this.recipientType,
    required this.templateText,
    this.tags = const [],
    this.isPremium = false,
    this.usageCount = 0,
    this.rating = 0.0,
    this.previewImage,
    required this.createdAt,
  });

  factory MessageTemplate.fromJson(Map<String, dynamic> json) {
    return MessageTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      tone: json['tone'] as String,
      recipientType: json['recipientType'] as String,
      templateText: json['templateText'] as String,
      tags: List<String>.from(json['tags'] ?? []),
      isPremium: json['isPremium'] as bool? ?? false,
      usageCount: json['usageCount'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      previewImage: json['previewImage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'tone': tone,
      'recipientType': recipientType,
      'templateText': templateText,
      'tags': tags,
      'isPremium': isPremium,
      'usageCount': usageCount,
      'rating': rating,
      'previewImage': previewImage,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Template categories
class TemplateCategory {
  static const String romantic = 'Romantic';
  static const String professional = 'Professional';
  static const String apology = 'Apology';
  static const String gratitude = 'Gratitude';
  static const String celebration = 'Celebration';
  static const String sympathy = 'Sympathy';
  static const String casual = 'Casual';
  static const String flirty = 'Flirty';

  static List<String> get all => [
    romantic,
    professional,
    apology,
    gratitude,
    celebration,
    sympathy,
    casual,
    flirty,
  ];
}

/// Pre-defined premium templates
class PremiumTemplates {
  static final List<MessageTemplate> templates = [
    // Romantic Premium Templates
    MessageTemplate(
      id: 'romantic_1',
      name: 'Poetic Love',
      description: 'Express your love with beautiful poetry',
      category: TemplateCategory.romantic,
      tone: 'Romantic',
      recipientType: 'Crush',
      templateText:
          'In the quiet moments between heartbeats, I find myself thinking of you. Your smile is the sunrise that brightens my darkest days, and your laughter is the melody that plays in my heart. Every moment with you feels like a beautiful dream I never want to wake from.',
      tags: ['love', 'poetry', 'deep', 'emotional'],
      isPremium: true,
      rating: 4.9,
      createdAt: DateTime.now(),
    ),
    MessageTemplate(
      id: 'romantic_2',
      name: 'First Date Follow-up',
      description: 'Perfect message after an amazing first date',
      category: TemplateCategory.romantic,
      tone: 'Romantic',
      recipientType: 'Crush',
      templateText:
          'I can\'t stop smiling thinking about last night. The way you laugh, the stories you shared, the connection we had - it all felt so natural and right. I\'d love to see you again soon. How about we continue our conversation over coffee this weekend?',
      tags: ['date', 'follow-up', 'sweet', 'genuine'],
      isPremium: true,
      rating: 4.8,
      createdAt: DateTime.now(),
    ),

    // Professional Premium Templates
    MessageTemplate(
      id: 'professional_1',
      name: 'Executive Thank You',
      description: 'Professional gratitude for senior executives',
      category: TemplateCategory.professional,
      tone: 'Professional',
      recipientType: 'Boss',
      templateText:
          'I wanted to express my sincere gratitude for your mentorship and guidance. Your leadership has been instrumental in my professional growth, and I deeply appreciate the opportunities you\'ve provided. Thank you for believing in my potential and pushing me to exceed my own expectations.',
      tags: ['gratitude', 'executive', 'formal', 'career'],
      isPremium: true,
      rating: 4.9,
      createdAt: DateTime.now(),
    ),
    MessageTemplate(
      id: 'professional_2',
      name: 'Networking Follow-up',
      description: 'Perfect for post-conference networking',
      category: TemplateCategory.professional,
      tone: 'Professional',
      recipientType: 'Colleague',
      templateText:
          'It was a pleasure meeting you at [Event Name]. Our conversation about [Topic] was truly insightful, and I\'d love to continue the discussion. I believe there could be valuable synergies between our work. Would you be open to a brief call next week?',
      tags: ['networking', 'business', 'follow-up', 'professional'],
      isPremium: true,
      rating: 4.7,
      createdAt: DateTime.now(),
    ),

    // Apology Premium Templates
    MessageTemplate(
      id: 'apology_1',
      name: 'Heartfelt Apology',
      description: 'Deep, sincere apology for serious situations',
      category: TemplateCategory.apology,
      tone: 'Apologetic',
      recipientType: 'Best Friend',
      templateText:
          'I\'ve been reflecting on what happened, and I realize how much I hurt you. There\'s no excuse for my actions, and I take full responsibility. Your friendship means the world to me, and I\'m truly sorry for letting you down. I understand if you need time, but I hope we can work through this together.',
      tags: ['sincere', 'deep', 'friendship', 'accountability'],
      isPremium: true,
      rating: 4.8,
      createdAt: DateTime.now(),
    ),

    // Gratitude Premium Templates
    MessageTemplate(
      id: 'gratitude_1',
      name: 'Life-Changing Thank You',
      description: 'For someone who made a significant impact',
      category: TemplateCategory.gratitude,
      tone: 'Grateful',
      recipientType: 'Family',
      templateText:
          'Words can\'t fully express how grateful I am for everything you\'ve done for me. You\'ve been my rock, my inspiration, and my biggest supporter. The sacrifices you\'ve made and the love you\'ve shown have shaped who I am today. Thank you for being the incredible person you are.',
      tags: ['gratitude', 'family', 'emotional', 'heartfelt'],
      isPremium: true,
      rating: 5.0,
      createdAt: DateTime.now(),
    ),

    // Celebration Premium Templates
    MessageTemplate(
      id: 'celebration_1',
      name: 'Milestone Achievement',
      description: 'Celebrate major life achievements',
      category: TemplateCategory.celebration,
      tone: 'Grateful',
      recipientType: 'Best Friend',
      templateText:
          'I am so incredibly proud of you! This achievement is a testament to your hard work, dedication, and unwavering spirit. You\'ve overcome so many challenges to get here, and watching you succeed fills my heart with joy. Here\'s to this amazing milestone and all the incredible things yet to come!',
      tags: ['celebration', 'achievement', 'proud', 'success'],
      isPremium: true,
      rating: 4.9,
      createdAt: DateTime.now(),
    ),

    // Flirty Premium Templates
    MessageTemplate(
      id: 'flirty_1',
      name: 'Playful Tease',
      description: 'Light, playful flirting',
      category: TemplateCategory.flirty,
      tone: 'Flirty',
      recipientType: 'Crush',
      templateText:
          'I have a confession to make... I\'ve been finding excuses to text you all day. There\'s something about our conversations that makes everything else seem less interesting. So, what are you doing later? Because I might have some more "excuses" to share 😊',
      tags: ['flirty', 'playful', 'fun', 'charming'],
      isPremium: true,
      rating: 4.7,
      createdAt: DateTime.now(),
    ),

    // More Romantic Templates
    MessageTemplate(
      id: 'romantic_3',
      name: 'Good Morning Love',
      description: 'Sweet morning message',
      category: TemplateCategory.romantic,
      tone: 'Romantic',
      recipientType: 'Girlfriend/Boyfriend',
      templateText:
          'Good morning, beautiful. I woke up thinking about you, which has become my favorite way to start the day. Your smile is the sunshine I need, and your love is the coffee that energizes my soul. Can\'t wait to see you today. ☀️💕',
      tags: ['morning', 'sweet', 'love', 'daily'],
      isPremium: true,
      rating: 4.9,
      createdAt: DateTime.now(),
    ),
    MessageTemplate(
      id: 'romantic_4',
      name: 'Anniversary Message',
      description: 'Celebrate your love',
      category: TemplateCategory.romantic,
      tone: 'Romantic',
      recipientType: 'Girlfriend/Boyfriend',
      templateText:
          'Happy anniversary to the person who makes every day feel like a celebration. These months/years with you have been the best of my life. You\'ve taught me what it means to truly love and be loved. Here\'s to many more adventures together, my love. 💑',
      tags: ['anniversary', 'celebration', 'milestone', 'love'],
      isPremium: true,
      rating: 5.0,
      createdAt: DateTime.now(),
    ),

    // Professional Templates
    MessageTemplate(
      id: 'professional_3',
      name: 'Project Collaboration',
      description: 'Propose working together',
      category: TemplateCategory.professional,
      tone: 'Professional',
      recipientType: 'Colleague',
      templateText:
          'Hi [Name], I\'ve been impressed by your work on [Project]. I believe our skills complement each other well, and I\'d love to explore potential collaboration opportunities. Would you be interested in discussing this over coffee next week?',
      tags: ['collaboration', 'networking', 'project', 'teamwork'],
      isPremium: true,
      rating: 4.8,
      createdAt: DateTime.now(),
    ),
    MessageTemplate(
      id: 'professional_4',
      name: 'Performance Recognition',
      description: 'Acknowledge great work',
      category: TemplateCategory.professional,
      tone: 'Professional',
      recipientType: 'Colleague',
      templateText:
          'I wanted to take a moment to recognize your outstanding work on [Project]. Your attention to detail and innovative approach made a significant impact on our results. It\'s a pleasure working with someone who consistently delivers excellence.',
      tags: ['recognition', 'praise', 'teamwork', 'appreciation'],
      isPremium: true,
      rating: 4.9,
      createdAt: DateTime.now(),
    ),

    // Casual/Friendship Templates
    MessageTemplate(
      id: 'casual_1',
      name: 'Weekend Plans',
      description: 'Casual hangout invitation',
      category: TemplateCategory.casual,
      tone: 'Casual',
      recipientType: 'Best Friend',
      templateText:
          'Hey! This weekend is looking pretty open for me. Want to grab some food and catch up? It\'s been too long since we just hung out and did nothing productive together 😄 Let me know!',
      tags: ['casual', 'hangout', 'weekend', 'friendship'],
      isPremium: false,
      rating: 4.6,
      createdAt: DateTime.now(),
    ),
    MessageTemplate(
      id: 'casual_2',
      name: 'Check-In Message',
      description: 'Just checking in on a friend',
      category: TemplateCategory.casual,
      tone: 'Casual',
      recipientType: 'Best Friend',
      templateText:
          'Hey you! Just wanted to check in and see how you\'re doing. I know life gets crazy, but remember I\'m always here if you need to talk, vent, or just grab a coffee. Miss you! 💙',
      tags: ['check-in', 'support', 'friendship', 'caring'],
      isPremium: false,
      rating: 4.7,
      createdAt: DateTime.now(),
    ),

    // Sympathy Templates
    MessageTemplate(
      id: 'sympathy_1',
      name: 'Condolence Message',
      description: 'Express sympathy for loss',
      category: TemplateCategory.sympathy,
      tone: 'Sincere',
      recipientType: 'Family',
      templateText:
          'I was deeply saddened to hear about your loss. Please know that you and your family are in my thoughts during this difficult time. [Name] was a wonderful person who touched many lives. If there\'s anything I can do to support you, please don\'t hesitate to reach out.',
      tags: ['sympathy', 'loss', 'support', 'condolence'],
      isPremium: true,
      rating: 4.9,
      createdAt: DateTime.now(),
    ),
    MessageTemplate(
      id: 'sympathy_2',
      name: 'Get Well Soon',
      description: 'Wishing someone recovery',
      category: TemplateCategory.sympathy,
      tone: 'Sincere',
      recipientType: 'Family',
      templateText:
          'Sending you healing thoughts and warm wishes for a speedy recovery. I know this is a challenging time, but you\'re one of the strongest people I know. Take all the time you need to rest and heal. I\'m here for you. 💚',
      tags: ['get-well', 'recovery', 'health', 'support'],
      isPremium: true,
      rating: 4.8,
      createdAt: DateTime.now(),
    ),

    // Celebration Templates
    MessageTemplate(
      id: 'celebration_2',
      name: 'Birthday Wishes',
      description: 'Heartfelt birthday message',
      category: TemplateCategory.celebration,
      tone: 'Grateful',
      recipientType: 'Best Friend',
      templateText:
          'Happy Birthday to someone who makes life so much brighter! 🎉 Another year older, wiser, and more amazing. I\'m so grateful to have you in my life. Here\'s to celebrating you today and always. May this year bring you everything your heart desires! 🎂🎈',
      tags: ['birthday', 'celebration', 'friendship', 'wishes'],
      isPremium: false,
      rating: 4.8,
      createdAt: DateTime.now(),
    ),
    MessageTemplate(
      id: 'celebration_3',
      name: 'New Job Congratulations',
      description: 'Celebrate career success',
      category: TemplateCategory.celebration,
      tone: 'Professional',
      recipientType: 'Colleague',
      templateText:
          'Congratulations on your new position! This is such exciting news and so well-deserved. Your hard work and dedication have truly paid off. Wishing you all the best in this new chapter of your career. They\'re lucky to have you! 🎊',
      tags: ['congratulations', 'career', 'success', 'professional'],
      isPremium: true,
      rating: 4.9,
      createdAt: DateTime.now(),
    ),

    // More Apology Templates
    MessageTemplate(
      id: 'apology_2',
      name: 'Professional Apology',
      description: 'Apologize for work mistake',
      category: TemplateCategory.apology,
      tone: 'Apologetic',
      recipientType: 'Boss',
      templateText:
          'I want to sincerely apologize for [mistake]. I take full responsibility for this oversight and understand the impact it had on the team. I\'ve already taken steps to ensure this doesn\'t happen again, including [action]. Thank you for your understanding.',
      tags: ['professional', 'accountability', 'work', 'mistake'],
      isPremium: true,
      rating: 4.7,
      createdAt: DateTime.now(),
    ),
    MessageTemplate(
      id: 'apology_3',
      name: 'Late Response Apology',
      description: 'Apologize for delayed reply',
      category: TemplateCategory.apology,
      tone: 'Apologetic',
      recipientType: 'Best Friend',
      templateText:
          'I\'m so sorry for the late response! Life got incredibly hectic, but that\'s no excuse for leaving you hanging. Your message deserved a timely reply, and I apologize for dropping the ball. Let\'s catch up soon - I miss our conversations!',
      tags: ['apology', 'late-response', 'friendship', 'casual'],
      isPremium: false,
      rating: 4.5,
      createdAt: DateTime.now(),
    ),

    // More Gratitude Templates
    MessageTemplate(
      id: 'gratitude_2',
      name: 'Thank You for Support',
      description: 'Express gratitude for help',
      category: TemplateCategory.gratitude,
      tone: 'Grateful',
      recipientType: 'Best Friend',
      templateText:
          'I don\'t say this enough, but thank you for always being there for me. Your support during [situation] meant more than words can express. You have a gift for knowing exactly what to say and do. I\'m incredibly lucky to have you in my life. 🙏',
      tags: ['gratitude', 'support', 'friendship', 'appreciation'],
      isPremium: true,
      rating: 4.9,
      createdAt: DateTime.now(),
    ),
    MessageTemplate(
      id: 'gratitude_3',
      name: 'Thank You Gift',
      description: 'Acknowledge a thoughtful gift',
      category: TemplateCategory.gratitude,
      tone: 'Grateful',
      recipientType: 'Family',
      templateText:
          'Thank you so much for the wonderful gift! You always know exactly what I need. It\'s not just the gift itself, but the thought and love behind it that touches my heart. I\'m so blessed to have you in my life. ❤️',
      tags: ['gratitude', 'gift', 'thoughtful', 'appreciation'],
      isPremium: false,
      rating: 4.7,
      createdAt: DateTime.now(),
    ),
  ];

  static List<MessageTemplate> get freeTemplates =>
      templates.where((t) => !t.isPremium).toList();

  static List<MessageTemplate> get premiumTemplates =>
      templates.where((t) => t.isPremium).toList();

  static List<MessageTemplate> getByCategory(String category) =>
      templates.where((t) => t.category == category).toList();

  static List<MessageTemplate> getByTone(String tone) =>
      templates.where((t) => t.tone == tone).toList();

  static MessageTemplate? getById(String id) => templates
      .cast<MessageTemplate?>()
      .firstWhere((t) => t?.id == id, orElse: () => null);
}
