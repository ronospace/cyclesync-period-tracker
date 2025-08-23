import 'package:flutter/material.dart';
import '../models/reminder_models.dart';
import '../services/reminder_service.dart';

class EditReminderScreen extends StatefulWidget {
  final Reminder reminder;

  const EditReminderScreen({super.key, required this.reminder});

  @override
  State<EditReminderScreen> createState() => _EditReminderScreenState();
}

class _EditReminderScreenState extends State<EditReminderScreen> {
  final ReminderService _reminderService = ReminderService.instance;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return _EditReminderForm(
      reminder: widget.reminder,
      onSave: _updateReminder,
      onDelete: _deleteReminder,
      isLoading: _isLoading,
    );
  }

  Future<bool> _updateReminder(Reminder updatedReminder) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _reminderService.updateReminder(updatedReminder);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ ${updatedReminder.title} updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
        return true;
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update reminder'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }

    return false;
  }

  Future<void> _deleteReminder() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text(
          'Are you sure you want to delete "${widget.reminder.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await _reminderService.deleteReminder(
          widget.reminder.id,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.reminder.title} deleted'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context);
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
}

class _EditReminderForm extends StatefulWidget {
  final Reminder reminder;
  final Future<bool> Function(Reminder) onSave;
  final Future<void> Function() onDelete;
  final bool isLoading;

  const _EditReminderForm({
    required this.reminder,
    required this.onSave,
    required this.onDelete,
    required this.isLoading,
  });

  @override
  State<_EditReminderForm> createState() => _EditReminderFormState();
}

