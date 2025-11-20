import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import '../services/firebase_ai_service.dart';
import '../services/message_management_service.dart';
import '../core/di/service_locator.dart';
import '../core/services/logger_service.dart';

/// Enhanced message provider with offline support and caching
final enhancedMessageProvider = StateNotifierProvider<EnhancedMessageNotifier, EnhancedMessageState>((ref) {
  return EnhancedMessageNotifier();
});

/// Provider for message management service
final messageManagementServiceProvider = Provider<MessageManagementService>((ref) {
  return getIt<MessageManagementService>();
});

/// Provider for message statistics
final messageStatisticsProvider = FutureProvider<MessageStatistics>((ref) async {
  final service = ref.watch(messageManagementServiceProvider);
  return await service.getStatistics();
});

/// Provider for user's message history with filters
final messageHistoryProvider = FutureProvider.family<List<MessageModel>, MessageHistoryParams>((ref, params) async {
  final service = ref.watch(messageManagementServiceProvider);
  final result = await service.getMessages(
    recipientFilter: params.recipientFilter,
    toneFilter: params.toneFilter,
    fromDate: params.fromDate,
    toDate: params.toDate,
    favoritesOnly: params.favoritesOnly,
    searchQuery: params.searchQuery,
    limit: params.limit,
  );
  
  if (result.isSuccess) {
    return result.data!;
  } else {
    LoggerService.error('Failed to load message history', result.error);
    return [];
  }
});

/// Provider for favorite messages
final favoriteMessagesProvider = FutureProvider<List<MessageModel>>((ref) async {
  final service = ref.watch(messageManagementServiceProvider);
  final result = await service.getMessages(favoritesOnly: true);
  
  if (result.isSuccess) {
    return result.data!;
  } else {
    LoggerService.error('Failed to load favorite messages', result.error);
    return [];
  }
});

/// Provider for unique recipients
final uniqueRecipientsProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.watch(messageManagementServiceProvider);
  return await service.getUniqueRecipients();
});

/// Provider for unique tones
final uniqueTonesProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.watch(messageManagementServiceProvider);
  return await service.getUniqueTones();
});

/// Enhanced message state
class EnhancedMessageState {
  final bool isLoading;
  final bool isGenerating;
  final MessageModel? currentMessage;
  final List<MessageModel> variations;
  final String? error;
  final bool isOffline;

  const EnhancedMessageState({
    this.isLoading = false,
    this.isGenerating = false,
    this.currentMessage,
    this.variations = const [],
    this.error,
    this.isOffline = false,
  });

