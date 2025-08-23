import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/smart_notification_service.dart';
import '../services/notification_service.dart';

/// 🚀 Smart Notification Settings Screen
/// Nova-level notification controls with AI preferences
class SmartNotificationSettingsScreen extends StatefulWidget {
  const SmartNotificationSettingsScreen({super.key});

  @override
  State<SmartNotificationSettingsScreen> createState() =>
      _SmartNotificationSettingsScreenState();
}

class _SmartNotificationSettingsScreenState
    extends State<SmartNotificationSettingsScreen> {
  bool _isLoading = true;
  bool _notificationsEnabled = false;

  // Smart Notification Categories
  final Map<String, bool> _smartPreferences = {
    'predictive': true,
    'insights': true,
    'health_alerts': true,
    'medication': true,
    'wellness': true,
  };

  // Scheduling preferences
  TimeOfDay _preferredTime = const TimeOfDay(hour: 9, minute: 0);
  bool _weekendsEnabled = true;
  int _maxDailyNotifications = 3;
  bool _doNotDisturbMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      // Check if notifications are enabled
      _notificationsEnabled =
          await NotificationService.areNotificationsEnabled();

      // Load preferences from SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        _smartPreferences['predictive'] =
            prefs.getBool('smart_predictive') ?? true;
        _smartPreferences['insights'] = prefs.getBool('smart_insights') ?? true;
        _smartPreferences['health_alerts'] =
            prefs.getBool('smart_health_alerts') ?? true;
        _smartPreferences['medication'] =
            prefs.getBool('smart_medication') ?? true;
        _smartPreferences['wellness'] = prefs.getBool('smart_wellness') ?? true;

        _preferredTime = TimeOfDay(
          hour: prefs.getInt('preferred_hour') ?? 9,
          minute: prefs.getInt('preferred_minute') ?? 0,
        );
        _weekendsEnabled = prefs.getBool('weekends_enabled') ?? true;
        _maxDailyNotifications = prefs.getInt('max_daily_notifications') ?? 3;
        _doNotDisturbMode = prefs.getBool('do_not_disturb') ?? false;

        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save smart preferences
      await prefs.setBool('smart_predictive', _smartPreferences['predictive']!);
      await prefs.setBool('smart_insights', _smartPreferences['insights']!);
      await prefs.setBool(
        'smart_health_alerts',
        _smartPreferences['health_alerts']!,
      );
      await prefs.setBool('smart_medication', _smartPreferences['medication']!);
      await prefs.setBool('smart_wellness', _smartPreferences['wellness']!);

      // Save scheduling preferences
      await prefs.setInt('preferred_hour', _preferredTime.hour);
      await prefs.setInt('preferred_minute', _preferredTime.minute);
      await prefs.setBool('weekends_enabled', _weekendsEnabled);
      await prefs.setInt('max_daily_notifications', _maxDailyNotifications);
      await prefs.setBool('do_not_disturb', _doNotDisturbMode);

      // Update smart notification service
      await SmartNotificationService.updateSmartPreferences(_smartPreferences);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification settings saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _requestPermissions() async {
    final granted = await NotificationService.requestPermissions();
    setState(() {
      _notificationsEnabled = granted;
    });

    if (granted) {
      await _saveSettings();
    }
  }

  Future<void> _testSmartNotifications() async {
    try {
      await SmartNotificationService.runSmartAnalysis();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Smart analysis complete! Check for notifications.'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error running smart analysis: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔔 Smart Notifications'),
        backgroundColor: Colors.purple.shade50,
        foregroundColor: Colors.purple.shade700,
        iconTheme: IconThemeData(color: Colors.purple.shade700),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.purple.shade700),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPermissionSection(theme),
                  const SizedBox(height: 24),
                  _buildSmartCategoriesSection(theme),
                  const SizedBox(height: 24),
                  _buildSchedulingSection(theme),
                  const SizedBox(height: 24),
                  _buildAdvancedSection(theme),
                  const SizedBox(height: 24),
                  _buildActionsSection(theme),
                  const SizedBox(height: 100), // Bottom padding for FAB
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _testSmartNotifications,
        icon: const Icon(Icons.psychology),
        label: const Text('Run Smart Analysis'),
        backgroundColor: theme.primaryColor,
      ),
    );
  }

  Widget _buildPermissionSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _notificationsEnabled
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                  color: _notificationsEnabled ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  'Notification Permissions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _notificationsEnabled
                  ? 'Notifications are enabled. You\'ll receive smart insights and reminders.'
                  : 'Enable notifications to receive AI-powered health insights and personalized reminders.',
              style: theme.textTheme.bodyMedium,
            ),
            if (!_notificationsEnabled) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _requestPermissions,
                  icon: const Icon(Icons.notifications),
                  label: const Text('Enable Notifications'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSmartCategoriesSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Smart Notification Categories',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSmartCategory(
              'predictive',
              'Predictive Insights',
              'AI-powered cycle predictions with confidence levels',
              Icons.auto_graph,
              Colors.blue,
              theme,
            ),
            _buildSmartCategory(
              'insights',
              'Personal Insights',
              'Weekly summaries and personalized health trends',
              Icons.insights,
              Colors.green,
              theme,
            ),
            _buildSmartCategory(
              'health_alerts',
              'Health Alerts',
              'Important pattern alerts and health recommendations',
              Icons.health_and_safety,
              Colors.red,
              theme,
            ),
            _buildSmartCategory(
              'medication',
              'Smart Medication',
              'Cycle-aware medication and supplement reminders',
              Icons.medication,
              Colors.orange,
              theme,
            ),
            _buildSmartCategory(
              'wellness',
              'Wellness Check-ins',
              'Gentle mood and wellness reminders',
              Icons.self_improvement,
              Colors.pink,
              theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartCategory(
    String key,
    String title,
    String description,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _smartPreferences[key] ?? false,
            onChanged: _notificationsEnabled
                ? (value) {
                    setState(() => _smartPreferences[key] = value);
                    _saveSettings();
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSchedulingSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  'Scheduling Preferences',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Preferred Time'),
              subtitle: Text(
                'Receive notifications around ${_preferredTime.format(context)}',
              ),
              trailing: TextButton(
                onPressed: _notificationsEnabled ? () => _selectTime() : null,
                child: const Text('Change'),
              ),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.weekend),
              title: const Text('Weekend Notifications'),
              subtitle: const Text('Receive notifications on weekends'),
              value: _weekendsEnabled,
              onChanged: _notificationsEnabled
                  ? (value) {
                      setState(() => _weekendsEnabled = value);
                      _saveSettings();
                    }
                  : null,
            ),
            ListTile(
              leading: const Icon(Icons.notifications_none),
              title: const Text('Daily Notification Limit'),
              subtitle: Text(
                'Maximum $_maxDailyNotifications notifications per day',
              ),
              trailing: DropdownButton<int>(
                value: _maxDailyNotifications,
                items: [1, 2, 3, 4, 5]
                    .map((i) => DropdownMenuItem(value: i, child: Text('$i')))
                    .toList(),
                onChanged: _notificationsEnabled
                    ? (value) {
                        if (value != null) {
                          setState(() => _maxDailyNotifications = value);
                          _saveSettings();
                        }
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings_suggest, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  'Advanced Settings',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              secondary: const Icon(Icons.do_not_disturb),
              title: const Text('Smart Do Not Disturb'),
              subtitle: const Text(
                'Automatically reduce notifications during stressful periods',
              ),
              value: _doNotDisturbMode,
              onChanged: _notificationsEnabled
                  ? (value) {
                      setState(() => _doNotDisturbMode = value);
                      _saveSettings();
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tune, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Actions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _notificationsEnabled
                    ? () async {
                        await NotificationService.cancelAllNotifications();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('All notifications cancelled'),
                            ),
                          );
                        }
                      }
                    : null,
                icon: const Icon(Icons.clear_all),
                label: const Text('Cancel All Notifications'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _preferredTime,
    );

    if (time != null) {
      setState(() => _preferredTime = time);
      _saveSettings();
    }
  }
}
