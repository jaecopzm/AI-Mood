import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../config/theme.dart';
import '../../widgets/app_widgets.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String _currentPlan = 'free';
  final int _messagesUsed = 3;
  final int _messagesLimit = 5;

  @override
  Widget build(BuildContext context) {
    final subscription = AppConfig.subscriptionTiers;

    return Scaffold(
      appBar: AppBar(title: const Text('Plans & Subscription'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Usage
            Text(
              'Current Usage',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.md),
            AppCard(
              backgroundColor: AppTheme.primaryLight,
              borderColor: AppTheme.primary,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'This Month',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '$_messagesUsed / $_messagesLimit',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    child: LinearProgressIndicator(
                      value: _messagesUsed / _messagesLimit,
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.5),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.md),
                  Text(
                    'You have ${_messagesLimit - _messagesUsed} messages remaining',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.xl),

            // Available Plans
            Text(
              'Available Plans',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.md),

            ...subscription.entries.map((entry) {
              final planId = entry.key;
              final plan = entry.value;
              final isCurrentPlan = _currentPlan == planId;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.lg),
                child: AppCard(
                  backgroundColor: isCurrentPlan
                      ? AppTheme.primaryLight
                      : AppTheme.surface,
                  borderColor: isCurrentPlan
                      ? AppTheme.primary
                      : AppTheme.border,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plan.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              if (isCurrentPlan)
                                Text(
                                  'Current Plan',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppTheme.success,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                            ],
                          ),
                          Text(
                            plan.price == 0 ? 'Free' : '\$${plan.price}/mo',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.md),

                      // Credits
                      Row(
                        children: [
                          Icon(
                            Icons.mail_outline,
                            size: 18,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: AppTheme.sm),
                          Text(
                            plan.monthlyCredits == -1
                                ? 'Unlimited Messages'
                                : '${plan.monthlyCredits} Messages/Month',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.sm),

                      // Features
                      ...plan.features.map((feature) {
                        return Padding(
                          padding: const EdgeInsets.only(top: AppTheme.sm),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 18,
                                color: AppTheme.success,
                              ),
                              const SizedBox(width: AppTheme.sm),
                              Text(
                                feature,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: AppTheme.lg),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        child: isCurrentPlan
                            ? OutlinedButton(
                                onPressed: () {},
                                child: const Text('Current Plan'),
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                ),
                                onPressed: () {
                                  setState(() => _currentPlan = planId);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Upgraded to ${plan.name}!',
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  plan.price == 0
                                      ? 'Choose Free'
                                      : 'Upgrade Now',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: AppTheme.xl),

            // Billing Info
            Text(
              'Billing Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Billing Cycle',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'Monthly',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: AppTheme.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Next Renewal',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'Dec 14, 2025',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: AppTheme.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payment Method',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.credit_card,
                            size: 18,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: AppTheme.sm),
                          Text(
                            'Visa •••• 4242',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.lg),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: Navigate to edit payment method
                      },
                      child: const Text('Update Payment Method'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.lg),
          ],
        ),
      ),
    );
  }
}
