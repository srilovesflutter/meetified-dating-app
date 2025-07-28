import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../../features/auth/screens/phone_auth_screen.dart';
import '../../features/auth/screens/verification_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/onboarding/screens/welcome_screen.dart';
import '../../features/profile/screens/profile_building_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/matching/screens/matching_screen.dart';
import '../../features/chat/screens/chat_list_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/payment/screens/premium_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/welcome',
    redirect: _redirect,
    routes: [
      // Welcome/Splash route
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),

      // Onboarding route
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Auth routes
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const PhoneAuthScreen(),
      ),
      
      GoRoute(
        path: '/verification',
        name: 'verification',
        builder: (context, state) {
          final phoneNumber = state.extra as String? ?? '';
          return VerificationScreen(phoneNumber: phoneNumber);
        },
      ),

      // Profile building route
      GoRoute(
        path: '/profile-building',
        name: 'profile-building',
        builder: (context, state) => const ProfileBuildingScreen(),
      ),

      // Main app shell with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          // Home tab
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),

          // Matching tab
          GoRoute(
            path: '/matching',
            name: 'matching',
            builder: (context, state) => const MatchingScreen(),
          ),

          // Chat tab
          GoRoute(
            path: '/chats',
            name: 'chats',
            builder: (context, state) => const ChatListScreen(),
          ),

          // Profile tab
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Chat screen (outside shell for full screen)
      GoRoute(
        path: '/chat/:chatId',
        name: 'chat',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          final matchId = state.extra as String? ?? '';
          return ChatScreen(chatId: chatId, matchId: matchId);
        },
      ),

      // Settings screen
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Premium screen
      GoRoute(
        path: '/premium',
        name: 'premium',
        builder: (context, state) => const PremiumScreen(),
      ),
    ],
  );

  static String? _redirect(BuildContext context, GoRouterState state) {
    final container = ProviderScope.containerOf(context);
    final authState = container.read(authStateProvider);
    
    return authState.when(
      data: (user) {
        final isOnWelcome = state.location == '/welcome';
        final isOnOnboarding = state.location == '/onboarding';
        final isOnAuth = state.location.startsWith('/auth') || state.location == '/verification';
        final isOnProfileBuilding = state.location == '/profile-building';

        // If user is not authenticated
        if (user == null) {
          if (isOnAuth || isOnWelcome || isOnOnboarding) {
            return null; // Stay on current auth-related screen
          }
          return '/welcome'; // Redirect to welcome
        }

        // If user is authenticated
        if (isOnWelcome || isOnAuth) {
          // Check if user has completed profile building
          // This would need to be checked from user profile data
          // For now, assume they need to complete profile building
          return '/profile-building';
        }

        if (isOnProfileBuilding) {
          // Check if profile building is complete
          // For now, assume it's complete and redirect to home
          return '/home';
        }

        return null; // No redirect needed
      },
      loading: () => null, // Stay on current screen while loading
      error: (_, __) => '/welcome', // Redirect to welcome on error
    );
  }
}

// Main shell widget with bottom navigation
class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Matches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).location;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/matching')) return 1;
    if (location.startsWith('/chats')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/home');
        break;
      case 1:
        GoRouter.of(context).go('/matching');
        break;
      case 2:
        GoRouter.of(context).go('/chats');
        break;
      case 3:
        GoRouter.of(context).go('/profile');
        break;
    }
  }
}

// Route names for easy access
class AppRoutes {
  static const String welcome = '/welcome';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String verification = '/verification';
  static const String profileBuilding = '/profile-building';
  static const String home = '/home';
  static const String matching = '/matching';
  static const String chats = '/chats';
  static const String chat = '/chat';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String premium = '/premium';
}