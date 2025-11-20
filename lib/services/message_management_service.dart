import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/message_model.dart';
import '../core/services/logger_service.dart';
import '../core/utils/result.dart';
import 'dart:math' as math;

/// Enhanced service for managing user messages with search, filtering, and favorites
class MessageManagementService {
  static const String _messagesBoxName = 'user_messages';
  static const String _favoritesBoxName = 'favorite_messages';
  static const String _tagsBoxName = 'message_tags';
  
  Box<String>? _messagesBox;
  Box<String>? _favoritesBox;
  Box<String>? _tagsBox;

  /// Initialize the message management service
  Future<void> initialize() async {
    try {
      _messagesBox = await Hive.openBox<String>(_messagesBoxName);
      _favoritesBox = await Hive.openBox<String>(_favoritesBoxName);
      _tagsBox = await Hive.openBox<String>(_tagsBoxName);
      
      LoggerService.info('✅ Message management service initialized');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to initialize message management service', e, stackTrace);
    }
  }

  /// Save a message to user's history
  Future<Result<void>> saveMessage(MessageModel message) async {
    try {
      await _messagesBox?.put(message.id, jsonEncode(message.toJson()));
      LoggerService.debug('💾 Saved message: ${message.id}');
      return Result.success(null);
    } catch (e) {
      LoggerService.error('Failed to save message', e);
      return Result.failure(Exception('Failed to save message: $e'));
    }
  }

