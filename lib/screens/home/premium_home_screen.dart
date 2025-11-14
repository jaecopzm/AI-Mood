import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/premium_theme.dart';
import '../../widgets/premium_widgets.dart';
import '../../config/app_config.dart';
import '../../providers/message_provider.dart';
import '../../providers/auth_provider.dart';

class PremiumHomeScreen extends ConsumerStatefulWidget {
  const PremiumHomeScreen({super.key});

  @override
  ConsumerState<PremiumHomeScreen> createState() => _PremiumHomeScreenState();
}

class _PremiumHomeScreenState extends ConsumerState<PremiumHomeScreen>
    with SingleTickerProviderStateMixin {
  // Controllers
  final TextEditingController _contextController = TextEditingController();
  final TextEditingController _additionalContextController =
      TextEditingController();

  // State
  String? _selectedRecipient;
  String? _selectedTone;
  int _selectedWordLimit = 50;
  bool _isGenerating = false;
  List<String> _generatedMessages = [];
  int _selectedMessageIndex = 0;
  bool _showAdvancedOptions = false;

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: PremiumTheme.animationNormal,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _contextController.dispose();
    _additionalContextController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _generateMessage() async {
    if (_selectedRecipient == null || _selectedTone == null) {
      _showSnackBar('Please select recipient and tone', isError: true);
      return;
    }

    if (_contextController.text.trim().isEmpty) {
      _showSnackBar('Please enter message context', isError: true);
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final authState = ref.read(authStateProvider);
      final userId = authState.user?.uid ?? 'guest';

      await ref.read(messageProvider.notifier).generateMessages(
        recipientType: _selectedRecipient!,
        tone: _selectedTone!,
        context: _contextController.text,
        wordLimit: _selectedWordLimit,
        additionalContext: _additionalContextController.text.isEmpty
            ? null
            : _additionalContextController.text,
        userId: userId,
      );

      final messageState = ref.read(messageProvider);
      
      if (messageState.error != null) {
        _showSnackBar('Failed: ${messageState.error}', isError: true);
      } else {
        setState(() {
          _generatedMessages = messageState.currentVariations;
          _selectedMessageIndex = 0;
        });
        _animationController.forward(from: 0);
        _showSnackBar('Messages generated successfully! 🎉', isError: false);
      }
    } catch (e) {
      _showSnackBar('Failed to generate message: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? PremiumTheme.error : PremiumTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              PremiumTheme.background,
              PremiumTheme.primaryLight.withValues(alpha: 0.05),
              PremiumTheme.secondaryLight.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverToBoxAdapter(child: _buildAppBar()),

              // Stats Section
              SliverToBoxAdapter(child: _buildStatsSection()),

              // Quick Actions
              SliverToBoxAdapter(child: _buildQuickActions()),

              // Main Content
              SliverToBoxAdapter(child: _buildMainContent()),

              // Generated Messages
              if (_generatedMessages.isNotEmpty)
                SliverToBoxAdapter(child: _buildGeneratedMessages()),

              // Bottom Spacing
              const SliverToBoxAdapter(
                child: SizedBox(height: PremiumTheme.space3xl),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(PremiumTheme.spaceLg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) =>
                      PremiumTheme.primaryGradient.createShader(bounds),
                  child: const Text(
                    'AI Mood',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: PremiumTheme.spaceXs),
                Text(
                  'Craft the perfect message ✨',
                  style: PremiumTheme.bodyMedium.copyWith(
                    color: PremiumTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(PremiumTheme.spaceSm),
            decoration: BoxDecoration(
              gradient: PremiumTheme.goldGradient,
              borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
              boxShadow: [PremiumTheme.shadowGold],
            ),
            child: Row(
              children: [
                const Icon(Icons.diamond, color: Colors.white, size: 16),
                const SizedBox(width: PremiumTheme.spaceXs),
                Text(
                  'Pro',
                  style: PremiumTheme.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PremiumTheme.spaceLg),
      child: Row(
        children: [
          Expanded(
            child: StatsCard(
              icon: Icons.edit_note,
              value: '47',
              label: 'Messages',
              gradient: PremiumTheme.primaryGradient,
            ),
          ),
          const SizedBox(width: PremiumTheme.spaceMd),
          Expanded(
            child: StatsCard(
              icon: Icons.favorite,
              value: '12',
              label: 'Favorites',
              gradient: PremiumTheme.secondaryGradient,
            ),
          ),
          const SizedBox(width: PremiumTheme.spaceMd),
          Expanded(
            child: StatsCard(
              icon: Icons.trending_up,
              value: '94%',
              label: 'Success',
              gradient: PremiumTheme.successGradient,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(PremiumTheme.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: PremiumTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PremiumTheme.spaceMd),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickActionCard(
                  'Love Note',
                  Icons.favorite,
                  PremiumTheme.secondaryGradient,
                  () => _quickGenerate('Crush', 'Romantic'),
                ),
                const SizedBox(width: PremiumTheme.spaceMd),
                _buildQuickActionCard(
                  'Apology',
                  Icons.psychology,
                  PremiumTheme.accentGradient,
                  () => _quickGenerate('Best Friend', 'Apologetic'),
                ),
                const SizedBox(width: PremiumTheme.spaceMd),
                _buildQuickActionCard(
                  'Thank You',
                  Icons.card_giftcard,
                  PremiumTheme.goldGradient,
                  () => _quickGenerate('Family', 'Grateful'),
                ),
                const SizedBox(width: PremiumTheme.spaceMd),
                _buildQuickActionCard(
                  'Professional',
                  Icons.business_center,
                  PremiumTheme.oceanGradient,
                  () => _quickGenerate('Colleague', 'Professional'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Gradient gradient,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(PremiumTheme.spaceMd),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(PremiumTheme.radiusLg),
          boxShadow: [PremiumTheme.shadowLg],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: PremiumTheme.spaceSm),
            Text(
              title,
              textAlign: TextAlign.center,
              style: PremiumTheme.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _quickGenerate(String recipient, String tone) {
    setState(() {
      _selectedRecipient = recipient;
      _selectedTone = tone;
    });
    _showSnackBar('Selected: $recipient - $tone', isError: false);
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(PremiumTheme.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create Message',
            style: PremiumTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PremiumTheme.spaceMd),

          // Recipient Selection
          _buildSectionTitle('Who is it for?', Icons.person),
          const SizedBox(height: PremiumTheme.spaceSm),
          Wrap(
            spacing: PremiumTheme.spaceSm,
            runSpacing: PremiumTheme.spaceSm,
            children: AppConfig.recipientCategories.map((recipient) {
              return PremiumChip(
                label: recipient,
                isSelected: _selectedRecipient == recipient,
                onTap: () => setState(() => _selectedRecipient = recipient),
                gradient: PremiumTheme.primaryGradient,
              );
            }).toList(),
          ),

          const SizedBox(height: PremiumTheme.spaceLg),

          // Tone Selection
          _buildSectionTitle('Choose the tone', Icons.mood),
          const SizedBox(height: PremiumTheme.spaceSm),
          Wrap(
            spacing: PremiumTheme.spaceSm,
            runSpacing: PremiumTheme.spaceSm,
            children: AppConfig.availableTones.map((tone) {
              return PremiumChip(
                label: tone,
                isSelected: _selectedTone == tone,
                onTap: () => setState(() => _selectedTone = tone),
                gradient: PremiumTheme.secondaryGradient,
              );
            }).toList(),
          ),

          const SizedBox(height: PremiumTheme.spaceLg),

          // Context Input
          _buildSectionTitle('What do you want to say?', Icons.message),
          const SizedBox(height: PremiumTheme.spaceSm),
          PremiumTextField(
            label: 'Message Context',
            hint: 'E.g., "Sorry for being late to our date"',
            icon: Icons.edit_note,
            controller: _contextController,
            maxLines: 3,
          ),

          const SizedBox(height: PremiumTheme.spaceMd),

          // Advanced Options Toggle
          GestureDetector(
            onTap: () =>
                setState(() => _showAdvancedOptions = !_showAdvancedOptions),
            child: Row(
              children: [
                Icon(
                  _showAdvancedOptions
                      ? Icons.expand_less
                      : Icons.expand_more,
                  color: PremiumTheme.primary,
                ),
                const SizedBox(width: PremiumTheme.spaceXs),
                Text(
                  'Advanced Options',
                  style: PremiumTheme.labelMedium.copyWith(
                    color: PremiumTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Advanced Options
          if (_showAdvancedOptions) ...[
            const SizedBox(height: PremiumTheme.spaceMd),
            PremiumTextField(
              label: 'Additional Context (Optional)',
              hint: 'Add specific details...',
              icon: Icons.add_circle_outline,
              controller: _additionalContextController,
              maxLines: 2,
            ),
            const SizedBox(height: PremiumTheme.spaceMd),
            _buildSectionTitle('Word Limit', Icons.text_fields),
            const SizedBox(height: PremiumTheme.spaceSm),
            _buildWordLimitSlider(),
          ],

          const SizedBox(height: PremiumTheme.spaceLg),

          // Generate Button
          PremiumButton(
            text: _isGenerating ? 'Generating...' : 'Generate Messages ✨',
            onPressed: _isGenerating ? null : _generateMessage,
            isLoading: _isGenerating,
            icon: Icons.auto_awesome,
            gradient: PremiumTheme.premiumGradient,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: PremiumTheme.primary),
        const SizedBox(width: PremiumTheme.spaceXs),
        Text(
          title,
          style: PremiumTheme.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWordLimitSlider() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Max Words: $_selectedWordLimit',
              style: PremiumTheme.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            PremiumBadge(
              text: _selectedWordLimit > 100 ? 'PREMIUM' : 'FREE',
              gradient: _selectedWordLimit > 100
                  ? PremiumTheme.goldGradient
                  : PremiumTheme.successGradient,
            ),
          ],
        ),
        const SizedBox(height: PremiumTheme.spaceSm),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: PremiumTheme.primary,
            inactiveTrackColor: PremiumTheme.border,
            thumbColor: PremiumTheme.primary,
            overlayColor: PremiumTheme.primary.withValues(alpha: 0.2),
            trackHeight: 6,
          ),
          child: Slider(
            value: _selectedWordLimit.toDouble(),
            min: 20,
            max: 200,
            divisions: 18,
            onChanged: (value) {
              setState(() => _selectedWordLimit = value.toInt());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGeneratedMessages() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.all(PremiumTheme.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: PremiumTheme.gold),
                const SizedBox(width: PremiumTheme.spaceXs),
                Text(
                  'Generated Messages',
                  style: PremiumTheme.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: PremiumTheme.spaceMd),

            // Message Tabs
            Row(
              children: List.generate(_generatedMessages.length, (index) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedMessageIndex = index),
                    child: AnimatedContainer(
                      duration: PremiumTheme.animationFast,
                      margin: const EdgeInsets.symmetric(
                        horizontal: PremiumTheme.spaceXs,
                      ),
                      padding:
                          const EdgeInsets.symmetric(vertical: PremiumTheme.spaceSm),
                      decoration: BoxDecoration(
                        gradient: _selectedMessageIndex == index
                            ? PremiumTheme.primaryGradient
                            : null,
                        color: _selectedMessageIndex != index
                            ? PremiumTheme.surfaceVariant
                            : null,
                        borderRadius:
                            BorderRadius.circular(PremiumTheme.radiusMd),
                      ),
                      child: Text(
                        'Option ${index + 1}',
                        textAlign: TextAlign.center,
                        style: PremiumTheme.labelMedium.copyWith(
                          color: _selectedMessageIndex == index
                              ? Colors.white
                              : PremiumTheme.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: PremiumTheme.spaceMd),

            // Message Card
            PremiumCard(
              gradient: PremiumTheme.primaryGradient,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _generatedMessages[_selectedMessageIndex],
                          style: PremiumTheme.bodyLarge.copyWith(
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: PremiumTheme.spaceLg),
                  Row(
                    children: [
                      Expanded(
                        child: PremiumButton(
                          text: 'Copy',
                          icon: Icons.copy,
                          gradient: PremiumTheme.accentGradient,
                          onPressed: () {
                            // Copy to clipboard logic
                            _showSnackBar('Copied to clipboard!', isError: false);
                          },
                        ),
                      ),
                      const SizedBox(width: PremiumTheme.spaceSm),
                      Expanded(
                        child: PremiumButton(
                          text: 'Save',
                          icon: Icons.bookmark,
                          gradient: PremiumTheme.goldGradient,
                          onPressed: () {
                            // Save message logic
                            _showSnackBar('Message saved!', isError: false);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
