import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/theme_service.dart';
import '../services/localization_service.dart';
import '../l10n/generated/app_localizations.dart';
import '../widgets/ai_splash_widget.dart';

class EnhancedSettingsScreen extends StatefulWidget {
  const EnhancedSettingsScreen({super.key});

  @override
  State<EnhancedSettingsScreen> createState() => _EnhancedSettingsScreenState();
}

class _EnhancedSettingsScreenState extends State<EnhancedSettingsScreen> with TickerProviderStateMixin {
  static const String _displayNameKey = 'display_name';
  static const String _compactViewKey = 'compact_view';
  static const String _aiConsentKey = 'ai_consent_given';
  
  late TabController _tabController;
  
  String _customDisplayName = '';
  bool _compactView = false;
  bool _aiConsentGiven = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _customDisplayName = prefs.getString(_displayNameKey) ?? '';
        _compactView = prefs.getBool(_compactViewKey) ?? false;
        _aiConsentGiven = prefs.getBool(_aiConsentKey) ?? false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      }
    } catch (e) {
      debugPrint('Error saving setting: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final l10n = AppLocalizations.of(context);
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.settingsTitle ?? 'Settings'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.pink.shade400,
                    Colors.purple.shade400,
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.settingsTitle ?? 'Settings',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.grey.shade50,
        foregroundColor: Colors.grey.shade800,
        elevation: 0,
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.purple.shade700,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: Colors.purple.shade600,
          isScrollable: true,
          tabs: [
            Tab(icon: Icon(Icons.palette), text: l10n.appearance ?? 'Appearance'),
            Tab(icon: Icon(Icons.psychology), text: 'FlowSense AI'),
            Tab(icon: Icon(Icons.tune), text: l10n.advanced ?? 'Advanced'),
            Tab(icon: Icon(Icons.person), text: l10n.account ?? 'Account'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppearanceTab(context),
          _buildFlowSenseAITab(context),
          _buildAdvancedTab(context),
          _buildAccountTab(context),
        ],
      ),
    );
  }

  Widget _buildAppearanceTab(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Theme Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.themeSettings ?? 'Theme Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<ThemeService>(
                    builder: (context, themeService, child) {
                      return Column(
                        children: [
                          _buildThemeOption(
                            context: context,
                            title: l10n.lightMode ?? 'Light Mode',
                            subtitle: l10n.lightModeDescription ?? 'Use light theme',
                            icon: Icons.light_mode,
                            color: Colors.amber,
                            isSelected: themeService.themeMode == ThemeMode.light,
                            onTap: () => themeService.setThemeMode(ThemeMode.light),
                          ),
                          const SizedBox(height: 8),
                          _buildThemeOption(
                            context: context,
                            title: l10n.darkMode ?? 'Dark Mode',
                            subtitle: l10n.darkModeDescription ?? 'Use dark theme',
                            icon: Icons.dark_mode,
                            color: Colors.indigo,
                            isSelected: themeService.themeMode == ThemeMode.dark,
                            onTap: () => themeService.setThemeMode(ThemeMode.dark),
                          ),
                          const SizedBox(height: 8),
                          _buildThemeOption(
                            context: context,
                            title: l10n.systemDefault ?? 'System Default',
                            subtitle: l10n.systemDefaultDescription ?? 'Follow system settings',
                            icon: Icons.settings_brightness,
                            color: Colors.green,
                            isSelected: themeService.themeMode == ThemeMode.system,
                            onTap: () => themeService.setThemeMode(ThemeMode.system),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Language Settings
          Consumer<LocalizationService>(
            builder: (context, localizationService, child) {
              return Card(
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.cyan.shade400],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.language, color: Colors.white),
                  ),
                  title: Text(l10n.languageTitle ?? 'Language'),
                  subtitle: Text('${localizationService.currentLanguageName} • ${LocalizationService.supportedLocales.length} languages available'),
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
          
          const SizedBox(height: 16),
          
          // Display Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.displaySettings ?? 'Display Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text(l10n.compactView ?? 'Compact View'),
                    subtitle: Text(l10n.compactViewDescription ?? 'Reduce spacing and use smaller elements'),
                    value: _compactView,
                    onChanged: (value) async {
                      setState(() => _compactView = value);
                      await _saveSetting(_compactViewKey, value);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowSenseAITab(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FlowSense AI Introduction
          Card(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.withOpacity(0.05),
                    Colors.pink.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purple.shade400, Colors.pink.shade400],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.psychology, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FlowSense AI',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade700,
                              ),
                            ),
                            Text(
                              'Advanced AI-powered menstrual health insights',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const AIPoweredBadge(isSmall: false),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'FlowSense AI uses advanced machine learning to provide personalized cycle predictions, symptom pattern analysis, and health insights tailored specifically to your unique cycle patterns.',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // AI Consent Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified_user, color: Colors.green.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'AI Features Consent',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'To provide personalized AI insights, FlowSense needs your consent to analyze your cycle data using machine learning algorithms.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  
                  SwitchListTile(
                    title: Text('Enable AI Features'),
                    subtitle: Text(_aiConsentGiven 
                        ? 'AI analysis is enabled for your cycle data'
                        : 'AI analysis is disabled'),
                    value: _aiConsentGiven,
                    activeColor: Colors.purple.shade600,
                    onChanged: (value) => _handleAIConsentChange(value),
                  ),
                  
                  if (!_aiConsentGiven) ...
                    [
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange.shade600, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Without AI consent, advanced features like cycle predictions and pattern analysis will be limited.',
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // AI Features List
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI-Powered Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildAIFeatureItem(
                    icon: Icons.timeline,
                    title: 'Cycle Predictions',
                    description: 'Advanced algorithms predict your next cycle with high accuracy',
                    isEnabled: _aiConsentGiven,
                  ),
                  
                  _buildAIFeatureItem(
                    icon: Icons.analytics,
                    title: 'Pattern Analysis',
                    description: 'Identify trends and patterns in your symptoms and cycle length',
                    isEnabled: _aiConsentGiven,
                  ),
                  
                  _buildAIFeatureItem(
                    icon: Icons.insights,
                    title: 'Personalized Insights',
                    description: 'Get tailored health recommendations based on your data',
                    isEnabled: _aiConsentGiven,
                  ),
                  
                  _buildAIFeatureItem(
                    icon: Icons.warning_amber,
                    title: 'Anomaly Detection',
                    description: 'Alert you to unusual patterns that may need attention',
                    isEnabled: _aiConsentGiven,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Privacy & Data Usage
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.privacy_tip, color: Colors.blue.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Privacy & Data Usage',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildPrivacyPoint('Your data is processed securely and never shared with third parties'),
                  _buildPrivacyPoint('AI analysis is performed on encrypted, anonymized data'),
                  _buildPrivacyPoint('You can disable AI features at any time without data loss'),
                  _buildPrivacyPoint('All AI processing complies with healthcare privacy regulations'),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => _showPrivacyPolicy(),
                        icon: Icon(Icons.article_outlined, size: 16),
                        label: Text('Privacy Policy'),
                        style: TextButton.styleFrom(foregroundColor: Colors.blue.shade600),
                      ),
                      const SizedBox(width: 16),
                      TextButton.icon(
                        onPressed: () => _showDataUsageDetails(),
                        icon: Icon(Icons.info_outlined, size: 16),
                        label: Text('Data Usage'),
                        style: TextButton.styleFrom(foregroundColor: Colors.blue.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedTab(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Data & Privacy
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
                  leading: const Icon(Icons.cloud_sync, color: Colors.green),
                  title: Text(l10n.syncStatus ?? 'Sync Status'),
                  subtitle: Text(l10n.syncStatusDescription ?? 'Check cloud synchronization'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showSyncStatusDialog(context),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Notifications
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications, color: Colors.orange),
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
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Analytics & Tools
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.analytics, color: Colors.indigo),
                  title: Text(l10n.homeAnalytics ?? 'Analytics'),
                  subtitle: Text(l10n.viewCycleInsights ?? 'View cycle insights'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/analytics'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.science, color: Colors.teal),
                  title: Text(l10n.diagnosticsTitle ?? 'Diagnostics'),
                  subtitle: Text(l10n.testFirebaseConnection ?? 'Test Firebase connection'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/diagnostics'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTab(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = FirebaseAuth.instance.currentUser;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Profile
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
                                Icon(Icons.verified, size: 16, color: Colors.green),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.verified ?? 'Verified',
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
            const SizedBox(height: 16),
          ],
          
          // Support & Info
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline, color: Colors.blue),
                  title: Text(l10n.settingsHelp ?? 'Help & Support'),
                  subtitle: Text(l10n.getHelpUsing ?? 'Get help using the app'),
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
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? color : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Radio<bool>(
          value: true,
          groupValue: isSelected,
          activeColor: color,
          onChanged: (_) => onTap(),
        ),
        onTap: onTap,
      ),
    );
  }


  void _showAboutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_getDisplayName()} v1.0.0'),
            const SizedBox(height: 8),
            Text(l10n.appDescription ?? 'A modern cycle tracking app built with Flutter.'),
            const SizedBox(height: 16),
            Text(
              l10n.features ?? 'Features:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('• ${l10n.featureCycleTracking ?? "Cycle logging and tracking"}'),
            Text('• ${l10n.featureAnalytics ?? "Analytics and insights"}'),
            Text('• ${l10n.featureAI ?? "AI-powered predictions"}'),
            Text('• ${l10n.featureSmartInsights ?? "Smart health insights"}'),
            Text('• ${l10n.featureDarkMode ?? "Dark mode support"}'),
            Text('• ${l10n.featureCloudSync ?? "Cloud synchronization"}'),
            Text('• ${l10n.featurePrivacy ?? "Privacy-focused design"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close ?? 'Close'),
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
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.signOut ?? 'Sign Out'),
        content: Text(l10n.signOutConfirmation ?? 'Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel ?? 'Cancel'),
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
            child: Text(l10n.signOut ?? 'Sign Out'),
          ),
        ],
      ),
    );
  }

  // AI Consent and Feature Methods
  Future<void> _handleAIConsentChange(bool value) async {
    if (value) {
      // Show consent dialog before enabling
      final confirmed = await _showAIConsentDialog();
      if (confirmed) {
        setState(() => _aiConsentGiven = true);
        await _saveSetting(_aiConsentKey, true);
        _showConsentGrantedMessage();
      }
    } else {
      setState(() => _aiConsentGiven = false);
      await _saveSetting(_aiConsentKey, false);
    }
  }

  Future<bool> _showAIConsentDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.psychology, color: Colors.purple.shade600),
            const SizedBox(width: 8),
            const Text('AI Features Consent'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FlowSense AI would like to analyze your cycle data to provide:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            _buildConsentFeature('• Personalized cycle predictions'),
            _buildConsentFeature('• Symptom pattern analysis'),
            _buildConsentFeature('• Health insights and recommendations'),
            _buildConsentFeature('• Anomaly detection and alerts'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.security, color: Colors.blue.shade600, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Your Privacy is Protected',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'All data is processed securely, never shared with third parties, and you can revoke consent at any time.',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Decline'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Accept & Enable AI'),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget _buildConsentFeature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 14,
        ),
      ),
    );
  }

  void _showConsentGrantedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text('AI features enabled! Enhanced insights coming soon.'),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildAIFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isEnabled,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isEnabled ? Colors.purple.shade600 : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isEnabled ? Colors.grey.shade800 : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isEnabled ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          if (isEnabled)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Text(
                'Active',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Text(
                'Disabled',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 500,
          height: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.privacy_tip, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  const Text(
                    'Privacy Policy',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPolicySection(
                        'Data Collection',
                        'FlowSense AI collects only the menstrual cycle data you voluntarily provide through the app interface.',
                      ),
                      _buildPolicySection(
                        'Data Usage',
                        'Your data is used exclusively to provide personalized health insights and predictions. We employ advanced encryption and anonymization techniques.',
                      ),
                      _buildPolicySection(
                        'Data Sharing',
                        'We never share, sell, or transfer your personal health data to third parties. All AI processing is performed locally or on secure, HIPAA-compliant servers.',
                      ),
                      _buildPolicySection(
                        'Data Retention',
                        'Your data is retained only as long as necessary to provide services. You can request data deletion at any time.',
                      ),
                      _buildPolicySection(
                        'Your Rights',
                        'You have the right to access, modify, or delete your data. You can also revoke AI consent without losing your historical data.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDataUsageDetails() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  const Text(
                    'Data Usage Details',
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
              
              _buildDataUsageItem(
                'Cycle Dates',
                'Used for prediction algorithms and pattern analysis',
                Icons.calendar_month,
              ),
              _buildDataUsageItem(
                'Symptoms',
                'Analyzed to identify patterns and provide health insights',
                Icons.favorite,
              ),
              _buildDataUsageItem(
                'Mood Tracking',
                'Correlated with cycle phases for personalized recommendations',
                Icons.mood,
              ),
              _buildDataUsageItem(
                'Notes',
                'Processed for context but kept private and encrypted',
                Icons.note,
              ),
              
              const SizedBox(height: 20),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'All data processing happens with your explicit consent and can be disabled at any time.',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataUsageItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.blue.shade600,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayName() {
    return 'FlowSense AI';
  }
}
