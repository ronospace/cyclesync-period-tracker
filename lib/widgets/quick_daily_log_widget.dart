import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../models/daily_log_models.dart';
import '../services/firebase_service.dart';
import '../l10n/generated/app_localizations.dart';

class QuickDailyLogWidget extends StatefulWidget {
  final DateTime? selectedDate;
  final VoidCallback? onLogSaved;

  const QuickDailyLogWidget({super.key, this.selectedDate, this.onLogSaved});

  @override
  State<QuickDailyLogWidget> createState() => _QuickDailyLogWidgetState();
}

class _QuickDailyLogWidgetState extends State<QuickDailyLogWidget> {
  late DateTime _selectedDate;
  DailyLogEntry? _existingLog;
  bool _isLoading = true;
  bool _isSaving = false;

  double? _mood;
  double? _energy;
  double? _pain;
  List<String> _symptoms = [];
  String _notes = '';

  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
    _loadExistingLog();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingLog() async {
    setState(() => _isLoading = true);

    try {
      final logData = await FirebaseService.getDailyLogForDate(
        date: _selectedDate,
      );

      if (logData != null) {
        final log = DailyLogEntry(
          id: logData['id'],
          date: DateTime.parse(logData['date']),
          mood: logData['mood']?.toDouble(),
          energy: logData['energy']?.toDouble(),
          pain: logData['pain']?.toDouble(),
          symptoms: List<String>.from(logData['symptoms'] ?? []),
          notes: logData['notes'] ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        setState(() {
          _existingLog = log;
          _mood = log.mood;
          _energy = log.energy;
          _pain = log.pain;
          _symptoms = List.from(log.symptoms);
          _notes = log.notes;
          _notesController.text = log.notes;
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.failedToLoadExistingLog(e.toString()) ??
                  'Failed to load existing log: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveLog() async {
    setState(() => _isSaving = true);

    try {
      final dailyLogData = {
        'date': _selectedDate,
        'mood_level': _mood,
        'energy_level': _energy,
        'pain_level': _pain,
        'symptoms': _symptoms.isEmpty ? null : _symptoms,
        'notes': _notes.isEmpty ? null : _notes,
        'created_at': DateTime.now().toIso8601String(),
      };

      await FirebaseService.saveDailyLog(dailyLogData);

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(l10n.dailyLogSaved ?? 'Daily log saved!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        widget.onLogSaved?.call();

        // Navigate to onboarding completion screen for next steps
        context.go('/onboarding-complete');
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.failedToSaveLog(e.toString()) ?? 'Failed to save log: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _applyTemplate(QuickLogTemplate template) {
    setState(() {
      _mood = template.mood;
      _energy = template.energy;
      _pain = template.pain;
      _symptoms = List.from(template.symptoms);
      _notes = template.notes;
      _notesController.text = template.notes;
    });
  }

  Widget _buildMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.mood, color: Colors.purple.shade600, size: 20),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).mood ?? 'Mood',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            if (_mood != null) ...[
              const Spacer(),
              Text(
                DailyLogEntry(
                  id: '',
                  date: _selectedDate,
                  mood: _mood,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ).moodDescription,
                style: TextStyle(
                  color: DailyLogEntry(
                    id: '',
                    date: _selectedDate,
                    mood: _mood,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ).moodColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: MoodRating.all.map((rating) {
            final isSelected = _mood == rating.value;
            return GestureDetector(
              onTap: () => setState(() => _mood = rating.value),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? rating.color.withValues(alpha: 0.2)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? rating.color : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Icon(
                  rating.icon,
                  color: isSelected ? rating.color : Colors.grey.shade600,
                  size: 24,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSliderSection(
    String label,
    IconData icon,
    Color color,
    double? value,
    Function(double) onChanged,
    List<String> descriptions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            if (value != null) ...[
              const Spacer(),
              Text(
                descriptions[value.toInt() - 1],
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value ?? 3.0,
          min: 1.0,
          max: 5.0,
          divisions: 4,
          activeColor: color,
          inactiveColor: color.withValues(alpha: 0.3),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildQuickTemplates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).quickLogTemplates ??
              'Quick Log Templates',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: QuickLogTemplate.getDefaultTemplates().map((template) {
            return GestureDetector(
              onTap: () => _applyTemplate(template),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: template.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: template.color.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(template.icon, color: template.color, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      template.name,
                      style: TextStyle(
                        color: template.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.today, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Text(
                  '${AppLocalizations.of(context).dailyLogTitle ?? 'Daily Log'} - ${DateFormat.yMMMd().format(_selectedDate)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_existingLog != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      AppLocalizations.of(context).updated ?? 'Updated',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Quick Templates
            _buildQuickTemplates(),

            const SizedBox(height: 16),

            // Mood Selector
            _buildMoodSelector(),

            const SizedBox(height: 16),

            // Energy Slider
            _buildSliderSection(
              AppLocalizations.of(context).energy ?? 'Energy',
              Icons.battery_charging_full,
              Colors.orange.shade600,
              _energy,
              (value) => setState(() => _energy = value),
              ['Exhausted', 'Low', 'Okay', 'Good', 'High'],
            ),

            const SizedBox(height: 16),

            // Pain Slider
            _buildSliderSection(
              AppLocalizations.of(context).painLevel ?? 'Pain Level',
              Icons.healing,
              Colors.red.shade600,
              _pain,
              (value) => setState(() => _pain = value),
              ['None', 'Mild', 'Moderate', 'Severe', 'Extreme'],
            ),

            const SizedBox(height: 16),

            // Notes
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText:
                    AppLocalizations.of(context).notesOptional ??
                    'Notes (optional)',
                hintText:
                    AppLocalizations.of(context).howAreYouFeelingToday ??
                    'How are you feeling today?',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.note, color: Colors.grey.shade600),
              ),
              maxLines: 2,
              onChanged: (value) => _notes = value,
            ),

            const SizedBox(height: 16),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveLog,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _isSaving
                      ? (AppLocalizations.of(context).saving ?? 'Saving...')
                      : (AppLocalizations.of(context).saveDailyLog ??
                            'Save Daily Log'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
