import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../services/firebase_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _notificationsEnabled = false;
  bool _cycleStartReminders = true;
  bool _ovulationReminders = true;
  bool _cycleEndReminders = true;
  bool _dailyLoggingReminders = false;
  
  bool _isLoading = true;
  bool _isUpdatingPermissions = false;
  String? _error;
  
  List<String> _pendingNotifications = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkNotificationStatus();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _cycleStartReminders = prefs.getBool('cycle_start_reminders') ?? true;
        _ovulationReminders = prefs.getBool('ovulation_reminders') ?? true;
        _cycleEndReminders = prefs.getBool('cycle_end_reminders') ?? true;
        _dailyLoggingReminders = prefs.getBool('daily_logging_reminders') ?? false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading settings: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkNotificationStatus() async {
    try {
      final enabled = await NotificationService.areNotificationsEnabled();
      final pending = await NotificationService.getPendingNotifications();
      
      setState(() {
        _notificationsEnabled = enabled;
        _pendingNotifications = pending.map((n) => n.title ?? 'Untitled').toList();
      });
    } catch (e) {
      debugPrint('Error checking notification status: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('cycle_start_reminders', _cycleStartReminders);
      await prefs.setBool('ovulation_reminders', _ovulationReminders);
      await prefs.setBool('cycle_end_reminders', _cycleEndReminders);
      await prefs.setBool('daily_logging_reminders', _dailyLoggingReminders);
      
      // Update notifications based on current settings
      if (_notificationsEnabled) {
        await _updateNotifications();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving settings: $e')),
        );
      }
    }
  }

  Future<void> _updateNotifications() async {
    try {
      // Get cycles to update predictions
      final cycles = await FirebaseService.getCycles();
      await NotificationService.updateCycleNotifications(cycles);
      
      // Schedule daily logging reminder if enabled
      if (_dailyLoggingReminders) {
        await NotificationService.scheduleCycleLoggingReminder();
      }
      
      await _checkNotificationStatus(); // Refresh pending notifications
    } catch (e) {
      debugPrint('Error updating notifications: $e');
    }
  }

  Future<void> _toggleNotifications() async {
    setState(() {
      _isUpdatingPermissions = true;
    });

    try {
      if (!_notificationsEnabled) {
        // Initialize and request permissions
        final initialized = await NotificationService.initialize();
        if (initialized) {
          final granted = await NotificationService.requestPermissions();
          if (granted) {
            setState(() {
              _notificationsEnabled = true;
            });
            await _updateNotifications();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications enabled!')),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notification permission denied')),
              );
            }
          }
        }
      } else {
        // Cancel all notifications
        await NotificationService.cancelAllNotifications();
        setState(() {
          _notificationsEnabled = false;
          _pendingNotifications.clear();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notifications disabled!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() {
        _isUpdatingPermissions = false;
      });
    }
  }

  Widget _buildNotificationToggle() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
                  color: _notificationsEnabled ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Push Notifications',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _notificationsEnabled ? 'Enabled' : 'Disabled',
                        style: TextStyle(
                          color: _notificationsEnabled ? Colors.green : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _isUpdatingPermissions
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Switch(
                        value: _notificationsEnabled,
                        onChanged: (_) => _toggleNotifications(),
                      ),
              ],
            ),
            if (!_notificationsEnabled)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Enable notifications to receive cycle reminders and predictions',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderSettings() {
    if (!_notificationsEnabled) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reminder Types',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildReminderTile(
              title: 'Cycle Start Reminders',
              subtitle: 'Get notified before your next cycle starts',
              icon: Icons.calendar_today,
              value: _cycleStartReminders,
              onChanged: (value) {
                setState(() {
                  _cycleStartReminders = value;
                });
                _saveSettings();
              },
            ),
            _buildReminderTile(
              title: 'Ovulation Reminders',
              subtitle: 'Get notified during your fertile window',
              icon: Icons.favorite,
              value: _ovulationReminders,
              onChanged: (value) {
                setState(() {
                  _ovulationReminders = value;
                });
                _saveSettings();
              },
            ),
            _buildReminderTile(
              title: 'Cycle End Reminders',
              subtitle: 'Get reminded to log when your cycle ends',
              icon: Icons.event_available,
              value: _cycleEndReminders,
              onChanged: (value) {
                setState(() {
                  _cycleEndReminders = value;
                });
                _saveSettings();
              },
            ),
            _buildReminderTile(
              title: 'Daily Logging Reminders',
              subtitle: 'Daily reminder to track your cycle data',
              icon: Icons.edit_calendar,
              value: _dailyLoggingReminders,
              onChanged: (value) {
                setState(() {
                  _dailyLoggingReminders = value;
                });
                _saveSettings();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.pink.shade300, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildPendingNotifications() {
    if (!_notificationsEnabled || _pendingNotifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming Notifications (${_pendingNotifications.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            for (String title in _pendingNotifications.take(3))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_pendingNotifications.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'And ${_pendingNotifications.length - 3} more...',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton() {
    if (!_notificationsEnabled) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          try {
            await NotificationService.scheduleCycleLoggingReminder();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Test notification scheduled!')),
              );
            }
            await _checkNotificationStatus();
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          }
        },
        icon: const Icon(Icons.send),
        label: const Text('Send Test Notification'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pink.shade100,
          foregroundColor: Colors.pink.shade700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notification Settings'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notification Settings'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _isLoading = true;
                  });
                  _loadSettings();
                  _checkNotificationStatus();
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: Colors.pink.shade50,
      ),
      body: RefreshIndicator(
        onRefresh: _checkNotificationStatus,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNotificationToggle(),
              _buildReminderSettings(),
              _buildPendingNotifications(),
              _buildTestButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
