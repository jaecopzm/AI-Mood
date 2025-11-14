import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../widgets/app_widgets.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final ValueChanged<bool>? onThemeChanged;

  const ProfileScreen({super.key, required this.onLogout, this.onThemeChanged});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  final String _displayName = 'John Doe';
  final String _email = 'john@example.com';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.shadowMdList,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: AppTheme.md),
                  Text(
                    _displayName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppTheme.xs),
                  Text(_email, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: AppTheme.md),
                  AppBadge(
                    label: 'Pro Member',
                    backgroundColor: AppTheme.accentLight,
                    icon: Icons.verified,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.xxl),

            // Account Settings
            Text(
              'Account Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.md),
            AppCard(
              child: Column(
                children: [
                  _buildSettingItem(
                    context,
                    icon: Icons.person_outline,
                    label: 'Edit Profile',
                    onTap: () {
                      // TODO: Navigate to edit profile
                    },
                  ),
                  const Divider(height: AppTheme.lg),
                  _buildSettingItem(
                    context,
                    icon: Icons.lock_outline,
                    label: 'Change Password',
                    onTap: () {
                      // TODO: Navigate to change password
                    },
                  ),
                  const Divider(height: AppTheme.lg),
                  _buildSettingItem(
                    context,
                    icon: Icons.email_outlined,
                    label: 'Email Preferences',
                    onTap: () {
                      // TODO: Navigate to email preferences
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.xl),

            // Preferences
            Text('Preferences', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppTheme.md),
            AppCard(
              child: Column(
                children: [
                  _buildToggleItem(
                    context,
                    icon: Icons.notifications_outlined,
                    label: 'Push Notifications',
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() => _notificationsEnabled = value);
                    },
                  ),
                  const Divider(height: AppTheme.lg),
                  _buildToggleItem(
                    context,
                    icon: Icons.dark_mode_outlined,
                    label: 'Dark Mode',
                    value: _darkModeEnabled,
                    onChanged: (value) {
                      setState(() => _darkModeEnabled = value);
                      widget.onThemeChanged?.call(value);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.xl),

            // Advanced Features
            Text(
              'Advanced Features',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.md),
            AppCard(
              child: Column(
                children: [
                  _buildSettingItem(
                    context,
                    icon: Icons.analytics_outlined,
                    label: 'View Statistics',
                    onTap: () {
                      // TODO: Show analytics dashboard
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Analytics coming soon!')),
                      );
                    },
                  ),
                  const Divider(height: AppTheme.lg),
                  _buildSettingItem(
                    context,
                    icon: Icons.download_outlined,
                    label: 'Export Messages',
                    onTap: () {
                      // TODO: Export messages as CSV/PDF
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Export feature coming soon!'),
                        ),
                      );
                    },
                  ),
                  const Divider(height: AppTheme.lg),
                  _buildSettingItem(
                    context,
                    icon: Icons.backup_outlined,
                    label: 'Backup Data',
                    onTap: () {
                      // TODO: Backup user data
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Backup completed!')),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.xl),

            // Support & Legal
            Text(
              'Support & Legal',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.md),
            AppCard(
              child: Column(
                children: [
                  _buildSettingItem(
                    context,
                    icon: Icons.help_outline,
                    label: 'Help & Support',
                    onTap: () {
                      // TODO: Navigate to help
                    },
                  ),
                  const Divider(height: AppTheme.lg),
                  _buildSettingItem(
                    context,
                    icon: Icons.description_outlined,
                    label: 'Terms of Service',
                    onTap: () {
                      // TODO: Open terms URL
                    },
                  ),
                  const Divider(height: AppTheme.lg),
                  _buildSettingItem(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    label: 'Privacy Policy',
                    onTap: () {
                      // TODO: Open privacy URL
                    },
                  ),
                  const Divider(height: AppTheme.lg),
                  _buildSettingItem(
                    context,
                    icon: Icons.info_outline,
                    label: 'About AI Mood',
                    onTap: () {
                      showAboutDialog(context: context);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.xl),

            // Logout Button
            AppButton(
              label: 'Sign Out',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Sign Out?'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onLogout();
                        },
                        child: const Text(
                          'Sign Out',
                          style: TextStyle(color: AppTheme.error),
                        ),
                      ),
                    ],
                  ),
                );
              },
              backgroundColor: AppTheme.error.withValues(alpha: 0.1),
              textColor: AppTheme.error,
            ),

            const SizedBox(height: AppTheme.lg),

            // Delete Account
            AppOutlineButton(
              label: 'Delete Account',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Account?'),
                    content: const Text(
                      'This action cannot be undone. All your data will be permanently deleted.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Delete account
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: AppTheme.error),
                        ),
                      ),
                    ],
                  ),
                );
              },
              borderColor: AppTheme.error,
              textColor: AppTheme.error,
            ),

            const SizedBox(height: AppTheme.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 20),
          const SizedBox(width: AppTheme.md),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppTheme.textTertiary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 20),
        const SizedBox(width: AppTheme.md),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppTheme.primary,
        ),
      ],
    );
  }
}
