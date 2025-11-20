import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/premium_theme.dart';
import '../../widgets/connectivity_banner.dart';
import '../../widgets/enhanced_message_widgets.dart';
import '../../widgets/usage_indicator.dart';
import '../../providers/enhanced_message_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_config.dart';
import '../../models/message_model.dart';
import '../../services/voice_service.dart';
import '../../services/analytics_service.dart';
import '../../core/di/service_locator.dart';
import '../subscription/paywall_screen.dart';
import '../../core/services/logger_service.dart';

/// MAIN HOME SCREEN - Consolidated from premium and enhanced versions
class MainHomeScreen extends ConsumerStatefulWidget {
  const MainHomeScreen({super.key});

  @override
  ConsumerState<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends ConsumerState<MainHomeScreen>
    with TickerProviderStateMixin {
  final _contextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedRecipient = AppConfig.recipientCategories.first;
  String _selectedTone = AppConfig.availableTones.first;
  int _wordLimit = 100;

  late AnimationController _animationController;
  late AnimationController _voiceAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _voiceAnimation;

  VoiceService? _voiceService;
  bool _isVoiceInitialized = false;

  // Analytics service
  late AnalyticsService _analytics;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeVoiceService();
    _analytics = getIt<AnalyticsService>();

    // Track screen view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authStateProvider);
      if (authState.user != null) {
        _analytics.trackScreenView(authState.user!.uid, 'home');
      }
    });
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _voiceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _voiceAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _voiceAnimationController,
        curve: Curves.elasticInOut,
      ),
    );

    _animationController.forward();
  }

  void _initializeVoiceService() async {
    try {
      _voiceService = VoiceService();
      final result = await _voiceService!.initialize();
      if (result.isSuccess) {
        setState(() => _isVoiceInitialized = true);

        // Listen to voice results
        _voiceService!.speechResultStream.listen((result) {
          _handleVoiceResult(result);
        });
      }
    } catch (e) {
      LoggerService.warning('Voice service initialization failed', e);
    }
  }

  @override
  void dispose() {
    _contextController.dispose();
    _animationController.dispose();
    _voiceAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messageState = ref.watch(enhancedMessageProvider);

    return ConnectivityBanner(
      child: Scaffold(
        backgroundColor: PremiumTheme.background,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(PremiumTheme.spaceMd),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPremiumHeader(),
                    const SizedBox(height: PremiumTheme.spaceMd),
                    const UsageIndicator(compact: false),
                    const SizedBox(height: PremiumTheme.spaceLg),
                    _buildEnhancedMessageForm(),
                    const SizedBox(height: PremiumTheme.spaceLg),
                    if (messageState.error != null)
                      _buildErrorCard(messageState.error!),
                    if (messageState.currentMessage != null) ...[
                      _buildGeneratedMessage(messageState.currentMessage!),
                      const SizedBox(height: PremiumTheme.spaceMd),
                      if (messageState.variations.isNotEmpty)
                        _buildVariations(messageState.variations),
                    ],
                    const SizedBox(height: 120), // Bottom padding
                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: _buildVoiceActionButton(),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      padding: const EdgeInsets.all(PremiumTheme.spaceLg),
      decoration: BoxDecoration(
        gradient: PremiumTheme.premiumGradient,
        borderRadius: BorderRadius.circular(PremiumTheme.radiusLg),
        boxShadow: [PremiumTheme.shadow2xl],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(PremiumTheme.spaceMd),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: PremiumTheme.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Message Generator',
                      style: PremiumTheme.headlineSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Create personalized messages with AI & Voice',
                      style: PremiumTheme.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isVoiceInitialized)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.mic, color: Colors.white, size: 20),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedMessageForm() {
    return Container(
      padding: const EdgeInsets.all(PremiumTheme.spaceLg),
      decoration: BoxDecoration(
        color: PremiumTheme.surface,
        borderRadius: BorderRadius.circular(PremiumTheme.radiusLg),
        border: Border.all(color: PremiumTheme.border.withValues(alpha: 0.3)),
        boxShadow: [PremiumTheme.shadowLg],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Message Details',
                  style: PremiumTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: PremiumTheme.textPrimary,
                  ),
                ),
              ),
              if (_isVoiceInitialized)
                IconButton(
                  onPressed: _toggleVoiceInput,
                  icon: ScaleTransition(
                    scale: _voiceAnimation,
                    child: Icon(
                      _voiceService?.isListening ?? false
                          ? Icons.mic
                          : Icons.mic_none,
                      color: _voiceService?.isListening ?? false
                          ? PremiumTheme.accent
                          : PremiumTheme.textSecondary,
                    ),
                  ),
                  tooltip: 'Voice Input',
                ),
            ],
          ),
          const SizedBox(height: PremiumTheme.spaceMd),
          _buildRecipientSelector(),
          const SizedBox(height: PremiumTheme.spaceMd),
          _buildToneSelector(),
          const SizedBox(height: PremiumTheme.spaceMd),
          _buildContextField(),
          const SizedBox(height: PremiumTheme.spaceMd),
          _buildWordLimitSlider(),
          const SizedBox(height: PremiumTheme.spaceLg),
          _buildGenerateButton(),
        ],
      ),
    );
  }

  Widget _buildRecipientSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Who is this message for?',
          style: PremiumTheme.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: PremiumTheme.textPrimary,
          ),
        ),
        const SizedBox(height: PremiumTheme.spaceSm),
        Container(
          decoration: BoxDecoration(
            color: PremiumTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
            border: Border.all(color: PremiumTheme.border),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedRecipient,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: PremiumTheme.spaceMd,
                vertical: PremiumTheme.spaceSm,
              ),
            ),
            items: AppConfig.recipientCategories.map((recipient) {
              return DropdownMenuItem(
                value: recipient,
                child: Row(
                  children: [
                    Icon(
                      _getRecipientIcon(recipient),
                      size: 20,
                      color: PremiumTheme.textSecondary,
                    ),
                    const SizedBox(width: PremiumTheme.spaceSm),
                    Text(recipient),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedRecipient = value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildToneSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What tone should the message have?',
          style: PremiumTheme.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: PremiumTheme.textPrimary,
          ),
        ),
        const SizedBox(height: PremiumTheme.spaceSm),
        Wrap(
          spacing: PremiumTheme.spaceSm,
          runSpacing: PremiumTheme.spaceSm,
          children: AppConfig.availableTones.map((tone) {
            final isSelected = _selectedTone == tone;
            return GestureDetector(
              onTap: () => setState(() => _selectedTone = tone),
              child: AnimatedContainer(
                duration: PremiumTheme.animationNormal,
                padding: const EdgeInsets.symmetric(
                  horizontal: PremiumTheme.spaceMd,
                  vertical: PremiumTheme.spaceSm,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected ? _getToneGradient(tone) : null,
                  color: isSelected ? null : PremiumTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(PremiumTheme.radiusFull),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : PremiumTheme.border,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _getToneColor(tone).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  tone,
                  style: PremiumTheme.labelMedium.copyWith(
                    color: isSelected
                        ? Colors.white
                        : PremiumTheme.textSecondary,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildContextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'What\'s the context or occasion?',
                style: PremiumTheme.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: PremiumTheme.textPrimary,
                ),
              ),
            ),
            if (_isVoiceInitialized)
              Text(
                'Tap 🎤 for voice input',
                style: PremiumTheme.bodySmall.copyWith(
                  color: PremiumTheme.textTertiary,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        const SizedBox(height: PremiumTheme.spaceSm),
        TextFormField(
          controller: _contextController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText:
                'e.g., "It\'s their birthday and I want to wish them well" or "Apologizing for being late to dinner"',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
              borderSide: const BorderSide(color: PremiumTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
              borderSide: const BorderSide(
                color: PremiumTheme.primary,
                width: 2,
              ),
            ),
            fillColor: PremiumTheme.surfaceVariant,
            filled: true,
            suffixIcon: _isVoiceInitialized
                ? IconButton(
                    onPressed: _toggleVoiceInput,
                    icon: Icon(
                      _voiceService?.isListening ?? false
                          ? Icons.mic
                          : Icons.mic_none,
                      color: _voiceService?.isListening ?? false
                          ? PremiumTheme.accent
                          : PremiumTheme.textSecondary,
                    ),
                  )
                : null,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please provide some context for the message';
            }
            if (value.trim().length < 10) {
              return 'Please provide more context (at least 10 characters)';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildWordLimitSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Message length: $_wordLimit words',
          style: PremiumTheme.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: PremiumTheme.textPrimary,
          ),
        ),
        const SizedBox(height: PremiumTheme.spaceSm),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackShape: const RoundedRectSliderTrackShape(),
            activeTrackColor: PremiumTheme.primary,
            inactiveTrackColor: PremiumTheme.border,
            thumbColor: PremiumTheme.primary,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayColor: PremiumTheme.primary.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: _wordLimit.toDouble(),
            min: 20,
            max: 200,
            divisions: 18,
            onChanged: (value) {
              setState(() => _wordLimit = value.round());
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Short (20)', style: PremiumTheme.bodySmall),
            Text('Medium (100)', style: PremiumTheme.bodySmall),
            Text('Long (200)', style: PremiumTheme.bodySmall),
          ],
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    final messageState = ref.watch(enhancedMessageProvider);
    final isLoading = messageState.isGenerating;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _generateMessage,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: isLoading
                ? LinearGradient(
                    colors: [Colors.grey.shade400, Colors.grey.shade500],
                  )
                : PremiumTheme.premiumGradient,
            borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
          ),
          child: Container(
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.white),
                      const SizedBox(width: PremiumTheme.spaceSm),
                      Text(
                        'Generate Message',
                        style: PremiumTheme.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceActionButton() {
    if (!_isVoiceInitialized) return const SizedBox.shrink();

    return ScaleTransition(
      scale: _voiceAnimation,
      child: FloatingActionButton(
        onPressed: _toggleVoiceInput,
        backgroundColor: _voiceService?.isListening ?? false
            ? PremiumTheme.accent
            : PremiumTheme.primary,
        child: Icon(
          _voiceService?.isListening ?? false ? Icons.mic : Icons.mic_none,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      margin: const EdgeInsets.only(bottom: PremiumTheme.spaceMd),
      padding: const EdgeInsets.all(PremiumTheme.spaceMd),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600),
          const SizedBox(width: PremiumTheme.spaceSm),
          Expanded(
            child: Text(
              error,
              style: PremiumTheme.bodyMedium.copyWith(
                color: Colors.red.shade800,
              ),
            ),
          ),
          IconButton(
            onPressed: () =>
                ref.read(enhancedMessageProvider.notifier).clearError(),
            icon: Icon(Icons.close, color: Colors.red.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratedMessage(MessageModel message) {
    return Column(
      children: [
        EnhancedMessageCard(
          message: message,
          isExpanded: true,
          onFavoriteToggle: () => ref
              .read(enhancedMessageProvider.notifier)
              .toggleFavorite(message),
          onEdit: () => _editMessage(message),
        ),
        const SizedBox(height: PremiumTheme.spaceMd),
        if (_isVoiceInitialized) _buildVoiceControls(message),
      ],
    );
  }

  Widget _buildVoiceControls(MessageModel message) {
    return Container(
      padding: const EdgeInsets.all(PremiumTheme.spaceMd),
      decoration: BoxDecoration(
        color: PremiumTheme.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
        border: Border.all(color: PremiumTheme.border.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.headphones, color: PremiumTheme.textSecondary),
          const SizedBox(width: PremiumTheme.spaceSm),
          Text(
            'Voice Controls',
            style: PremiumTheme.labelMedium.copyWith(
              color: PremiumTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => _speakMessage(message.generatedText),
            icon: Icon(
              _voiceService?.isSpeaking ?? false
                  ? Icons.stop
                  : Icons.play_arrow,
              color: PremiumTheme.primary,
            ),
            tooltip: _voiceService?.isSpeaking ?? false ? 'Stop' : 'Listen',
          ),
        ],
      ),
    );
  }

  Widget _buildVariations(List<MessageModel> variations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alternative Versions',
          style: PremiumTheme.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: PremiumTheme.spaceMd),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: variations.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: PremiumTheme.spaceSm),
              child: EnhancedMessageCard(
                message: variations[index],
                showActions: false,
                onTap: () => _selectVariation(variations[index]),
              ),
            );
          },
        ),
        const SizedBox(height: PremiumTheme.spaceMd),
        OutlinedButton.icon(
          onPressed: _generateMoreVariations,
          icon: const Icon(Icons.refresh),
          label: const Text('Generate More Variations'),
        ),
      ],
    );
  }

  // Voice-related methods
  void _toggleVoiceInput() async {
    if (_voiceService?.isListening ?? false) {
      await _voiceService?.stopListening();
      _voiceAnimationController.stop();
    } else {
      final result = await _voiceService?.startListening();
      if (result?.isSuccess ?? false) {
        _voiceAnimationController.repeat(reverse: true);
      }
    }
  }

  void _handleVoiceResult(String result) {
    setState(() {
      _contextController.text = result;
    });
    _voiceAnimationController.stop();

    // Parse voice commands
    final command = _voiceService?.parseVoiceCommand(result);
    if (command != null) {
      _handleVoiceCommand(command);
    }
  }

  void _handleVoiceCommand(VoiceCommand command) {
    switch (command.type) {
      case VoiceCommandType.generateMessage:
        if (command.parameters.containsKey('recipient')) {
          final recipient = command.parameters['recipient']!;
          if (AppConfig.recipientCategories.contains(recipient)) {
            setState(() => _selectedRecipient = recipient);
          }
        }
        if (command.parameters.containsKey('tone')) {
          final tone = command.parameters['tone']!;
          if (AppConfig.availableTones.contains(tone)) {
            setState(() => _selectedTone = tone);
          }
        }
        if (command.parameters.containsKey('context')) {
          _contextController.text = command.parameters['context']!;
        }
        _generateMessage();
        break;
      case VoiceCommandType.readMessage:
        final currentMessage = ref.read(enhancedMessageProvider).currentMessage;
        if (currentMessage != null) {
          _speakMessage(currentMessage.generatedText);
        }
        break;
      default:
        break;
    }
  }

  void _speakMessage(String text) async {
    if (_voiceService?.isSpeaking ?? false) {
      await _voiceService?.stopSpeaking();
    } else {
      await _voiceService?.speak(text);
    }
  }

  // Action methods
  void _generateMessage() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authStateProvider);
    final userId = authState.user?.uid;
    if (userId == null) return;

    // Check if user can generate message
    final canGenerate = await ref
        .read(subscriptionProvider.notifier)
        .canGenerateMessage(userId);

    if (!canGenerate) {
      // Track limit reached
      await _analytics.trackLimitReached(
        userId,
        tier: ref.read(subscriptionProvider).currentTier.name,
        messagesUsed: ref.read(subscriptionProvider).messagesUsed,
      );

      // Show paywall
      if (!mounted) return;
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PaywallScreen(),
          fullscreenDialog: true,
        ),
      );

      if (result != true) return;
    }

    // Increment usage
    await ref.read(subscriptionProvider.notifier).incrementMessageUsage(userId);

    // Track message generation
    await _analytics.trackMessageGenerated(
      userId,
      recipientType: _selectedRecipient,
      tone: _selectedTone,
      wordCount: _wordLimit,
      usedVoice: false,
    );

    // Generate message
    await ref
        .read(enhancedMessageProvider.notifier)
        .generateMessage(
          recipientType: _selectedRecipient,
          tone: _selectedTone,
          context: _contextController.text.trim(),
          wordLimit: _wordLimit,
        );
  }

  void _generateMoreVariations() async {
    await ref
        .read(enhancedMessageProvider.notifier)
        .generateVariations(
          recipientType: _selectedRecipient,
          tone: _selectedTone,
          context: _contextController.text.trim(),
          wordLimit: _wordLimit,
        );
  }

  void _selectVariation(MessageModel variation) {
    // Use proper state update method instead of direct state assignment
    ref.read(enhancedMessageProvider.notifier).selectMessage(variation);
  }

  void _editMessage(MessageModel message) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message editing coming soon!')),
    );
  }

  // Helper methods
  IconData _getRecipientIcon(String recipient) {
    switch (recipient.toLowerCase()) {
      case 'crush':
        return Icons.favorite_outline;
      case 'girlfriend/boyfriend':
        return Icons.favorite;
      case 'best friend':
        return Icons.person;
      case 'family':
        return Icons.family_restroom;
      case 'boss':
        return Icons.business;
      case 'colleague':
        return Icons.work;
      case 'parent':
        return Icons.family_restroom;
      case 'sibling':
        return Icons.people;
      default:
        return Icons.person_outline;
    }
  }

  LinearGradient _getToneGradient(String tone) {
    switch (tone.toLowerCase()) {
      case 'romantic':
        return PremiumTheme.secondaryGradient;
      case 'funny':
        return PremiumTheme.accentGradient;
      case 'professional':
        return PremiumTheme.oceanGradient;
      case 'apologetic':
        return LinearGradient(
          colors: [Colors.orange.shade400, Colors.red.shade400],
        );
      case 'grateful':
        return PremiumTheme.goldGradient;
      default:
        return PremiumTheme.primaryGradient;
    }
  }

  Color _getToneColor(String tone) {
    switch (tone.toLowerCase()) {
      case 'romantic':
        return PremiumTheme.secondary;
      case 'funny':
        return PremiumTheme.accent;
      case 'professional':
        return Colors.blue.shade600;
      case 'apologetic':
        return Colors.orange.shade500;
      case 'grateful':
        return PremiumTheme.gold;
      default:
        return PremiumTheme.primary;
    }
  }
}