  EnhancedMessageState copyWith({
    bool? isLoading,
    bool? isGenerating,
    MessageModel? currentMessage,
    List<MessageModel>? variations,
    String? error,
    bool? isOffline,
    bool clearError = false,
    bool clearMessage = false,
  }) {
    return EnhancedMessageState(
      isLoading: isLoading ?? this.isLoading,
      isGenerating: isGenerating ?? this.isGenerating,
      currentMessage: clearMessage ? null : (currentMessage ?? this.currentMessage),
      variations: variations ?? this.variations,
      error: clearError ? null : (error ?? this.error),
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

/// Enhanced message notifier with comprehensive features
class EnhancedMessageNotifier extends StateNotifier<EnhancedMessageState> {
  EnhancedMessageNotifier() : super(const EnhancedMessageState()) {
    _initializeServices();
  }

  final FirebaseAIService _aiService = FirebaseAIService();
  late final MessageManagementService _managementService;

  Future<void> _initializeServices() async {
    try {
      await _aiService.initialize();
      _managementService = getIt<MessageManagementService>();
      LoggerService.info('📱 Enhanced message provider initialized');
    } catch (e) {
      LoggerService.error('Failed to initialize enhanced message provider', e);
      state = state.copyWith(error: 'Failed to initialize services');
    }
  }

  /// Generate a new message with enhanced error handling
  Future<void> generateMessage({
    required String recipientType,
    required String tone,
    required String context,
    int wordLimit = 100,
    String? userId,
  }) async {
    state = state.copyWith(
      isGenerating: true,
      clearError: true,
      clearMessage: true,
    );

    try {
      LoggerService.info('🤖 Generating message for $recipientType with $tone tone');

      final result = await _aiService.generateMessage(
        recipient: recipientType,
        tone: tone,
        context: context,
        wordLimit: wordLimit,
        userId: userId,
      );

      if (result.isSuccess) {
        final message = result.data!;
        
        // Save to message history
        await _managementService.saveMessage(message);
        
        state = state.copyWith(
          isGenerating: false,
          currentMessage: message,
          isOffline: false,
        );

        LoggerService.info('✅ Message generated successfully');
      } else {
        state = state.copyWith(
          isGenerating: false,
          error: result.error?.toString() ?? 'Unknown error occurred',
        );
        LoggerService.error('Failed to generate message', result.error);
      }
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: 'Unexpected error: ${e.toString()}',
      );
      LoggerService.error('Unexpected error during message generation', e);
    }
  }

  /// Generate multiple variations of a message
  Future<void> generateVariations({
    required String recipientType,
    required String tone,
    required String context,
    int wordLimit = 100,
    int count = 3,
  }) async {
    if (state.currentMessage == null) {
      state = state.copyWith(error: 'No current message to generate variations for');
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _aiService.generateMessageVariations(
        recipientType: recipientType,
        tone: tone,
        context: context,
        wordLimit: wordLimit,
        count: count,
      );

      if (result.isSuccess) {
        final variationTexts = result.data!;
        final variations = <MessageModel>[];

        for (int i = 0; i < variationTexts.length; i++) {
          final variation = MessageModel(
            id: '${state.currentMessage!.id}_var_$i',
            userId: state.currentMessage!.userId,
            recipientType: recipientType,
            tone: tone,
            context: context,
            generatedText: variationTexts[i],
            variations: [],
            wordLimit: wordLimit,
            createdAt: DateTime.now(),
            isSaved: false,
          );
          variations.add(variation);
        }

        state = state.copyWith(
          isLoading: false,
          variations: variations,
        );

        LoggerService.info('✅ Generated ${variations.length} message variations');
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to generate variations: ${result.error}',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Unexpected error generating variations: $e',
      );
    }
  }

  /// Toggle favorite status of a message
  Future<void> toggleFavorite(MessageModel message) async {
    try {
      if (message.isSaved) {
        await _managementService.removeFromFavorites(message.id);
        LoggerService.info('💔 Removed from favorites: ${message.id}');
      } else {
        await _managementService.addToFavorites(message);
        LoggerService.info('⭐ Added to favorites: ${message.id}');
      }

      // Update current message if it matches
      if (state.currentMessage?.id == message.id) {
        state = state.copyWith(
          currentMessage: MessageModel(
            id: message.id,
            userId: message.userId,
            recipientType: message.recipientType,
            tone: message.tone,
            context: message.context,
            generatedText: message.generatedText,
            variations: message.variations,
            wordLimit: message.wordLimit,
            createdAt: message.createdAt,
            isSaved: !message.isSaved,
          ),
        );
      }
    } catch (e) {
      LoggerService.error('Failed to toggle favorite', e);
      state = state.copyWith(error: 'Failed to update favorite status');
    }
  }

  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _managementService.deleteMessage(messageId);
      LoggerService.info('🗑️ Deleted message: $messageId');

      // Clear current message if it was deleted
      if (state.currentMessage?.id == messageId) {
        state = state.copyWith(clearMessage: true);
      }
    } catch (e) {
      LoggerService.error('Failed to delete message', e);
      state = state.copyWith(error: 'Failed to delete message');
    }
  }

  /// Clear current error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Clear current message
  void clearMessage() {
    state = state.copyWith(clearMessage: true, variations: []);
  }

  /// Set offline status
  void setOfflineStatus(bool isOffline) {
    state = state.copyWith(isOffline: isOffline);
  }

  /// Select a message variation as the current message
  void selectMessage(MessageModel message) {
    state = state.copyWith(currentMessage: message);
    LoggerService.info('📝 Selected message variation: ${message.id}');
  }
}

/// Parameters for filtering message history
class MessageHistoryParams {
  final String? recipientFilter;
  final String? toneFilter;
  final DateTime? fromDate;
  final DateTime? toDate;
  final bool favoritesOnly;
  final String? searchQuery;
  final int? limit;

  const MessageHistoryParams({
    this.recipientFilter,
    this.toneFilter,
    this.fromDate,
    this.toDate,
    this.favoritesOnly = false,
    this.searchQuery,
    this.limit,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageHistoryParams &&
        other.recipientFilter == recipientFilter &&
        other.toneFilter == toneFilter &&
        other.fromDate == fromDate &&
        other.toDate == toDate &&
        other.favoritesOnly == favoritesOnly &&
        other.searchQuery == searchQuery &&
        other.limit == limit;
  }

  @override
  int get hashCode {
    return Object.hash(
      recipientFilter,
      toneFilter,
      fromDate,
      toDate,
      favoritesOnly,
      searchQuery,
      limit,
    );
  }
}