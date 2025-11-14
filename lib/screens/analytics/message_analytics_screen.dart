import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/message_model.dart';
import '../../widgets/app_widgets.dart';

class MessageAnalyticsScreen extends StatelessWidget {
  final List<MessageModel> messages;

  const MessageAnalyticsScreen({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Message Analytics'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            _buildSummaryCard(
              context,
              label: 'Total Messages',
              value: messages.length.toString(),
              icon: Icons.message_outlined,
              color: AppTheme.primary,
            ),
            const SizedBox(height: AppTheme.md),
            _buildSummaryCard(
              context,
              label: 'Saved Messages',
              value: messages.where((m) => m.isSaved).length.toString(),
              icon: Icons.bookmark,
              color: AppTheme.accent,
            ),
            const SizedBox(height: AppTheme.md),
            _buildSummaryCard(
              context,
              label: 'Total Words',
              value: messages
                  .fold<int>(
                    0,
                    (sum, m) => sum + m.generatedText.split(' ').length,
                  )
                  .toString(),
              icon: Icons.description_outlined,
              color: AppTheme.success,
            ),
            const SizedBox(height: AppTheme.lg),

            // Average Rating
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Average Rating',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppTheme.md),
                  Row(
                    children: [
                      Text(
                        _calculateAverageRating().toStringAsFixed(1),
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(color: AppTheme.primary),
                      ),
                      const SizedBox(width: AppTheme.sm),
                      Text(
                        '/ 5.0',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < _calculateAverageRating().toInt()
                                ? Icons.star
                                : Icons.star_border,
                            color: AppTheme.accent,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.lg),

            // Recipients Breakdown
            Text(
              'Messages by Recipient',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.md),
            AppCard(child: Column(children: _buildRecipientBreakdown(context))),
            const SizedBox(height: AppTheme.lg),

            // Tones Breakdown
            Text(
              'Messages by Tone',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.md),
            AppCard(child: Column(children: _buildToneBreakdown(context))),
            const SizedBox(height: AppTheme.lg),

            // Top Rated Messages
            Text(
              'Top Rated Messages',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.md),
            ..._getTopRatedMessages().map((msg) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.md),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppBadge(label: _capitalize(msg.recipientType)),
                          Row(
                            children: List.generate(
                              5,
                              (index) => Icon(
                                msg.isSaved && index == 0
                                    ? Icons.star
                                    : Icons.star_border,
                                color: AppTheme.accent,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.sm),
                      Text(
                        msg.generatedText.substring(
                              0,
                              msg.generatedText.length > 100
                                  ? 100
                                  : msg.generatedText.length,
                            ) +
                            (msg.generatedText.length > 100 ? '...' : ''),
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: AppTheme.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary),
                ),
                const SizedBox(height: AppTheme.xs),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.displaySmall?.copyWith(color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRecipientBreakdown(BuildContext context) {
    final counts = <String, int>{};
    for (var msg in messages) {
      counts[msg.recipientType] = (counts[msg.recipientType] ?? 0) + 1;
    }

    return counts.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final recipient = entry.value.key;
      final count = entry.value.value;
      final percentage = (count / messages.length * 100).toStringAsFixed(1);

      return Column(
        children: [
          Row(
            children: [
              Text(
                _capitalize(recipient),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              Text(
                '$count ($percentage%)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: count / messages.length,
              backgroundColor: AppTheme.primaryLight,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              minHeight: 6,
            ),
          ),
          if (index < counts.length - 1) const SizedBox(height: AppTheme.md),
        ],
      );
    }).toList();
  }

  List<Widget> _buildToneBreakdown(BuildContext context) {
    final counts = <String, int>{};
    for (var msg in messages) {
      counts[msg.tone] = (counts[msg.tone] ?? 0) + 1;
    }

    return counts.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final tone = entry.value.key;
      final count = entry.value.value;
      final percentage = (count / messages.length * 100).toStringAsFixed(1);

      return Column(
        children: [
          Row(
            children: [
              Text(
                _capitalize(tone),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              Text(
                '$count ($percentage%)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: count / messages.length,
              backgroundColor: AppTheme.accentLight,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accent),
              minHeight: 6,
            ),
          ),
          if (index < counts.length - 1) const SizedBox(height: AppTheme.md),
        ],
      );
    }).toList();
  }

  double _calculateAverageRating() {
    if (messages.isEmpty) return 0.0;
    final savedCount = messages.where((m) => m.isSaved).length;
    return (savedCount / messages.length) * 5.0;
  }

  List<MessageModel> _getTopRatedMessages() {
    final sorted = List<MessageModel>.from(messages);
    sorted.sort(
      (a, b) => b.generatedText.length.compareTo(a.generatedText.length),
    );
    return sorted.take(3).toList();
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).replaceAll('_', ' ');
  }
}
