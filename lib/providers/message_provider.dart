import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import '../services/firebase_ai_service.dart';
import '../services/firebase_service.dart';
import '../core/di/service_locator.dart';
import '../core/services/error_handler.dart';
import '../core/services/logger_service.dart';
import '../core/validators/input_validators.dart';

// Service providers (using DI)
final firebaseAIServiceProvider = Provider<FirebaseAIService>((ref) {
  return getIt<FirebaseAIService>();
});

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return getIt<FirebaseService>();
});

// Message provider for handling message generation and history
final messageProvider = StateNotifierProvider<MessageNotifier, MessageState>((ref) {
  return MessageNotifier(
    ref.read(firebaseAIServiceProvider),
    ref.read(firebaseServiceProvider),
  );
});

class MessageState {
  final List<String> currentVariations;
  final List<MessageModel> history;
  final bool isGenerating;
  final String? error;
  final int selectedVariationIndex;

  MessageState({
    this.currentVariations = const [],
    this.history = const [],
    this.isGenerating = false,
    this.error,
    this.selectedVariationIndex = 0,
  });

  MessageState copyWith({
    List<String>? currentVariations,
    List<MessageModel>? history,
    bool? isGenerating,
    String? error,
    int? selectedVariationIndex,
  }) {
    return MessageState(
      currentVariations: currentVariations ?? this.currentVariations,
      history: history ?? this.history,
      isGenerating: isGenerating ?? this.isGenerating,
      error: error,
      selectedVariationIndex:
          selectedVariationIndex ?? this.selectedVariationIndex,
    );
  }
}

class MessageNotifier extends StateNotifier<MessageState> {
  final FirebaseAIService _firebaseAIService;
  final FirebaseService _firebaseService;

  MessageNotifier(this._firebaseAIService, this._firebaseService)
      : super(MessageState());

