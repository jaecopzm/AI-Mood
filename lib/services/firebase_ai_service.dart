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

    try {
      print('🔧 Initializing Firebase AI service...');
      
      // Initialize FirebaseApp if not already done
      if (Firebase.apps.isEmpty) {
        print('🔥 Initializing Firebase app...');
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        print('✅ Firebase app initialized');
      }

      // Initialize the Firebase AI service
      // Create a GenerativeModel instance with Gemini model
      print('🤖 Creating Gemini model instance...');
      _model = FirebaseAI.googleAI().generativeModel(model: 'gemini-1.5-flash');
      _isInitialized = true;
      
      print('✅ Firebase AI service initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize Firebase AI: $e');
      // Still mark as initialized so we can use fallbacks
      _isInitialized = true;
    }
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
    final contextualPrompts = _getContextualPrompt(recipient, tone);
    
    return '''
You are an expert message writer who crafts deeply personal, emotionally resonant messages. 

TASK: Write a ${tone.toLowerCase()} message to my ${recipient.toLowerCase()}.

CONTEXT: $context

RECIPIENT RELATIONSHIP: ${contextualPrompts['relationship']}
TONE GUIDANCE: ${contextualPrompts['toneGuide']}
EMOTIONAL APPROACH: ${contextualPrompts['emotional']}

WRITING STYLE REQUIREMENTS:
- Use natural, conversational language that feels authentic
- Include specific, relatable details that make it personal
- Vary sentence length for natural rhythm
- Use emotional intelligence to connect deeply
- Incorporate subtle humor or warmth where appropriate
- Make it feel like it comes from the heart, not a template

TECHNICAL REQUIREMENTS:
- Approximately $wordLimit words
- No generic phrases like "I hope this finds you well"
- No excessive emojis or formatting
- Write ONLY the message content, no explanations

ENHANCE WITH:
- Personal touches that show genuine care
- Specific language that matches the relationship dynamic
- Emotional depth appropriate for the tone and recipient

Generate the message:
''';
  }
  
  /// Get contextual prompts based on relationship and tone
  Map<String, String> _getContextualPrompt(String recipient, String tone) {
    final prompts = {
      'Crush': {
        'Romantic': {
          'relationship': 'Someone you\'re romantically interested in but not yet in a relationship with',
          'toneGuide': 'Flirty but respectful, confident but not overwhelming, sweet with a hint of playfulness',
          'emotional': 'Butterflies, excitement, nervous energy, hopeful attraction'
        },
        'Friendly': {
          'relationship': 'Someone you like but keeping it casual and light',
          'toneGuide': 'Warm, approachable, with subtle hints of interest without being too forward',
          'emotional': 'Genuine interest, friendly warmth, subtle charm'
        }
      },
      'Best Friend': {
        'Friendly': {
          'relationship': 'Your closest friend who knows you inside out',
          'toneGuide': 'Completely natural, inside jokes welcome, zero pretense, pure authenticity',
          'emotional': 'Deep connection, comfort, shared history, mutual understanding'
        },
        'Apologetic': {
          'relationship': 'Your best friend after you\'ve messed up',
          'toneGuide': 'Genuinely sorry, vulnerable, taking full responsibility, hoping to rebuild trust',
          'emotional': 'Remorse, love for the friendship, determination to make things right'
        }
      },
      'Family': {
        'Grateful': {
          'relationship': 'Family member who has been there for you',
          'toneGuide': 'Deeply appreciative, acknowledging specific sacrifices, honoring the bond',
          'emotional': 'Overwhelming gratitude, family love, recognition of their impact'
        },
        'Loving': {
          'relationship': 'Beloved family member',
          'toneGuide': 'Pure love, family warmth, celebrating the unique bond you share',
          'emotional': 'Unconditional love, family pride, deep affection'
        }
      },
      'Colleague': {
        'Professional': {
          'relationship': 'Work colleague or business contact',
          'toneGuide': 'Professional but personable, respectful, competent, collaborative',
          'emotional': 'Mutual respect, professional appreciation, team spirit'
        },
        'Grateful': {
          'relationship': 'Colleague who helped you professionally',
          'toneGuide': 'Professionally grateful, acknowledging their contribution, building rapport',
          'emotional': 'Professional appreciation, respect for their expertise, team collaboration'
        }
      }
    };

    final recipientPrompts = prompts[recipient] ?? {};
    final tonePrompt = recipientPrompts[tone] ?? {
      'relationship': 'Someone important to you',
      'toneGuide': 'Authentic and appropriate for the situation',
      'emotional': 'Genuine care and consideration'
    };

    return tonePrompt;
  }

  /// Build a prompt for generating variations
  String _buildVariationPrompt({
    required String recipient,
    required String tone,
    required String context,
    required int wordLimit,
    required int variationNumber,
  }) {
    final variations = [
      'Take a completely different approach - if the first was direct, be more subtle. If it was long, be concise.',
      'Focus on a different emotional angle - maybe more vulnerability, humor, or strength depending on the context.',
      'Change the opening and structure - start with a question, memory, or observation instead of a statement.'
    ];
    
    final variationGuidance = variations[(variationNumber - 1) % variations.length];
    final contextualPrompts = _getContextualPrompt(recipient, tone);
    
    return '''
You are creating VARIATION #$variationNumber of a message. This must be completely unique from previous versions.

VARIATION STRATEGY: $variationGuidance

TASK: Write a ${tone.toLowerCase()} message to my ${recipient.toLowerCase()}.
CONTEXT: $context
RECIPIENT RELATIONSHIP: ${contextualPrompts['relationship']}

VARIATION REQUIREMENTS:
- Completely different opening line and structure
- Different emotional emphasis while maintaining the same tone
- Unique word choices and phrasing 
- Approximately $wordLimit words
- Same depth of personalization but expressed differently

ENSURE THIS VARIATION:
- Has a distinctly different "voice" and approach
- Offers the recipient a genuine choice between styles
- Maintains authenticity while exploring different angles
- Feels fresh and not repetitive

Generate the unique message variation:
''';
  }

  /// Check if Firebase AI is properly configured
  static bool isConfigured() {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (e) {
      print('⚠️ Firebase configuration check failed: $e');
      return false;
    }
  }

  /// Generate a fallback message when AI fails
  String _getFallbackMessage(String recipient, String tone, String context) {
    final enhancedFallbacks = _getEnhancedFallbacks();
    final recipientKey = recipient.toLowerCase();
    final toneKey = tone.toLowerCase();
    
    // Try specific recipient + tone combination first
    final specificMessage = enhancedFallbacks[recipientKey]?[toneKey];
    if (specificMessage != null) {
      return specificMessage.replaceAll('{context}', context);
    }
    
    // Fall back to generic tone-based messages
    final genericMessages = {
      'romantic': 'I\'ve been thinking about you and wanted to share something from my heart. $context You bring such light into my world, and I felt compelled to tell you that.',
      'friendly': 'Hey you! I was just thinking about our friendship and wanted to reach out. $context You always know how to make things better, and I\'m grateful for that.',
      'professional': 'I wanted to follow up with you regarding something important. $context Your expertise and collaboration have been invaluable.',
      'apologetic': 'I\'ve been reflecting on what happened, and I realize I need to apologize. $context Your feelings matter to me, and I want to make this right.',
      'grateful': 'I\'ve been counting my blessings lately, and you\'re definitely one of them. $context Thank you for being such an important part of my life.',
      'casual': 'Hope you\'re having a great day! I wanted to drop you a quick message about something. $context Looking forward to hearing from you!',
      'loving': 'Just wanted to take a moment to tell you how much I love and appreciate you. $context You mean the world to me.',
    };

    final message = genericMessages[toneKey] ?? 
        'Hi! I wanted to reach out to you about $context Hope this message finds you well!';
    
    print('🔄 Using enhanced fallback message for $recipient with $tone tone');
    return message;
  }
  
  /// Get enhanced fallback messages by recipient and tone
  Map<String, Map<String, String>> _getEnhancedFallbacks() {
    return {
      'crush': {
        'romantic': 'I\'ve been thinking about you more than I probably should admit. {context} There\'s something about you that just lights up my day, and I couldn\'t help but reach out.',
        'friendly': 'Hey! You\'ve been on my mind lately (in the best way). {context} I love our conversations and just wanted to see how you\'re doing.',
        'casual': 'So I was just thinking about you and figured I\'d say hi! {context} Hope you\'re having an amazing day.',
      },
      'best friend': {
        'friendly': 'Okay so random thought, but I just had to text you because {context} You know how my brain works - everything reminds me of our friendship!',
        'apologetic': 'Listen, I messed up and I know it. {context} You mean way too much to me to let this sit unresolved. Can we talk?',
        'grateful': 'I don\'t tell you enough how much your friendship means to me. {context} Seriously, I hit the jackpot in the best friend department.',
      },
      'family': {
        'loving': 'Just wanted you to know how much I love you. {context} Family isn\'t just about blood - it\'s about the people who choose to love you unconditionally.',
        'grateful': 'I\'ve been reflecting on how blessed I am to have you in my life. {context} Thank you for being the incredible person you are.',
        'apologetic': 'Family means everything to me, which is why I need to make this right. {context} I love you and I\'m sorry.',
      },
      'colleague': {
        'professional': 'I wanted to reach out regarding our recent collaboration. {context} Your insights and expertise continue to impress me.',
        'grateful': 'I wanted to take a moment to acknowledge your contributions. {context} Working with someone of your caliber makes all the difference.',
        'friendly': 'Hope you\'re having a great week! I was thinking about our project and {context} Always enjoy our professional partnership.',
      },
    };
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

Important: Make sure to enable Firebase AI (Gemini) in your Firebase console:
1. Go to https://console.firebase.google.com/
2. Select your project: ai-mood-2d7d0
3. Navigate to "Build" > "Firebase AI" (if available)
4. Enable the Gemini API for your project
5. Ensure your API quota and billing are properly configured

Current status: Firebase apps configured = ${Firebase.apps.isNotEmpty}
''';
  }
}
