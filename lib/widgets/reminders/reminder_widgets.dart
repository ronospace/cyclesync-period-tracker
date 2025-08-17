import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/reminder_models.dart';
import '../../services/reminder_service.dart';
import '../../services/notification_permission_service.dart';
import '../../screens/add_reminder_screen.dart';
import '../../screens/reminders_screen.dart';

/// Quick reminder card widget for dashboard/home screen
class ReminderQuickCard extends StatelessWidget {
  final List<Reminder> todaysReminders;
  final VoidCallback? onViewAll;

  const ReminderQuickCard({
    super.key,
    required this.todaysReminders,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.alarm, color: Colors.pink),
                const SizedBox(width: 8),
                const Text(
                  'Today\'s Reminders',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (todaysReminders.isNotEmpty)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text('View All'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (todaysReminders.isEmpty)
              _buildEmptyState(context)
            else
              _buildRemindersList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 48,
            color: Colors.green.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          const Text(
            'No reminders today',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'You\'re all set! Enjoy your day.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _navigateToAddReminder(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Reminder'),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersList(BuildContext context) {
    return Column(
      children: [
        ...todaysReminders.take(3).map((reminder) => 
          _ReminderQuickItem(reminder: reminder)),
        if (todaysReminders.length > 3) ...[
          const SizedBox(height: 8),
          Text(
            '+ ${todaysReminders.length - 3} more reminders',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
        const SizedBox(height: 12),
        _buildQuickActions(context),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _navigateToAddReminder(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onViewAll,
            icon: const Icon(Icons.list, size: 18),
            label: const Text('View All'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToAddReminder(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddReminderScreen(),
      ),
    );
  }
}

/// Individual reminder item in quick card
class _ReminderQuickItem extends StatelessWidget {
  final Reminder reminder;

  const _ReminderQuickItem({required this.reminder});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getReminderColor(reminder.type).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getReminderColor(reminder.type).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getReminderColor(reminder.type).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                _getReminderEmoji(reminder.type),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (reminder.nextOccurrence != null)
                  Text(
                    _formatTime(reminder.nextOccurrence!),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          _ReminderQuickActions(reminder: reminder),
        ],
      ),
    );
  }

  Color _getReminderColor(ReminderType type) {
    switch (type) {
      case ReminderType.cyclePrediction: return Colors.pink;
      case ReminderType.medication: return Colors.blue;
      case ReminderType.appointment: return Colors.green;
      case ReminderType.symptomTracking: return Colors.purple;
      case ReminderType.waterIntake: return Colors.cyan;
      case ReminderType.exercise: return Colors.orange;
      case ReminderType.selfCare: return Colors.indigo;
      case ReminderType.custom: return Colors.grey;
    }
  }

  String _getReminderEmoji(ReminderType type) {
    switch (type) {
      case ReminderType.cyclePrediction: return '🌸';
      case ReminderType.medication: return '💊';
      case ReminderType.appointment: return '📅';
      case ReminderType.symptomTracking: return '📝';
      case ReminderType.waterIntake: return '💧';
      case ReminderType.exercise: return '🏃‍♀️';
      case ReminderType.selfCare: return '🧘‍♀️';
      case ReminderType.custom: return '⏰';
    }
  }

  String _formatTime(DateTime time) {
    return DateFormat.jm().format(time);
  }
}

/// Quick action buttons for reminder items
class _ReminderQuickActions extends StatelessWidget {
  final Reminder reminder;

  const _ReminderQuickActions({required this.reminder});

  @override
  Widget build(BuildContext context) {
    if (reminder.status != ReminderStatus.active) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.check_circle_outline, size: 20),
          onPressed: () => _completeReminder(context),
          color: Colors.green,
          visualDensity: VisualDensity.compact,
          tooltip: 'Complete',
        ),
        IconButton(
          icon: const Icon(Icons.snooze, size: 20),
          onPressed: () => _snoozeReminder(context),
          color: Colors.orange,
          visualDensity: VisualDensity.compact,
          tooltip: 'Snooze 15m',
        ),
      ],
    );
  }

  Future<void> _completeReminder(BuildContext context) async {
    final success = await ReminderService.instance.markReminderCompleted(reminder.id);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ ${reminder.title} completed'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _snoozeReminder(BuildContext context) async {
    final success = await ReminderService.instance.snoozeReminder(
      reminder.id,
      const Duration(minutes: 15),
    );
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⏰ ${reminder.title} snoozed for 15 minutes'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

/// Floating action button with reminder quick actions
class ReminderQuickActionFAB extends StatelessWidget {
  const ReminderQuickActionFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showQuickActionMenu(context),
      icon: const Icon(Icons.alarm_add),
      label: const Text('Quick Reminder'),
      backgroundColor: Colors.pink,
      foregroundColor: Colors.white,
    );
  }

  void _showQuickActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _QuickActionBottomSheet(),
    );
  }
}