  Future<void> generateMessages({
    required String recipientType,
    required String tone,
    required String context,
    required int wordLimit,
    String? additionalContext,
    required String userId,
  }) async {
    // Validate inputs
    if (recipientType.isEmpty) {
      state = state.copyWith(
        error: 'Please select a recipient type',
        isGenerating: false,
      );
      return;
    }

    if (tone.isEmpty) {
      state = state.copyWith(
        error: 'Please select a tone',
        isGenerating: false,
      );
    }

    final contextError = InputValidators.validateMessageContext(context);
    if (contextError != null) {
      state = state.copyWith(error: contextError, isGenerating: false);
      return;
    }

    if (wordLimit < 10 || wordLimit > 500) {
      state = state.copyWith(
        error: 'Word limit must be between 10 and 500',
        isGenerating: false,
      );
      return;
    }

    state = state.copyWith(isGenerating: true, error: null);

    try {
      LoggerService.info('Message: Starting generation for $recipientType');

      // Generate message variations
      final variationsResult = await _firebaseAIService.generateMessageVariations(
        recipientType: recipientType,
        tone: tone,
        context: context.trim(),
        wordLimit: wordLimit,
        additionalContext: additionalContext?.trim(),
        count: 3,
      );

      await variationsResult.when(
        success: (variations) async {
          LoggerService.info('Message: Generated ${variations.length} variations');

          // Create message model
          final message = MessageModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: userId,
            recipientType: recipientType,
            tone: tone,
            context: context.trim(),
            generatedText: variations[0],
            variations: variations,
            wordLimit: wordLimit,
            createdAt: DateTime.now(),
            isSaved: false,
          );

          // Save to Firestore
          final saveResult = await _firebaseService.saveMessage(message);

          saveResult.when(
            success: (_) {
              state = state.copyWith(
                currentVariations: variations,
                isGenerating: false,
                selectedVariationIndex: 0,
                history: [message, ...state.history],
                error: null,
              );
              LoggerService.info('Message: Saved successfully');
            },
            failure: (error) {
              // Still show variations even if save failed
              state = state.copyWith(
                currentVariations: variations,
                isGenerating: false,
                selectedVariationIndex: 0,
                error: 'Message generated but could not be saved',
              );
              LoggerService.warning('Message: Generation succeeded but save failed', error);
            },
          );
        },
        failure: (error) {
          final message = ErrorHandler.getUserFriendlyMessage(error);
          state = state.copyWith(error: message, isGenerating: false);
          LoggerService.error('Message: Generation failed', error);
        },
      );
    } catch (e, stackTrace) {
      final message = ErrorHandler.getUserFriendlyMessage(e);
      state = state.copyWith(error: message, isGenerating: false);
      LoggerService.error('Message: Unexpected error during generation', e, stackTrace);
    }
  }

  void selectVariation(int index) {
    if (index >= 0 && index < state.currentVariations.length) {
      state = state.copyWith(selectedVariationIndex: index);
    }
  }

  Future<void> loadHistory(String userId) async {
    try {
      LoggerService.info('Message: Loading history for user $userId');

      final result = await _firebaseService.getUserMessages(userId);

      result.when(
        success: (messages) {
          state = state.copyWith(history: messages, error: null);
          LoggerService.info('Message: Loaded ${messages.length} messages');
        },
        failure: (error) {
          final message = ErrorHandler.getUserFriendlyMessage(error);
          state = state.copyWith(error: message);
          LoggerService.error('Message: Failed to load history', error);
        },
      );
    } catch (e, stackTrace) {
      final message = ErrorHandler.getUserFriendlyMessage(e);
      state = state.copyWith(error: message);
      LoggerService.error('Message: Unexpected error loading history', e, stackTrace);
    }
  }

  Future<void> toggleSaveMessage(String messageId, bool isSaved) async {
    try {
      LoggerService.info('Message: Toggling save status for $messageId');

      final result = await _firebaseService.updateMessage(
        messageId,
        {'isSaved': isSaved},
      );

      result.when(
        success: (_) {
          final updatedHistory = state.history.map((msg) {
            if (msg.id == messageId) {
              return MessageModel(
                id: msg.id,
                userId: msg.userId,
                recipientType: msg.recipientType,
                tone: msg.tone,
                context: msg.context,
                generatedText: msg.generatedText,
                variations: msg.variations,
                wordLimit: msg.wordLimit,
                createdAt: msg.createdAt,
                isSaved: isSaved,
              );
            }
            return msg;
          }).toList();

          state = state.copyWith(history: updatedHistory, error: null);
          LoggerService.info('Message: Save status updated');
        },
        failure: (error) {
          final message = ErrorHandler.getUserFriendlyMessage(error);
          state = state.copyWith(error: message);
          LoggerService.error('Message: Failed to update save status', error);
        },
      );
    } catch (e, stackTrace) {
      final message = ErrorHandler.getUserFriendlyMessage(e);
      state = state.copyWith(error: message);
      LoggerService.error('Message: Unexpected error updating save status', e, stackTrace);
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      LoggerService.info('Message: Deleting message $messageId');

      final result = await _firebaseService.deleteMessage(messageId);

      result.when(
        success: (_) {
          final updatedHistory = state.history
              .where((msg) => msg.id != messageId)
              .toList();
          state = state.copyWith(history: updatedHistory, error: null);
          LoggerService.info('Message: Deleted successfully');
        },
        failure: (error) {
          final message = ErrorHandler.getUserFriendlyMessage(error);
          state = state.copyWith(error: message);
          LoggerService.error('Message: Failed to delete', error);
        },
      );
    } catch (e, stackTrace) {
      final message = ErrorHandler.getUserFriendlyMessage(e);
      state = state.copyWith(error: message);
      LoggerService.error('Message: Unexpected error deleting message', e, stackTrace);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearCurrentVariations() {
    state = state.copyWith(currentVariations: [], selectedVariationIndex: 0);
  }
}
