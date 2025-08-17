import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reminder_models.dart';
import '../services/reminder_service.dart';
import '../widgets/common/app_bar.dart';

class AddReminderScreen extends StatefulWidget {
  final ReminderTemplate? template;

  const AddReminderScreen({super.key, this.template});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _messageController = TextEditingController();
  
  late ReminderType _selectedType;
  late ReminderFrequency _selectedFrequency;
  late ReminderPriority _selectedPriority;
  late NotificationSound _selectedSound;
  
  DateTime? _scheduledFor;
  List<DateTime> _notificationTimes = [];
  List<WeekDay> _selectedWeekDays = [];
  int? _customIntervalDays;
  int? _customIntervalHours;
  bool _vibrate = true;
  bool _isLoading = false;

  final ReminderService _reminderService = ReminderService.instance;

  @override
  void initState() {
    super.initState();
    _initializeFromTemplate();
  }

  void _initializeFromTemplate() {
    if (widget.template != null) {
      final template = widget.template!;
      _titleController.text = template.title;
      _descriptionController.text = template.description;
      _selectedType = template.type;
      _selectedFrequency = template.frequency;
      _selectedPriority = template.priority;
      _selectedSound = template.sound;
      _notificationTimes = List.from(template.defaultTimes);
    } else {
      _selectedType = ReminderType.custom;
      _selectedFrequency = ReminderFrequency.once;
      _selectedPriority = ReminderPriority.medium;
      _selectedSound = NotificationSound.defaultSound;
    }
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
      appBar: CustomAppBar(
        title: 'New Reminder',
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveReminder,
            child: _isLoading 
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
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

  Widget _buildOnceSchedule() {
    return ListTile(
      leading: const Icon(Icons.calendar_today),
      title: const Text('Date & Time'),
      subtitle: Text(
        _scheduledFor != null 
          ? DateFormat.yMMMd().add_jm().format(_scheduledFor!)
          : 'Tap to select',
      ),
      onTap: _selectDateTime,
    );
  }

  Widget _buildDailySchedule() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.access_time),
          title: const Text('Notification Times'),
          subtitle: Text(
            _notificationTimes.isEmpty
              ? 'Add notification times'
              : '${_notificationTimes.length} time(s) set',
          ),
          trailing: IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNotificationTime,
          ),
        ),
        if (_notificationTimes.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _notificationTimes.asMap().entries.map((entry) {
              final index = entry.key;
              final time = entry.value;
              return Chip(
                label: Text(DateFormat.jm().format(time)),
                onDeleted: () => _removeNotificationTime(index),
                deleteIcon: const Icon(Icons.close, size: 18),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildWeeklySchedule() {
    return Column(
      children: [
        const Text('Select days of the week:'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: WeekDay.values.map((day) {
            final isSelected = _selectedWeekDays.contains(day);
            return FilterChip(
              label: Text(_getWeekDayName(day)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedWeekDays.add(day);
                  } else {
                    _selectedWeekDays.remove(day);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _buildDailySchedule(),
      ],
    );
  }

  Widget _buildMonthlySchedule() {
    return _buildDailySchedule();
  }

  Widget _buildCustomSchedule() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Days',
                  hintText: '0',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _customIntervalDays = int.tryParse(value);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Hours',
                  hintText: '0',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _customIntervalHours = int.tryParse(value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDailySchedule(),
      ],
    );
  }

  Widget _buildCycleBasedSchedule() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome,
            color: Theme.of(context).colorScheme.primary,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFrequency == ReminderFrequency.cycleStart
              ? 'AI-Predicted Period Reminders'
              : 'AI-Predicted Fertility Reminders',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'This reminder will be automatically scheduled based on your cycle predictions.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
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
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
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

  Future<void> _addNotificationTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null && mounted) {
      final dateTime = DateTime(2024, 1, 1, time.hour, time.minute);
      setState(() {
        _notificationTimes.add(dateTime);
        _notificationTimes.sort((a, b) => a.compareTo(b));
      });
    }
  }

  void _removeNotificationTime(int index) {
    setState(() {
      _notificationTimes.removeAt(index);
    });
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Additional validation based on frequency
    if (!_validateFrequencySpecificFields()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final reminder = Reminder(
        id: '',
        userId: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
        type: _selectedType,
        frequency: _selectedFrequency,
        priority: _selectedPriority,
        createdAt: DateTime.now(),
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

      final id = await _reminderService.createReminder(reminder);
      
      if (id != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ ${reminder.title} created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create reminder'),
            backgroundColor: Colors.red,
          ),
        );
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _validateFrequencySpecificFields() {
    switch (_selectedFrequency) {
      case ReminderFrequency.once:
        if (_scheduledFor == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a date and time'),
              backgroundColor: Colors.orange,
            ),
          );
          return false;
        }
        break;
      case ReminderFrequency.daily:
        if (_notificationTimes.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please add at least one notification time'),
              backgroundColor: Colors.orange,
            ),
          );
          return false;
        }
        break;
      case ReminderFrequency.weekly:
        if (_selectedWeekDays.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select at least one day of the week'),
              backgroundColor: Colors.orange,
            ),
          );
          return false;
        }
        if (_notificationTimes.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please add at least one notification time'),
              backgroundColor: Colors.orange,
            ),
          );
          return false;
        }
        break;
      case ReminderFrequency.custom:
        if ((_customIntervalDays ?? 0) <= 0 && (_customIntervalHours ?? 0) <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please set a valid custom interval'),
              backgroundColor: Colors.orange,
            ),
          );
          return false;
        }
        break;
      default:
        break;
    }
    return true;
  }

  // Helper methods for display names and styling
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

  String _getReminderTypeName(ReminderType type) {
    switch (type) {
      case ReminderType.cyclePrediction: return 'Cycle';
      case ReminderType.medication: return 'Medication';
      case ReminderType.appointment: return 'Appointment';
      case ReminderType.symptomTracking: return 'Tracking';
      case ReminderType.waterIntake: return 'Hydration';
      case ReminderType.exercise: return 'Exercise';
      case ReminderType.selfCare: return 'Self Care';
      case ReminderType.custom: return 'Custom';
    }
  }

  String _getFrequencyDisplayName(ReminderFrequency frequency) {
    switch (frequency) {
      case ReminderFrequency.once: return 'Once';
      case ReminderFrequency.daily: return 'Daily';
      case ReminderFrequency.weekly: return 'Weekly';
      case ReminderFrequency.monthly: return 'Monthly';
      case ReminderFrequency.cycleStart: return 'Each Cycle Start';
      case ReminderFrequency.ovulation: return 'Ovulation Period';
      case ReminderFrequency.custom: return 'Custom Interval';
    }
  }

  String _getWeekDayName(WeekDay day) {
    switch (day) {
      case WeekDay.monday: return 'Mon';
      case WeekDay.tuesday: return 'Tue';
      case WeekDay.wednesday: return 'Wed';
      case WeekDay.thursday: return 'Thu';
      case WeekDay.friday: return 'Fri';
      case WeekDay.saturday: return 'Sat';
      case WeekDay.sunday: return 'Sun';
    }
  }

  String _getPriorityName(ReminderPriority priority) {
    switch (priority) {
      case ReminderPriority.low: return 'Low';
      case ReminderPriority.medium: return 'Medium';
      case ReminderPriority.high: return 'High';
      case ReminderPriority.critical: return 'Critical';
    }
  }

  IconData _getPriorityIcon(ReminderPriority priority) {
    switch (priority) {
      case ReminderPriority.low: return Icons.low_priority;
      case ReminderPriority.medium: return Icons.priority_high;
      case ReminderPriority.high: return Icons.priority_high;
      case ReminderPriority.critical: return Icons.warning;
    }
  }

  Color _getPriorityColor(ReminderPriority priority) {
    switch (priority) {
      case ReminderPriority.low: return Colors.green;
      case ReminderPriority.medium: return Colors.orange;
      case ReminderPriority.high: return Colors.red;
      case ReminderPriority.critical: return Colors.red.shade800;
    }
  }

  String _getSoundName(NotificationSound sound) {
    switch (sound) {
      case NotificationSound.defaultSound: return 'Default';
      case NotificationSound.gentle: return 'Gentle';
      case NotificationSound.chime: return 'Chime';
      case NotificationSound.bell: return 'Bell';
      case NotificationSound.nature: return 'Nature';
      case NotificationSound.silent: return 'Silent';
    }
  }
}
