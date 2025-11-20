import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../config/premium_theme.dart';
import '../../config/app_config.dart';
import '../../models/onboarding_model.dart';
import '../auth/premium_signin_screen.dart';

/// Personalization screen for user preferences
class PersonalizationScreen extends ConsumerStatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  ConsumerState<PersonalizationScreen> createState() =>
      _PersonalizationScreenState();
}

class _PersonalizationScreenState extends ConsumerState<PersonalizationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTab = 0;
  final Set<String> _selectedRecipients = {};
  final Set<String> _selectedTones = {};
  bool _enableVoice = true;
  bool _enableNotifications = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentTab = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              Padding(
                padding: const EdgeInsets.all(PremiumTheme.spaceLg),
                child: Column(
                  children: [
                    const Text('🎨', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: PremiumTheme.spaceMd),
                    Text(
                      'Personalize Your Experience',
                      style: PremiumTheme.headlineMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: PremiumTheme.spaceXs),
                    Text(
                      'Help us tailor AI Mood to your needs',
                      style: PremiumTheme.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Tab bar
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: PremiumTheme.spaceLg,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(PremiumTheme.radiusFull),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      PremiumTheme.radiusFull,
                    ),
                  ),
                  labelColor: PremiumTheme.primary,
                  unselectedLabelColor: Colors.white,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Recipients'),
                    Tab(text: 'Tones'),
                    Tab(text: 'Features'),
                  ],
                ),
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRecipientsTab(),
                    _buildTonesTab(),
                    _buildFeaturesTab(),
                  ],
                ),
              ),

              // Navigation buttons
              Padding(
                padding: const EdgeInsets.all(PremiumTheme.spaceLg),
                child: _buildNavigationButtons(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipientsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PremiumTheme.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Who do you message most?',
            style: PremiumTheme.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PremiumTheme.spaceXs),
          Text(
            'Select all that apply',
            style: PremiumTheme.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: PremiumTheme.spaceLg),
          Wrap(
            spacing: PremiumTheme.spaceSm,
            runSpacing: PremiumTheme.spaceSm,
            children: AppConfig.recipientCategories.map((recipient) {
              final isSelected = _selectedRecipients.contains(recipient);
              return _buildSelectableChip(
                label: recipient,
                icon: _getRecipientIcon(recipient),
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedRecipients.remove(recipient);
                    } else {
                      _selectedRecipients.add(recipient);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTonesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PremiumTheme.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What tones do you prefer?',
            style: PremiumTheme.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PremiumTheme.spaceXs),
          Text(
            'Select your favorite styles',
            style: PremiumTheme.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: PremiumTheme.spaceLg),
          Wrap(
            spacing: PremiumTheme.spaceSm,
            runSpacing: PremiumTheme.spaceSm,
            children: AppConfig.availableTones.map((tone) {
              final isSelected = _selectedTones.contains(tone);
              return _buildSelectableChip(
                label: tone,
                icon: _getToneIcon(tone),
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedTones.remove(tone);
                    } else {
                      _selectedTones.add(tone);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PremiumTheme.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enable features',
            style: PremiumTheme.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PremiumTheme.spaceXs),
          Text(
            'You can change these later',
            style: PremiumTheme.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: PremiumTheme.spaceLg),
          _buildFeatureToggle(
            title: 'Voice Input & Output',
            description: 'Speak your messages and hear them read aloud',
            icon: Icons.mic,
            value: _enableVoice,
            onChanged: (value) => setState(() => _enableVoice = value),
          ),
          const SizedBox(height: PremiumTheme.spaceMd),
          _buildFeatureToggle(
            title: 'Notifications',
            description: 'Get reminders and tips',
            icon: Icons.notifications,
            value: _enableNotifications,
            onChanged: (value) => setState(() => _enableNotifications = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: PremiumTheme.spaceMd,
          vertical: PremiumTheme.spaceSm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(PremiumTheme.radiusFull),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? PremiumTheme.primary : Colors.white,
            ),
            const SizedBox(width: PremiumTheme.spaceXs),
            Text(
              label,
              style: PremiumTheme.labelMedium.copyWith(
                color: isSelected ? PremiumTheme.primary : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: PremiumTheme.spaceXs),
              Icon(Icons.check_circle, size: 16, color: PremiumTheme.primary),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureToggle({
    required String title,
    required String description,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(PremiumTheme.spaceMd),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(PremiumTheme.spaceSm),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(PremiumTheme.radiusSm),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: PremiumTheme.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PremiumTheme.titleSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: PremiumTheme.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: PremiumTheme.success,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentTab > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                _tabController.animateTo(_currentTab - 1);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 2),
                padding: const EdgeInsets.symmetric(
                  vertical: PremiumTheme.spaceMd,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
                ),
              ),
              child: const Text(
                'Back',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        if (_currentTab > 0) const SizedBox(width: PremiumTheme.spaceMd),
        Expanded(
          child: ElevatedButton(
            onPressed: _currentTab < 2
                ? () => _tabController.animateTo(_currentTab + 1)
                : _completePersonalization,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: PremiumTheme.primary,
              padding: const EdgeInsets.symmetric(
                vertical: PremiumTheme.spaceMd,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
              ),
              elevation: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentTab < 2 ? 'Next' : 'Complete',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _currentTab < 2 ? Icons.arrow_forward : Icons.check,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _completePersonalization() async {
    // Save preferences
    final preferences = OnboardingPreferences(
      favoriteRecipients: _selectedRecipients.toList(),
      favoriteTones: _selectedTones.toList(),
      enableVoice: _enableVoice,
      enableNotifications: _enableNotifications,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'onboarding_preferences',
      json.encode(preferences.toJson()),
    );

    if (mounted) {
      // Navigate to sign in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PremiumSignInScreen(
            onSignInSuccess: () {
              // Will be handled by main app
            },
            onNavigateToSignUp: () {
              // Will be handled by main app
            },
          ),
        ),
      );
    }
  }

  IconData _getRecipientIcon(String recipient) {
    switch (recipient.toLowerCase()) {
      case 'crush':
        return Icons.favorite_outline;
      case 'girlfriend/boyfriend':
        return Icons.favorite;
      case 'best friend':
        return Icons.person;
      case 'family':
        return Icons.family_restroom;
      case 'boss':
        return Icons.business;
      case 'colleague':
        return Icons.work;
      case 'parent':
        return Icons.family_restroom;
      case 'sibling':
        return Icons.people;
      default:
        return Icons.person_outline;
    }
  }

  IconData _getToneIcon(String tone) {
    switch (tone.toLowerCase()) {
      case 'romantic':
        return Icons.favorite;
      case 'funny':
        return Icons.emoji_emotions;
      case 'professional':
        return Icons.business_center;
      case 'apologetic':
        return Icons.healing;
      case 'grateful':
        return Icons.volunteer_activism;
      case 'casual':
        return Icons.chat;
      case 'mysterious':
        return Icons.psychology;
      case 'flirty':
        return Icons.sentiment_satisfied;
      case 'sincere':
        return Icons.favorite_border;
      case 'playful':
        return Icons.sports_esports;
      default:
        return Icons.message;
    }
  }
}