/// Bottom sheet with quick reminder actions
class _QuickActionBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                childAspectRatio: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildQuickActionButton(
                    context,
                    icon: Icons.event,
                    label: 'Period Reminder',
                    color: Colors.pink,
                    onTap: () => _createPeriodReminder(context),
                  ),
                  _buildQuickActionButton(
                    context,
                    icon: Icons.medication,
                    label: 'Pill Reminder',
                    color: Colors.blue,
                    onTap: () => _createMedicationReminder(context),
                  ),
                  _buildQuickActionButton(
                    context,
                    icon: Icons.local_hospital,
                    label: 'Doctor Visit',
                    color: Colors.green,
                    onTap: () => _createAppointmentReminder(context),
                  ),
                  _buildQuickActionButton(
                    context,
                    icon: Icons.self_improvement,
                    label: 'Self Care',
                    color: Colors.indigo,
                    onTap: () => _createSelfCareReminder(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddReminderScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create Custom Reminder'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createPeriodReminder(BuildContext context) {
    Navigator.pop(context);
    final template = ReminderTemplates.getTemplate('period_start');
    if (template != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddReminderScreen(template: template),
        ),
      );
    }
  }

  void _createMedicationReminder(BuildContext context) {
    Navigator.pop(context);
    final template = ReminderTemplates.getTemplate('birth_control');
    if (template != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddReminderScreen(template: template),
        ),
      );
    }
  }

  void _createAppointmentReminder(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddReminderScreen(),
      ),
    );
  }

  void _createSelfCareReminder(BuildContext context) {
    Navigator.pop(context);
    final template = ReminderTemplates.getTemplate('self_care');
    if (template != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddReminderScreen(template: template),
        ),
      );
    }
  }
}

/// Widget for showing reminder statistics
class ReminderStatsWidget extends StatelessWidget {
  const ReminderStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: ReminderService.instance.getReminderStatistics(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final stats = snapshot.data!;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.analytics, color: Colors.pink),
                    SizedBox(width: 8),
                    Text(
                      'Reminder Statistics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Total',
                        '${stats['total'] ?? 0}',
                        Icons.alarm,
                        Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Active',
                        '${stats['active'] ?? 0}',
                        Icons.notifications_active,
                        Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Completed Today',
                        '${stats['completed_today'] ?? 0}',
                        Icons.check_circle,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Completion Rate: '),
                    Text(
                      '${((stats['completion_rate'] ?? 0.0) * 100).round()}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _showDetailedStats(context, stats),
                      child: const Text('View Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showDetailedStats(BuildContext context, Map<String, dynamic> stats) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detailed Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Reminders: ${stats['total'] ?? 0}'),
            Text('Active Reminders: ${stats['active'] ?? 0}'),
            Text('Completed Today: ${stats['completed_today'] ?? 0}'),
            Text('Completion Rate: ${((stats['completion_rate'] ?? 0.0) * 100).round()}%'),
            const SizedBox(height: 16),
            const Text('By Type:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...((stats['by_type'] as Map<String, int>? ?? {}).entries.map(
              (entry) => Text('${entry.key}: ${entry.value}'),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Permission banner widget
class NotificationPermissionBanner extends StatefulWidget {
  const NotificationPermissionBanner({super.key});

  @override
  State<NotificationPermissionBanner> createState() => _NotificationPermissionBannerState();
}

class _NotificationPermissionBannerState extends State<NotificationPermissionBanner> {
  bool _hasPermission = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final hasPermission = await NotificationPermissionService.instance
        .hasNotificationPermission();
    if (mounted) {
      setState(() {
        _hasPermission = hasPermission;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasPermission) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_off, color: Colors.orange),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enable Notifications',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                Text(
                  'Get reminders for periods, medications, and more',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _isLoading ? null : _requestPermission,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Enable'),
          ),
        ],
      ),
    );
  }

  Future<void> _requestPermission() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await NotificationPermissionService.instance
          .handlePermissionFlow(context);

      if (mounted) {
        if (result.isGranted) {
          setState(() {
            _hasPermission = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.displayMessage),
              backgroundColor: result.displayColor,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
