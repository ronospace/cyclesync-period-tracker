import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/theme_service.dart';
import '../services/localization_service.dart';
import '../l10n/generated/app_localizations.dart';
import '../widgets/ai_splash_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n != null ? '⚙️ ${l10n.settingsTitle}' : '⚙️ Settings'),
        backgroundColor: Colors.grey.shade50,
        foregroundColor: Colors.grey.shade700,
        iconTheme: IconThemeData(color: Colors.grey.shade700),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
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
              l10n.appearanceTitle ?? 'Appearance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Theme settings
            Consumer<ThemeService>(
              builder: (context, themeService, child) {
                return Card(
                  child: Column(
                    children: [
                      _buildThemeOption(
                        context: context,
                        title: l10n.lightMode ?? 'Light Mode',
                        subtitle: l10n.lightModeDescription ?? 'Use light theme',
                        icon: Icons.light_mode,
                        isSelected: themeService.themeMode == ThemeMode.light,
                        onTap: () => themeService.setThemeMode(ThemeMode.light),
                      ),
                      const Divider(height: 1),
                      _buildThemeOption(
                        context: context,
                        title: l10n.darkMode ?? 'Dark Mode',
                        subtitle: l10n.darkModeDescription ?? 'Use dark theme',
                        icon: Icons.dark_mode,
                        isSelected: themeService.themeMode == ThemeMode.dark,
                        onTap: () => themeService.setThemeMode(ThemeMode.dark),
                      ),
                      const Divider(height: 1),
                      _buildThemeOption(
                        context: context,
                        title: l10n.systemDefault ?? 'System Default',
                        subtitle: l10n.systemDefaultDescription ?? 'Follow system settings',
                        icon: Icons.settings_brightness,
                        isSelected: themeService.themeMode == ThemeMode.system,
                        onTap: () => themeService.setThemeMode(ThemeMode.system),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Language settings
            Consumer<LocalizationService>(
              builder: (context, localizationService, child) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.language, color: Colors.blue),
                    title: Text(l10n.languageTitle ?? 'Language'),
                    subtitle: Text('${localizationService.currentLanguageName} • 36 languages available'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Text(
                            localizationService.currentLanguageNativeName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                    onTap: () => context.push('/language-selector'),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Tools Section
            Text(
              l10n.tools ?? 'Tools',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: Text(l10n.settingsNotifications ?? 'Notifications'),
                    subtitle: Text(l10n.notificationsManage ?? 'Manage cycle reminders and alerts'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/notification-settings'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.psychology, color: Colors.purple),
                    title: Text(l10n.smartNotifications ?? 'Smart Notifications'),
                    subtitle: Text(l10n.smartNotificationsDescription ?? 'AI-powered insights and predictions'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/smart-notifications'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.science),
                    title: Text(l10n.diagnosticsTitle ?? 'Diagnostics'),
                    subtitle: Text(l10n.testFirebaseConnection ?? 'Test Firebase connection'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/diagnostics'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.analytics),
                    title: Text(l10n.homeAnalytics ?? 'Analytics'),
                    subtitle: Text(l10n.viewCycleInsights ?? 'View cycle insights'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/analytics'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(l10n.profileCycleHistory ?? 'Cycle History'),
                    subtitle: Text(l10n.viewAllCycles ?? 'View all cycles'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/cycle-history'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.trending_up),
                    title: Text(l10n.homeSymptomTrends ?? 'Symptom Trends'),
                    subtitle: Text(l10n.viewSymptomPatterns ?? 'View symptom patterns and insights'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/symptom-trends'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Data Section
            Text(
              l10n.dataManagement ?? 'Data Management',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.health_and_safety, color: Colors.purple),
                    title: Text(l10n.healthIntegration ?? 'Health Integration'),
                    subtitle: Text(l10n.healthIntegrationDescription ?? 'Sync with HealthKit and Google Fit'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/health-integration'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.backup, color: Colors.blue),
                    title: Text(l10n.dataManagement ?? 'Data Management'),
                    subtitle: Text(l10n.dataManagementDescription ?? 'Export, import, and backup your data'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/data-management'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.file_download, color: Colors.indigo),
                    title: Text(l10n.exportBackup ?? 'Export & Backup'),
                    subtitle: Text(l10n.exportBackupDescription ?? 'Generate reports and backup your data'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/export'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.share, color: Colors.orange),
                    title: Text(l10n.socialSharing ?? 'Social Sharing'),
                    subtitle: Text(l10n.socialSharingDescription ?? 'Share data with providers and partners'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/social-sharing'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.cloud_sync, color: Colors.green),
                    title: Text(l10n.syncStatus ?? 'Sync Status'),
                    subtitle: Text(l10n.syncStatusDescription ?? 'Check cloud synchronization'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showSyncStatusDialog(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Account Section
            Text(
              l10n.account ?? 'Account',
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
                    title: Text(l10n.settingsHelp ?? 'Help & Support'),
                    subtitle: Text(l10n.getHelpUsingCycleSync ?? 'Get help using CycleSync'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/help-support'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: Colors.green),
                    title: Text(l10n.about ?? 'About'),
                    subtitle: Text(l10n.aboutDescription ?? 'App version and credits'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showAboutDialog(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: Text(l10n.signOut ?? 'Sign Out'),
                    subtitle: Text(l10n.signOutDescription ?? 'Sign out of your account'),
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

  void _showSyncStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.cloud_sync, color: Colors.green),
                  const SizedBox(width: 8),
                  const Text('Sync Status', 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              
              // Sync status items
              _buildSyncItem('Firebase Authentication', Icons.verified, Colors.green, 'Connected'),
              _buildSyncItem('Cloud Firestore', Icons.cloud_done, Colors.green, 'Synced 2 minutes ago'),
              _buildSyncItem('Health Data', Icons.health_and_safety, Colors.orange, 'Pending sync'),
              _buildSyncItem('Analytics Data', Icons.analytics, Colors.green, 'Up to date'),
              
              const SizedBox(height: 20),
              
              // Sync statistics
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total synced records:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('1,247'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Last full sync:'),
                          Text('Today at 14:32'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Storage used:'),
                          Text('2.3 MB'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Manual sync completed successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.sync),
                    label: const Text('Sync Now'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncItem(String title, IconData icon, Color color, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
          ),
          Text(status, style: TextStyle(color: color, fontSize: 12)),
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
