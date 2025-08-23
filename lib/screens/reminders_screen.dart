import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reminder_models.dart';
import '../services/reminder_service.dart';
import '../widgets/common/app_bar.dart';
import '../widgets/common/loading_indicator.dart';
import '../widgets/common/empty_state.dart';
import 'add_reminder_screen.dart';
import 'edit_reminder_screen.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ReminderService _reminderService = ReminderService.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _requestNotificationPermissions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _requestNotificationPermissions() async {
    await _reminderService.requestNotificationPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Reminders',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showReminderSettings(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildQuickStats(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllReminders(),
                _buildTodayReminders(),
                _buildTemplates(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddReminder(context),
        icon: const Icon(Icons.add),
        label: const Text('New Reminder'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: FutureBuilder<List<Reminder>>(
        future: _reminderService.getTodaysReminders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();

          final todayCount = snapshot.data!.length;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Today', '$todayCount', Icons.today),
              _buildDivider(),
              StreamBuilder<List<Reminder>>(
                stream: _reminderService.getUserReminders(
                  status: ReminderStatus.active,
                ),
                builder: (context, snapshot) {
                  final activeCount = snapshot.data?.length ?? 0;
                  return _buildStatItem('Active', '$activeCount', Icons.alarm);
                },
              ),
              _buildDivider(),
              _buildStatItem('Completed', '0', Icons.check_circle),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Theme.of(
        context,
      ).colorScheme.onPrimaryContainer.withValues(alpha: 0.3),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: 0.6),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            width: 2.0,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Today'),
          Tab(text: 'Templates'),
        ],
      ),
    );
  }

  Widget _buildAllReminders() {
    return StreamBuilder<List<Reminder>>(
      stream: _reminderService.getUserReminders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return EmptyState(
            icon: Icons.alarm_off,
            title: 'No Reminders Yet',
            subtitle:
                'Create your first reminder to stay on track with your cycle.',
            actionText: 'Add Reminder',
            onActionPressed: () => _navigateToAddReminder(context),
          );
        }

        return _buildRemindersList(snapshot.data!);
      },
    );
  }

  Widget _buildTodayReminders() {
    return FutureBuilder<List<Reminder>>(
      future: _reminderService.getTodaysReminders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return EmptyState(
            icon: Icons.today,
            title: 'No Reminders Today',
            subtitle: 'You\'re all set for today! Check back tomorrow.',
          );
        }

        return _buildRemindersList(snapshot.data!);
      },
    );
  }

  Widget _buildRemindersList(List<Reminder> reminders) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final reminder = reminders[index];
          return _buildReminderCard(reminder);
        },
      ),
    );
  }

  Widget _buildReminderCard(Reminder reminder) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToEditReminder(context, reminder),
        child: Padding(
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
                      color: _getReminderColor(
                        reminder.type,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        _getReminderEmoji(reminder.type),
                        style: const TextStyle(fontSize: 20),
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
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (reminder.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            reminder.description!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  _buildReminderActions(reminder),
                ],
              ),
              const SizedBox(height: 12),
              _buildReminderDetails(reminder),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderActions(Reminder reminder) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (reminder.status == ReminderStatus.active) ...[
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () => _completeReminder(reminder),
            color: Colors.green,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: const Icon(Icons.snooze),
            onPressed: () => _snoozeReminder(reminder),
            color: Colors.orange,
            visualDensity: VisualDensity.compact,
          ),
        ],
        PopupMenuButton<String>(
          onSelected: (value) => _handleReminderAction(reminder, value),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
          child: const Icon(Icons.more_vert),
        ),
      ],
    );
  }

  Widget _buildReminderDetails(Reminder reminder) {
    final nextTime = reminder.nextOccurrence;
    final frequency = _getFrequencyDisplayText(reminder.frequency);

    return Row(
      children: [
        _buildDetailChip(
          frequency,
          Icons.repeat,
          _getReminderColor(reminder.type),
        ),
        const SizedBox(width: 8),
        if (nextTime != null) ...[
          _buildDetailChip(
            _formatNextOccurrence(nextTime),
            Icons.schedule,
            Colors.blue,
          ),
        ],
        const Spacer(),
        _buildPriorityIndicator(reminder.priority),
      ],
    );
  }

  Widget _buildDetailChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityIndicator(ReminderPriority priority) {
    Color color;
    IconData icon;

    switch (priority) {
      case ReminderPriority.low:
        color = Colors.green;
        icon = Icons.low_priority;
        break;
      case ReminderPriority.medium:
        color = Colors.orange;
        icon = Icons.priority_high;
        break;
      case ReminderPriority.high:
        color = Colors.red;
        icon = Icons.priority_high;
        break;
      case ReminderPriority.critical:
        color = Colors.red.shade800;
        icon = Icons.warning;
        break;
    }

    return Icon(icon, color: color, size: 18);
  }

  Widget _buildTemplates() {
    final templates = ReminderTemplates.templates;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return _buildTemplateCard(template);
      },
    );
  }

  Widget _buildTemplateCard(ReminderTemplate template) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _createFromTemplate(template),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getReminderColor(
                    template.type,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    _getReminderEmoji(template.type),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      template.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.add_circle_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getReminderColor(ReminderType type) {
    switch (type) {
      case ReminderType.cyclePrediction:
        return Colors.pink;
      case ReminderType.medication:
        return Colors.blue;
      case ReminderType.appointment:
        return Colors.green;
      case ReminderType.symptomTracking:
        return Colors.purple;
      case ReminderType.waterIntake:
        return Colors.cyan;
      case ReminderType.exercise:
        return Colors.orange;
      case ReminderType.selfCare:
        return Colors.indigo;
      case ReminderType.custom:
        return Colors.grey;
    }
  }

  String _getReminderEmoji(ReminderType type) {
    switch (type) {
      case ReminderType.cyclePrediction:
        return '🌸';
      case ReminderType.medication:
        return '💊';
      case ReminderType.appointment:
        return '📅';
      case ReminderType.symptomTracking:
        return '📝';
      case ReminderType.waterIntake:
        return '💧';
      case ReminderType.exercise:
        return '🏃‍♀️';
      case ReminderType.selfCare:
        return '🧘‍♀️';
      case ReminderType.custom:
        return '⏰';
    }
  }

  String _getFrequencyDisplayText(ReminderFrequency frequency) {
    switch (frequency) {
      case ReminderFrequency.once:
        return 'Once';
      case ReminderFrequency.daily:
        return 'Daily';
      case ReminderFrequency.weekly:
        return 'Weekly';
      case ReminderFrequency.monthly:
        return 'Monthly';
      case ReminderFrequency.cycleStart:
        return 'Each Cycle';
      case ReminderFrequency.ovulation:
        return 'Ovulation';
      case ReminderFrequency.custom:
        return 'Custom';
    }
  }

  String _formatNextOccurrence(DateTime nextTime) {
    final now = DateTime.now();
    final difference = nextTime.difference(now);

    if (difference.inDays == 0) {
      return 'Today ${DateFormat.jm().format(nextTime)}';
    } else if (difference.inDays == 1) {
      return 'Tomorrow ${DateFormat.jm().format(nextTime)}';
    } else if (difference.inDays < 7) {
      return '${DateFormat.E().format(nextTime)} ${DateFormat.jm().format(nextTime)}';
    } else {
      return DateFormat.MMMd().add_jm().format(nextTime);
    }
  }

  void _navigateToAddReminder(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddReminderScreen()),
    );
  }

  void _navigateToEditReminder(BuildContext context, Reminder reminder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditReminderScreen(reminder: reminder),
      ),
    );
  }

  Future<void> _completeReminder(Reminder reminder) async {
    final success = await _reminderService.markReminderCompleted(reminder.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ ${reminder.title} completed'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _snoozeReminder(Reminder reminder) async {
    final success = await _reminderService.snoozeReminder(
      reminder.id,
      const Duration(minutes: 15),
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⏰ ${reminder.title} snoozed for 15 minutes'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _handleReminderAction(Reminder reminder, String action) {
    switch (action) {
      case 'edit':
        _navigateToEditReminder(context, reminder);
        break;
      case 'duplicate':
        _duplicateReminder(reminder);
        break;
      case 'delete':
        _confirmDeleteReminder(reminder);
        break;
    }
  }

  Future<void> _duplicateReminder(Reminder reminder) async {
    final duplicated = reminder.copyWith(
      id: '',
      title: '${reminder.title} (Copy)',
      createdAt: DateTime.now(),
    );

    final id = await _reminderService.createReminder(duplicated);
    if (id != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reminder duplicated successfully'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _confirmDeleteReminder(Reminder reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text('Are you sure you want to delete "${reminder.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteReminder(reminder);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteReminder(Reminder reminder) async {
    final success = await _reminderService.deleteReminder(reminder.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${reminder.title} deleted'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createFromTemplate(ReminderTemplate template) async {
    final id = await _reminderService.createReminderFromTemplate(template);
    if (id != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${template.title} reminder created'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showReminderSettings(BuildContext context) {
    // Navigate to settings page
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reminder Settings'),
        content: const Text('Reminder settings will be implemented here.'),
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
