import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../services/theme_service.dart';
class CycleLoggingScreen extends StatefulWidget {
  const CycleLoggingScreen({super.key});

  @override
  State<CycleLoggingScreen> createState() => _CycleLoggingScreenState();
}

class _CycleLoggingScreenState extends State<CycleLoggingScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSaving = false;
  
  // Symptom tracking
  String _flow = 'Medium';
  double _moodLevel = 3.0; // 1-5 scale
  double _energyLevel = 3.0; // 1-5 scale
  double _painLevel = 1.0; // 1-5 scale
  Set<String> _symptoms = <String>{};
  String _notes = '';

  Future<void> _saveCycle() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick both start and end dates')),
      );
      return;
    }

    // Prevent double-saving
    if (_isSaving) {
      debugPrint('⚠️ Save already in progress, ignoring duplicate request');
      return;
    }

    setState(() => _isSaving = true);
    debugPrint('🟡 Starting save operation...');

    try {
      // Use the robust FirebaseService with shorter timeout for better UX
      await FirebaseService.saveCycle(
        startDate: _startDate!,
        endDate: _endDate!,
        timeout: const Duration(seconds: 15), // Shorter timeout for quicker feedback
      );

      debugPrint('✅ Save successful!');

      if (!mounted) {
        debugPrint('⚠️ Widget unmounted, skipping UI updates');
        return;
      }

      // Update notifications with latest cycle data
      try {
        final cycles = await FirebaseService.getCycles();
        await NotificationService.updateCycleNotifications(cycles);
        debugPrint('✅ Notifications updated successfully');
      } catch (e) {
        debugPrint('⚠️ Failed to update notifications: $e');
      }

      // Clear the form after successful save
      _startDate = null;
      _endDate = null;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cycle logged successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('❌ Error saving cycle: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');

      if (mounted) {
        String userMessage;
        if (e.toString().contains('timeout')) {
          userMessage = 'Save timed out. Please check your internet connection and try again.';
        } else if (e.toString().contains('permission-denied')) {
          userMessage = 'Permission denied. Please check your account settings.';
        } else if (e.toString().contains('network')) {
          userMessage = 'Network error. Please check your internet connection.';
        } else {
          userMessage = 'Failed to save: ${e.toString().split(':').last.trim()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _saveCycle(),
            ),
          ),
        );
      }
    } finally {
      debugPrint('🔁 Cleaning up save operation...');
      if (mounted) {
        setState(() => _isSaving = false);
        debugPrint('🔁 UI reset complete - isSaving: $_isSaving');
      } else {
        debugPrint('⚠️ Widget unmounted during cleanup');
      }
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final themeService = Provider.of<ThemeService>(context, listen: false);
    final isDarkMode = themeService.isDarkModeEnabled(context);
    final theme = Theme.of(context);
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: isDarkMode 
                ? theme.colorScheme.copyWith(
                    surface: const Color(0xFF2D2D2D),
                    onSurface: Colors.white,
                  )
                : theme.colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMMd();
    final themeService = Provider.of<ThemeService>(context);
    final isDarkMode = themeService.isDarkModeEnabled(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🩸 Log Your Cycle'),
        backgroundColor: isDarkMode 
            ? theme.colorScheme.surface 
            : theme.colorScheme.primaryContainer,
        foregroundColor: isDarkMode 
            ? theme.colorScheme.onSurface 
            : theme.colorScheme.onPrimaryContainer,
        elevation: isDarkMode ? 0 : 1,
      ),
      backgroundColor: themeService.getBackgroundColor(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode ? null : LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer.withOpacity(0.1),
              theme.colorScheme.background,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Date selection cards
              Card(
                elevation: isDarkMode ? 2 : 4,
                color: themeService.getSurfaceColor(context),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Select Cycle Dates',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: themeService.getTextColor(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Start date button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _pickDate(true),
                          icon: Icon(Icons.calendar_today, 
                              color: isDarkMode ? Colors.white : null),
                          label: Text(
                            _startDate == null
                                ? 'Pick Start Date'
                                : 'Start: ${dateFormat.format(_startDate!)}',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : null,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDarkMode 
                                ? theme.colorScheme.primary.withOpacity(0.8)
                                : theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // End date button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _pickDate(false),
                          icon: Icon(Icons.event, 
                              color: isDarkMode ? Colors.white : null),
                          label: Text(
                            _endDate == null
                                ? 'Pick End Date'
                                : 'End: ${dateFormat.format(_endDate!)}',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : null,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDarkMode 
                                ? theme.colorScheme.secondary.withOpacity(0.8)
                                : theme.colorScheme.secondary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveCycle,
                  icon: _isSaving
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDarkMode ? Colors.white : Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _isSaving ? 'Saving...' : 'Save Cycle',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode 
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: isDarkMode ? 4 : 8,
                    shadowColor: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Tips section
              if (_startDate == null || _endDate == null)
                Card(
                  color: isDarkMode 
                      ? theme.colorScheme.surfaceVariant.withOpacity(0.5)
                      : theme.colorScheme.primaryContainer.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: isDarkMode 
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tip: Select both start and end dates to log your complete cycle',
                            style: TextStyle(
                              color: isDarkMode 
                                  ? theme.colorScheme.onSurfaceVariant
                                  : theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
