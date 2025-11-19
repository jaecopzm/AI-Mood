import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../core/utils/result.dart';

class FirebaseAIService {
  GenerativeModel? _model;
  bool _isInitialized = false;

  /// Initialize Firebase AI service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize FirebaseApp if not already done
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    // Initialize the Firebase AI service
    // Create a GenerativeModel instance with Gemini model
    _model = FirebaseAI.googleAI().generativeModel(model: 'gemini-1.5-flash');
    _isInitialized = true;
  }

  /// Generate a personalized message using Firebase AI (Gemini)
  Future<String> generateMessage({
    required String recipient,
    required String tone,
    required String context,
    required int wordLimit,
  }) async {
    if (!_isInitialized || _model == null) {
      await initialize();
    }

    try {
      // Build the prompt based on user input
      final prompt = _buildPrompt(
        recipient: recipient,
        tone: tone,
        context: context,
        wordLimit: wordLimit,
      );

      // Generate content using Firebase AI
      final response = await _model!.generateContent([Content.text(prompt)]);

      if (response.text != null && response.text!.isNotEmpty) {
        return response.text!;
      } else {
        throw Exception('No response generated from Firebase AI');
      }
    } catch (e) {
      throw Exception('Firebase AI Error: $e');
    }
  }

  /// Generate multiple message variations
  Future<Result<List<String>>> generateMessageVariations({
    required String recipientType,
    required String tone,
    required String context,
    required int wordLimit,
    String? additionalContext,
    int count = 3,
  }) async {
    if (!_isInitialized || _model == null) {
      await initialize();
    }

    try {
      final variations = <String>[];

      for (int i = 0; i < count; i++) {
        final prompt = _buildVariationPrompt(
          recipient: recipientType,
          tone: tone,
          context: context,
          wordLimit: wordLimit,
          variationNumber: i + 1,
        );

        final response = await _model!.generateContent([Content.text(prompt)]);

        if (response.text != null && response.text!.isNotEmpty) {
          variations.add(response.text!);
        }
      }

      if (variations.isEmpty) {
        return Result.failure(
          Exception('No variations generated from Firebase AI'),
        );
      }

      return Result.success(variations);
    } catch (e) {
      return Result.failure(
        Exception('Firebase AI Error generating variations: $e'),
      );
    }
  }

  /// Build a detailed prompt for the AI
  String _buildPrompt({
    required String recipient,
    required String tone,
    required String context,
    required int wordLimit,
  }) {
    return '''
Write a $tone message to my $recipient.

Context: $context

Requirements:
- Keep the message to approximately $wordLimit words
- Be genuine and heartfelt
- Match the requested tone ($tone)
- Make it personal and meaningful
- Do not include excessive formatting or emojis
- Write only the message content, no additional text or explanations

Generate the message:
''';
  }

  /// Build a prompt for generating variations
  String _buildVariationPrompt({
    required String recipient,
    required String tone,
    required String context,
    required int wordLimit,
    required int variationNumber,
  }) {
    return '''
Write a $tone message to my $recipient (Variation #$variationNumber).

Context: $context

Requirements:
- Keep the message to approximately $wordLimit words
- Be genuine and heartfelt
- Match the requested tone ($tone)
- Make it personal and meaningful
- Do not include excessive formatting or emojis
- Create a unique variation that's different from previous attempts
- Write only the message content, no additional text or explanations

Generate the message variation:
''';
  }

  /// Check if Firebase AI is properly configured
  static bool isConfigured() {
    return Firebase.apps.isNotEmpty;
  }

  /// Get configuration instructions
  static String getConfigurationInstructions() {
    return '''
To use Firebase AI for message generation:

1. Ensure Firebase is properly configured in your project
2. Make sure firebase_ai package is added to pubspec.yaml
3. Firebase AI (Gemini) should be enabled in your Firebase console
4. The service will automatically initialize when first used

No additional API keys are required - Firebase AI uses your Firebase project configuration.
''';
  }
}
