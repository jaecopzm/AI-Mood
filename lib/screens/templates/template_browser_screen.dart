import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/premium_theme.dart';
import '../../models/template_model.dart';
import '../../models/subscription_model.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/analytics_service.dart';
import '../../core/di/service_locator.dart';
import '../subscription/paywall_screen.dart';

/// Template browser screen
class TemplateBrowserScreen extends ConsumerStatefulWidget {
  const TemplateBrowserScreen({super.key});

  @override
  ConsumerState<TemplateBrowserScreen> createState() =>
      _TemplateBrowserScreenState();
}

class _TemplateBrowserScreenState extends ConsumerState<TemplateBrowserScreen> {
  String _selectedCategory = 'All';
  late AnalyticsService _analytics;

  @override
  void initState() {
    super.initState();
    _analytics = getIt<AnalyticsService>();

    // Track screen view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authStateProvider);
      if (authState.user != null) {
        _analytics.trackScreenView(authState.user!.uid, 'template_browser');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionProvider);
    final isPremium = subscriptionState.currentTier == SubscriptionTier.premium;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Templates'),
        elevation: 0,
        backgroundColor: PremiumTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              _showTemplateInfo(context);
            },
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter
          _buildCategoryFilter(),

          // Templates grid
          Expanded(child: _buildTemplatesGrid(isPremium)),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['All', ...TemplateCategory.all];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: PremiumTheme.spaceSm),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: PremiumTheme.spaceMd),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: PremiumTheme.spaceSm),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedCategory = category);
              },
              selectedColor: PremiumTheme.primary.withValues(alpha: 0.2),
              checkmarkColor: PremiumTheme.primary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTemplatesGrid(bool isPremium) {
    final templates = _selectedCategory == 'All'
        ? PremiumTemplates.templates
        : PremiumTemplates.getByCategory(_selectedCategory);

    if (templates.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(PremiumTheme.spaceMd),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: PremiumTheme.spaceMd,
        mainAxisSpacing: PremiumTheme.spaceMd,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        return _buildTemplateCard(templates[index], isPremium);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 64,
            color: PremiumTheme.textSecondary,
          ),
          const SizedBox(height: PremiumTheme.spaceMd),
          Text(
            'No templates found',
            style: PremiumTheme.titleMedium.copyWith(
              color: PremiumTheme.textSecondary,
            ),
          ),
          const SizedBox(height: PremiumTheme.spaceXs),
          Text(
            'Try selecting a different category',
            style: PremiumTheme.bodyMedium.copyWith(
              color: PremiumTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(MessageTemplate template, bool isPremium) {
    final isLocked = template.isPremium && !isPremium;

    return GestureDetector(
      onTap: () => _handleTemplateSelect(template, isLocked),
      child: Container(
        decoration: BoxDecoration(
          color: PremiumTheme.surface,
          borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
          border: Border.all(color: PremiumTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Content
            Padding(
              padding: const EdgeInsets.all(PremiumTheme.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PremiumTheme.spaceSm,
                      vertical: PremiumTheme.spaceXs,
                    ),
                    decoration: BoxDecoration(
                      color: PremiumTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        PremiumTheme.radiusSm,
                      ),
                    ),
                    child: Text(
                      template.category,
                      style: PremiumTheme.labelSmall.copyWith(
                        color: PremiumTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: PremiumTheme.spaceSm),

                  // Title
                  Text(
                    template.name,
                    style: PremiumTheme.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: PremiumTheme.spaceXs),

                  // Description
                  Text(
                    template.description,
                    style: PremiumTheme.bodySmall.copyWith(
                      color: PremiumTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),

                  // Rating and premium badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: PremiumTheme.gold,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            template.rating.toString(),
                            style: PremiumTheme.labelSmall,
                          ),
                        ],
                      ),
                      if (template.isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: PremiumTheme.gold,
                            borderRadius: BorderRadius.circular(
                              PremiumTheme.radiusSm,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.diamond,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Premium',
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
                ],
              ),
            ),

            // Premium lock overlay
            if (isLocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock, color: Colors.white, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'Premium Only',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Tap to unlock',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
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

  void _handleTemplateSelect(MessageTemplate template, bool isLocked) async {
    final authState = ref.read(authStateProvider);
    final userId = authState.user?.uid;

    if (isLocked) {
      // Track premium template attempt
      if (userId != null) {
        await _analytics.trackPaywallShown(
          userId,
          trigger: 'premium_template',
          highlightedTier: 'premium',
        );
      }

      // Show paywall
      if (!mounted) return;
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PaywallScreen(highlightTier: 'premium'),
          fullscreenDialog: true,
        ),
      );

      // If user subscribed, they can now use the template
      if (result == true) {
        _useTemplate(template);
      }
    } else {
      _useTemplate(template);
    }
  }

  void _useTemplate(MessageTemplate template) async {
    final authState = ref.read(authStateProvider);
    final userId = authState.user?.uid;

    // Track template usage
    if (userId != null) {
      await _analytics.trackTemplateUsed(
        userId,
        templateId: template.id,
        isPremium: template.isPremium,
      );
    }

    // Return template to previous screen
    if (mounted) {
      Navigator.pop(context, template);
    }
  }

  void _showTemplateInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Templates'),
        content: const Text(
          'Templates are pre-written messages for different occasions. Premium templates offer more sophisticated and personalized content.\n\nFree users get access to basic templates, while Premium subscribers unlock all high-quality templates.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
