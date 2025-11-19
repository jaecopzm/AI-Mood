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

      print('🤖 Firebase AI: Generating content with prompt length: ${prompt.length}');
      
      // Generate content using Firebase AI
      final response = await _model!.generateContent([Content.text(prompt)]);
      
      print('📝 Firebase AI: Response received');
      
      if (response.text != null && response.text!.isNotEmpty) {
        print('✅ Firebase AI: Generated text with length: ${response.text!.length}');
        return response.text!;
      } else {
        throw Exception('No response text in Firebase AI response');
      }
    } catch (e) {
      print('❌ Firebase AI Error: $e');
      
      // Return a fallback message instead of throwing
      return _getFallbackMessage(recipient, tone, context);
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
        } else {
          // Add fallback variation if Firebase AI fails
          variations.add(_getFallbackMessage(recipientType, tone, context));
        }
      }

      if (variations.isEmpty) {
        return Result.failure(
          Exception('No variations generated from Firebase AI'),
        );
      }

      return Result.success(variations);
    } catch (e) {
      print('❌ Firebase AI Variations Error: $e');
      
      // Return fallback variations instead of failure
      final fallbackVariations = List.generate(count, (index) {
        return _getFallbackMessage(recipientType, tone, '$context (Variation ${index + 1})');
      });
      
      return Result.success(fallbackVariations);
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

  /// Generate a fallback message when AI fails
  String _getFallbackMessage(String recipient, String tone, String context) {
    final fallbackMessages = {
      'romantic': 'I wanted to reach out and let you know how much you mean to me. $context Your presence in my life brings joy and warmth that I treasure every day.',
      'friendly': 'Hey! I was thinking about you and wanted to check in. $context Hope you\'re doing well and that we can catch up soon!',
      'professional': 'I hope this message finds you well. $context I wanted to touch base and maintain our professional connection.',
      'casual': 'Hi there! $context Just wanted to drop you a quick message and see how things are going.',
    };

    final message = fallbackMessages[tone.toLowerCase()] ?? 
        'Hi! I wanted to reach out about $context Hope you\'re doing well!';
    
    print('🔄 Using fallback message for tone: $tone');
    return message;
  }

  /// Get configuration instructions
  static String getConfigurationInstructions() {
    return '''
To use Firebase AI for message generation:

1. Ensure Firebase is properly configured in your project
2. Make sure firebase_ai package is added to pubspec.yaml
3. Firebase AI (Gemini) should be enabled in your Firebase console
4. The service will automatically initialize when first used

Note: If Firebase AI is not available, the app will use fallback messages.
''';
  }
}
