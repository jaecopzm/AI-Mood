import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../widgets/app_widgets.dart';
import '../../providers/message_provider.dart';

class MessageHistoryScreen extends ConsumerStatefulWidget {
  const MessageHistoryScreen({super.key});

  @override
  ConsumerState<MessageHistoryScreen> createState() =>
      _MessageHistoryScreenState();
}

class _MessageHistoryScreenState extends ConsumerState<MessageHistoryScreen> {
  String _selectedFilter = 'all';
  bool _isSavedOnly = false;

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final messageHistoryState = ref.watch(messageProvider);

    final filteredMessages = messageHistoryState.history.where((msg) {
      if (_isSavedOnly && !msg.isSaved) return false;
      if (_selectedFilter != 'all' &&
          msg.recipientType.toLowerCase() != _selectedFilter) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Message History'), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filters
            Padding(
              padding: const EdgeInsets.all(AppTheme.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Messages',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      FilterChip(
                        selected: _isSavedOnly,
                        onSelected: (value) {
                          setState(() => _isSavedOnly = value);
                        },
                        label: const Text('Saved Only'),
                        selectedColor: AppTheme.success,
                        backgroundColor: AppTheme.surface,
                        side: BorderSide(
                          color: _isSavedOnly
                              ? AppTheme.success
                              : AppTheme.border,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.md),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Crush', 'Friend', 'Family', 'Boss']
                          .map((filter) {
                            final isSelected =
                                _selectedFilter ==
                                (filter == 'All'
                                    ? 'all'
                                    : filter.toLowerCase());
                            return Padding(
                              padding: const EdgeInsets.only(
                                right: AppTheme.sm,
                              ),
                              child: FilterChip(
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(
                                    () => _selectedFilter = filter == 'All'
                                        ? 'all'
                                        : filter.toLowerCase(),
                                  );
                                },
                                label: Text(filter),
                                backgroundColor: AppTheme.surface,
                                selectedColor: AppTheme.primary,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppTheme.primary
                                      : AppTheme.border,
                                ),
                              ),
                            );
                          })
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Message List
            if (filteredMessages.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.xl),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: AppTheme.textTertiary,
                      ),
                      const SizedBox(height: AppTheme.md),
                      Text(
                        'No messages yet',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.lg),
                child: Column(
                  children: List.generate(filteredMessages.length, (index) {
                    final message = filteredMessages[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.md),
                      child: AppCard(
                        onTap: () {
                          // TODO: Show message detail
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    AppBadge(
                                      label: message.recipientType,
                                      backgroundColor: AppTheme.primaryLight,
                                    ),
                                    const SizedBox(width: AppTheme.md),
                                    AppBadge(
                                      label: message.tone,
                                      backgroundColor: AppTheme.accentLight,
                                    ),
                                  ],
                                ),
                                PopupMenuButton(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: const Text('Edit'),
                                      onTap: () {
                                        // TODO: Edit message
                                      },
                                    ),
                                    PopupMenuItem(
                                      child: const Text('Delete'),
                                      onTap: () {
                                        ref
                                            .read(
                                              messageProvider.notifier,
                                            )
                                            .deleteMessage(message.id);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.md),

                            // Content
                            Text(
                              message.generatedText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppTheme.md),

                            // Footer
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _getTimeAgo(message.createdAt),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Row(
                                  children: [
                                    if (message.isSaved)
                                      const Icon(
                                        Icons.bookmark,
                                        size: 18,
                                        color: AppTheme.success,
                                      ),
                                    const SizedBox(width: AppTheme.sm),
                                    // Rating removed, using saved status
                                    Icon(
                                      message.isSaved ? Icons.star : Icons.star_border,
                                      size: 18,
                                      color: AppTheme.warning,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            const SizedBox(height: AppTheme.lg),
          ],
        ),
      ),
    );
  }
}
