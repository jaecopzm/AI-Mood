import 'dart:convert';
import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/message_model.dart';
import '../core/services/logger_service.dart';
import '../core/utils/result.dart';

/// ML-powered personalization service for intelligent message suggestions
class MLPersonalizationService {
  static const String _userBehaviorBoxName = 'user_behavior';
  static const String _personalPreferencesBoxName = 'personal_preferences';
  static const String _messagePatternsBoxName = 'message_patterns';

  Box<String>? _behaviorBox;
  Box<String>? _preferencesBox;
  Box<String>? _patternsBox;

  /// Initialize the ML personalization service
  Future<void> initialize() async {
    try {
      _behaviorBox = await Hive.openBox<String>(_userBehaviorBoxName);
      _preferencesBox = await Hive.openBox<String>(_personalPreferencesBoxName);
      _patternsBox = await Hive.openBox<String>(_messagePatternsBoxName);

      LoggerService.info('🤖 ML Personalization service initialized');
    } catch (e, stackTrace) {
      LoggerService.error(
        'Failed to initialize ML personalization service',
        e,
        stackTrace,
      );
    }
  }

  /// Record user interaction with a message
  Future<void> recordInteraction(UserInteraction interaction) async {
    try {
      final interactionData = jsonEncode(interaction.toJson());
      final key =
          '${DateTime.now().millisecondsSinceEpoch}_${interaction.type.name}';

      await _behaviorBox?.put(key, interactionData);

      // Update patterns based on this interaction
      await _updateMessagePatterns(interaction);

      LoggerService.debug('📊 Recorded interaction: ${interaction.type.name}');
    } catch (e) {
      LoggerService.error('Failed to record user interaction', e);
    }
  }

  /// Get personalized message suggestions based on user behavior
  Future<List<PersonalizedSuggestion>> getPersonalizedSuggestions({
    String? recipientType,
    String? context,
    int maxSuggestions = 5,
  }) async {
    try {
      final userProfile = await _buildUserProfile();
      final suggestions = <PersonalizedSuggestion>[];

      // Analyze user patterns
      final patterns = await _getMessagePatterns();

      // Generate suggestions based on patterns
      for (final pattern in patterns) {
        if (recipientType != null && pattern.recipientType != recipientType) {
          continue;
        }

        final suggestion = PersonalizedSuggestion(
          recipientType: pattern.recipientType,
          tone: pattern.preferredTone,
          context: pattern.commonContext,
          confidence: _calculateConfidence(pattern, userProfile),
          reason: _generateReason(pattern),
          templateId: pattern.templateId,
        );

        suggestions.add(suggestion);
      }

      // Sort by confidence and limit results
      suggestions.sort((a, b) => b.confidence.compareTo(a.confidence));
      return suggestions.take(maxSuggestions).toList();
    } catch (e) {
      LoggerService.error('Failed to generate personalized suggestions', e);
      return [];
    }
  }

