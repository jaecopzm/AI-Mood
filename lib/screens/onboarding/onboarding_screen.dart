import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/premium_theme.dart';
import '../../models/onboarding_model.dart';
import 'personalization_screen.dart';

/// Main onboarding screen with page view
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<OnboardingPage> _pages = OnboardingData.pages;

  @override
  void dispose() {
    _pageController.dispose();
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
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    'Skip',
                    style: PremiumTheme.labelLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Page view
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),

              // Page indicator
              _buildPageIndicator(),

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

  Widget _buildPage(OnboardingPage page) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(PremiumTheme.spaceLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: PremiumTheme.spaceLg),

            // Icon
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Text(page.icon, style: const TextStyle(fontSize: 100)),
                );
              },
            ),

            const SizedBox(height: PremiumTheme.spaceLg),

            // Title
            Text(
              page.title,
              style: PremiumTheme.headlineMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: PremiumTheme.spaceMd),

            // Description
            Text(
              page.description,
              style: PremiumTheme.bodyLarge.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: PremiumTheme.spaceLg),

            // Features
            Container(
              padding: const EdgeInsets.all(PremiumTheme.spaceMd),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(PremiumTheme.radiusLg),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: page.features.map((feature) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: PremiumTheme.spaceXs,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: PremiumTheme.spaceSm),
                        Expanded(
                          child: Text(
                            feature,
                            style: PremiumTheme.bodyMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: PremiumTheme.spaceLg),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Colors.white
                : Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final isLastPage = _currentPage == _pages.length - 1;

    return Row(
      children: [
        // Back button
        if (_currentPage > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
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

        if (_currentPage > 0) const SizedBox(width: PremiumTheme.spaceMd),

        // Next/Get Started button
        Expanded(
          flex: _currentPage > 0 ? 1 : 1,
          child: ElevatedButton(
            onPressed: isLastPage ? _completeOnboarding : _nextPage,
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
                  isLastPage ? 'Get Started' : 'Next',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(isLastPage ? Icons.check : Icons.arrow_forward, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _skipOnboarding() async {
    await _markOnboardingComplete();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PersonalizationScreen()),
      );
    }
  }

  void _completeOnboarding() async {
    await _markOnboardingComplete();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PersonalizationScreen()),
      );
    }
  }

  Future<void> _markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
  }
}
