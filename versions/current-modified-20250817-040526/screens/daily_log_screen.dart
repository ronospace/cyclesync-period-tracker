import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/daily_log_models.dart';
import '../models/cycle_models.dart';
import '../services/firebase_service.dart';
import '../widgets/quick_daily_log_widget.dart';
import '../l10n/generated/app_localizations.dart';

class DailyLogScreen extends StatefulWidget {
  const DailyLogScreen({super.key});

  @override
  State<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends State<DailyLogScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  List<DailyLogEntry> _recentLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRecentLogs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentLogs() async {
    setState(() => _isLoading = true);
    
    try {
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      
      final logsData = await FirebaseService.getDailyLogs(
        startDate: thirtyDaysAgo,
        endDate: now,
        limit: 30,
      );
      
      final logs = logsData.map((data) {
        return DailyLogEntry(
          id: data['id'],
          date: DateTime.parse(data['date']),
          mood: data['mood']?.toDouble(),
          energy: data['energy']?.toDouble(),
          pain: data['pain']?.toDouble(),
          symptoms: List<String>.from(data['symptoms'] ?? []),
          notes: data['notes'] ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList();
      
      setState(() {
        _recentLogs = logs;
      });
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToLoadLogs(e.toString()) ?? 'Failed to load logs: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildQuickLogTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Date Selector
          Card(
            child: ListTile(
              leading: Icon(Icons.calendar_today, color: Colors.blue.shade600),
              title: Text(AppLocalizations.of(context).selectedDate ?? 'Selected Date'),
              subtitle: Text(DateFormat.yMMMEd().format(_selectedDate)),
              trailing: Icon(Icons.chevron_right, color: Colors.grey.shade600),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Quick Log Widget
          QuickDailyLogWidget(
            selectedDate: _selectedDate,
            onLogSaved: _loadRecentLogs,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_recentLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).noDailyLogsYet ?? 'No daily logs yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).startLoggingDailyMood ?? 'Start logging your daily mood and energy',
              style: TextStyle(color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _tabController.animateTo(0),
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context).logToday ?? 'Log Today'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRecentLogs,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _recentLogs.length,
        itemBuilder: (context, index) {
          final log = _recentLogs[index];
          return _buildLogCard(log);
        },
      ),
    );
  }

  Widget _buildLogCard(DailyLogEntry log) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                  DateFormat.yMMMEd().format(log.date),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildOverallMoodIndicator(log),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Metrics
            Row(
              children: [
                if (log.mood != null)
                  Expanded(
                    child: _buildMetricChip(
                      'Mood',
                      log.moodDescription,
                      Icons.mood,
                      log.moodColor,
                    ),
                  ),
                if (log.energy != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricChip(
                      AppLocalizations.of(context).energy ?? 'Energy',
                      log.energyDescription,
                      Icons.battery_charging_full,
                      log.energyColor,
                    ),
                  ),
                ],
                if (log.pain != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricChip(
                      AppLocalizations.of(context).painLevel ?? 'Pain',
                      log.painDescription,
                      Icons.healing,
                      log.painColor,
                    ),
                  ),
                ],
              ],
            ),
            
            // Symptoms
            if (log.symptoms.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context).symptoms ?? 'Symptoms',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: log.symptoms.take(5).map((symptomName) {
                  final symptom = Symptom.fromName(symptomName);
                  if (symptom == null) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        symptomName,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: symptom.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: symptom.color.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(symptom.icon, size: 10, color: symptom.color),
                        const SizedBox(width: 4),
                        Text(
                          symptom.displayName,
                          style: TextStyle(
                            color: symptom.color,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              if (log.symptoms.length > 5)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+${log.symptoms.length - 5} more',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
            
            // Notes
            if (log.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).notes ?? 'Notes',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      log.notes,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallMoodIndicator(DailyLogEntry log) {
    if (log.mood == null) {
      return const SizedBox.shrink();
    }

    final moodRating = MoodRating.fromValue(log.mood!);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: moodRating.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        moodRating.icon,
        color: moodRating.color,
        size: 20,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📝 ${AppLocalizations.of(context).dailyLogTitle ?? 'Daily Log'}'),
        backgroundColor: Colors.blue.shade50,
        foregroundColor: Colors.blue.shade700,
        iconTheme: IconThemeData(color: Colors.blue.shade700),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue.shade700),
          onPressed: () => context.go('/home'),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue.shade700,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: Colors.blue.shade700,
          tabs: [
            Tab(
              icon: Icon(Icons.add_circle_outline),
              text: AppLocalizations.of(context).logToday ?? 'Log Today',
            ),
            Tab(
              icon: Icon(Icons.history),
              text: AppLocalizations.of(context).history ?? 'History',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.blue.shade700),
            onPressed: _loadRecentLogs,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQuickLogTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }
}
