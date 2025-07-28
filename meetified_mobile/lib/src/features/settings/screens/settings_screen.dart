import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          // Appearance
          _buildSectionHeader(theme, 'Appearance'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.palette_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Theme'),
                  subtitle: Text(_getThemeText(themeMode)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showThemeDialog(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Preferences
          _buildSectionHeader(theme, 'Dating Preferences'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.tune,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Age Range'),
                  subtitle: const Text('25 - 35 years'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showAgeRangeDialog(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.location_on_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Distance'),
                  subtitle: const Text('Within 50 miles'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showDistanceDialog(),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: Icon(
                    Icons.pause_circle_outline,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Hold Matchmaking'),
                  subtitle: const Text('Temporarily pause finding new matches'),
                  value: false,
                  onChanged: (value) {
                    _showHoldMatchmakingDialog(value);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Notifications
          _buildSectionHeader(theme, 'Notifications'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    Icons.notifications_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Get notified about matches and messages'),
                  value: true,
                  onChanged: (value) {
                    // Handle notification toggle
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: Icon(
                    Icons.favorite_outline,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Match Notifications'),
                  subtitle: const Text('When you get a new match'),
                  value: true,
                  onChanged: (value) {
                    // Handle match notification toggle
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: Icon(
                    Icons.chat_bubble_outline,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Message Notifications'),
                  subtitle: const Text('When you receive a new message'),
                  value: true,
                  onChanged: (value) {
                    // Handle message notification toggle
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Privacy & Safety
          _buildSectionHeader(theme, 'Privacy & Safety'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.privacy_tip_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Privacy Settings'),
                  subtitle: const Text('Control who can see your profile'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to privacy settings
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.block_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Blocked Users'),
                  subtitle: const Text('Manage blocked accounts'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to blocked users
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.report_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Safety Center'),
                  subtitle: const Text('Tips and tools for safe dating'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to safety center
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Account
          _buildSectionHeader(theme, 'Account'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.star_outline,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Premium'),
                  subtitle: const Text('Upgrade your experience'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Upgrade',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.amber.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  onTap: () {
                    // Navigate to premium
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.download_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Download My Data'),
                  subtitle: const Text('Get a copy of your information'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showDataDownloadDialog();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Support
          _buildSectionHeader(theme, 'Support'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.help_outline,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Help & Support'),
                  subtitle: const Text('Get help and contact us'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to help
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('About'),
                  subtitle: Text('Version ${AppConstants.appVersion}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showAboutDialog();
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.description_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Terms & Privacy'),
                  subtitle: const Text('Legal information'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to terms
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  String _getThemeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System default';
    }
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: ref.read(themeModeProvider),
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                }
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: ref.read(themeModeProvider),
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                }
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System default'),
              value: ThemeMode.system,
              groupValue: ref.read(themeModeProvider),
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAgeRangeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Age Range'),
        content: const Text('Feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDistanceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Maximum Distance'),
        content: const Text('Feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHoldMatchmakingDialog(bool enable) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(enable ? 'Hold Matchmaking' : 'Resume Matchmaking'),
        content: Text(
          enable 
              ? 'This will pause finding new matches for you. You can resume anytime.'
              : 'This will resume finding new matches for you.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    enable 
                        ? 'Matchmaking paused' 
                        : 'Matchmaking resumed',
                  ),
                ),
              );
            },
            child: Text(enable ? 'Hold' : 'Resume'),
          ),
        ],
      ),
    );
  }

  void _showDataDownloadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download My Data'),
        content: const Text(
          'We\'ll prepare a file with your information and send it to your registered email address within 24 hours.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data download requested. Check your email in 24 hours.'),
                ),
              );
            },
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: const Icon(
          Icons.favorite,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: [
        const Text('AI-powered dating app that understands you.'),
        const SizedBox(height: 16),
        const Text('Find meaningful connections through intelligent matching and conversational AI.'),
      ],
    );
  }
}