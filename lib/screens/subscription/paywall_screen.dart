import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../config/premium_theme.dart';
import '../../models/subscription_model.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/auth_provider.dart';

/// Paywall screen for subscription selection
class PaywallScreen extends ConsumerStatefulWidget {
  final bool showCloseButton;
  final String? highlightTier; // 'pro' or 'premium'

  const PaywallScreen({
    super.key,
    this.showCloseButton = true,
    this.highlightTier,
  });

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen>
    with SingleTickerProviderStateMixin {
  bool _isAnnual = false;
  String _selectedTier = 'pro';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _selectedTier = widget.highlightTier ?? 'pro';
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    // Load offerings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subscriptionProvider.notifier).loadOfferings();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionProvider);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              PremiumTheme.primary,
              PremiumTheme.secondary,
              PremiumTheme.accent,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Content
              Expanded(
                child: subscriptionState.isLoading
                    ? _buildLoading()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(PremiumTheme.spaceLg),
                        child: Column(
                          children: [
                            _buildBillingToggle(),
                            const SizedBox(height: PremiumTheme.spaceLg),
                            _buildPlanCards(),
                            const SizedBox(height: PremiumTheme.spaceLg),
                            _buildFeatureComparison(),
                            const SizedBox(height: PremiumTheme.spaceLg),
                            _buildContinueButton(authState.user?.uid),
                            const SizedBox(height: PremiumTheme.spaceMd),
                            _buildRestoreButton(authState.user?.uid),
                            const SizedBox(height: PremiumTheme.spaceLg),
                            _buildFooter(),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(PremiumTheme.spaceMd),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.showCloseButton)
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white),
            )
          else
            const SizedBox(width: 48),
          Expanded(
            child: Column(
              children: [
                const Icon(Icons.diamond, color: Colors.white, size: 48),
                const SizedBox(height: PremiumTheme.spaceXs),
                Text(
                  'Upgrade to Premium',
                  style: PremiumTheme.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Unlock unlimited messages & features',
                  style: PremiumTheme.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildBillingToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(PremiumTheme.radiusFull),
      ),
      child: Row(
        children: [
          Expanded(child: _buildToggleButton('Monthly', !_isAnnual)),
          Expanded(child: _buildToggleButton('Annual (Save 20%)', _isAnnual)),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _isAnnual = !_isAnnual),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: PremiumTheme.spaceSm),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(PremiumTheme.radiusFull),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: PremiumTheme.labelMedium.copyWith(
            color: isSelected ? PremiumTheme.primary : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCards() {
    return Row(
      children: [
        Expanded(
          child: _buildPlanCard(
            tier: 'pro',
            plan: SubscriptionPlan.pro,
            badge: 'Most Popular',
            badgeColor: PremiumTheme.accent,
          ),
        ),
        const SizedBox(width: PremiumTheme.spaceMd),
        Expanded(
          child: _buildPlanCard(
            tier: 'premium',
            plan: SubscriptionPlan.premium,
            badge: 'Best Value',
            badgeColor: PremiumTheme.gold,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required String tier,
    required SubscriptionPlan plan,
    required String badge,
    required Color badgeColor,
  }) {
    final isSelected = _selectedTier == tier;
    final price = _isAnnual ? plan.annualPrice : plan.monthlyPrice;
    final period = _isAnnual ? 'year' : 'month';

    return GestureDetector(
      onTap: () => setState(() => _selectedTier = tier),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(PremiumTheme.spaceMd),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(PremiumTheme.radiusLg),
          border: Border.all(
            color: isSelected ? badgeColor : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: badgeColor.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Column(
          children: [
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: PremiumTheme.spaceSm,
                vertical: PremiumTheme.spaceXs,
              ),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(PremiumTheme.radiusFull),
              ),
              child: Text(
                badge,
                style: PremiumTheme.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: PremiumTheme.spaceSm),

            // Plan name
            Text(
              plan.name,
              style: PremiumTheme.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: PremiumTheme.spaceXs),

            // Price
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$',
                  style: PremiumTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  price.toStringAsFixed(2),
                  style: PremiumTheme.displaySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: PremiumTheme.primary,
                  ),
                ),
              ],
            ),
            Text(
              'per $period',
              style: PremiumTheme.bodySmall.copyWith(
                color: PremiumTheme.textSecondary,
              ),
            ),

            // Message limit
            const SizedBox(height: PremiumTheme.spaceSm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: PremiumTheme.spaceSm,
                vertical: PremiumTheme.spaceXs,
              ),
              decoration: BoxDecoration(
                color: PremiumTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(PremiumTheme.radiusSm),
              ),
              child: Text(
                plan.messageLimit == -1
                    ? 'Unlimited messages'
                    : '${plan.messageLimit} messages/month',
                style: PremiumTheme.labelSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Selection indicator
            const SizedBox(height: PremiumTheme.spaceSm),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? badgeColor : PremiumTheme.border,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureComparison() {
    final selectedPlan = _selectedTier == 'pro'
        ? SubscriptionPlan.pro
        : SubscriptionPlan.premium;

    return Container(
      padding: const EdgeInsets.all(PremiumTheme.spaceLg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(PremiumTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s Included',
            style: PremiumTheme.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PremiumTheme.spaceMd),
          ...selectedPlan.features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: PremiumTheme.spaceSm),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: PremiumTheme.success,
                    size: 20,
                  ),
                  const SizedBox(width: PremiumTheme.spaceSm),
                  Expanded(
                    child: Text(feature, style: PremiumTheme.bodyMedium),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(String? userId) {
    final subscriptionState = ref.watch(subscriptionProvider);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: subscriptionState.isLoading || userId == null
            ? null
            : () => _handlePurchase(userId),
        style: ElevatedButton.styleFrom(
          backgroundColor: PremiumTheme.gold,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
          ),
          elevation: 8,
        ),
        child: subscriptionState.isLoading
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
                  const Icon(Icons.diamond),
                  const SizedBox(width: PremiumTheme.spaceSm),
                  Text(
                    'Continue with ${_selectedTier == 'pro' ? 'Pro' : 'Premium'}',
                    style: PremiumTheme.labelLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildRestoreButton(String? userId) {
    return TextButton(
      onPressed: userId == null ? null : () => _handleRestore(userId),
      child: Text(
        'Restore Purchases',
        style: PremiumTheme.labelMedium.copyWith(
          color: Colors.white,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Cancel anytime • Secure payment',
          style: PremiumTheme.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: PremiumTheme.spaceXs),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // TODO: Show terms of service
              },
              child: Text(
                'Terms',
                style: PremiumTheme.labelSmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Text(
              ' • ',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
            ),
            TextButton(
              onPressed: () {
                // TODO: Show privacy policy
              },
              child: Text(
                'Privacy',
                style: PremiumTheme.labelSmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  Future<void> _handlePurchase(String userId) async {
    try {
      final subscriptionState = ref.read(subscriptionProvider);
      final offerings = subscriptionState.offerings;

      if (offerings == null || offerings.current == null) {
        _showError('No subscription packages available');
        return;
      }

      // Get the selected package
      Package? package;
      final packages = offerings.current!.availablePackages;

      if (_selectedTier == 'pro') {
        package = packages.firstWhere(
          (p) => p.identifier == (_isAnnual ? 'pro_annual' : 'pro_monthly'),
          orElse: () => packages.first,
        );
      } else {
        package = packages.firstWhere(
          (p) =>
              p.identifier ==
              (_isAnnual ? 'premium_annual' : 'premium_monthly'),
          orElse: () => packages.first,
        );
      }

      // Purchase
      final success = await ref
          .read(subscriptionProvider.notifier)
          .purchaseSubscription(package, userId);

      if (success && mounted) {
        // Show success and close
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🎉 Subscription activated!'),
            backgroundColor: PremiumTheme.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showError('Purchase failed: $e');
    }
  }

  Future<void> _handleRestore(String userId) async {
    try {
      final success = await ref
          .read(subscriptionProvider.notifier)
          .restorePurchases(userId);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✅ Purchases restored!'),
              backgroundColor: PremiumTheme.success,
            ),
          );
          Navigator.pop(context, true);
        } else {
          _showError('No purchases found to restore');
        }
      }
    } catch (e) {
      _showError('Restore failed: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: PremiumTheme.error),
    );
  }
}
