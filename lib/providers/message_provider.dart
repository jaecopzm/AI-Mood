import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import '../services/cloudflare_ai_service.dart';
import '../services/firebase_service.dart';

// Message provider for handling message generation and history
final messageProvider = StateNotifierProvider<MessageNotifier, MessageState>((
  ref,
) {
  return MessageNotifier();
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
  final FirebaseService _firebaseService = FirebaseService();

  MessageNotifier() : super(MessageState());

  Future<void> generateMessages({
    required String recipientType,
    required String tone,
    required String context,
    required int wordLimit,
    String? additionalContext,
    required String userId,
  }) async {
    state = state.copyWith(isGenerating: true, error: null);

    try {
      final variations = await CloudflareAIService.generateMessageVariations(
        recipientType: recipientType,
        tone: tone,
        context: context,
        wordLimit: wordLimit,
        additionalContext: additionalContext,
        count: 3,
      );

      // Save to Firestore
      final message = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        recipientType: recipientType,
        tone: tone,
        context: context,
        generatedText: variations[0],
        variations: variations,
        wordLimit: wordLimit,
        createdAt: DateTime.now(),
        isSaved: false,
      );

      await _firebaseService.saveMessage(message);

      state = state.copyWith(
        currentVariations: variations,
        isGenerating: false,
        selectedVariationIndex: 0,
        history: [message, ...state.history],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isGenerating: false);
    }
  }

  void selectVariation(int index) {
    if (index >= 0 && index < state.currentVariations.length) {
      state = state.copyWith(selectedVariationIndex: index);
    }
  }

  Future<void> loadHistory(String userId) async {
    try {
      final messages = await _firebaseService.getUserMessages(userId);
      state = state.copyWith(history: messages);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleSaveMessage(String messageId, bool isSaved) async {
    try {
      await _firebaseService.updateMessage(messageId, {'isSaved': isSaved});

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

      state = state.copyWith(history: updatedHistory);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _firebaseService.deleteMessage(messageId);

      final updatedHistory = state.history
          .where((msg) => msg.id != messageId)
          .toList();
      state = state.copyWith(history: updatedHistory);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearCurrentVariations() {
    state = state.copyWith(currentVariations: [], selectedVariationIndex: 0);
  }
}