  /// Predict the best tone for a given recipient and context
  Future<TonePrediction> predictBestTone({
    required String recipientType,
    String? context,
  }) async {
    try {
      final userProfile = await _buildUserProfile();
      final patterns = await _getMessagePatterns();

      // Filter patterns for this recipient type
      final relevantPatterns = patterns
          .where(
            (p) => p.recipientType.toLowerCase() == recipientType.toLowerCase(),
          )
          .toList();

      if (relevantPatterns.isEmpty) {
        return TonePrediction(
          tone: 'casual',
          confidence: 0.5,
          reason: 'No previous patterns found, using default tone',
        );
      }

      // Calculate tone preferences based on successful interactions
      final toneScores = <String, double>{};

      for (final pattern in relevantPatterns) {
        final score = pattern.successRate * pattern.usageCount;
        toneScores[pattern.preferredTone] =
            (toneScores[pattern.preferredTone] ?? 0) + score;
      }

      // Find the best tone
      final bestTone = toneScores.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );

      final confidence = _normalizeConfidence(
        bestTone.value,
        toneScores.values,
      );

      return TonePrediction(
        tone: bestTone.key,
        confidence: confidence,
        reason:
            'Based on ${relevantPatterns.length} previous successful messages',
      );
    } catch (e) {
      LoggerService.error('Failed to predict best tone', e);
      return TonePrediction(
        tone: 'casual',
        confidence: 0.5,
        reason: 'Prediction failed, using default',
      );
    }
  }

  /// Get smart context suggestions based on recipient and past messages
  Future<List<ContextSuggestion>> getContextSuggestions({
    required String recipientType,
    String? partialContext,
    int maxSuggestions = 3,
  }) async {
    try {
      final patterns = await _getMessagePatterns();
      final suggestions = <ContextSuggestion>[];

      // Filter patterns for this recipient
      final relevantPatterns = patterns
          .where(
            (p) => p.recipientType.toLowerCase() == recipientType.toLowerCase(),
          )
          .toList();

      // Extract common contexts
      final contextFrequency = <String, int>{};
      for (final pattern in relevantPatterns) {
        final contexts = pattern.commonContext.split(',');
        for (final context in contexts) {
          final trimmed = context.trim().toLowerCase();
          if (trimmed.isNotEmpty) {
            contextFrequency[trimmed] = (contextFrequency[trimmed] ?? 0) + 1;
          }
        }
      }

      // Filter by partial context if provided
      var filteredContexts = contextFrequency.entries.toList();
      if (partialContext != null && partialContext.isNotEmpty) {
        filteredContexts = filteredContexts
            .where((entry) => entry.key.contains(partialContext.toLowerCase()))
            .toList();
      }

      // Sort by frequency and create suggestions
      filteredContexts.sort((a, b) => b.value.compareTo(a.value));

      for (final entry in filteredContexts.take(maxSuggestions)) {
        suggestions.add(
          ContextSuggestion(
            context: _capitalizeFirst(entry.key),
            frequency: entry.value,
            examples: await _getExampleMessages(recipientType, entry.key),
          ),
        );
      }

      return suggestions;
    } catch (e) {
      LoggerService.error('Failed to get context suggestions', e);
      return [];
    }
  }

  /// Analyze user writing style and preferences
  Future<WritingStyleAnalysis> analyzeWritingStyle() async {
    try {
      final interactions = await _getAllInteractions();
      final analysis = WritingStyleAnalysis();

      // Analyze message lengths
      final lengths = <int>[];
      final toneUsage = <String, int>{};
      final recipientUsage = <String, int>{};
      final timePatterns = <int, int>{}; // Hour -> Count

      for (final interaction in interactions) {
        if (interaction.messageLength > 0) {
          lengths.add(interaction.messageLength);
        }

        toneUsage[interaction.tone] = (toneUsage[interaction.tone] ?? 0) + 1;
        recipientUsage[interaction.recipientType] =
            (recipientUsage[interaction.recipientType] ?? 0) + 1;

        final hour = interaction.timestamp.hour;
        timePatterns[hour] = (timePatterns[hour] ?? 0) + 1;
      }

      // Calculate statistics
      if (lengths.isNotEmpty) {
        analysis.averageWordCount =
            lengths.reduce((a, b) => a + b) / lengths.length;
        analysis.preferredMessageLength = _categorizeLength(
          analysis.averageWordCount,
        );
      }

      // Find preferred tone
      if (toneUsage.isNotEmpty) {
        analysis.mostUsedTone = toneUsage.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
      }

      // Find preferred recipient
      if (recipientUsage.isNotEmpty) {
        analysis.mostMessagedRecipient = recipientUsage.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
      }

      // Find peak activity time
      if (timePatterns.isNotEmpty) {
        final peakHour = timePatterns.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
        analysis.peakActivityTime = _formatHour(peakHour);
      }

      analysis.totalMessages = interactions.length;
      analysis.uniqueRecipients = recipientUsage.keys.length;
      analysis.uniqueTones = toneUsage.keys.length;

      return analysis;
    } catch (e) {
      LoggerService.error('Failed to analyze writing style', e);
      return WritingStyleAnalysis();
    }
  }

  /// Get personalized templates based on user preferences
  Future<List<PersonalizedTemplate>> getPersonalizedTemplates({
    required String recipientType,
    required String tone,
    int maxTemplates = 3,
  }) async {
    try {
      final userProfile = await _buildUserProfile();
      final patterns = await _getMessagePatterns();

      // Find matching patterns
      final matchingPatterns = patterns
          .where(
            (p) =>
                p.recipientType.toLowerCase() == recipientType.toLowerCase() &&
                p.preferredTone.toLowerCase() == tone.toLowerCase(),
          )
          .toList();

      final templates = <PersonalizedTemplate>[];

      for (final pattern in matchingPatterns.take(maxTemplates)) {
        templates.add(
          PersonalizedTemplate(
            templateId: pattern.templateId,
            content: await _generatePersonalizedTemplate(pattern, userProfile),
            confidence: pattern.successRate,
            usageCount: pattern.usageCount,
            lastUsed: pattern.lastUsed,
          ),
        );
      }

      return templates;
    } catch (e) {
      LoggerService.error('Failed to get personalized templates', e);
      return [];
    }
  }

  /// Update message patterns based on user interaction
  Future<void> _updateMessagePatterns(UserInteraction interaction) async {
    try {
      final patternKey = '${interaction.recipientType}_${interaction.tone}';
      final existingData = _patternsBox?.get(patternKey);

      MessagePattern pattern;
      if (existingData != null) {
        pattern = MessagePattern.fromJson(jsonDecode(existingData));
      } else {
        pattern = MessagePattern(
          recipientType: interaction.recipientType,
          preferredTone: interaction.tone,
          commonContext: interaction.context,
          usageCount: 0,
          successRate: 0.0,
          lastUsed: DateTime.now(),
          templateId: _generateTemplateId(),
        );
      }

      // Update pattern based on interaction
      pattern = pattern.copyWith(
        usageCount: pattern.usageCount + 1,
        successRate: _calculateSuccessRate(pattern, interaction),
        lastUsed: DateTime.now(),
        commonContext: _updateContext(
          pattern.commonContext,
          interaction.context,
        ),
      );

      await _patternsBox?.put(patternKey, jsonEncode(pattern.toJson()));
    } catch (e) {
      LoggerService.error('Failed to update message patterns', e);
    }
  }

  /// Build user profile from all interactions
  Future<UserProfile> _buildUserProfile() async {
    try {
      final interactions = await _getAllInteractions();

      if (interactions.isEmpty) {
        return UserProfile.defaultProfile();
      }

      final profile = UserProfile();

      // Analyze patterns
      final toneFreq = <String, int>{};
      final recipientFreq = <String, int>{};
      var totalLength = 0;
      var favoriteCount = 0;
      var shareCount = 0;

      for (final interaction in interactions) {
        toneFreq[interaction.tone] = (toneFreq[interaction.tone] ?? 0) + 1;
        recipientFreq[interaction.recipientType] =
            (recipientFreq[interaction.recipientType] ?? 0) + 1;
        totalLength += interaction.messageLength;

        if (interaction.type == InteractionType.favorite) favoriteCount++;
        if (interaction.type == InteractionType.share) shareCount++;
      }

      profile.preferredTones =
          toneFreq.entries
              .map((e) => TonePreference(tone: e.key, frequency: e.value))
              .toList()
            ..sort((a, b) => b.frequency.compareTo(a.frequency));

      profile.preferredRecipients =
          recipientFreq.entries
              .map(
                (e) =>
                    RecipientPreference(recipient: e.key, frequency: e.value),
              )
              .toList()
            ..sort((a, b) => b.frequency.compareTo(a.frequency));

      profile.averageMessageLength = totalLength / interactions.length;
      profile.engagementLevel =
          (favoriteCount + shareCount) / interactions.length;
      profile.totalInteractions = interactions.length;

      return profile;
    } catch (e) {
      LoggerService.error('Failed to build user profile', e);
      return UserProfile.defaultProfile();
    }
  }

  /// Get all user interactions
  Future<List<UserInteraction>> _getAllInteractions() async {
    final interactions = <UserInteraction>[];

    try {
      for (final key in _behaviorBox?.keys ?? <String>[]) {
        final data = _behaviorBox?.get(key);
        if (data != null) {
          final interaction = UserInteraction.fromJson(jsonDecode(data));
          interactions.add(interaction);
        }
      }
    } catch (e) {
      LoggerService.error('Failed to get all interactions', e);
    }

    return interactions;
  }

  /// Get all message patterns
  Future<List<MessagePattern>> _getMessagePatterns() async {
    final patterns = <MessagePattern>[];

    try {
      for (final key in _patternsBox?.keys ?? <String>[]) {
        final data = _patternsBox?.get(key);
        if (data != null) {
          final pattern = MessagePattern.fromJson(jsonDecode(data));
          patterns.add(pattern);
        }
      }
    } catch (e) {
      LoggerService.error('Failed to get message patterns', e);
    }

    return patterns;
  }

  // Helper methods
  double _calculateConfidence(MessagePattern pattern, UserProfile profile) {
    double confidence = pattern.successRate * 0.4; // Base success rate
    confidence += (pattern.usageCount / 100).clamp(0.0, 0.3); // Usage frequency

    // Boost if it matches user preferences
    final preferredTone = profile.preferredTones.isNotEmpty
        ? profile.preferredTones.first.tone
        : null;
    if (preferredTone == pattern.preferredTone) {
      confidence += 0.2;
    }

    // Recency boost
    final daysSinceLastUse = DateTime.now().difference(pattern.lastUsed).inDays;
    if (daysSinceLastUse < 7) {
      confidence += 0.1;
    }

    return confidence.clamp(0.0, 1.0);
  }

  String _generateReason(MessagePattern pattern) {
    if (pattern.usageCount > 10) {
      return 'You frequently use this style with ${pattern.recipientType}';
    } else if (pattern.successRate > 0.8) {
      return 'This approach has been very successful for you';
    } else {
      return 'Based on your messaging patterns';
    }
  }

  double _normalizeConfidence(double value, Iterable<double> allValues) {
    if (allValues.isEmpty) return 0.5;

    final maxValue = allValues.reduce((a, b) => a > b ? a : b);
    final minValue = allValues.reduce((a, b) => a < b ? a : b);

    if (maxValue == minValue) return 0.5;

    return ((value - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);
  }

  double _calculateSuccessRate(
    MessagePattern pattern,
    UserInteraction interaction,
  ) {
    // Simple success calculation based on interaction type
    double newScore;
    switch (interaction.type) {
      case InteractionType.favorite:
        newScore = 1.0;
        break;
      case InteractionType.share:
        newScore = 0.9;
        break;
      case InteractionType.copy:
        newScore = 0.8;
        break;
      case InteractionType.view:
        newScore = 0.6;
        break;
      case InteractionType.generate:
        newScore = 0.7;
        break;
      default:
        newScore = 0.5;
    }

    // Weighted average with existing success rate
    final totalInteractions = pattern.usageCount;
    if (totalInteractions == 0) return newScore;

    return (pattern.successRate * totalInteractions + newScore) /
        (totalInteractions + 1);
  }

  String _updateContext(String existingContext, String newContext) {
    final existing = existingContext
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final newContexts = newContext
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final combined = {...existing, ...newContexts}.toList();
    return combined.take(5).join(', '); // Keep top 5 contexts
  }

  String _generateTemplateId() {
    return 'template_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _categorizeLength(double averageLength) {
    if (averageLength < 50) return 'Short';
    if (averageLength < 120) return 'Medium';
    return 'Long';
  }

  String _formatHour(int hour) {
    if (hour < 12) return '${hour == 0 ? 12 : hour}:00 AM';
    return '${hour == 12 ? 12 : hour - 12}:00 PM';
  }

  Future<List<String>> _getExampleMessages(
    String recipientType,
    String context,
  ) async {
    // Return example messages for the context - simplified for demo
    return ['Example message for $context', 'Another example for this context'];
  }

  Future<String> _generatePersonalizedTemplate(
    MessagePattern pattern,
    UserProfile profile,
  ) async {
    // Generate a personalized template based on the pattern and user profile
    // This would be more sophisticated in a real implementation
    return 'Personalized template for ${pattern.recipientType} with ${pattern.preferredTone} tone about ${pattern.commonContext}';
  }

  /// Clean up old data to manage storage
  Future<void> cleanupOldData() async {
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 365));
      final keysToDelete = <String>[];

      // Clean old interactions
      for (final key in _behaviorBox?.keys ?? <String>[]) {
        try {
          final timestamp = int.parse(key.split('_')[0]);
          final date = DateTime.fromMillisecondsSinceEpoch(timestamp);

          if (date.isBefore(cutoffDate)) {
            keysToDelete.add(key);
          }
        } catch (e) {
          // If we can't parse the key, mark it for deletion
          keysToDelete.add(key);
        }
      }

      for (final key in keysToDelete) {
        await _behaviorBox?.delete(key);
      }

      LoggerService.info(
        '🧹 ML service cleaned up ${keysToDelete.length} old records',
      );
    } catch (e) {
      LoggerService.error('Failed to cleanup ML data', e);
    }
  }
}

