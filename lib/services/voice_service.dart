import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/services/logger_service.dart';
import '../core/utils/result.dart';

/// Voice service for speech-to-text and text-to-speech functionality
class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  late SpeechToText _speechToText;
  late FlutterTts _flutterTts;
  
  bool _speechEnabled = false;
  bool _ttsEnabled = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  
  final StreamController<String> _speechResultController = StreamController<String>.broadcast();
  final StreamController<VoiceServiceState> _stateController = StreamController<VoiceServiceState>.broadcast();
  
  Stream<String> get speechResultStream => _speechResultController.stream;
  Stream<VoiceServiceState> get stateStream => _stateController.stream;
  
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get speechEnabled => _speechEnabled;
  bool get ttsEnabled => _ttsEnabled;

  /// Initialize voice services
  Future<Result<void>> initialize() async {
    try {
      LoggerService.info('🎤 Initializing voice services...');
      
      // Check and request permissions
      final permissionResult = await _requestPermissions();
      if (permissionResult.isFailure) {
        return permissionResult;
      }
      
      // Initialize Speech-to-Text
      await _initializeSpeechToText();
      
      // Initialize Text-to-Speech
      await _initializeTextToSpeech();
      
      _updateState();
      LoggerService.info('✅ Voice services initialized successfully');
      return Result.success(null);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to initialize voice services', e, stackTrace);
      return Result.failure(Exception('Voice initialization failed: $e'));
    }
  }

  /// Request necessary permissions
  Future<Result<void>> _requestPermissions() async {
    try {
      final microphoneStatus = await Permission.microphone.request();
      final speechStatus = await Permission.speech.request();
      
      if (microphoneStatus != PermissionStatus.granted) {
        return Result.failure(Exception('Microphone permission is required for voice input'));
      }
      
      if (speechStatus != PermissionStatus.granted) {
        LoggerService.warning('Speech permission not granted, some features may be limited');
      }
      
      return Result.success(null);
    } catch (e) {
      return Result.failure(Exception('Permission request failed: $e'));
    }
  }

  /// Initialize Speech-to-Text
  Future<void> _initializeSpeechToText() async {
    _speechToText = SpeechToText();
    _speechEnabled = await _speechToText.initialize(
      onStatus: _onSpeechStatus,
      onError: _onSpeechError,
      debugLogging: kDebugMode,
    );
    
    LoggerService.info('🎤 Speech-to-Text: ${_speechEnabled ? "Enabled" : "Disabled"}');
  }

  /// Initialize Text-to-Speech
  Future<void> _initializeTextToSpeech() async {
    _flutterTts = FlutterTts();
    
    // Configure TTS
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    // Set up callbacks
    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
      _updateState();
    });
    
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      _updateState();
    });
    
    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
      _updateState();
      LoggerService.error('TTS Error: $msg');
    });
    
    _ttsEnabled = true;
    LoggerService.info('🔊 Text-to-Speech: Enabled');
  }

  /// Start listening for voice input
  Future<Result<void>> startListening({
    String locale = 'en_US',
    Duration timeout = const Duration(seconds: 30),
    Duration pauseFor = const Duration(seconds: 3),
  }) async {
    if (!_speechEnabled) {
      return Result.failure(Exception('Speech recognition not available'));
    }
    
    if (_isListening) {
      return Result.failure(Exception('Already listening'));
    }

    try {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: timeout,
        pauseFor: pauseFor,
        partialResults: true,
        localeId: locale,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );
      
      _isListening = true;
      _updateState();
      LoggerService.info('🎤 Started listening...');
      return Result.success(null);
    } catch (e) {
      LoggerService.error('Failed to start listening', e);
      return Result.failure(Exception('Failed to start voice input: $e'));
    }
  }

  /// Stop listening for voice input
  Future<Result<void>> stopListening() async {
    if (!_isListening) {
      return Result.success(null);
    }

    try {
      await _speechToText.stop();
      _isListening = false;
      _updateState();
      LoggerService.info('🎤 Stopped listening');
      return Result.success(null);
    } catch (e) {
      LoggerService.error('Failed to stop listening', e);
      return Result.failure(Exception('Failed to stop voice input: $e'));
    }
  }

  /// Cancel current listening session
  Future<Result<void>> cancelListening() async {
    try {
      await _speechToText.cancel();
      _isListening = false;
      _updateState();
      LoggerService.info('🎤 Cancelled listening');
      return Result.success(null);
    } catch (e) {
      LoggerService.error('Failed to cancel listening', e);
      return Result.failure(Exception('Failed to cancel voice input: $e'));
    }
  }

  /// Speak text using TTS
  Future<Result<void>> speak(String text, {
    double rate = 0.5,
    double volume = 1.0,
    double pitch = 1.0,
  }) async {
    if (!_ttsEnabled) {
      return Result.failure(Exception('Text-to-speech not available'));
    }

    if (text.isEmpty) {
      return Result.failure(Exception('No text to speak'));
    }

    try {
      // Stop any current speech
      await _flutterTts.stop();
      
      // Set parameters
      await _flutterTts.setSpeechRate(rate);
      await _flutterTts.setVolume(volume);
      await _flutterTts.setPitch(pitch);
      
      // Speak the text
      final result = await _flutterTts.speak(text);
      
      if (result == 1) {
        LoggerService.info('🔊 Speaking: "${text.length > 50 ? "${text.substring(0, 50)}..." : text}"');
        return Result.success(null);
      } else {
        return Result.failure(Exception('Failed to start speech'));
      }
    } catch (e) {
      LoggerService.error('Failed to speak text', e);
      return Result.failure(Exception('Text-to-speech failed: $e'));
    }
  }

  /// Stop current speech
  Future<Result<void>> stopSpeaking() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
      _updateState();
      LoggerService.info('🔊 Stopped speaking');
      return Result.success(null);
    } catch (e) {
      LoggerService.error('Failed to stop speaking', e);
      return Result.failure(Exception('Failed to stop speech: $e'));
    }
  }

  /// Get available languages for TTS
  Future<List<String>> getAvailableLanguages() async {
    try {
      final languages = await _flutterTts.getLanguages;
      return List<String>.from(languages);
    } catch (e) {
      LoggerService.error('Failed to get available languages', e);
      return ['en-US']; // Default fallback
    }
  }

  /// Get available speech recognition locales
  Future<List<LocaleName>> getAvailableLocales() async {
    if (!_speechEnabled) return [];
    
    try {
      return await _speechToText.locales();
    } catch (e) {
      LoggerService.error('Failed to get available locales', e);
      return [];
    }
  }

  /// Set TTS language
  Future<Result<void>> setLanguage(String language) async {
    try {
      await _flutterTts.setLanguage(language);
      LoggerService.info('🌐 TTS language set to: $language');
      return Result.success(null);
    } catch (e) {
      LoggerService.error('Failed to set TTS language', e);
      return Result.failure(Exception('Failed to set language: $e'));
    }
  }

  /// Voice command processing for common actions
  VoiceCommand? parseVoiceCommand(String text) {
    final lowercaseText = text.toLowerCase().trim();
    
    // Generate message commands
    if (lowercaseText.contains('generate') || lowercaseText.contains('create')) {
      if (lowercaseText.contains('message')) {
        return VoiceCommand(
          type: VoiceCommandType.generateMessage,
          parameters: _extractMessageParameters(lowercaseText),
        );
      }
    }
    
    // Navigation commands
    if (lowercaseText.contains('show') || lowercaseText.contains('open')) {
      if (lowercaseText.contains('history')) {
        return VoiceCommand(type: VoiceCommandType.openHistory);
      }
      if (lowercaseText.contains('favorites') || lowercaseText.contains('saved')) {
        return VoiceCommand(type: VoiceCommandType.openFavorites);
      }
      if (lowercaseText.contains('profile')) {
        return VoiceCommand(type: VoiceCommandType.openProfile);
      }
    }
    
    // Action commands
    if (lowercaseText.contains('read') || lowercaseText.contains('speak')) {
      return VoiceCommand(type: VoiceCommandType.readMessage);
    }
    
    if (lowercaseText.contains('save') || lowercaseText.contains('favorite')) {
      return VoiceCommand(type: VoiceCommandType.saveMessage);
    }
    
    if (lowercaseText.contains('share')) {
      return VoiceCommand(type: VoiceCommandType.shareMessage);
    }
    
    return null;
  }

  /// Extract message parameters from voice input
  Map<String, String> _extractMessageParameters(String text) {
    final params = <String, String>{};
    
    // Extract recipient
    final recipients = ['crush', 'girlfriend', 'boyfriend', 'friend', 'family', 'boss', 'colleague'];
    for (final recipient in recipients) {
      if (text.contains(recipient)) {
        params['recipient'] = recipient;
        break;
      }
    }
    
    // Extract tone
    final tones = ['romantic', 'funny', 'professional', 'casual', 'apologetic', 'grateful'];
    for (final tone in tones) {
      if (text.contains(tone)) {
        params['tone'] = tone;
        break;
      }
    }
    
    // Extract context (everything after "about" or "for")
    final aboutIndex = text.indexOf('about');
    final forIndex = text.indexOf('for');
    
    if (aboutIndex != -1) {
      params['context'] = text.substring(aboutIndex + 5).trim();
    } else if (forIndex != -1) {
      params['context'] = text.substring(forIndex + 3).trim();
    }
    
    return params;
  }

  // Callbacks
  void _onSpeechResult(result) {
    final recognizedWords = result.recognizedWords;
    if (recognizedWords.isNotEmpty) {
      _speechResultController.add(recognizedWords);
      LoggerService.debug('🎤 Speech result: $recognizedWords');
    }
  }

  void _onSpeechStatus(String status) {
    LoggerService.debug('🎤 Speech status: $status');
    
    if (status == 'done' || status == 'notListening') {
      _isListening = false;
      _updateState();
    }
  }

  void _onSpeechError(error) {
    LoggerService.warning('🎤 Speech error: ${error.errorMsg}');
    _isListening = false;
    _updateState();
  }

  void _updateState() {
    _stateController.add(VoiceServiceState(
      isListening: _isListening,
      isSpeaking: _isSpeaking,
      speechEnabled: _speechEnabled,
      ttsEnabled: _ttsEnabled,
    ));
  }

  /// Dispose resources
  void dispose() {
    _speechResultController.close();
    _stateController.close();
    _flutterTts.stop();
  }
}

/// Voice service state
class VoiceServiceState {
  final bool isListening;
  final bool isSpeaking;
  final bool speechEnabled;
  final bool ttsEnabled;

  const VoiceServiceState({
    required this.isListening,
    required this.isSpeaking,
    required this.speechEnabled,
    required this.ttsEnabled,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VoiceServiceState &&
        other.isListening == isListening &&
        other.isSpeaking == isSpeaking &&
        other.speechEnabled == speechEnabled &&
        other.ttsEnabled == ttsEnabled;
  }

  @override
  int get hashCode {
    return Object.hash(isListening, isSpeaking, speechEnabled, ttsEnabled);
  }
}

/// Voice command types
enum VoiceCommandType {
  generateMessage,
  openHistory,
  openFavorites,
  openProfile,
  readMessage,
  saveMessage,
  shareMessage,
  unknown,
}

/// Voice command model
class VoiceCommand {
  final VoiceCommandType type;
  final Map<String, String> parameters;

  const VoiceCommand({
    required this.type,
    this.parameters = const {},
  });
}