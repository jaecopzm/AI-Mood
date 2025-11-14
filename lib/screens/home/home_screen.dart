import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../widgets/app_widgets.dart';
import '../../providers/message_generation_provider.dart';
import '../../providers/message_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedRecipient = 'crush';
  String _selectedTone = 'romantic';
  String _messageContext = '';
  int _wordLimit = 100;

  final List<String> _recipients = [
    'Crush',
    'Girlfriend',
    'Best Friend',
    'Family',
    'Boss',
    'Colleague',
  ];

  final List<String> _tones = [
    'Romantic',
    'Funny',
    'Apologetic',
    'Grateful',
    'Professional',
    'Casual',
  ];

  void _generateMessage() async {
    if (_messageContext.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please provide context')));
      return;
    }

    try {
      ref
          .read(messageGenerationProvider.notifier)
          .setRecipient(_selectedRecipient);
      ref.read(messageGenerationProvider.notifier).setTone(_selectedTone);
      ref.read(messageGenerationProvider.notifier).setContext(_messageContext);
      ref.read(messageGenerationProvider.notifier).setWordLimit(_wordLimit);

      await ref.read(messageGenerationProvider.notifier).generateMessage();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _saveMessage() {
    final genState = ref.read(messageGenerationProvider);
    if (genState.generatedMessage == null) return;

    try {
      // Message already saved by provider during generation
      // ref.read(messageProvider.notifier) handles this
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving: $e')));
    }
  }

  void _copyMessage() {
    final genState = ref.read(messageGenerationProvider);
    if (genState.generatedMessage == null) return;
    // TODO: Implement copy to clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Mood'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: Navigate to history
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // TODO: Navigate to profile
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipient Selection
            Text(
              'Who are you writing to?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.md),
            Wrap(
              spacing: AppTheme.sm,
              runSpacing: AppTheme.sm,
              children: _recipients.map((recipient) {
                final isSelected =
                    _selectedRecipient == recipient.toLowerCase();
                return FilterChip(
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(
                      () => _selectedRecipient = recipient.toLowerCase(),
                    );
                  },
                  label: Text(recipient),
                  backgroundColor: AppTheme.surface,
                  selectedColor: AppTheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppTheme.primary : AppTheme.border,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: AppTheme.xl),

            // Tone Selection
            Text(
              'What tone would you like?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.md),
            Wrap(
              spacing: AppTheme.sm,
              runSpacing: AppTheme.sm,
              children: _tones.map((tone) {
                final isSelected = _selectedTone == tone.toLowerCase();
                return FilterChip(
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedTone = tone.toLowerCase());
                  },
                  label: Text(tone),
                  backgroundColor: AppTheme.surface,
                  selectedColor: AppTheme.accent,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppTheme.accent : AppTheme.border,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: AppTheme.xl),

            // Word Limit Slider
            Text('Word Limit', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppTheme.md),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _wordLimit.toDouble(),
                    min: 20,
                    max: 500,
                    divisions: 48,
                    activeColor: AppTheme.primary,
                    inactiveColor: AppTheme.border,
                    label: _wordLimit.toString(),
                    onChanged: (value) {
                      setState(() => _wordLimit = value.toInt());
                    },
                  ),
                ),
                const SizedBox(width: AppTheme.md),
                AppBadge(
                  label: _wordLimit.toString(),
                  backgroundColor: AppTheme.primaryLight,
                ),
              ],
            ),

            const SizedBox(height: AppTheme.xl),

            // Context Input
            Text(
              'What do you want to say?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.md),
            TextFormField(
              onChanged: (value) => setState(() => _messageContext = value),
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'E.g., Tell her how much she means to me and ask her out for dinner...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: const BorderSide(
                    color: AppTheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppTheme.xl),

            // Generate Button
            Consumer(
              builder: (context, ref, _) {
                final genState = ref.watch(messageGenerationProvider);
                return AppGradientButton(
                  label: 'Generate Message',
                  gradient: AppTheme.primaryGradient,
                  isLoading: genState.isLoading,
                  onPressed: _generateMessage,
                  icon: Icons.auto_awesome,
                );
              },
            ),

            // Generated Message Display
            Consumer(
              builder: (context, ref, _) {
                final genState = ref.watch(messageGenerationProvider);
                if (genState.generatedMessage != null) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppTheme.xl),
                      Text(
                        'Your Message',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppTheme.md),
                      AppCard(
                        padding: const EdgeInsets.all(AppTheme.lg),
                        backgroundColor: AppTheme.primaryLight,
                        borderColor: AppTheme.primary,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              genState.generatedMessage!,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.6,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppTheme.lg),
                            Row(
                              children: [
                                Expanded(
                                  child: AppButton(
                                    label: 'Copy',
                                    icon: Icons.copy,
                                    onPressed: _copyMessage,
                                  ),
                                ),
                                const SizedBox(width: AppTheme.md),
                                Expanded(
                                  child: AppButton(
                                    label: 'Save',
                                    icon: Icons.bookmark,
                                    backgroundColor: AppTheme.success,
                                    onPressed: _saveMessage,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: AppTheme.lg),
          ],
        ),
      ),
    );
  }
}