  /// Get all user messages with optional filtering
  Future<Result<List<MessageModel>>> getMessages({
    String? recipientFilter,
    String? toneFilter,
    DateTime? fromDate,
    DateTime? toDate,
    bool favoritesOnly = false,
    String? searchQuery,
    int? limit,
  }) async {
    try {
      final allMessages = <MessageModel>[];
      final box = favoritesOnly ? _favoritesBox : _messagesBox;
      
      for (final key in box?.keys ?? <String>[]) {
        try {
          final messageData = box?.get(key);
          if (messageData != null) {
            final message = MessageModel.fromJson(jsonDecode(messageData));
            allMessages.add(message);
          }
        } catch (e) {
          LoggerService.warning('Failed to parse message $key: $e');
        }
      }

      // Apply filters
      var filteredMessages = allMessages;
      
      if (recipientFilter != null) {
        filteredMessages = filteredMessages
            .where((msg) => msg.recipientType.toLowerCase().contains(recipientFilter.toLowerCase()))
            .toList();
      }
      
      if (toneFilter != null) {
        filteredMessages = filteredMessages
            .where((msg) => msg.tone.toLowerCase().contains(toneFilter.toLowerCase()))
            .toList();
      }
      
      if (fromDate != null) {
        filteredMessages = filteredMessages
            .where((msg) => msg.createdAt.isAfter(fromDate))
            .toList();
      }
      
      if (toDate != null) {
        filteredMessages = filteredMessages
            .where((msg) => msg.createdAt.isBefore(toDate))
            .toList();
      }
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        filteredMessages = filteredMessages.where((msg) {
          return msg.generatedText.toLowerCase().contains(query) ||
                 msg.context.toLowerCase().contains(query) ||
                 msg.recipientType.toLowerCase().contains(query) ||
                 msg.tone.toLowerCase().contains(query);
        }).toList();
      }
      
      // Sort by creation date (newest first)
      filteredMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // Apply limit
      if (limit != null && limit > 0) {
        filteredMessages = filteredMessages.take(limit).toList();
      }
      
      LoggerService.debug('📋 Retrieved ${filteredMessages.length} messages');
      return Result.success(filteredMessages);
    } catch (e) {
      LoggerService.error('Failed to get messages', e);
      return Result.failure(Exception('Failed to retrieve messages: $e'));
    }
  }

  /// Add message to favorites
  Future<Result<void>> addToFavorites(MessageModel message) async {
    try {
      final updatedMessage = MessageModel(
        id: message.id,
        userId: message.userId,
        recipientType: message.recipientType,
        tone: message.tone,
        context: message.context,
        generatedText: message.generatedText,
        variations: message.variations,
        wordLimit: message.wordLimit,
        createdAt: message.createdAt,
        isSaved: true,
      );
      
      await _favoritesBox?.put(message.id, jsonEncode(updatedMessage.toJson()));
      
      // Also update in main messages box
      await _messagesBox?.put(message.id, jsonEncode(updatedMessage.toJson()));
      
      LoggerService.debug('⭐ Added to favorites: ${message.id}');
      return Result.success(null);
    } catch (e) {
      LoggerService.error('Failed to add to favorites', e);
      return Result.failure(Exception('Failed to add to favorites: $e'));
    }
  }

  /// Remove message from favorites
  Future<Result<void>> removeFromFavorites(String messageId) async {
    try {
      await _favoritesBox?.delete(messageId);
      
      // Update in main messages box
      final messageData = _messagesBox?.get(messageId);
      if (messageData != null) {
        final message = MessageModel.fromJson(jsonDecode(messageData));
        final updatedMessage = MessageModel(
          id: message.id,
          userId: message.userId,
          recipientType: message.recipientType,
          tone: message.tone,
          context: message.context,
          generatedText: message.generatedText,
          variations: message.variations,
          wordLimit: message.wordLimit,
          createdAt: message.createdAt,
          isSaved: false,
        );
        await _messagesBox?.put(messageId, jsonEncode(updatedMessage.toJson()));
      }
      
      LoggerService.debug('💔 Removed from favorites: $messageId');
      return Result.success(null);
    } catch (e) {
      LoggerService.error('Failed to remove from favorites', e);
      return Result.failure(Exception('Failed to remove from favorites: $e'));
    }
  }

  /// Check if message is in favorites
  bool isFavorite(String messageId) {
    return _favoritesBox?.containsKey(messageId) ?? false;
  }

  /// Delete a message permanently
  Future<Result<void>> deleteMessage(String messageId) async {
    try {
      await _messagesBox?.delete(messageId);
      await _favoritesBox?.delete(messageId);
      
      LoggerService.debug('🗑️ Deleted message: $messageId');
      return Result.success(null);
    } catch (e) {
      LoggerService.error('Failed to delete message', e);
      return Result.failure(Exception('Failed to delete message: $e'));
    }
  }

  /// Get message statistics
  Future<MessageStatistics> getStatistics() async {
    try {
      final allMessages = await getMessages();
      if (allMessages.isFailure) {
        throw Exception('Failed to retrieve messages for statistics');
      }
      
      final messages = allMessages.data!;
      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month, 1);
      
      final stats = MessageStatistics(
        totalMessages: messages.length,
        favoritesCount: _favoritesBox?.length ?? 0,
        thisMonthCount: messages.where((msg) => msg.createdAt.isAfter(thisMonth)).length,
        mostUsedTone: _getMostUsedTone(messages),
        mostUsedRecipient: _getMostUsedRecipient(messages),
        averageWordsPerMessage: _getAverageWords(messages),
      );
      
      LoggerService.debug('📊 Generated message statistics');
      return stats;
    } catch (e) {
      LoggerService.error('Failed to generate statistics', e);
      return MessageStatistics.empty();
    }
  }

  /// Get unique recipients from user messages
  Future<List<String>> getUniqueRecipients() async {
    try {
      final result = await getMessages();
      if (result.isFailure) return [];
      
      final recipients = result.data!
          .map((msg) => msg.recipientType)
          .toSet()
          .toList();
      recipients.sort();
      
      return recipients;
    } catch (e) {
      LoggerService.error('Failed to get unique recipients', e);
      return [];
    }
  }

  /// Get unique tones from user messages
  Future<List<String>> getUniqueTones() async {
    try {
      final result = await getMessages();
      if (result.isFailure) return [];
      
      final tones = result.data!
          .map((msg) => msg.tone)
          .toSet()
          .toList();
      tones.sort();
      
      return tones;
    } catch (e) {
      LoggerService.error('Failed to get unique tones', e);
      return [];
    }
  }

  /// Get recent search suggestions
  Future<List<String>> getSearchSuggestions() async {
    try {
      final result = await getMessages(limit: 50);
      if (result.isFailure) return [];
      
      final suggestions = <String>{};
      
      for (final message in result.data!) {
        // Add context words
        final contextWords = message.context.split(' ')
            .where((word) => word.length > 3)
            .take(3);
        suggestions.addAll(contextWords);
        
        // Add recipient and tone
        suggestions.add(message.recipientType);
        suggestions.add(message.tone);
      }
      
      return suggestions.toList()..sort();
    } catch (e) {
      LoggerService.error('Failed to get search suggestions', e);
      return [];
    }
  }

  /// Export messages to JSON
  Future<Result<String>> exportMessages({
    bool favoritesOnly = false,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final result = await getMessages(
        favoritesOnly: favoritesOnly,
        fromDate: fromDate,
        toDate: toDate,
      );
      
      if (result.isFailure) {
        return Result.failure(Exception('Failed to retrieve messages for export'));
      }
      
      final exportData = {
        'exportedAt': DateTime.now().toIso8601String(),
        'messageCount': result.data!.length,
        'exportType': favoritesOnly ? 'favorites' : 'all',
        'dateRange': {
          'from': fromDate?.toIso8601String(),
          'to': toDate?.toIso8601String(),
        },
        'messages': result.data!.map((msg) => msg.toJson()).toList(),
      };
      
      final jsonString = jsonEncode(exportData);
      LoggerService.info('📤 Exported ${result.data!.length} messages');
      
      return Result.success(jsonString);
    } catch (e) {
      LoggerService.error('Failed to export messages', e);
      return Result.failure(Exception('Failed to export messages: $e'));
    }
  }

  /// Export message as plain text
  String exportMessageAsText(MessageModel message) {
    return '''Message for ${message.recipientType}
Tone: ${message.tone}
Date: ${message.createdAt.toString().split('.')[0]}

${message.generatedText}

---
Generated by AI Mood
''';
  }

  /// Export message as markdown
  String exportMessageAsMarkdown(MessageModel message) {
    return '''# Message for ${_capitalizeFirst(message.recipientType)}

**Tone:** ${_capitalizeFirst(message.tone)}  
**Created:** ${message.createdAt.toString().split('.')[0]}

> ${message.generatedText}

---
*Generated by AI Mood*
''';
  }

  /// Calculate average message length
  double calculateAverageLength(List<MessageModel> messages) {
    if (messages.isEmpty) return 0.0;
    final total = messages.fold<int>(
      0,
      (sum, msg) => sum + msg.generatedText.length,
    );
    return total / messages.length;
  }

  /// Count messages by recipient
  Map<String, int> countByRecipient(List<MessageModel> messages) {
    final counts = <String, int>{};
    for (var msg in messages) {
      counts[msg.recipientType] = (counts[msg.recipientType] ?? 0) + 1;
    }
    return counts;
  }

  /// Count messages by tone
  Map<String, int> countByTone(List<MessageModel> messages) {
    final counts = <String, int>{};
    for (var msg in messages) {
      counts[msg.tone] = (counts[msg.tone] ?? 0) + 1;
    }
    return counts;
  }

  /// Calculate total words generated
  int calculateTotalWords(List<MessageModel> messages) {
    return messages.fold(
      0,
      (sum, msg) => sum + msg.generatedText.split(' ').length,
    );
  }

  /// Get generation statistics
  Map<String, dynamic> getGenerationStats(List<MessageModel> messages) {
    return {
      'totalMessages': messages.length,
      'totalWords': calculateTotalWords(messages),
      'averageLength': calculateAverageLength(messages),
      'byRecipient': countByRecipient(messages),
      'byTone': countByTone(messages),
      'savedCount': messages.where((m) => m.isSaved).length,
    };
  }

  /// Clean up old messages (keep last 1000 or 6 months)
  Future<void> cleanupOldMessages({
    int maxMessages = 1000,
    Duration maxAge = const Duration(days: 180),
  }) async {
    try {
      final result = await getMessages();
      if (result.isFailure) return;
      
      final messages = result.data!;
      final cutoffDate = DateTime.now().subtract(maxAge);
      
      // Sort by date (newest first)
      messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      final messagesToDelete = <String>[];
      
      // Mark messages for deletion if they exceed count limit
      if (messages.length > maxMessages) {
        for (int i = maxMessages; i < messages.length; i++) {
          messagesToDelete.add(messages[i].id);
        }
      }
      
      // Mark old messages for deletion (but preserve favorites)
      for (final message in messages) {
        if (message.createdAt.isBefore(cutoffDate) && !message.isSaved) {
          messagesToDelete.add(message.id);
        }
      }
      
      // Delete marked messages
      for (final messageId in messagesToDelete) {
        await _messagesBox?.delete(messageId);
      }
      
      LoggerService.info('🧹 Cleaned up ${messagesToDelete.length} old messages');
    } catch (e) {
      LoggerService.error('Failed to cleanup old messages', e);
    }
  }

  // Helper methods
  String _getMostUsedTone(List<MessageModel> messages) {
    if (messages.isEmpty) return '';
    
    final toneCount = <String, int>{};
    for (final message in messages) {
      toneCount[message.tone] = (toneCount[message.tone] ?? 0) + 1;
    }
    
    return toneCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  String _getMostUsedRecipient(List<MessageModel> messages) {
    if (messages.isEmpty) return '';
    
    final recipientCount = <String, int>{};
    for (final message in messages) {
      recipientCount[message.recipientType] = (recipientCount[message.recipientType] ?? 0) + 1;
    }
    
    return recipientCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  double _getAverageWords(List<MessageModel> messages) {
    if (messages.isEmpty) return 0.0;
    
    final totalWords = messages.fold<int>(0, (sum, message) {
      return sum + message.generatedText.split(' ').length;
    });
    
    return totalWords / messages.length;
  }
  
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

/// Statistics about user's messages
class MessageStatistics {
  final int totalMessages;
  final int favoritesCount;
  final int thisMonthCount;
  final String mostUsedTone;
  final String mostUsedRecipient;
  final double averageWordsPerMessage;

  const MessageStatistics({
    required this.totalMessages,
    required this.favoritesCount,
    required this.thisMonthCount,
    required this.mostUsedTone,
    required this.mostUsedRecipient,
    required this.averageWordsPerMessage,
  });

  factory MessageStatistics.empty() {
    return const MessageStatistics(
      totalMessages: 0,
      favoritesCount: 0,
      thisMonthCount: 0,
      mostUsedTone: '',
      mostUsedRecipient: '',
      averageWordsPerMessage: 0.0,
    );
  }
}