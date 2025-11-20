import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/message_model.dart';
import '../core/services/logger_service.dart';

/// Service for caching messages and providing offline fallbacks
class MessageCacheService {
  static const String _cacheBoxName = 'message_cache';
  static const String _templatesBoxName = 'message_templates';
  static const String _userPreferencesBoxName = 'user_preferences';
  
  Box<String>? _cacheBox;
  Box<String>? _templatesBox;
  Box<String>? _userPreferencesBox;

  /// Initialize the cache service
  Future<void> initialize() async {
    try {
      _cacheBox = await Hive.openBox<String>(_cacheBoxName);
      _templatesBox = await Hive.openBox<String>(_templatesBoxName);
      _userPreferencesBox = await Hive.openBox<String>(_userPreferencesBoxName);
      
      await _initializeDefaultTemplates();
      LoggerService.info('✅ Message cache service initialized');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to initialize message cache service', e, stackTrace);
    }
  }

  /// Cache a generated message for future offline use
  Future<void> cacheMessage(MessageModel message) async {
    try {
      final key = _generateCacheKey(
        message.recipientType, 
        message.tone, 
        message.context
      );
      await _cacheBox?.put(key, jsonEncode(message.toJson()));
      LoggerService.debug('📦 Cached message: $key');
    } catch (e) {
      LoggerService.error('Failed to cache message', e);
    }
  }

  /// Get cached message if available
  MessageModel? getCachedMessage(String recipientType, String tone, String context) {
    try {
      final key = _generateCacheKey(recipientType, tone, context);
      final cachedData = _cacheBox?.get(key);
      
      if (cachedData != null) {
        final messageJson = jsonDecode(cachedData);
        LoggerService.debug('📦 Retrieved cached message: $key');
        return MessageModel.fromJson(messageJson);
      }
    } catch (e) {
      LoggerService.error('Failed to retrieve cached message', e);
    }
    return null;
  }

  /// Get offline fallback message based on preferences
  String getOfflineFallbackMessage({
    required String recipientType,
    required String tone,
    required String context,
  }) {
    try {
      final templates = _getTemplatesForScenario(recipientType, tone);
      if (templates.isNotEmpty) {
        // Simple template selection based on context keywords
        final selectedTemplate = _selectBestTemplate(templates, context);
        return _personalizeTemplate(selectedTemplate, context);
      }
    } catch (e) {
      LoggerService.error('Failed to get offline fallback message', e);
    }
    
    return _getGenericFallback(recipientType, tone);
  }

  /// Store user message preferences for personalization
  Future<void> storeUserPreference({
    required String recipientType,
    required String tone,
    required String preferredStyle,
  }) async {
    try {
      final key = '${recipientType}_$tone';
      await _userPreferencesBox?.put(key, preferredStyle);
      LoggerService.debug('👤 Stored user preference: $key -> $preferredStyle');
    } catch (e) {
      LoggerService.error('Failed to store user preference', e);
    }
  }

  /// Get user preferred style for recipient/tone combination
  String? getUserPreference(String recipientType, String tone) {
    try {
      final key = '${recipientType}_$tone';
      return _userPreferencesBox?.get(key);
    } catch (e) {
      LoggerService.error('Failed to get user preference', e);
    }
    return null;
  }

  /// Generate cache key for message
  String _generateCacheKey(String recipientType, String tone, String context) {
    final contextHash = context.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return '${recipientType.toLowerCase()}_${tone.toLowerCase()}_${contextHash.length > 10 ? contextHash.substring(0, 10) : contextHash}';
  }

