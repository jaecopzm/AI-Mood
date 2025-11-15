import 'package:flutter/material.dart';
import '../../config/premium_theme.dart';
import '../../config/app_config.dart';
import '../../widgets/premium_widgets.dart';

class PremiumSubscriptionScreen extends StatefulWidget {
  const PremiumSubscriptionScreen({super.key});

  @override
  State<PremiumSubscriptionScreen> createState() =>
      _PremiumSubscriptionScreenState();
}

class _PremiumSubscriptionScreenState extends State<PremiumSubscriptionScreen>
    with SingleTickerProviderStateMixin {
  String _selectedTier = 'pro';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              PremiumTheme.background,
              PremiumTheme.primaryLight.withValues(alpha: 0.1),
              PremiumTheme.secondaryLight.withValues(alpha: 0.1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(child: _buildHeader()),

              // Feature Highlights
              SliverToBoxAdapter(child: _buildFeatureHighlights()),

              // Pricing Cards
              SliverToBoxAdapter(child: _buildPricingCards()),

              // Comparison Table
              SliverToBoxAdapter(child: _buildComparisonTable()),

              // CTA Button
              SliverToBoxAdapter(child: _buildCTAButton()),

              // FAQ
              SliverToBoxAdapter(child: _buildFAQ()),

              const SliverToBoxAdapter(
                child: SizedBox(height: PremiumTheme.space4xl),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(PremiumTheme.spaceLg),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_animationController.value * 0.1),
                child: Container(
                  padding: const EdgeInsets.all(PremiumTheme.spaceLg),
                  decoration: BoxDecoration(
                    gradient: PremiumTheme.premiumGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: PremiumTheme.primary.withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.diamond,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: PremiumTheme.spaceLg),
          ShaderMask(
            shaderCallback: (bounds) =>
                PremiumTheme.premiumGradient.createShader(bounds),
            child: const Text(
              'Unlock Premium',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: PremiumTheme.spaceSm),
          Text(
            'Unlimited AI-powered messages at your fingertips',
            style: PremiumTheme.bodyLarge.copyWith(
              color: PremiumTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureHighlights() {
    return Padding(
      padding: const EdgeInsets.all(PremiumTheme.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why Go Premium?',
            style: PremiumTheme.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PremiumTheme.spaceMd),
          _buildFeatureItem(
            Icons.all_inclusive,
            'Unlimited Messages',
            'Generate as many messages as you need',
            PremiumTheme.primaryGradient,
          ),
          const SizedBox(height: PremiumTheme.spaceSm),
          _buildFeatureItem(
            Icons.auto_awesome,
            'Advanced AI Models',
            'Access to the most powerful AI technology',
            PremiumTheme.secondaryGradient,
          ),
          const SizedBox(height: PremiumTheme.spaceSm),
          _buildFeatureItem(
            Icons.history,
            'Full History',
            'Never lose a great message again',
            PremiumTheme.accentGradient,
          ),
          const SizedBox(height: PremiumTheme.spaceSm),
          _buildFeatureItem(
            Icons.tune,
            'Custom Tones',
            'Create your own unique tone styles',
            PremiumTheme.goldGradient,
          ),
          const SizedBox(height: PremiumTheme.spaceSm),
          _buildFeatureItem(
            Icons.file_download,
            'Export & Share',
            'Download and share your messages',
            PremiumTheme.secondaryGradient,
          ),
          const SizedBox(height: PremiumTheme.spaceSm),
          _buildFeatureItem(
            Icons.support_agent,
            'Priority Support',
            '24/7 dedicated customer support',
            PremiumTheme.successGradient,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    IconData icon,
    String title,
    String description,
    Gradient gradient,
  ) {
    return Container(
      padding: const EdgeInsets.all(PremiumTheme.spaceMd),
      decoration: BoxDecoration(
        color: PremiumTheme.surface,
        borderRadius: BorderRadius.circular(PremiumTheme.radiusLg),
        boxShadow: [PremiumTheme.shadowSm],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(PremiumTheme.spaceSm),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: PremiumTheme.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PremiumTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: PremiumTheme.spaceXs),
                Text(
                  description,
                  style: PremiumTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCards() {
    return Padding(
      padding: const EdgeInsets.all(PremiumTheme.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Your Plan',
            style: PremiumTheme.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PremiumTheme.spaceMd),
          _buildPricingCard('free'),
          const SizedBox(height: PremiumTheme.spaceMd),
          _buildPricingCard('pro'),
          const SizedBox(height: PremiumTheme.spaceMd),
          _buildPricingCard('premium'),
        ],
      ),
    );
  }

  Widget _buildPricingCard(String tierId) {
    final tier = AppConfig.subscriptionTiers[tierId]!;
    final isSelected = _selectedTier == tierId;
    final isPremium = tierId == 'premium';
    final isPro = tierId == 'pro';

    Gradient gradient;
    if (isPremium) {
      gradient = PremiumTheme.diamondGradient;
    } else if (isPro) {
      gradient = PremiumTheme.goldGradient;
    } else {
      gradient = PremiumTheme.accentGradient;
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedTier = tierId),
      child: AnimatedContainer(
        duration: PremiumTheme.animationNormal,
        transform: Matrix4.identity()
          ..scale(isSelected ? 1.02 : 1.0),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(PremiumTheme.spaceLg),
              decoration: BoxDecoration(
                gradient: isSelected ? gradient : null,
                color: isSelected ? null : PremiumTheme.surface,
                borderRadius: BorderRadius.circular(PremiumTheme.radiusXl),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : PremiumTheme.border,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: isPremium
                              ? PremiumTheme.diamond.withValues(alpha: 0.3)
                              : isPro
                                  ? PremiumTheme.gold.withValues(alpha: 0.3)
                                  : PremiumTheme.accent.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ]
                    : [PremiumTheme.shadowSm],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  tier.name,
                                  style: PremiumTheme.headlineMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : PremiumTheme.textPrimary,
                                  ),
                                ),
                                if (isPremium) ...[
                                  const SizedBox(width: PremiumTheme.spaceXs),
                                  Icon(
                                    Icons.star,
                                    color: isSelected
                                        ? Colors.white
                                        : PremiumTheme.gold,
                                    size: 20,
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: PremiumTheme.spaceXs),
                            Text(
                              tier.monthlyCredits == -1
                                  ? 'Unlimited messages'
                                  : '${tier.monthlyCredits} messages/month',
                              style: PremiumTheme.bodySmall.copyWith(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.9)
                                    : PremiumTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (tier.price > 0) ...[
                            Text(
                              '\$${tier.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : PremiumTheme.textPrimary,
                              ),
                            ),
                            Text(
                              '/month',
                              style: PremiumTheme.bodySmall.copyWith(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.9)
                                    : PremiumTheme.textSecondary,
                              ),
                            ),
                          ] else ...[
                            Text(
                              'FREE',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : PremiumTheme.success,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: PremiumTheme.spaceLg),
                  ...tier.features.map((feature) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: PremiumTheme.spaceSm),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: isSelected
                                ? Colors.white
                                : PremiumTheme.success,
                            size: 20,
                          ),
                          const SizedBox(width: PremiumTheme.spaceSm),
                          Expanded(
                            child: Text(
                              feature,
                              style: PremiumTheme.bodyMedium.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : PremiumTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            if (isPremium)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PremiumTheme.spaceMd,
                    vertical: PremiumTheme.spaceXs,
                  ),
                  decoration: BoxDecoration(
                    color: PremiumTheme.gold,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(PremiumTheme.radiusXl),
                      bottomLeft: Radius.circular(PremiumTheme.radiusMd),
                    ),
                  ),
                  child: Text(
                    'BEST VALUE',
                    style: PremiumTheme.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (isPro && !isPremium)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PremiumTheme.spaceMd,
                    vertical: PremiumTheme.spaceXs,
                  ),
                  decoration: BoxDecoration(
                    color: PremiumTheme.secondary,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(PremiumTheme.radiusXl),
                      bottomLeft: Radius.circular(PremiumTheme.radiusMd),
                    ),
                  ),
                  child: Text(
                    'POPULAR',
                    style: PremiumTheme.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTable() {
    return Padding(
      padding: const EdgeInsets.all(PremiumTheme.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Feature Comparison',
            style: PremiumTheme.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PremiumTheme.spaceMd),
          Container(
            decoration: BoxDecoration(
              color: PremiumTheme.surface,
              borderRadius: BorderRadius.circular(PremiumTheme.radiusLg),
              boxShadow: [PremiumTheme.shadowMd],
            ),
            child: Column(
              children: [
                _buildComparisonRow(
                  'Monthly Messages',
                  '5',
                  '100',
                  'Unlimited',
                  isHeader: true,
                ),
                _buildComparisonRow('All Tones', false, true, true),
                _buildComparisonRow('Message History', false, true, true),
                _buildComparisonRow('Multiple Variations', false, true, true),
                _buildComparisonRow('Custom Tones', false, false, true),
                _buildComparisonRow('Export Messages', false, false, true),
                _buildComparisonRow('Priority Support', false, false, true),
                _buildComparisonRow('No Ads', false, true, true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(
    String feature,
    dynamic free,
    dynamic pro,
    dynamic premium, {
    bool isHeader = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(PremiumTheme.spaceMd),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: PremiumTheme.border,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: isHeader
                  ? PremiumTheme.titleMedium.copyWith(fontWeight: FontWeight.bold)
                  : PremiumTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: _buildComparisonCell(free),
          ),
          Expanded(
            child: _buildComparisonCell(pro),
          ),
          Expanded(
            child: _buildComparisonCell(premium),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCell(dynamic value) {
    if (value is bool) {
      return Icon(
        value ? Icons.check_circle : Icons.cancel,
        color: value ? PremiumTheme.success : PremiumTheme.error,
        size: 20,
      );
    }
    return Text(
      value.toString(),
      style: PremiumTheme.bodySmall.copyWith(
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCTAButton() {
    final tier = AppConfig.subscriptionTiers[_selectedTier]!;
    
    return Padding(
      padding: const EdgeInsets.all(PremiumTheme.spaceLg),
      child: Column(
        children: [
          PremiumButton(
            text: tier.price > 0
                ? 'Upgrade to ${tier.name} - \$${tier.price.toStringAsFixed(2)}/mo'
                : 'Continue with Free',
            icon: tier.price > 0 ? Icons.diamond : Icons.check,
            gradient: _selectedTier == 'premium'
                ? PremiumTheme.diamondGradient
                : _selectedTier == 'pro'
                    ? PremiumTheme.goldGradient
                    : PremiumTheme.successGradient,
            onPressed: () {
              // Handle subscription
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Upgrading to ${tier.name}...'),
                  backgroundColor: PremiumTheme.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(height: PremiumTheme.spaceSm),
          Text(
            'Cancel anytime • Secure payment • 7-day free trial',
            style: PremiumTheme.bodySmall.copyWith(
              color: PremiumTheme.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFAQ() {
    return Padding(
      padding: const EdgeInsets.all(PremiumTheme.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frequently Asked Questions',
            style: PremiumTheme.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PremiumTheme.spaceMd),
          _buildFAQItem(
            'Can I cancel anytime?',
            'Yes! You can cancel your subscription at any time. No questions asked.',
          ),
          _buildFAQItem(
            'What happens to my messages after canceling?',
            'Your message history is preserved and you can still view them, but you won\'t be able to generate new ones.',
          ),
          _buildFAQItem(
            'Is there a free trial?',
            'Yes! All paid plans come with a 7-day free trial. No credit card required.',
          ),
          _buildFAQItem(
            'How does the AI work?',
            'We use advanced AI models from Cloudflare to generate contextual, personalized messages based on your inputs.',
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: PremiumTheme.spaceMd),
      padding: const EdgeInsets.all(PremiumTheme.spaceMd),
      decoration: BoxDecoration(
        color: PremiumTheme.surface,
        borderRadius: BorderRadius.circular(PremiumTheme.radiusLg),
        boxShadow: [PremiumTheme.shadowSm],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: PremiumTheme.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PremiumTheme.spaceXs),
          Text(
            answer,
            style: PremiumTheme.bodyMedium.copyWith(
              color: PremiumTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
