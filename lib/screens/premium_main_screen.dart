import 'package:flutter/material.dart';
import '../config/premium_theme.dart';
import 'home/main_home_screen.dart';
import 'history/premium_history_screen.dart';
import 'subscription/premium_subscription_screen.dart';
import 'profile/premium_profile_screen.dart';

class PremiumMainScreen extends StatefulWidget {
  const PremiumMainScreen({super.key});

  @override
  State<PremiumMainScreen> createState() => _PremiumMainScreenState();
}

class _PremiumMainScreenState extends State<PremiumMainScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fabAnimationController;

  final List<Widget> _screens = const [
    MainHomeScreen(),
    PremiumHistoryScreen(),
    PremiumSubscriptionScreen(),
    PremiumProfileScreen(),
  ];

  final List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.home_rounded,
      label: 'Home',
      gradient: PremiumTheme.primaryGradient,
    ),
    _NavItem(
      icon: Icons.history_rounded,
      label: 'History',
      gradient: PremiumTheme.accentGradient,
    ),
    _NavItem(
      icon: Icons.diamond_rounded,
      label: 'Premium',
      gradient: PremiumTheme.goldGradient,
    ),
    _NavItem(
      icon: Icons.person_rounded,
      label: 'Profile',
      gradient: PremiumTheme.secondaryGradient,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: PremiumTheme.animationNormal,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: PremiumTheme.animationNormal,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: _currentIndex == 0 ? _buildFAB() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.all(PremiumTheme.spaceMd),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PremiumTheme.radiusXl),
        boxShadow: [
          PremiumTheme.shadow2xl,
          BoxShadow(
            color: PremiumTheme.primary.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PremiumTheme.radiusXl),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                PremiumTheme.surface,
                PremiumTheme.surface.withValues(alpha: 0.95),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(
              color: PremiumTheme.border.withValues(alpha: 0.5),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(PremiumTheme.radiusXl),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: PremiumTheme.spaceSm,
                vertical: PremiumTheme.spaceXs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_navItems.length, (index) {
                  return _buildNavItem(index);
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navItems[index];
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onNavTap(index),
      child: AnimatedContainer(
        duration: PremiumTheme.animationNormal,
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? PremiumTheme.spaceMd : PremiumTheme.spaceSm,
          vertical: PremiumTheme.spaceSm,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? item.gradient : null,
          borderRadius: BorderRadius.circular(PremiumTheme.radiusLg),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _getGradientColor(item.gradient).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: isSelected ? Colors.white : PremiumTheme.textTertiary,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: PremiumTheme.spaceXs),
              Text(
                item.label,
                style: PremiumTheme.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Transform.rotate(
            angle: value * 2 * 3.14159,
            child: child,
          ),
        );
      },
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: PremiumTheme.premiumGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: PremiumTheme.primary.withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
            PremiumTheme.shadow2xl,
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _showQuickActions,
            customBorder: const CircleBorder(),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  Color _getGradientColor(Gradient gradient) {
    if (gradient == PremiumTheme.primaryGradient) return PremiumTheme.primary;
    if (gradient == PremiumTheme.secondaryGradient) return PremiumTheme.secondary;
    if (gradient == PremiumTheme.accentGradient) return PremiumTheme.accent;
    if (gradient == PremiumTheme.goldGradient) return PremiumTheme.gold;
    return PremiumTheme.primary;
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: PremiumTheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(PremiumTheme.radiusXl),
            topRight: Radius.circular(PremiumTheme.radiusXl),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PremiumTheme.spaceLg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          PremiumTheme.premiumGradient.createShader(bounds),
                      child: const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: PremiumTheme.spaceLg),
                    _buildQuickActionItem(
                      Icons.favorite,
                      'Love Message',
                      'Send a romantic message',
                      PremiumTheme.secondaryGradient,
                    ),
                    _buildQuickActionItem(
                      Icons.business,
                      'Professional',
                      'Write a work email',
                      PremiumTheme.oceanGradient,
                    ),
                    _buildQuickActionItem(
                      Icons.celebration,
                      'Congratulations',
                      'Celebrate a success',
                      PremiumTheme.goldGradient,
                    ),
                    _buildQuickActionItem(
                      Icons.psychology,
                      'Apology',
                      'Make amends',
                      PremiumTheme.accentGradient,
                    ),
                    const SizedBox(height: PremiumTheme.spaceLg),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(
    IconData icon,
    String title,
    String subtitle,
    Gradient gradient,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: PremiumTheme.spaceSm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            // Handle quick action
          },
          borderRadius: BorderRadius.circular(PremiumTheme.radiusLg),
          child: Container(
            padding: const EdgeInsets.all(PremiumTheme.spaceMd),
            decoration: BoxDecoration(
              color: PremiumTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(PremiumTheme.radiusLg),
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
                      Text(
                        subtitle,
                        style: PremiumTheme.bodySmall.copyWith(
                          color: PremiumTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: PremiumTheme.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final Gradient gradient;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.gradient,
  });
}
