import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/theme_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Card
            if (user != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          user.email?.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.displayName ?? 'User',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              user.email ?? '',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (user.emailVerified)
                              Row(
                                children: [
                                  Icon(
                                    Icons.verified,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Verified',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
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
              ),
              const SizedBox(height: 24),
            ],

            // Appearance Section
            Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Consumer<ThemeService>(
              builder: (context, themeService, child) {
                return Card(
                  child: Column(
                    children: [
                      _buildThemeOption(
                        context: context,
                        title: 'Light Mode',
                        subtitle: 'Use light theme',
                        icon: Icons.light_mode,
                        isSelected: themeService.themeMode == ThemeMode.light,
                        onTap: () => themeService.setThemeMode(ThemeMode.light),
                      ),
                      const Divider(height: 1),
                      _buildThemeOption(
                        context: context,
                        title: 'Dark Mode',
                        subtitle: 'Use dark theme',
                        icon: Icons.dark_mode,
                        isSelected: themeService.themeMode == ThemeMode.dark,
                        onTap: () => themeService.setThemeMode(ThemeMode.dark),
                      ),
                      const Divider(height: 1),
                      _buildThemeOption(
                        context: context,
                        title: 'System Default',
                        subtitle: 'Follow system settings',
                        icon: Icons.settings_brightness,
                        isSelected: themeService.themeMode == ThemeMode.system,
                        onTap: () => themeService.setThemeMode(ThemeMode.system),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Tools Section
            Text(
              'Tools',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.science),
                    title: const Text('Diagnostics'),
                    subtitle: const Text('Test Firebase connection'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/diagnostics'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.analytics),
                    title: const Text('Analytics'),
                    subtitle: const Text('View cycle insights'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/analytics'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Cycle History'),
                    subtitle: const Text('View all cycles'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/cycle-history'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Data Section
            Text(
              'Data Management',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.backup, color: Colors.blue),
                    title: const Text('Export Data'),
                    subtitle: const Text('Download your cycle data'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showComingSoonDialog(context, 'Export Data'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.cloud_sync, color: Colors.green),
                    title: const Text('Sync Status'),
                    subtitle: const Text('Check cloud synchronization'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showComingSoonDialog(context, 'Sync Status'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Account Section
            Text(
              'Account',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.help_outline, color: Colors.blue),
                    title: const Text('Help & Support'),
                    subtitle: const Text('Get help using CycleSync'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showComingSoonDialog(context, 'Help & Support'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: Colors.green),
                    title: const Text('About'),
                    subtitle: const Text('App version and credits'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showAboutDialog(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Sign Out'),
                    subtitle: const Text('Sign out of your account'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showSignOutDialog(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Radio<bool>(
        value: true,
        groupValue: isSelected,
        onChanged: (_) => onTap(),
      ),
      onTap: onTap,
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: Text('$feature will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About CycleSync'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CycleSync v1.0.0'),
            SizedBox(height: 8),
            Text('A modern cycle tracking app built with Flutter.'),
            SizedBox(height: 16),
            Text(
              'Features:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text('• Cycle logging and tracking'),
            Text('• Analytics and insights'),
            Text('• Dark mode support'),
            Text('• Cloud synchronization'),
            Text('• Privacy-focused design'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
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
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