class _EditReminderFormState extends State<_EditReminderForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _messageController;

  late ReminderType _selectedType;
  late ReminderFrequency _selectedFrequency;
  late ReminderPriority _selectedPriority;
  late NotificationSound _selectedSound;

  DateTime? _scheduledFor;
  List<DateTime> _notificationTimes = [];
  List<WeekDay> _selectedWeekDays = [];
  int? _customIntervalDays;
  int? _customIntervalHours;
  late bool _vibrate;

  @override
  void initState() {
    super.initState();
    _initializeFromReminder();
  }

  void _initializeFromReminder() {
    final reminder = widget.reminder;

    _titleController = TextEditingController(text: reminder.title);
    _descriptionController = TextEditingController(
      text: reminder.description ?? '',
    );
    _messageController = TextEditingController(
      text: reminder.customMessage ?? '',
    );

    _selectedType = reminder.type;
    _selectedFrequency = reminder.frequency;
    _selectedPriority = reminder.priority;
    _selectedSound = reminder.sound;
    _scheduledFor = reminder.scheduledFor;
    _notificationTimes = List.from(reminder.notificationTimes);
    _selectedWeekDays = List.from(reminder.weeklyDays ?? []);
    _customIntervalDays = reminder.customIntervalDays;
    _customIntervalHours = reminder.customIntervalHours;
    _vibrate = reminder.vibrate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Reminder'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: widget.isLoading ? null : widget.onDelete,
            color: Colors.red,
          ),
          TextButton(
            onPressed: widget.isLoading ? null : _saveReminder,
            child: widget.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBasicInfo(),
            const SizedBox(height: 24),
            _buildTypeSelection(),
            const SizedBox(height: 24),
            _buildScheduling(),
            const SizedBox(height: 24),
            _buildNotificationSettings(),
            const SizedBox(height: 24),
            _buildAdvancedOptions(),
            const SizedBox(height: 24),
            _buildReminderStats(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter reminder title',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Add more details...',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reminder Type',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ReminderType.values.map((type) {
                final isSelected = _selectedType == type;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_getReminderEmoji(type)),
                      const SizedBox(width: 4),
                      Text(_getReminderTypeName(type)),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedType = type;
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduling() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Schedule',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildFrequencySelection(),
            const SizedBox(height: 16),
            _buildScheduleDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencySelection() {
    return DropdownButtonFormField<ReminderFrequency>(
      value: _selectedFrequency,
      decoration: const InputDecoration(
        labelText: 'Frequency',
        prefixIcon: Icon(Icons.repeat),
      ),
      items: ReminderFrequency.values.map((frequency) {
        return DropdownMenuItem(
          value: frequency,
          child: Text(_getFrequencyDisplayName(frequency)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedFrequency = value;
            _resetFrequencySpecificFields();
          });
        }
      },
    );
  }

  Widget _buildScheduleDetails() {
    // Similar implementation to AddReminderScreen but using existing data
    switch (_selectedFrequency) {
      case ReminderFrequency.once:
        return _buildOnceSchedule();
      case ReminderFrequency.daily:
        return _buildDailySchedule();
      case ReminderFrequency.weekly:
        return _buildWeeklySchedule();
      case ReminderFrequency.monthly:
        return _buildMonthlySchedule();
      case ReminderFrequency.custom:
        return _buildCustomSchedule();
      case ReminderFrequency.cycleStart:
      case ReminderFrequency.ovulation:
        return _buildCycleBasedSchedule();
    }
  }

  Widget _buildNotificationSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Settings',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ReminderPriority>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                prefixIcon: Icon(Icons.flag),
              ),
              items: ReminderPriority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Row(
                    children: [
                      Icon(
                        _getPriorityIcon(priority),
                        color: _getPriorityColor(priority),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(_getPriorityName(priority)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPriority = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<NotificationSound>(
              value: _selectedSound,
              decoration: const InputDecoration(
                labelText: 'Sound',
                prefixIcon: Icon(Icons.music_note),
              ),
              items: NotificationSound.values.map((sound) {
                return DropdownMenuItem(
                  value: sound,
                  child: Text(_getSoundName(sound)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedSound = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Vibrate'),
              subtitle: const Text('Enable vibration for this reminder'),
              value: _vibrate,
              onChanged: (value) {
                setState(() {
                  _vibrate = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedOptions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advanced Options',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Custom Message (Optional)',
                hintText: 'Custom notification message',
                prefixIcon: Icon(Icons.message),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderStats() {
    final reminder = widget.reminder;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Triggered',
                    '${reminder.timesTriggered}',
                    Icons.notifications,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Completed',
                    '${reminder.timesCompleted}',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Missed',
                    '${reminder.timesMissed}',
                    Icons.cancel,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  // Schedule detail widgets (same as AddReminderScreen)
  Widget _buildOnceSchedule() {
    return ListTile(
      leading: const Icon(Icons.calendar_today),
      title: const Text('Date & Time'),
      subtitle: Text(
        _scheduledFor != null
            ? '${_scheduledFor!.day}/${_scheduledFor!.month}/${_scheduledFor!.year} ${_scheduledFor!.hour}:${_scheduledFor!.minute.toString().padLeft(2, '0')}'
            : 'Tap to select',
      ),
      onTap: _selectDateTime,
    );
  }

  Widget _buildDailySchedule() {
    return const Text('Daily schedule UI would go here');
  }

  Widget _buildWeeklySchedule() {
    return const Text('Weekly schedule UI would go here');
  }

  Widget _buildMonthlySchedule() {
    return const Text('Monthly schedule UI would go here');
  }

  Widget _buildCustomSchedule() {
    return const Text('Custom schedule UI would go here');
  }

  Widget _buildCycleBasedSchedule() {
    return const Text('Cycle-based schedule UI would go here');
  }

  void _resetFrequencySpecificFields() {
    _scheduledFor = null;
    _notificationTimes.clear();
    _selectedWeekDays.clear();
    _customIntervalDays = null;
    _customIntervalHours = null;
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledFor ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: _scheduledFor != null
            ? TimeOfDay.fromDateTime(_scheduledFor!)
            : TimeOfDay.now(),
      );

      if (time != null && mounted) {
        setState(() {
          _scheduledFor = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedReminder = widget.reminder.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      type: _selectedType,
      frequency: _selectedFrequency,
      priority: _selectedPriority,
      scheduledFor: _scheduledFor,
      notificationTimes: _notificationTimes,
      weeklyDays: _selectedWeekDays.isEmpty ? null : _selectedWeekDays,
      customIntervalDays: _customIntervalDays,
      customIntervalHours: _customIntervalHours,
      sound: _selectedSound,
      vibrate: _vibrate,
      customMessage: _messageController.text.trim().isEmpty
          ? null
          : _messageController.text.trim(),
    );

    await widget.onSave(updatedReminder);
  }

  // Helper methods (same as AddReminderScreen)
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

  String _getReminderTypeName(ReminderType type) {
    switch (type) {
      case ReminderType.cyclePrediction:
        return 'Cycle';
      case ReminderType.medication:
        return 'Medication';
      case ReminderType.appointment:
        return 'Appointment';
      case ReminderType.symptomTracking:
        return 'Tracking';
      case ReminderType.waterIntake:
        return 'Hydration';
      case ReminderType.exercise:
        return 'Exercise';
      case ReminderType.selfCare:
        return 'Self Care';
      case ReminderType.custom:
        return 'Custom';
    }
  }

  String _getFrequencyDisplayName(ReminderFrequency frequency) {
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
        return 'Each Cycle Start';
      case ReminderFrequency.ovulation:
        return 'Ovulation Period';
      case ReminderFrequency.custom:
        return 'Custom Interval';
    }
  }

  String _getPriorityName(ReminderPriority priority) {
    switch (priority) {
      case ReminderPriority.low:
        return 'Low';
      case ReminderPriority.medium:
        return 'Medium';
      case ReminderPriority.high:
        return 'High';
      case ReminderPriority.critical:
        return 'Critical';
    }
  }

  IconData _getPriorityIcon(ReminderPriority priority) {
    switch (priority) {
      case ReminderPriority.low:
        return Icons.low_priority;
      case ReminderPriority.medium:
        return Icons.priority_high;
      case ReminderPriority.high:
        return Icons.priority_high;
      case ReminderPriority.critical:
        return Icons.warning;
    }
  }

  Color _getPriorityColor(ReminderPriority priority) {
    switch (priority) {
      case ReminderPriority.low:
        return Colors.green;
      case ReminderPriority.medium:
        return Colors.orange;
      case ReminderPriority.high:
        return Colors.red;
      case ReminderPriority.critical:
        return Colors.red.shade800;
    }
  }

  String _getSoundName(NotificationSound sound) {
    switch (sound) {
      case NotificationSound.defaultSound:
        return 'Default';
      case NotificationSound.gentle:
        return 'Gentle';
      case NotificationSound.chime:
        return 'Chime';
      case NotificationSound.bell:
        return 'Bell';
      case NotificationSound.nature:
        return 'Nature';
      case NotificationSound.silent:
        return 'Silent';
    }
  }
}
