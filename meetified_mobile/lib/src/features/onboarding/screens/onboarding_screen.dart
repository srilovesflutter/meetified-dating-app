import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/local_storage_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'AI-Powered Profile Building',
      description: 'Our AI assistant helps you create an authentic profile through natural conversation. No boring forms, just chat!',
      icon: Icons.psychology,
      color: Colors.purple,
    ),
    OnboardingPage(
      title: 'Smart Compatibility Matching',
      description: 'Advanced algorithms analyze both what you say and how you say it to find truly compatible matches.',
      icon: Icons.favorite,
      color: Colors.pink,
    ),
    OnboardingPage(
      title: 'Anonymous Chat First',
      description: 'Get to know each other through anonymous conversations. Reveal identities only when you\'re both ready.',
      icon: Icons.chat_bubble,
      color: Colors.blue,
    ),
    OnboardingPage(
      title: 'Question Exchange System',
      description: 'Ask questions through our AI to learn more about potential matches before making decisions.',
      icon: Icons.help_outline,
      color: Colors.green,
    ),
    OnboardingPage(
      title: 'Premium Identity Reveal',
      description: 'Upgrade to premium for instant identity reveals and enhanced matching features.',
      icon: Icons.star,
      color: Colors.amber,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.normalAnimation,
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: AppConstants.normalAnimation,
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _completeOnboarding() async {
    await LocalStorageService.setOnboardingCompleted(true);
    if (mounted) {
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with skip button
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary,
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.favorite,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppConstants.appName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  // Skip button
                  TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      'Skip',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_pages[index], theme, size);
                },
              ),
            ),

            // Bottom section
            Padding(
              padding: const EdgeInsets.all(AppConstants.largePadding),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _buildPageIndicator(index, theme),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Navigation buttons
                  Row(
                    children: [
                      // Previous button
                      if (_currentPage > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _previousPage,
                            child: const Text('Previous'),
                          ),
                        ),
                      
                      if (_currentPage > 0) const SizedBox(width: 16),

                      // Next/Get Started button
                      Expanded(
                        flex: _currentPage == 0 ? 1 : 1,
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          child: Text(
                            _currentPage == _pages.length - 1 
                                ? 'Get Started' 
                                : 'Next',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page, ThemeData theme, Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.largePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              page.icon,
              size: 60,
              color: page.color,
            ),
          ),

          const SizedBox(height: 48),

          // Title
          Text(
            page.title,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Description
          Text(
            page.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index, ThemeData theme) {
    final isActive = index == _currentPage;
    
    return AnimatedContainer(
      duration: AppConstants.fastAnimation,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive 
            ? theme.colorScheme.primary 
            : theme.colorScheme.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}