// Data Models for ML Service
class UserInteraction {
  final InteractionType type;
  final String recipientType;
  final String tone;
  final String context;
  final int messageLength;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const UserInteraction({
    required this.type,
    required this.recipientType,
    required this.tone,
    required this.context,
    required this.messageLength,
    required this.timestamp,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'recipientType': recipientType,
    'tone': tone,
    'context': context,
    'messageLength': messageLength,
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata,
  };

  factory UserInteraction.fromJson(Map<String, dynamic> json) =>
      UserInteraction(
        type: InteractionType.values.firstWhere((e) => e.name == json['type']),
        recipientType: json['recipientType'],
        tone: json['tone'],
        context: json['context'],
        messageLength: json['messageLength'],
        timestamp: DateTime.parse(json['timestamp']),
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      );
}

enum InteractionType { generate, view, copy, share, favorite, delete, edit }

class MessagePattern {
  final String recipientType;
  final String preferredTone;
  final String commonContext;
  final int usageCount;
  final double successRate;
  final DateTime lastUsed;
  final String templateId;

  const MessagePattern({
    required this.recipientType,
    required this.preferredTone,
    required this.commonContext,
    required this.usageCount,
    required this.successRate,
    required this.lastUsed,
    required this.templateId,
  });

  MessagePattern copyWith({
    String? recipientType,
    String? preferredTone,
    String? commonContext,
    int? usageCount,
    double? successRate,
    DateTime? lastUsed,
    String? templateId,
  }) {
    return MessagePattern(
      recipientType: recipientType ?? this.recipientType,
      preferredTone: preferredTone ?? this.preferredTone,
      commonContext: commonContext ?? this.commonContext,
      usageCount: usageCount ?? this.usageCount,
      successRate: successRate ?? this.successRate,
      lastUsed: lastUsed ?? this.lastUsed,
      templateId: templateId ?? this.templateId,
    );
  }

