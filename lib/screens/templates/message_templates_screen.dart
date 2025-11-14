import 'package:flutter/material.dart';
import '../../config/premium_theme.dart';
import '../../widgets/premium_widgets.dart';

class MessageTemplatesScreen extends StatefulWidget {
  const MessageTemplatesScreen({super.key});

  @override
  State<MessageTemplatesScreen> createState() => _MessageTemplatesScreenState();
}

class _MessageTemplatesScreenState extends State<MessageTemplatesScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Romantic',
    'Professional',
    'Friendly',
    'Apologetic',
    'Grateful',
  ];

  final List<Map<String, dynamic>> _templates = [
    {
      'title': 'Morning Love',
      'description': 'Start the day with a sweet message',
      'category': 'Romantic',
      'preview': 'Good morning beautiful! Just wanted you to know...',
      'icon': Icons.wb_sunny,
      'gradient': PremiumTheme.secondaryGradient,
      'isPremium': false,
    },
    {
      'title': 'Meeting Request',
      'description': 'Professional meeting invitation',
      'category': 'Professional',
      'preview': 'I hope this message finds you well. I would like to...',
      'icon': Icons.business_center,
      'gradient': PremiumTheme.oceanGradient,
      'isPremium': false,
    },
    {
      'title': 'Heartfelt Apology',
      'description': 'Sincere apology message',
      'category': 'Apologetic',
      'preview': 'I am truly sorry for what happened. I never meant...',
      'icon': Icons.favorite_border,
      'gradient': PremiumTheme.primaryGradient,
      'isPremium': true,
    },
    {
      'title': 'Thank You Note',
      'description': 'Express gratitude professionally',
      'category': 'Grateful',
      'preview': 'Thank you so much for your support. It means...',
      'icon': Icons.card_giftcard,
      'gradient': PremiumTheme.goldGradient,
      'isPremium': false,
    },
    {
      'title': 'Date Invitation',
      'description': 'Ask someone out romantically',
      'category': 'Romantic',
      'preview': 'I\'ve been thinking... would you like to go out...',
      'icon': Icons.local_cafe,
      'gradient': PremiumTheme.secondaryGradient,
      'isPremium': true,
    },
    {
      'title': 'Follow Up Email',
      'description': 'Professional follow-up message',
      'category': 'Professional',
      'preview': 'Following up on our previous conversation...',
      'icon': Icons.email,
      'gradient': PremiumTheme.oceanGradient,
      'isPremium': true,
    },
    {
      'title': 'Weekend Plans',
      'description': 'Make plans with friends',
      'category': 'Friendly',
      'preview': 'Hey! What are you up to this weekend? Want to...',
      'icon': Icons.celebration,
      'gradient': PremiumTheme.accentGradient,
      'isPremium': false,
    },
    {
      'title': 'Birthday Wishes',
      'description': 'Celebrate someone\'s birthday',
      'category': 'Friendly',
      'preview': 'Happy Birthday! I hope your special day is filled...',
      'icon': Icons.cake,
      'gradient': PremiumTheme.goldGradient,
      'isPremium': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredTemplates {
    if (_selectedCategory == 'All') return _templates;
    return _templates
        .where((t) => t['category'] == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              PremiumTheme.background,
              PremiumTheme.accentLight.withValues(alpha: 0.05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildCategoryFilter(),
              Expanded(child: _buildTemplateGrid()),
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
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) =>
                      PremiumTheme.primaryGradient.createShader(bounds),
                  child: const Text(
                    'Templates',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  '${_filteredTemplates.length} templates available',
                  style: PremiumTheme.bodySmall.copyWith(
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
              Icons.add,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: PremiumTheme.spaceLg),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: PremiumTheme.spaceSm),
            child: PremiumChip(
              label: category,
              isSelected: _selectedCategory == category,
              onTap: () => setState(() => _selectedCategory = category),
              gradient: PremiumTheme.primaryGradient,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTemplateGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(PremiumTheme.spaceLg),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: PremiumTheme.spaceMd,
        crossAxisSpacing: PremiumTheme.spaceMd,
        childAspectRatio: 0.85,
      ),
      itemCount: _filteredTemplates.length,
      itemBuilder: (context, index) {
        return _buildTemplateCard(_filteredTemplates[index], index);
      },
    );
  }

  Widget _buildTemplateCard(Map<String, dynamic> template, int index) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => _showTemplateDetails(template),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: PremiumTheme.surface,
                borderRadius: BorderRadius.circular(PremiumTheme.radiusLg),
                boxShadow: [PremiumTheme.shadowMd],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: template['gradient'],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(PremiumTheme.radiusLg),
                        topRight: Radius.circular(PremiumTheme.radiusLg),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        template['icon'],
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(PremiumTheme.spaceMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template['title'],
                            style: PremiumTheme.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: PremiumTheme.spaceXs),
                          Text(
                            template['description'],
                            style: PremiumTheme.bodySmall.copyWith(
                              color: PremiumTheme.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: PremiumTheme.spaceSm,
                              vertical: PremiumTheme.spaceXs,
                            ),
                            decoration: BoxDecoration(
                              color: PremiumTheme.surfaceVariant,
                              borderRadius:
                                  BorderRadius.circular(PremiumTheme.radiusFull),
                            ),
                            child: Text(
                              template['category'],
                              style: PremiumTheme.labelSmall.copyWith(
                                color: PremiumTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (template['isPremium'])
              Positioned(
                top: PremiumTheme.spaceSm,
                right: PremiumTheme.spaceSm,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PremiumTheme.spaceXs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: PremiumTheme.goldGradient,
                    borderRadius:
                        BorderRadius.circular(PremiumTheme.radiusFull),
                    boxShadow: [PremiumTheme.shadowGold],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.diamond, color: Colors.white, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        'PRO',
                        style: PremiumTheme.labelSmall.copyWith(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
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

  void _showTemplateDetails(Map<String, dynamic> template) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
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
                    Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        gradient: template['gradient'],
                        borderRadius:
                            BorderRadius.circular(PremiumTheme.radiusLg),
                      ),
                      child: Center(
                        child: Icon(
                          template['icon'],
                          color: Colors.white,
                          size: 64,
                        ),
                      ),
                    ),
                    const SizedBox(height: PremiumTheme.spaceLg),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            template['title'],
                            style: PremiumTheme.headlineMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (template['isPremium'])
                          PremiumBadge(
                            text: 'PRO',
                            gradient: PremiumTheme.goldGradient,
                          ),
                      ],
                    ),
                    const SizedBox(height: PremiumTheme.spaceSm),
                    Text(
                      template['description'],
                      style: PremiumTheme.bodyMedium.copyWith(
                        color: PremiumTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: PremiumTheme.spaceLg),
                    Text(
                      'Preview',
                      style: PremiumTheme.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: PremiumTheme.spaceSm),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(PremiumTheme.spaceMd),
                      decoration: BoxDecoration(
                        color: PremiumTheme.surfaceVariant,
                        borderRadius:
                            BorderRadius.circular(PremiumTheme.radiusLg),
                        border: Border.all(
                          color: PremiumTheme.border,
                        ),
                      ),
                      child: Text(
                        template['preview'],
                        style: PremiumTheme.bodyMedium.copyWith(
                          height: 1.6,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: PremiumTheme.spaceLg),
                    Text(
                      'Category',
                      style: PremiumTheme.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: PremiumTheme.spaceSm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: PremiumTheme.spaceMd,
                        vertical: PremiumTheme.spaceSm,
                      ),
                      decoration: BoxDecoration(
                        gradient: template['gradient'],
                        borderRadius:
                            BorderRadius.circular(PremiumTheme.radiusFull),
                      ),
                      child: Text(
                        template['category'],
                        style: PremiumTheme.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: PremiumTheme.space2xl),
                    PremiumButton(
                      text: template['isPremium']
                          ? 'Use Template (Pro)'
                          : 'Use Template',
                      icon: Icons.edit,
                      gradient: template['gradient'],
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Using template: ${template['title']}'),
                            backgroundColor: PremiumTheme.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: PremiumTheme.spaceSm),
                    PremiumButton(
                      text: 'Customize',
                      icon: Icons.tune,
                      gradient: PremiumTheme.accentGradient,
                      onPressed: () {
                        Navigator.pop(context);
                      },
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
}
