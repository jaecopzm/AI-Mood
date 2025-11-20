import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/premium_theme.dart';
import '../providers/subscription_provider.dart';
import '../screens/subscription/paywall_screen.dart';

/// Widget to show message usage and limits
class UsageIndicator extends ConsumerWidget {
  final bool showUpgradeButton;
  final bool compact;

  const UsageIndicator({
    super.key,
    this.showUpgradeButton = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(subscriptionProvider);
    final usage = subscriptionState.usage;

    if (usage == null) {
      return const SizedBox.shrink();
    }

    // Premium users have unlimited
    if (subscriptionState.currentTier.name == 'premium') {
      return _buildPremiumBadge();
    }

    return compact
        ? _buildCompact(context, subscriptionState)
        : _buildFull(context, subscriptionState);
  }

  Widget _buildPremiumBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PremiumTheme.spaceSm,
        vertical: PremiumTheme.spaceXs,
      ),
      decoration: BoxDecoration(
        gradient: PremiumTheme.goldGradient,
        borderRadius: BorderRadius.circular(PremiumTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.diamond, color: Colors.white, size: 16),
          const SizedBox(width: PremiumTheme.spaceXs),
          Text(
            'Premium • Unlimited',
            style: PremiumTheme.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompact(BuildContext context, SubscriptionState state) {
    final usage = state.usage!;
    final isNearLimit = usage.isNearLimit;
    final hasReachedLimit = usage.hasReachedLimit;

    return GestureDetector(
      onTap: showUpgradeButton && (isNearLimit || hasReachedLimit)
          ? () => _showPaywall(context)
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PremiumTheme.spaceSm,
          vertical: PremiumTheme.spaceXs,
        ),
        decoration: BoxDecoration(
          color: hasReachedLimit
              ? PremiumTheme.error.withValues(alpha: 0.1)
              : isNearLimit
              ? PremiumTheme.warning.withValues(alpha: 0.1)
              : PremiumTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(PremiumTheme.radiusFull),
          border: Border.all(
            color: hasReachedLimit
                ? PremiumTheme.error
                : isNearLimit
                ? PremiumTheme.warning
                : PremiumTheme.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasReachedLimit
                  ? Icons.block
                  : isNearLimit
                  ? Icons.warning_amber
                  : Icons.message,
              size: 16,
              color: hasReachedLimit
                  ? PremiumTheme.error
                  : isNearLimit
                  ? PremiumTheme.warning
                  : PremiumTheme.textSecondary,
            ),
            const SizedBox(width: PremiumTheme.spaceXs),
            Text(
              '${usage.messagesUsedThisMonth}/${usage.messagesLimit == -1 ? '∞' : usage.messagesLimit}',
              style: PremiumTheme.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: hasReachedLimit
                    ? PremiumTheme.error
                    : isNearLimit
                    ? PremiumTheme.warning
                    : PremiumTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFull(BuildContext context, SubscriptionState state) {
    final usage = state.usage!;
    final isNearLimit = usage.isNearLimit;
    final hasReachedLimit = usage.hasReachedLimit;

    return Container(
      padding: const EdgeInsets.all(PremiumTheme.spaceMd),
      decoration: BoxDecoration(
        color: hasReachedLimit
            ? PremiumTheme.error.withValues(alpha: 0.1)
            : isNearLimit
            ? PremiumTheme.warning.withValues(alpha: 0.1)
            : PremiumTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
        border: Border.all(
          color: hasReachedLimit
              ? PremiumTheme.error
              : isNearLimit
              ? PremiumTheme.warning
              : PremiumTheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    hasReachedLimit
                        ? Icons.block
                        : isNearLimit
                        ? Icons.warning_amber
                        : Icons.message,
                    color: hasReachedLimit
                        ? PremiumTheme.error
                        : isNearLimit
                        ? PremiumTheme.warning
                        : PremiumTheme.primary,
                  ),
                  const SizedBox(width: PremiumTheme.spaceSm),
                  Text(
                    hasReachedLimit
                        ? 'Limit Reached'
                        : isNearLimit
                        ? 'Almost at Limit'
                        : 'Message Usage',
                    style: PremiumTheme.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: hasReachedLimit
                          ? PremiumTheme.error
                          : isNearLimit
                          ? PremiumTheme.warning
                          : PremiumTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: PremiumTheme.spaceSm,
                  vertical: PremiumTheme.spaceXs,
                ),
                decoration: BoxDecoration(
                  color: PremiumTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(PremiumTheme.radiusSm),
                ),
                child: Text(
                  state.currentTier.displayName,
                  style: PremiumTheme.labelSmall.copyWith(
                    color: PremiumTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: PremiumTheme.spaceMd),

          // Usage text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${usage.messagesUsedThisMonth} of ${usage.messagesLimit == -1 ? '∞' : usage.messagesLimit} messages used',
                style: PremiumTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${usage.messagesRemaining == -1 ? '∞' : usage.messagesRemaining} left',
                style: PremiumTheme.bodySmall.copyWith(
                  color: PremiumTheme.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: PremiumTheme.spaceSm),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(PremiumTheme.radiusFull),
            child: LinearProgressIndicator(
              value: usage.usagePercentage / 100,
              minHeight: 8,
              backgroundColor: PremiumTheme.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                hasReachedLimit
                    ? PremiumTheme.error
                    : isNearLimit
                    ? PremiumTheme.warning
                    : PremiumTheme.primary,
              ),
            ),
          ),

          const SizedBox(height: PremiumTheme.spaceSm),

          // Reset info
          Text(
            'Resets in ${usage.daysUntilReset} days',
            style: PremiumTheme.bodySmall.copyWith(
              color: PremiumTheme.textSecondary,
            ),
          ),

          // Upgrade button
          if (showUpgradeButton && (isNearLimit || hasReachedLimit)) ...[
            const SizedBox(height: PremiumTheme.spaceMd),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showPaywall(context),
                icon: const Icon(Icons.diamond, size: 20),
                label: Text(
                  hasReachedLimit
                      ? 'Upgrade to Continue'
                      : 'Upgrade for More Messages',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PremiumTheme.gold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: PremiumTheme.spaceSm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showPaywall(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PaywallScreen(),
        fullscreenDialog: true,
      ),
    );
  }
}