  Map<String, dynamic> toJson() => {
    'recipientType': recipientType,
    'preferredTone': preferredTone,
    'commonContext': commonContext,
    'usageCount': usageCount,
    'successRate': successRate,
    'lastUsed': lastUsed.toIso8601String(),
    'templateId': templateId,
  };

  factory MessagePattern.fromJson(Map<String, dynamic> json) => MessagePattern(
    recipientType: json['recipientType'],
    preferredTone: json['preferredTone'],
    commonContext: json['commonContext'],
    usageCount: json['usageCount'],
    successRate: json['successRate'],
    lastUsed: DateTime.parse(json['lastUsed']),
    templateId: json['templateId'],
  );
}

class PersonalizedSuggestion {
  final String recipientType;
  final String tone;
  final String context;
  final double confidence;
  final String reason;
  final String templateId;

  const PersonalizedSuggestion({
    required this.recipientType,
    required this.tone,
    required this.context,
    required this.confidence,
    required this.reason,
    required this.templateId,
  });
}

class TonePrediction {
  final String tone;
  final double confidence;
  final String reason;

  const TonePrediction({
    required this.tone,
    required this.confidence,
    required this.reason,
  });
}

class ContextSuggestion {
  final String context;
  final int frequency;
  final List<String> examples;

  const ContextSuggestion({
    required this.context,
    required this.frequency,
    required this.examples,
  });
}

class WritingStyleAnalysis {
  double averageWordCount = 0;
  String preferredMessageLength = 'Medium';
  String mostUsedTone = '';
  String mostMessagedRecipient = '';
  String peakActivityTime = '';
  int totalMessages = 0;
  int uniqueRecipients = 0;
  int uniqueTones = 0;
}

class PersonalizedTemplate {
  final String templateId;
  final String content;
  final double confidence;
  final int usageCount;
  final DateTime lastUsed;

  const PersonalizedTemplate({
    required this.templateId,
    required this.content,
    required this.confidence,
    required this.usageCount,
    required this.lastUsed,
  });
}

class UserProfile {
  List<TonePreference> preferredTones = [];
  List<RecipientPreference> preferredRecipients = [];
  double averageMessageLength = 0;
  double engagementLevel = 0;
  int totalInteractions = 0;

  UserProfile(); // Add default constructor

  factory UserProfile.defaultProfile() {
    final profile = UserProfile();
    profile.preferredTones = [TonePreference(tone: 'casual', frequency: 1)];
    profile.preferredRecipients = [
      RecipientPreference(recipient: 'friend', frequency: 1),
    ];
    profile.averageMessageLength = 50;
    profile.engagementLevel = 0.5;
    profile.totalInteractions = 0;
    return profile;
  }
}

class TonePreference {
  final String tone;
  final int frequency;

  const TonePreference({required this.tone, required this.frequency});
}

class RecipientPreference {
  final String recipient;
  final int frequency;

  const RecipientPreference({required this.recipient, required this.frequency});
}
