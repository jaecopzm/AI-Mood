import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/premium_theme.dart';
import '../../widgets/premium_widgets.dart';
import '../../providers/message_provider.dart';
import '../../providers/auth_provider.dart';

class PremiumHistoryScreen extends ConsumerStatefulWidget {
  const PremiumHistoryScreen({super.key});

  @override
  ConsumerState<PremiumHistoryScreen> createState() => _PremiumHistoryScreenState();
}

class _PremiumHistoryScreenState extends ConsumerState<PremiumHistoryScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Romantic', 'Professional', 'Funny', 'Apologetic'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final authState = ref.read(authStateProvider);
    if (authState.user != null) {
      await ref.read(messageProvider.notifier).loadHistory(authState.user!.uid);
    }
    setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _messages {
    final messageState = ref.watch(messageProvider);
    return messageState.history.map((msg) => {
      'text': msg.generatedText,
      'recipient': msg.recipientType,
      'tone': msg.tone,
      'date': _formatDate(msg.createdAt),
      'saved': msg.isSaved,
      'gradient': _getGradientForTone(msg.tone),
      'id': msg.id,
    }).toList();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    if (diff.inDays == 1) return 'Yesterday, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    return '${date.month}/${date.day}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Gradient _getGradientForTone(String tone) {
    switch (tone.toLowerCase()) {
      case 'romantic': return PremiumTheme.secondaryGradient;
      case 'professional': return PremiumTheme.oceanGradient;
      case 'funny': return PremiumTheme.accentGradient;
      case 'apologetic': return PremiumTheme.primaryGradient;
      default: return PremiumTheme.goldGradient;
    }
  }

  // Mock data kept for fallback if needed
  final List<Map<String, dynamic>> _unusedMockMessages = [
    {
      'text': 'Hey love, just wanted to say you make every moment brighter. Can\'t wait to see you tonight! 💕',
      'recipient': 'Crush',
      'tone': 'Romantic',
      'date': 'Today, 2:30 PM',
      'saved': true,
      'gradient': PremiumTheme.secondaryGradient,
    },
    {
      'text': 'I sincerely apologize for missing our meeting. It won\'t happen again. Let\'s reschedule at your convenience.',
      'recipient': 'Boss',
      'tone': 'Professional',
      'date': 'Yesterday, 10:15 AM',
      'saved': false,
      'gradient': PremiumTheme.oceanGradient,
    },
    {
      'text': 'Dude, that was hilarious! We need to hang out more often. Coffee this weekend? ☕',
      'recipient': 'Best Friend',
      'tone': 'Funny',
      'date': 'Dec 28, 4:20 PM',
      'saved': true,
      'gradient': PremiumTheme.accentGradient,
    },
    {
      'text': 'I\'m really sorry about what happened. You mean the world to me, and I never meant to hurt you.',
      'recipient': 'Girlfriend',
      'tone': 'Apologetic',
      'date': 'Dec 27, 9:00 PM',
      'saved': false,
      'gradient': PremiumTheme.primaryGradient,
    },
    {
      'text': 'Thank you so much for always being there for me. Your support means everything! 🙏',
      'recipient': 'Family',
      'tone': 'Grateful',
      'date': 'Dec 25, 11:30 AM',
      'saved': true,
      'gradient': PremiumTheme.goldGradient,
    },
  ];

  List<Map<String, dynamic>> get _filteredMessages {
    if (_selectedFilter == 'All') return _messages;
    return _messages.where((m) => m['tone'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              PremiumTheme.background,
              PremiumTheme.primaryLight.withValues(alpha: 0.03),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildFilterChips(),
              Expanded(child: _buildMessageList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                    'Message History',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: PremiumTheme.spaceXs),
                Text(
                  '${_filteredMessages.length} messages',
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
              gradient: PremiumTheme.primaryGradient,
              borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
              boxShadow: [PremiumTheme.shadowPrimary],
            ),
            child: const Icon(
              Icons.search,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: PremiumTheme.spaceLg),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          return Padding(
            padding: const EdgeInsets.only(right: PremiumTheme.spaceSm),
            child: PremiumChip(
              label: filter,
              isSelected: _selectedFilter == filter,
              onTap: () => setState(() => _selectedFilter = filter),
              gradient: PremiumTheme.primaryGradient,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredMessages.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(PremiumTheme.spaceLg),
        itemCount: _filteredMessages.length,
        itemBuilder: (context, index) {
          return _buildMessageCard(_filteredMessages[index], index);
        },
      ),
    );
  }

  Widget _buildMessageCard(Map<String, dynamic> message, int index) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: PremiumTheme.spaceMd),
        child: PremiumCard(
          gradient: message['gradient'],
          onTap: () => _showMessageDetails(message),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PremiumTheme.spaceSm,
                      vertical: PremiumTheme.spaceXs,
                    ),
                    decoration: BoxDecoration(
                      gradient: message['gradient'],
                      borderRadius: BorderRadius.circular(PremiumTheme.radiusFull),
                    ),
                    child: Text(
                      message['recipient'],
                      style: PremiumTheme.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: PremiumTheme.spaceXs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PremiumTheme.spaceSm,
                      vertical: PremiumTheme.spaceXs,
                    ),
                    decoration: BoxDecoration(
                      color: PremiumTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(PremiumTheme.radiusFull),
                    ),
                    child: Text(
                      message['tone'],
                      style: PremiumTheme.labelSmall.copyWith(
                        color: PremiumTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (message['saved'])
                    Icon(
                      Icons.bookmark,
                      color: PremiumTheme.gold,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: PremiumTheme.spaceMd),
              Text(
                message['text'],
                style: PremiumTheme.bodyMedium.copyWith(
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: PremiumTheme.spaceMd),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    message['date'],
                    style: PremiumTheme.bodySmall.copyWith(
                      color: PremiumTheme.textTertiary,
                    ),
                  ),
                  Row(
                    children: [
                      _buildActionButton(
                        Icons.copy,
                        () => _copyMessage(message['text']),
                      ),
                      const SizedBox(width: PremiumTheme.spaceXs),
                      _buildActionButton(
                        Icons.share,
                        () => _shareMessage(message['text']),
                      ),
                      const SizedBox(width: PremiumTheme.spaceXs),
                      _buildActionButton(
                        message['saved'] ? Icons.bookmark : Icons.bookmark_border,
                        () => _toggleSave(message),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(PremiumTheme.spaceXs),
        decoration: BoxDecoration(
          color: PremiumTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(PremiumTheme.radiusSm),
        ),
        child: Icon(
          icon,
          size: 18,
          color: PremiumTheme.primary,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(PremiumTheme.spaceLg),
            decoration: BoxDecoration(
              gradient: PremiumTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [PremiumTheme.shadowPrimary],
            ),
            child: const Icon(
              Icons.inbox,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: PremiumTheme.spaceLg),
          Text(
            'No messages yet',
            style: PremiumTheme.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PremiumTheme.spaceSm),
          Text(
            'Start generating messages to see them here',
            style: PremiumTheme.bodyMedium.copyWith(
              color: PremiumTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: PremiumTheme.spaceLg),
          PremiumButton(
            text: 'Create Message',
            icon: Icons.add,
            gradient: PremiumTheme.primaryGradient,
            isFullWidth: false,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showMessageDetails(Map<String, dynamic> message) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: PremiumTheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(PremiumTheme.radiusXl),
            topRight: Radius.circular(PremiumTheme.radiusXl),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: PremiumTheme.spaceSm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: PremiumTheme.border,
                borderRadius: BorderRadius.circular(PremiumTheme.radiusFull),
              ),
            ),
            const SizedBox(height: PremiumTheme.spaceLg),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(PremiumTheme.spaceLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        PremiumBadge(
                          text: message['recipient'],
                          gradient: message['gradient'],
                        ),
                        const SizedBox(width: PremiumTheme.spaceXs),
                        PremiumBadge(
                          text: message['tone'],
                          backgroundColor: PremiumTheme.surfaceVariant,
                        ),
                      ],
                    ),
                    const SizedBox(height: PremiumTheme.spaceLg),
                    Text(
                      'Message',
                      style: PremiumTheme.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: PremiumTheme.spaceMd),
                    Container(
                      padding: const EdgeInsets.all(PremiumTheme.spaceMd),
                      decoration: BoxDecoration(
                        color: PremiumTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(PremiumTheme.radiusLg),
                      ),
                      child: Text(
                        message['text'],
                        style: PremiumTheme.bodyLarge.copyWith(
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: PremiumTheme.spaceLg),
                    Text(
                      'Created',
                      style: PremiumTheme.titleSmall,
                    ),
                    const SizedBox(height: PremiumTheme.spaceXs),
                    Text(
                      message['date'],
                      style: PremiumTheme.bodyMedium.copyWith(
                        color: PremiumTheme.textSecondary,
                      ),
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
                              _copyMessage(message['text']);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        const SizedBox(width: PremiumTheme.spaceSm),
                        Expanded(
                          child: PremiumButton(
                            text: 'Share',
                            icon: Icons.share,
                            gradient: PremiumTheme.primaryGradient,
                            onPressed: () {
                              _shareMessage(message['text']);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyMessage(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard!'),
        backgroundColor: PremiumTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
        ),
      ),
    );
  }

  void _shareMessage(String text) {
    // Share logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sharing message...'),
        backgroundColor: PremiumTheme.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
        ),
      ),
    );
  }

  Future<void> _toggleSave(Map<String, dynamic> message) async {
    final messageId = message['id'] as String;
    final isSaved = message['saved'] as bool;
    
    await ref.read(messageProvider.notifier).toggleSaveMessage(messageId, !isSaved);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(!isSaved ? 'Message saved!' : 'Message removed from saved'),
          backgroundColor: PremiumTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
          ),
        ),
      );
    }
  }
}
