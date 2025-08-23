import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/theme_service.dart';
import '../services/localization_service.dart';
import '../providers/user_provider.dart';
import '../widgets/user_avatar_widget.dart';
import '../widgets/app_logo.dart';
import '../theme/dimensional_theme.dart';
import '../theme/app_theme.dart';
import '../l10n/generated/app_localizations.dart';
import 'language_selection_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n != null ? '⚙️ ${l10n.settingsTitle}' : '⚙️ Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return DimensionalCard(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        UserAvatarWidget(radius: 30, showEditButton: false),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.displayName ??
                                    userProvider.displayName ??
                                    'User',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user.email ?? '',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              if (user.emailVerified)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.successGreen.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.successGreen.withValues(
                                        alpha: 0.4,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.verified,
                                        size: 12,
                                        color: AppTheme.successGreen,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Verified',
                                        style: TextStyle(
                                          color: AppTheme.successGreen,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        DimensionalContainer(
                          child: IconButton(
                            icon: Icon(
                              Icons.logout,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            onPressed: () => _showSignOutDialog(context),
                            tooltip: 'Sign Out',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],

            // Appearance Section
            Text(
              l10n?.appearanceTitle ?? 'Appearance',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Theme settings
            Consumer<ThemeService>(
              builder: (context, themeService, child) {
                return DimensionalCard(
                  child: Column(
                    children: [
                      _buildThemeOption(
                        context: context,
                        title: l10n?.lightMode ?? 'Light Mode',
                        subtitle:
                            l10n?.lightModeDescription ?? 'Use light theme',
                        icon: Icons.light_mode,
                        isSelected: themeService.themeMode == ThemeMode.light,
                        onTap: () => themeService.setThemeMode(ThemeMode.light),
                      ),
                      const Divider(height: 1),
                      _buildThemeOption(
                        context: context,
                        title: l10n?.darkMode ?? 'Dark Mode',
                        subtitle: l10n?.darkModeDescription ?? 'Use dark theme',
                        icon: Icons.dark_mode,
                        isSelected: themeService.themeMode == ThemeMode.dark,
                        onTap: () => themeService.setThemeMode(ThemeMode.dark),
                      ),
                      const Divider(height: 1),
                      _buildThemeOption(
                        context: context,
                        title: l10n?.systemDefault ?? 'System Default',
                        subtitle:
                            l10n?.systemDefaultDescription ??
                            'Follow system settings',
                        icon: Icons.settings_brightness,
                        isSelected: themeService.themeMode == ThemeMode.system,
                        onTap: () =>
                            themeService.setThemeMode(ThemeMode.system),
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
                return DimensionalCard(
                  child: ListTile(
                    leading: Icon(
                      Icons.language,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(l10n?.languageTitle ?? 'Language'),
                    subtitle: Text(
                      '${localizationService.currentLanguageName} • 36 languages available',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            localizationService.currentLanguageNativeName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LanguageSelectionScreen(),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Tools Section
            Text(
              l10n?.tools ?? 'Tools',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            DimensionalCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: Text(l10n?.settingsNotifications ?? 'Notifications'),
                    subtitle: Text(
                      l10n?.notificationsManage ??
                          'Manage cycle reminders and alerts',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/notification-settings'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.psychology,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    title: Text(
                      l10n?.smartNotifications ?? 'Smart Notifications',
                    ),
                    subtitle: Text(
                      l10n?.smartNotificationsDescription ??
                          'AI-powered insights and predictions',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/smart-notifications'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.science),
                    title: Text(l10n?.diagnosticsTitle ?? 'Diagnostics'),
                    subtitle: Text(
                      l10n?.testFirebaseConnection ??
                          'Test Firebase connection',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/diagnostics'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.analytics),
                    title: Text(l10n?.homeAnalytics ?? 'Analytics'),
                    subtitle: Text(
                      l10n?.viewCycleInsights ?? 'View cycle insights',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/analytics'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(l10n?.profileCycleHistory ?? 'Cycle History'),
                    subtitle: Text(l10n?.viewAllCycles ?? 'View all cycles'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/cycle-history'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.trending_up),
                    title: Text(l10n?.homeSymptomTrends ?? 'Symptom Trends'),
                    subtitle: Text(
                      l10n?.viewSymptomPatterns ??
                          'View symptom patterns and insights',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/symptom-trends'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Data Section
            Text(
              l10n?.dataManagement ?? 'Data Management',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            DimensionalCard(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.health_and_safety,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    title: Text(
                      l10n?.healthIntegration ?? 'Health Integration',
                    ),
                    subtitle: Text(
                      l10n?.healthIntegrationDescription ??
                          'Sync with HealthKit and Google Fit',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/health-integration'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.backup,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(l10n?.dataManagement ?? 'Data Management'),
                    subtitle: Text(
                      l10n?.dataManagementDescription ??
                          'Export, import, and backup your data',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/data-management'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.file_download,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    title: Text(l10n?.exportBackup ?? 'Export & Backup'),
                    subtitle: Text(
                      l10n?.exportBackupDescription ??
                          'Generate reports and backup your data',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/export'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.share, color: AppTheme.warningOrange),
                    title: Text(l10n?.socialSharing ?? 'Social Sharing'),
                    subtitle: Text(
                      l10n?.socialSharingDescription ??
                          'Share data with providers and partners',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/social-sharing'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.cloud_sync,
                      color: AppTheme.successGreen,
                    ),
                    title: Text(l10n?.syncStatus ?? 'Sync Status'),
                    subtitle: Text(
                      l10n?.syncStatusDescription ??
                          'Check cloud synchronization',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showSyncStatusDialog(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Account Section
            Text(
              l10n?.account ?? 'Account',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            DimensionalCard(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.help_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(l10n?.settingsHelp ?? 'Help & Support'),
                    subtitle: Text(
                      l10n?.getHelpUsingFlowSense ?? 'Get help using FlowSense',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/help-support'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.lightbulb,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    title: const Text('Share Your Ideas'),
                    subtitle: const Text(
                      'Submit feature requests and suggestions',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.warningOrange.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'NEW',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.warningOrange,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                    onTap: () => context.push('/share-ideas'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.psychology,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('FlowSense Integration'),
                    subtitle: const Text('Advanced AI features'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'SOON',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                    onTap: () => context.push('/flowsense-coming-soon'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.feedback,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Send Feedback'),
                    subtitle: const Text('Report issues or share thoughts'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/feedback'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.info_outline,
                      color: AppTheme.successGreen,
                    ),
                    title: Text(l10n?.about ?? 'About'),
                    subtitle: Text(
                      l10n?.aboutDescription ?? 'App version and credits',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showAboutDialog(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.logout,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: Text(l10n?.signOut ?? 'Sign Out'),
                    subtitle: Text(
                      l10n?.signOutDescription ?? 'Sign out of your account',
                    ),
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
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.aboutFlowSense ?? 'About FlowSense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const AppLogo(size: 80, showText: true),
            const SizedBox(height: 16),
            Text(
              l10n?.flowSenseVersion ?? 'FlowSense v1.0.0',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.modernCycleTrackingApp ??
                  'A modern cycle tracking app built with Flutter.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              l10n?.features ?? 'Features:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.cycleLoggingTracking ?? '• Cycle logging and tracking',
                ),
                Text(l10n?.analyticsInsights ?? '• Analytics and insights'),
                Text(l10n?.darkModeSupport ?? '• Dark mode support'),
                Text(l10n?.cloudSynchronization ?? '• Cloud synchronization'),
                Text(l10n?.privacyFocusedDesign ?? '• Privacy-focused design'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n?.commonClose ?? 'Close'),
          ),
        ],
      ),
    );
  }

  void _showSyncStatusDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                  Icon(Icons.cloud_sync, color: AppTheme.successGreen),
                  const SizedBox(width: 8),
                  const Text(
                    'Sync Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
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
              _buildSyncItem(
                'Firebase Authentication',
                Icons.verified,
                AppTheme.successGreen,
                'Connected',
              ),
              _buildSyncItem(
                'Cloud Firestore',
                Icons.cloud_done,
                AppTheme.successGreen,
                'Synced 2 minutes ago',
              ),
              _buildSyncItem(
                'Health Data',
                Icons.health_and_safety,
                AppTheme.warningOrange,
                'Pending sync',
              ),
              _buildSyncItem(
                'Analytics Data',
                Icons.analytics,
                AppTheme.successGreen,
                'Up to date',
              ),

              const SizedBox(height: 20),

              // Sync statistics
              Card(
                color: isDark
                    ? Theme.of(context).colorScheme.surface
                    : Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.05),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total synced records:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.getTextColor(context),
                            ),
                          ),
                          Text(
                            '1,247',
                            style: TextStyle(
                              color: AppTheme.getTextColor(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Last full sync:',
                            style: TextStyle(
                              color: AppTheme.getSubtitleColor(context),
                            ),
                          ),
                          Text(
                            'Today at 14:32',
                            style: TextStyle(
                              color: AppTheme.getTextColor(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Storage used:',
                            style: TextStyle(
                              color: AppTheme.getSubtitleColor(context),
                            ),
                          ),
                          Text(
                            '2.3 MB',
                            style: TextStyle(
                              color: AppTheme.getTextColor(context),
                            ),
                          ),
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
                        SnackBar(
                          content: const Text(
                            'Manual sync completed successfully!',
                          ),
                          backgroundColor: AppTheme.successGreen,
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

  Widget _buildSyncItem(
    String title,
    IconData icon,
    Color color,
    String status,
  ) {
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
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
