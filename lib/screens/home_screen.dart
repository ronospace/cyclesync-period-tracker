import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../services/smart_notification_service.dart';
import '../services/theme_service.dart';
import '../theme/app_theme.dart';
import '../widgets/health_integration_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _recentCycles = [];
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _cycleStatus;
  Map<String, dynamic>? _predictions;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    // Trigger smart analysis after data loads
    _runSmartAnalysis();
  }

  Future<void> _runSmartAnalysis() async {
    // Run smart notification analysis in background
    try {
      await SmartNotificationService.runSmartAnalysis();
      debugPrint('🧠 Smart analysis completed on home screen');
    } catch (e) {
      debugPrint('❌ Smart analysis error: $e');
    }
  }

  // Helper method to parse DateTime from various formats
  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    
    if (value is DateTime) {
      return value;
    }
    
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('⚠️ Failed to parse DateTime from string: $value, error: $e');
        return null;
      }
    }
    
    // Handle Firestore Timestamp objects if needed
    if (value.runtimeType.toString().contains('Timestamp')) {
      try {
        return (value as dynamic).toDate();
      } catch (e) {
        print('⚠️ Failed to parse DateTime from Timestamp: $value, error: $e');
        return null;
      }
    }
    
    print('⚠️ Unknown DateTime format: ${value.runtimeType} - $value');
    return null;
  }

  Future<void> _loadDashboardData() async {
    try {
      final cycles = await FirebaseService.getCycles(limit: 5);
      final status = _calculateCycleStatus(cycles);
      final predictions = _calculatePredictions(cycles);
      
      setState(() {
        _recentCycles = cycles;
        _cycleStatus = status;
        _predictions = predictions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic>? _calculateCycleStatus(List<Map<String, dynamic>> cycles) {
    if (cycles.isEmpty) return null;
    
    final now = DateTime.now();
    final lastCycle = cycles.first;
    
    // Safe date parsing
    DateTime? startDate;
    DateTime? endDate;
    
    try {
      // Parse start date
      if (lastCycle['start'] != null) {
        if (lastCycle['start'] is DateTime) {
          startDate = lastCycle['start'];
        } else if (lastCycle['start_date'] != null) {
          startDate = _parseDateTime(lastCycle['start_date']);
        } else {
          startDate = _parseDateTime(lastCycle['start']);
        }
      }
      
      // Parse end date
      if (lastCycle['end'] != null) {
        if (lastCycle['end'] is DateTime) {
          endDate = lastCycle['end'];
        } else if (lastCycle['end_date'] != null) {
          endDate = _parseDateTime(lastCycle['end_date']);
        } else {
          endDate = _parseDateTime(lastCycle['end']);
        }
      }
    } catch (e) {
      print('Error parsing cycle dates in status calculation: $e');
      return null;
    }
    
    if (startDate == null) return null;
    
    // Calculate days since last period
    final daysSinceStart = now.difference(startDate).inDays;
    
    String phase;
    String description;
    Color color;
    IconData icon;
    
    if (endDate != null) {
      // Last cycle ended
      final daysSinceEnd = now.difference(endDate).inDays;
      
      if (daysSinceEnd < 0) {
        // Currently on period
        phase = 'Menstrual';
        description = 'Day ${daysSinceStart + 1} of your cycle';
        color = AppTheme.healthColors['menstruation']!;
        icon = Icons.water_drop;
      } else if (daysSinceEnd <= 7) {
        // Follicular phase
        phase = 'Follicular';
        description = 'Post-period recovery phase';
        color = AppTheme.healthColors['fertile']!;
        icon = Icons.eco;
      } else if (daysSinceEnd >= 10 && daysSinceEnd <= 16) {
        // Ovulation window (assuming 28-day cycle)
        phase = 'Ovulation';
        description = 'Fertile window - ovulation likely';
        color = AppTheme.healthColors['ovulation']!;
        icon = Icons.favorite;
      } else {
        // Luteal phase
        phase = 'Luteal';
        description = 'Pre-period phase';
        color = AppTheme.healthColors['luteal']!;
        icon = Icons.nightlight_round;
      }
    } else {
      // Current cycle ongoing
      phase = 'Menstrual';
      description = 'Day ${daysSinceStart + 1} of current cycle';
      color = Colors.red;
      icon = Icons.water_drop;
    }
    
    return {
      'phase': phase,
      'description': description,
      'color': color,
      'icon': icon,
      'daysSinceStart': daysSinceStart,
    };
  }

  Map<String, dynamic>? _calculatePredictions(List<Map<String, dynamic>> cycles) {
    if (cycles.length < 2) return null;
    
    // Calculate average cycle length
    int totalDays = 0;
    int completedCycles = 0;
    
    for (var cycle in cycles) {
      final start = _parseDateTime(cycle['start']) ?? _parseDateTime(cycle['start_date']);
      final end = _parseDateTime(cycle['end']) ?? _parseDateTime(cycle['end_date']);
      if (start != null && end != null) {
        totalDays += end.difference(start).inDays + 1;
        completedCycles++;
      }
    }
    
    if (completedCycles == 0) return null;
    
    final avgCycleLength = totalDays / completedCycles;
    final lastCycle = cycles.first;
    final lastStart = _parseDateTime(lastCycle['start']) ?? _parseDateTime(lastCycle['start_date']);
    final lastEnd = _parseDateTime(lastCycle['end']) ?? _parseDateTime(lastCycle['end_date']);
    
    if (lastStart == null) return null;
    
    DateTime? nextPeriodDate;
    DateTime? ovulationDate;
    DateTime? fertileWindowStart;
    DateTime? fertileWindowEnd;
    
    if (lastEnd != null) {
      // Calculate based on completed last cycle
      nextPeriodDate = lastEnd.add(Duration(days: avgCycleLength.round()));
    } else {
      // Current cycle ongoing, predict based on start
      nextPeriodDate = lastStart.add(Duration(days: avgCycleLength.round()));
    }
    
    // Ovulation typically 14 days before next period
    ovulationDate = nextPeriodDate.subtract(const Duration(days: 14));
    fertileWindowStart = ovulationDate.subtract(const Duration(days: 5));
    fertileWindowEnd = ovulationDate.add(const Duration(days: 1));
    
    return {
      'nextPeriod': nextPeriodDate,
      'ovulation': ovulationDate,
      'fertileStart': fertileWindowStart,
      'fertileEnd': fertileWindowEnd,
      'avgCycleLength': avgCycleLength.round(),
    };
  }

  Widget _buildWelcomeCard() {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? user?.email?.split('@')[0] ?? 'User';
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.pink.shade100,
                  child: Icon(
                    Icons.favorite,
                    color: Colors.pink.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $displayName!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Track your cycle with confidence',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleStatusCard() {
    if (_isLoading) {
      return const Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_cycleStatus == null) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.calendar_today, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Start Tracking Your Cycle',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Log your first cycle to see personalized insights and predictions.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.go('/log-cycle'),
                icon: const Icon(Icons.add),
                label: const Text('Log First Cycle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final status = _cycleStatus!;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              (status['color'] as Color).withOpacity(0.1),
              (status['color'] as Color).withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (status['color'] as Color).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      status['icon'] as IconData,
                      color: status['color'] as Color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${status['phase']} Phase',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: status['color'] as Color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          status['description'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPredictionsCard() {
    if (_isLoading || _predictions == null) {
      return const SizedBox.shrink();
    }

    final predictions = _predictions!;
    final now = DateTime.now();
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming Events',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Next Period
            _buildPredictionItem(
              icon: Icons.water_drop,
              color: Colors.red,
              title: 'Next Period',
              date: predictions['nextPeriod'] as DateTime,
              now: now,
            ),
            
            const SizedBox(height: 8),
            
            // Ovulation
            _buildPredictionItem(
              icon: Icons.favorite,
              color: Colors.orange,
              title: 'Ovulation',
              date: predictions['ovulation'] as DateTime,
              now: now,
            ),
            
            const SizedBox(height: 8),
            
            // Fertile Window
            Row(
              children: [
                Icon(Icons.eco, color: Colors.green, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fertile Window',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${_formatPredictionDate(predictions['fertileStart'] as DateTime, now)} - ${_formatPredictionDate(predictions['fertileEnd'] as DateTime, now)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionItem({
    required IconData icon,
    required Color color,
    required String title,
    required DateTime date,
    required DateTime now,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          _formatPredictionDate(date, now),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatPredictionDate(DateTime date, DateTime now) {
    final difference = date.difference(now).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference > 0) {
      return 'In $difference days';
    } else {
      final pastDays = -difference;
      if (pastDays == 1) {
        return 'Yesterday';
      } else {
        return '$pastDays days ago';
      }
    }
  }

  Widget _buildQuickActions() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.add_circle,
                    label: 'Log Cycle',
                    color: Colors.pink,
                    onTap: () => context.go('/log-cycle'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.history,
                    label: 'View History',
                    color: Colors.blue,
                    onTap: () => context.go('/cycle-history'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.calendar_month,
                    label: 'Calendar',
                    color: Colors.green,
                    onTap: () => context.go('/calendar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.analytics,
                    label: 'Analytics',
                    color: Colors.purple,
                    onTap: () => context.go('/analytics'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.psychology,
                    label: 'AI Insights',
                    color: Colors.deepPurple,
                    onTap: () => context.go('/ai-insights'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.edit_note,
                    label: 'Daily Log',
                    color: Colors.teal,
                    onTap: () => context.go('/daily-log'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.health_and_safety,
                    label: 'Health Insights',
                    color: Colors.red,
                    onTap: () => context.go('/health-insights'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.trending_up,
                    label: 'Symptom Trends',
                    color: Colors.amber,
                    onTap: () => context.go('/symptom-trends'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.smart_toy,
                    label: 'AI Health Coach',
                    color: Colors.indigo,
                    onTap: () => context.go('/ai-health-coach'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.settings,
                    label: 'Settings',
                    color: Colors.grey,
                    onTap: () => context.go('/settings'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCycles() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Cycles',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/cycle-history'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.orange,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              const Text('Unable to load recent cycles'),
                              TextButton(
                                onPressed: _loadDashboardData,
                                child: const Text('Try Again'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _recentCycles.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'No cycles logged yet. Start tracking!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : Column(
                            children: _recentCycles.take(3).map((cycle) {
                              return _buildRecentCycleItem(cycle);
                            }).toList(),
                          ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCycleItem(Map<String, dynamic> cycle) {
    // Parse dates safely
    DateTime? startDate;
    DateTime? endDate;
    
    try {
      if (cycle['start'] != null) {
        if (cycle['start'] is DateTime) {
          startDate = cycle['start'];
        } else if (cycle['start'].toString().contains('Timestamp')) {
          // Handle Firestore Timestamp
          startDate = (cycle['start'] as dynamic).toDate();
        } else {
          startDate = DateTime.parse(cycle['start'].toString());
        }
      }
      if (cycle['end'] != null) {
        if (cycle['end'] is DateTime) {
          endDate = cycle['end'];
        } else if (cycle['end'].toString().contains('Timestamp')) {
          // Handle Firestore Timestamp  
          endDate = (cycle['end'] as dynamic).toDate();
        } else {
          endDate = DateTime.parse(cycle['end'].toString());
        }
      }
    } catch (e) {
      print('Error parsing cycle dates: $e');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: Colors.pink.shade300,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              startDate != null && endDate != null
                  ? '${_formatDate(startDate)} - ${_formatDate(endDate)}'
                  : 'Invalid dates',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          if (startDate != null && endDate != null)
            Text(
              '${endDate.difference(startDate).inDays + 1} days',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '${difference} days ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌸 CycleSync'),
        backgroundColor: Colors.pink.shade50,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.pink.shade700, // Make icons darker and more visible
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.pink.shade700,
            ),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.pink.shade700,
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),
              _buildCycleStatusCard(),
              _buildPredictionsCard(),
              _buildQuickActions(),
              _buildRecentCycles(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
