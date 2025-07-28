import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            // Profile header
            _buildProfileHeader(theme),
            
            const SizedBox(height: 24),
            
            // Premium status
            _buildPremiumStatus(theme),
            
            const SizedBox(height: 24),
            
            // Profile sections
            _buildProfileSection(theme, 'About Me', Icons.person, [
              'Software Engineer at Google',
              'Love hiking and outdoor activities',
              'Coffee enthusiast ☕',
              'Looking for meaningful connections',
            ]),
            
            const SizedBox(height: 16),
            
            _buildProfileSection(theme, 'Interests', Icons.favorite, [
              'Hiking', 'Technology', 'Coffee', 'Travel', 'Photography'
            ]),
            
            const SizedBox(height: 16),
            
            _buildProfileSection(theme, 'Values', Icons.star, [
              'Honesty', 'Kindness', 'Adventure', 'Growth'
            ]),
            
            const SizedBox(height: 24),
            
            // Action buttons
            _buildActionButtons(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Column(
      children: [
        // Profile image
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(60),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.3),
              width: 3,
            ),
          ),
          child: Icon(
            Icons.person,
            size: 60,
            color: theme.colorScheme.primary.withOpacity(0.7),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Name and age
        Text(
          'John Doe, 28',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Location
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 4),
            Text(
              'San Francisco, CA',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Profile stats
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(theme, '24', 'Profile Views'),
            Container(
              width: 1,
              height: 30,
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
            _buildStatItem(theme, '12', 'Matches'),
            Container(
              width: 1,
              height: 30,
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
            _buildStatItem(theme, '94%', 'Avg Match Score'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(ThemeData theme, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumStatus(ThemeData theme) {
    final isPremium = false; // This would come from state

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPremium 
              ? [Colors.amber.shade400, Colors.orange.shade400]
              : [theme.colorScheme.primary, theme.colorScheme.secondary],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Row(
        children: [
          Icon(
            isPremium ? Icons.star : Icons.star_outline,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPremium ? 'Premium Member' : 'Upgrade to Premium',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isPremium 
                      ? 'Enjoy all premium features'
                      : 'Unlock instant identity reveals and more',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          if (!isPremium)
            ElevatedButton(
              onPressed: () => context.go('/premium'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Upgrade'),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(
    ThemeData theme,
    String title,
    IconData icon,
    List<String> items,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    // Edit section
                  },
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (title == 'About Me')
              ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  item,
                  style: theme.textTheme.bodyMedium,
                ),
              ))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items.map((item) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    item,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // Edit profile
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Preview profile
            },
            icon: const Icon(Icons.preview),
            label: const Text('Preview as Others See'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Danger zone
        Card(
          color: theme.colorScheme.errorContainer.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Actions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showSignOutDialog();
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showDeleteAccountDialog();
                    },
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Delete Account'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(authControllerProvider.notifier).signOut();
              if (mounted) {
                context.go('/welcome');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(authControllerProvider.notifier).deleteAccount();
              if (mounted) {
                context.go('/welcome');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}