import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/premium_theme.dart';
import '../../widgets/premium_widgets.dart';
import '../../providers/auth_provider.dart';
import '../../providers/message_provider.dart';

class PremiumProfileScreen extends ConsumerStatefulWidget {
  const PremiumProfileScreen({super.key});

  @override
  ConsumerState<PremiumProfileScreen> createState() =>
      _PremiumProfileScreenState();
}

class _PremiumProfileScreenState extends ConsumerState<PremiumProfileScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final messageState = ref.watch(messageProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              PremiumTheme.background,
              PremiumTheme.accentLight.withOpacity(0.05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Profile Header
              SliverToBoxAdapter(child: _buildProfileHeader(authState)),

              // Stats Overview
              SliverToBoxAdapter(child: _buildStatsOverview(messageState)),

              // Subscription Status
              SliverToBoxAdapter(child: _buildSubscriptionStatus()),

              // Usage Analytics
              SliverToBoxAdapter(child: _buildUsageAnalytics()),

              // Settings
              SliverToBoxAdapter(child: _buildSettings()),

              // Account Actions
              SliverToBoxAdapter(child: _buildAccountActions()),

              const SliverToBoxAdapter(
                child: SizedBox(height: PremiumTheme.space4xl),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic authState) {
    return Padding(
      padding: const EdgeInsets.all(PremiumTheme.spaceLg),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Animated gradient background
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: PremiumTheme.premiumGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: PremiumTheme.primary.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
              // Avatar
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: PremiumTheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: ClipOval(
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: PremiumTheme.primary,
                  ),
                ),
              ),
              // Edit button
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(PremiumTheme.spaceXs),
                  decoration: BoxDecoration(
                    gradient: PremiumTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [PremiumTheme.shadowMd],
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: PremiumTheme.spaceMd),
          Text(
            authState.user?.displayName ?? 'John Doe',
            style: PremiumTheme.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PremiumTheme.spaceXs),
          Text(
            authState.user?.email ?? 'john.doe@example.com',
            style: PremiumTheme.bodyMedium.copyWith(
              color: PremiumTheme.textSecondary,
            ),
          ),
          const SizedBox(height: PremiumTheme.spaceSm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PremiumTheme.spaceMd,
              vertical: PremiumTheme.spaceXs,
            ),
            decoration: BoxDecoration(
              gradient: PremiumTheme.goldGradient,
              borderRadius: BorderRadius.circular(PremiumTheme.radiusFull),
              boxShadow: [PremiumTheme.shadowGold],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.diamond, color: Colors.white, size: 16),
                const SizedBox(width: PremiumTheme.spaceXs),
                Text(
                  'Premium Member',
                  style: PremiumTheme.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(dynamic messageState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PremiumTheme.spaceLg),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              '${messageState.history.length}',
              'Messages',
              Icons.message,
              PremiumTheme.primaryGradient,
            ),
          ),
          const SizedBox(width: PremiumTheme.spaceMd),
          Expanded(
            child: _buildStatCard(
              '${messageState.history.where((m) => m.isSaved).length}',
              'Saved',
              Icons.bookmark,
              PremiumTheme.secondaryGradient,
            ),
          ),
          const SizedBox(width: PremiumTheme.spaceMd),
          Expanded(
            child: _buildStatCard(
              '12',
              'Shared',
              Icons.share,
              PremiumTheme.accentGradient,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Gradient gradient,
  ) {
    return Container(
      padding: const EdgeInsets.all(PremiumTheme.spaceMd),
      decoration: BoxDecoration(
        color: PremiumTheme.surface,
        borderRadius: BorderRadius.circular(PremiumTheme.radiusLg),
        boxShadow: [PremiumTheme.shadowMd],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(PremiumTheme.spaceSm),
            decoration: BoxDecoration(
              gradient: gradient,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: PremiumTheme.spaceSm),
          Text(
            value,
            style: PremiumTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: PremiumTheme.bodySmall.copyWith(
              color: PremiumTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionStatus() {
    return Padding(
      padding: const EdgeInsets.all(PremiumTheme.spaceLg),
      child: PremiumCard(
        gradient: PremiumTheme.diamondGradient,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(PremiumTheme.spaceSm),
                  decoration: BoxDecoration(
                    gradient: PremiumTheme.goldGradient,
                    borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
                  ),
                  child: const Icon(
                    Icons.diamond,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: PremiumTheme.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Premium Plan',
                        style: PremiumTheme.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Unlimited access',
                        style: PremiumTheme.bodySmall.copyWith(
                          color: PremiumTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$9.99/mo',
                  style: PremiumTheme.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: PremiumTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: PremiumTheme.spaceLg),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Billing',
                        style: PremiumTheme.bodySmall.copyWith(
                          color: PremiumTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: PremiumTheme.spaceXs),
                      Text(
                        'Jan 15, 2024',
                        style: PremiumTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                PremiumButton(
                  text: 'Manage',
                  icon: Icons.settings,
                  gradient: PremiumTheme.primaryGradient,
                  isFullWidth: false,
                  padding: const EdgeInsets.symmetric(
                    horizontal: PremiumTheme.spaceMd,
                    vertical: PremiumTheme.spaceSm,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageAnalytics() {
    return Padding(
      padding: const EdgeInsets.all(PremiumTheme.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Usage This Month',
            style: PremiumTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PremiumTheme.spaceMd),
          Container(
            padding: const EdgeInsets.all(PremiumTheme.spaceLg),
            decoration: BoxDecoration(
              color: PremiumTheme.surface,
              borderRadius: BorderRadius.circular(PremiumTheme.radiusLg),
              boxShadow: [PremiumTheme.shadowMd],
            ),
            child: Column(
              children: [
                _buildUsageItem(
                  'Messages Generated',
                  47,
                  100,
                  PremiumTheme.primaryGradient,
                ),
                const SizedBox(height: PremiumTheme.spaceMd),
                _buildUsageItem(
                  'Favorite Tone',
                  0.75,
                  1,
                  PremiumTheme.secondaryGradient,
                  label: 'Romantic (75%)',
                ),
                const SizedBox(height: PremiumTheme.spaceMd),
                _buildUsageItem(
                  'Most Used Recipient',
                  0.6,
                  1,
                  PremiumTheme.accentGradient,
                  label: 'Crush (60%)',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageItem(
    String title,
    double value,
    double max,
    Gradient gradient, {
    String? label,
  }) {
    final progress = value / max;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: PremiumTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label ?? '${value.toInt()}/${max.toInt()}',
              style: PremiumTheme.bodySmall.copyWith(
                color: PremiumTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: PremiumTheme.spaceXs),
        PremiumProgressBar(progress: progress, gradient: gradient),
      ],
    );
  }

  Widget _buildSettings() {
    return Padding(
      padding: const EdgeInsets.all(PremiumTheme.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: PremiumTheme.headlineSmall.copyWith(
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
                _buildSettingItem(
                  Icons.dark_mode,
                  'Dark Mode',
                  'Toggle dark theme',
                  trailing: Switch(
                    value: _isDarkMode,
                    onChanged: (value) {
                      setState(() => _isDarkMode = value);
                    },
                    activeThumbColor: PremiumTheme.primary,
                  ),
                ),
                _buildDivider(),
                _buildSettingItem(
                  Icons.notifications,
                  'Notifications',
                  'Push notifications',
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() => _notificationsEnabled = value);
                    },
                    activeThumbColor: PremiumTheme.primary,
                  ),
                ),
                _buildDivider(),
                _buildSettingItem(
                  Icons.language,
                  'Language',
                  'English',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingItem(
                  Icons.security,
                  'Privacy & Security',
                  'Manage your data',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingItem(
                  Icons.help,
                  'Help & Support',
                  'FAQs and contact',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    String subtitle, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(PremiumTheme.spaceSm),
        decoration: BoxDecoration(
          gradient: PremiumTheme.primaryGradient,
          borderRadius: BorderRadius.circular(PremiumTheme.radiusSm),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: PremiumTheme.titleMedium.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: PremiumTheme.bodySmall.copyWith(
          color: PremiumTheme.textSecondary,
        ),
      ),
      trailing:
          trailing ??
          const Icon(Icons.chevron_right, color: PremiumTheme.textTertiary),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: PremiumTheme.border,
      indent: PremiumTheme.spaceMd,
      endIndent: PremiumTheme.spaceMd,
    );
  }

  Widget _buildAccountActions() {
    return Padding(
      padding: const EdgeInsets.all(PremiumTheme.spaceLg),
      child: Column(
        children: [
          PremiumButton(
            text: 'Edit Profile',
            icon: Icons.edit,
            gradient: PremiumTheme.primaryGradient,
            onPressed: () {},
          ),
          const SizedBox(height: PremiumTheme.spaceSm),
          PremiumButton(
            text: 'Share App',
            icon: Icons.share,
            gradient: PremiumTheme.accentGradient,
            onPressed: () {},
          ),
          const SizedBox(height: PremiumTheme.spaceSm),
          TextButton(
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
            },
            child: Text(
              'Sign Out',
              style: PremiumTheme.labelLarge.copyWith(
                color: PremiumTheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
