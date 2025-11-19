import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_ai_service.dart';

// Message generation provider
final messageGenerationProvider =
    StateNotifierProvider<MessageGenerationNotifier, MessageGenerationState>((
      ref,
    ) {
      return MessageGenerationNotifier();
    });

class MessageGenerationState {
  final String? generatedMessage;
  final bool isLoading;
  final String? error;
  final String recipient;
  final String tone;
  final String context;
  final int wordLimit;

  MessageGenerationState({
    this.generatedMessage,
    this.isLoading = false,
    this.error,
    this.recipient = 'crush',
    this.tone = 'romantic',
    this.context = '',
    this.wordLimit = 100,
  });

  MessageGenerationState copyWith({
    String? generatedMessage,
    bool? isLoading,
    String? error,
    String? recipient,
    String? tone,
    String? context,
    int? wordLimit,
  }) {
    return MessageGenerationState(
      generatedMessage: generatedMessage ?? this.generatedMessage,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      recipient: recipient ?? this.recipient,
      tone: tone ?? this.tone,
      context: context ?? this.context,
      wordLimit: wordLimit ?? this.wordLimit,
    );
  }
}

class MessageGenerationNotifier extends StateNotifier<MessageGenerationState> {
  final FirebaseAIService _aiService = FirebaseAIService();

  MessageGenerationNotifier() : super(MessageGenerationState());

  void setRecipient(String recipient) {
    state = state.copyWith(recipient: recipient);
  }

  void setTone(String tone) {
    state = state.copyWith(tone: tone);
  }

  void setContext(String context) {
    state = state.copyWith(context: context);
  }

  void setWordLimit(int limit) {
    state = state.copyWith(wordLimit: limit);
  }

  Future<void> generateMessage() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Check if Firebase AI is configured
      if (!FirebaseAIService.isConfigured()) {
        throw Exception(
          'Firebase AI not configured. ${FirebaseAIService.getConfigurationInstructions()}',
        );
      }

      // Call Firebase AI Service
      final generatedMessage = await _aiService.generateMessage(
        recipient: state.recipient,
        tone: state.tone,
        context: state.context,
        wordLimit: state.wordLimit,
      );

      state = state.copyWith(
        generatedMessage: generatedMessage,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to generate message: $e',
        isLoading: false,
      );
    }
  }

  void clearMessage() {
    state = state.copyWith(generatedMessage: null, error: null);
  }
}