  /// Initialize default message templates for offline use
  Future<void> _initializeDefaultTemplates() async {
    final defaultTemplates = {
      // Romantic messages
      'crush_romantic': [
        "I've been thinking about you lately, and I couldn't help but smile. {context} You have this amazing way of brightening my day just by being yourself.",
        "There's something magical about {context}. Every moment with you feels like a beautiful adventure waiting to unfold.",
        "I find myself getting lost in thoughts of you, especially when {context}. You're absolutely wonderful."
      ],
      'girlfriend/boyfriend_romantic': [
        "Every day with you feels like a blessing. {context} I love how you make even ordinary moments extraordinary.",
        "You know what I love most about us? {context} We've built something beautiful together, and I cherish every moment.",
        "My heart is full because of you. {context} Thank you for being the incredible person you are."
      ],
      
      // Friendly messages
      'best friend_casual': [
        "Hey bestie! I was just thinking about {context} and had to reach out. You always know how to make everything better!",
        "You're amazing, and I hope you know it! {context} Thanks for being such an incredible friend.",
        "Just wanted to remind you how awesome you are. {context} Lucky to have you in my life!"
      ],
      
      // Family messages
      'family_sincere': [
        "Family means everything to me, and you're such a special part of that. {context} Thank you for all the love and support.",
        "I'm so grateful to have you in my life. {context} Your love and guidance mean the world to me.",
        "Thinking of you today and feeling so thankful. {context} Love you so much!"
      ],
      
      // Professional messages
      'colleague_professional': [
        "I wanted to take a moment to acknowledge {context}. Your professionalism and dedication are truly appreciated.",
        "Thank you for your excellent work on {context}. It's a pleasure working with someone so capable and reliable.",
        "I'm impressed by your handling of {context}. Your expertise really made a difference."
      ],
      'boss_professional': [
        "I appreciate your leadership and guidance, especially regarding {context}. Thank you for your continued support.",
        "Your insights on {context} were invaluable. I'm grateful to learn from your experience and expertise.",
        "Thank you for the opportunity to work on {context}. I value your trust and mentorship."
      ],
      
      // Apologetic messages
      'friend_apologetic': [
        "I've been thinking about what happened, and I realize I was wrong about {context}. I'm truly sorry and hope we can work through this.",
        "I owe you an apology for {context}. You mean too much to me to let this come between us. Can we talk?",
        "I messed up with {context}, and I'm genuinely sorry. Your friendship is important to me, and I want to make things right."
      ],
      
      // Grateful messages
      'friend_grateful': [
        "I can't thank you enough for {context}. You went above and beyond, and it means the world to me.",
        "Your kindness regarding {context} has touched my heart. I'm so lucky to have a friend like you.",
        "Thank you for being there when {context}. Your support means everything to me."
      ]
    };

    for (final entry in defaultTemplates.entries) {
      await _templatesBox?.put(entry.key, jsonEncode(entry.value));
    }
  }

  /// Get templates for specific scenario
  List<String> _getTemplatesForScenario(String recipientType, String tone) {
    final key = '${recipientType.toLowerCase()}_${tone.toLowerCase()}';
    final templatesData = _templatesBox?.get(key);
    
    if (templatesData != null) {
      try {
        return List<String>.from(jsonDecode(templatesData));
      } catch (e) {
        LoggerService.error('Failed to decode templates for $key', e);
      }
    }
    
    return [];
  }

  /// Select best template based on context
  String _selectBestTemplate(List<String> templates, String context) {
    // Simple selection - in a real app, this could use ML or keyword matching
    if (templates.isEmpty) return '';
    
    // For now, just return a random template
    final index = context.length % templates.length;
    return templates[index];
  }

  /// Personalize template with context
  String _personalizeTemplate(String template, String context) {
    return template.replaceAll('{context}', context.isNotEmpty ? context : 'our connection');
  }

  /// Get generic fallback message
  String _getGenericFallback(String recipientType, String tone) {
    final fallbacks = {
      'romantic': "You mean so much to me. Every moment we share is precious, and I wanted you to know how much I care about you.",
      'funny': "Just wanted to brighten your day with a message! You always manage to make me smile, so I'm returning the favor.",
      'professional': "Thank you for your continued collaboration and professionalism. It's a pleasure working with you.",
      'apologetic': "I want to apologize and make things right between us. You're important to me, and I hope we can move forward together.",
      'grateful': "I'm truly grateful for everything you do and for being such an important part of my life. Thank you!",
      'casual': "Hey there! Just wanted to reach out and let you know I'm thinking of you. Hope you're having a great day!",
    };

    return fallbacks[tone.toLowerCase()] ?? 
           "Thank you for being such an important part of my life. I wanted to reach out and connect with you today.";
  }

  /// Clear old cache entries to manage storage
  Future<void> clearOldCache({Duration maxAge = const Duration(days: 30)}) async {
    try {
      final now = DateTime.now();
      final keysToDelete = <String>[];
      
      for (final key in _cacheBox?.keys ?? <String>[]) {
        try {
          final messageData = _cacheBox?.get(key);
          if (messageData != null) {
            final messageJson = jsonDecode(messageData);
            final createdAt = DateTime.parse(messageJson['createdAt']);
            
            if (now.difference(createdAt) > maxAge) {
              keysToDelete.add(key);
            }
          }
        } catch (e) {
          // If we can't parse the data, mark it for deletion
          keysToDelete.add(key);
        }
      }
      
      for (final key in keysToDelete) {
        await _cacheBox?.delete(key);
      }
      
      LoggerService.info('🧹 Cleared ${keysToDelete.length} old cache entries');
    } catch (e) {
      LoggerService.error('Failed to clear old cache', e);
    }
  }
}