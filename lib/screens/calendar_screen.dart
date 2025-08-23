import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../services/theme_service.dart';
import '../theme/dimensional_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final ValueNotifier<List<CycleEvent>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  List<Map<String, dynamic>> _cycles = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _loadCycles();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  Future<void> _loadCycles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final cycles = await FirebaseService.getCycles(limit: 100);
      setState(() {
        _cycles = cycles;
        _isLoading = false;
      });
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<CycleEvent> _getEventsForDay(DateTime day) {
    List<CycleEvent> events = [];

    for (final cycle in _cycles) {
      final startDate = _parseDateFromCycle(cycle['start']);
      final endDate = _parseDateFromCycle(cycle['end']);

      if (startDate != null && endDate != null) {
        // Check if day falls within cycle period
        if (day.isAfter(startDate.subtract(const Duration(days: 1))) &&
            day.isBefore(endDate.add(const Duration(days: 1)))) {
          String eventType;
          Color color;
          if (isSameDay(day, startDate)) {
            eventType = 'Start';
            color = Colors.red.shade600;
          } else if (isSameDay(day, endDate)) {
            eventType = 'End';
            color = Colors.pink.shade400;
          } else {
            eventType = 'Active';
            color = Colors.pink.shade300;
          }

          events.add(
            CycleEvent(
              id: cycle['id'],
              date: day,
              type: eventType,
              color: color,
              cycleData: cycle,
            ),
          );
        }
      }
    }

    return events;
  }

  List<CycleEvent> _getEventsForRange(DateTime start, DateTime end) {
    List<CycleEvent> events = [];
    DateTime current = start;

    while (current.isBefore(end.add(const Duration(days: 1)))) {
      events.addAll(_getEventsForDay(current));
      current = current.add(const Duration(days: 1));
    }

    return events;
  }

  DateTime? _parseDateFromCycle(dynamic date) {
    if (date == null) return null;

    try {
      if (date is DateTime) {
        return date;
      } else if (date.toString().contains('Timestamp')) {
        return (date as dynamic).toDate();
      } else {
        return DateTime.parse(date.toString());
      }
    } catch (e) {
      return null;
    }
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null;
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else {
      _selectedEvents.value = [];
    }
  }

  Widget _buildCalendar() {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return DimensionalTheme.getDimensionalCard(
          context: context,
          elevation: 8,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TableCalendar<CycleEvent>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            rangeSelectionMode: _rangeSelectionMode,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              // Default text style for calendar dates
              defaultTextStyle: TextStyle(
                color: themeService.getTextColor(context),
                fontWeight: FontWeight.w500,
              ),
              // Weekend text style
              weekendTextStyle: TextStyle(
                color: themeService
                    .getTextColor(context)
                    .withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
              // Holiday text style
              holidayTextStyle: TextStyle(
                color: themeService
                    .getTextColor(context)
                    .withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
              // Outside days (previous/next month dates)
              outsideTextStyle: TextStyle(
                color: themeService
                    .getTextColor(context)
                    .withValues(alpha: 0.3),
                fontWeight: FontWeight.w400,
              ),
              // Today's date decoration
              todayDecoration: BoxDecoration(
                color: themeService.isDarkModeEnabled(context)
                    ? const Color(0xFF40C4FF).withValues(alpha: 0.3)
                    : const Color(0xFF2196F3).withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              // Today's text style
              todayTextStyle: TextStyle(
                color: themeService.isDarkModeEnabled(context)
                    ? Colors.white
                    : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
              // Selected date decoration
              selectedDecoration: BoxDecoration(
                color: themeService.isDarkModeEnabled(context)
                    ? const Color(0xFFFF4081)
                    : const Color(0xFFE91E63),
                shape: BoxShape.circle,
              ),
              // Selected date text style
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              // Range selection decorations
              rangeStartDecoration: BoxDecoration(
                color: themeService.isDarkModeEnabled(context)
                    ? const Color(0xFFFF4081)
                    : const Color(0xFFE91E63),
                shape: BoxShape.circle,
              ),
              rangeEndDecoration: BoxDecoration(
                color: themeService.isDarkModeEnabled(context)
                    ? const Color(0xFFFF4081)
                    : const Color(0xFFE91E63),
                shape: BoxShape.circle,
              ),
              // Range highlight color
              rangeHighlightColor: themeService.isDarkModeEnabled(context)
                  ? const Color(0xFFFF4081).withValues(alpha: 0.2)
                  : const Color(0xFFE91E63).withValues(alpha: 0.2),
              // Range start/end text styles
              rangeStartTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              rangeEndTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              // Marker decoration for events
              markerDecoration: BoxDecoration(
                color: themeService.isDarkModeEnabled(context)
                    ? const Color(0xFFFF4081)
                    : const Color(0xFFE91E63),
                shape: BoxShape.circle,
              ),
              // Disable days text style
              disabledTextStyle: TextStyle(
                color: themeService
                    .getTextColor(context)
                    .withValues(alpha: 0.2),
                fontWeight: FontWeight.w400,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
              formatButtonDecoration: BoxDecoration(
                color: themeService
                    .getPrimaryColor(context)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: themeService
                      .getPrimaryColor(context)
                      .withValues(alpha: 0.3),
                ),
              ),
              formatButtonTextStyle: TextStyle(
                color: themeService.getPrimaryColor(context),
                fontWeight: FontWeight.w600,
              ),
              titleTextStyle: TextStyle(
                color: themeService.getTextColor(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: themeService.getTextColor(context),
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: themeService.getTextColor(context),
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              // Style for day names (Sun, Mon, Tue, etc.)
              weekdayStyle: TextStyle(
                color: themeService
                    .getTextColor(context)
                    .withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              weekendStyle: TextStyle(
                color: themeService
                    .getTextColor(context)
                    .withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            onDaySelected: _onDaySelected,
            onRangeSelected: _onRangeSelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
        );
      },
    );
  }

  Widget _buildCycleList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Recent Cycles',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        if (_cycles.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No cycle data available',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ..._cycles.take(10).map((cycle) => _buildCycleCardFromData(cycle)),
      ],
    );
  }

  Widget _buildCycleCardFromData(Map<String, dynamic> cycle) {
    final startDate = _parseDateFromCycle(cycle['start']);
    final endDate = _parseDateFromCycle(cycle['end']);

    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return DimensionalTheme.getDimensionalCard(
          context: context,
          elevation: 4,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.pink.shade400.withValues(alpha: 0.15),
                    Colors.pink.shade400.withValues(alpha: 0.25),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.pink.shade400.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.shade400.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.calendar_today,
                color: Colors.pink.shade400,
                size: 24,
              ),
            ),
            title: Text(
              startDate != null && endDate != null
                  ? 'Cycle: ${DateFormat.MMM().format(startDate)} ${startDate.day} - ${DateFormat.MMM().format(endDate)} ${endDate.day}'
                  : 'Cycle Data',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: themeService.getTextColor(context),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                if (startDate != null && endDate != null)
                  _buildInfoChip(
                    'Duration',
                    '${endDate.difference(startDate).inDays + 1} days',
                  ),
                if (cycle['flow'] != null)
                  _buildInfoChip('Flow', cycle['flow']),
                if (cycle['symptoms'] != null &&
                    (cycle['symptoms'] as List).isNotEmpty)
                  _buildInfoChip(
                    'Symptoms',
                    (cycle['symptoms'] as List).take(2).join(', '),
                  ),
              ],
            ),
            trailing: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: themeService.getSurfaceColor(context),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: themeService
                      .getTextColor(context)
                      .withValues(alpha: 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: themeService
                      .getTextColor(context)
                      .withValues(alpha: 0.6),
                  size: 18,
                ),
                onPressed: () => _showCycleDetails(cycle),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventCard(CycleEvent event) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return DimensionalTheme.getDimensionalCard(
          context: context,
          elevation: 4,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    event.color.withValues(alpha: 0.15),
                    event.color.withValues(alpha: 0.25),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: event.color.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: event.color.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _getEventIcon(event.type),
                color: event.color,
                size: 24,
              ),
            ),
            title: Text(
              'Cycle ${event.type}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: themeService.getTextColor(context),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildInfoChip('Date', DateFormat.yMMMd().format(event.date)),
                if (event.cycleData['flow'] != null)
                  _buildInfoChip('Flow', event.cycleData['flow']),
                if (event.cycleData['symptoms'] != null &&
                    (event.cycleData['symptoms'] as List).isNotEmpty)
                  _buildInfoChip(
                    'Symptoms',
                    (event.cycleData['symptoms'] as List).take(2).join(', '),
                  ),
              ],
            ),
            trailing: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: themeService.getSurfaceColor(context),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: themeService
                      .getTextColor(context)
                      .withValues(alpha: 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: themeService
                      .getTextColor(context)
                      .withValues(alpha: 0.6),
                  size: 18,
                ),
                onPressed: () => _showCycleDetails(event.cycleData),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: themeService
                  .getPrimaryColor(context)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: themeService
                    .getPrimaryColor(context)
                    .withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
            child: Text(
              '$label: $value',
              style: TextStyle(
                fontSize: 12,
                color: themeService
                    .getTextColor(context)
                    .withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getEventIcon(String type) {
    switch (type) {
      case 'Start':
        return Icons.play_arrow;
      case 'End':
        return Icons.stop;
      case 'Active':
        return Icons.circle;
      default:
        return Icons.event;
    }
  }

  void _showCycleDetails(Map<String, dynamic> cycle) {
    final startDate = _parseDateFromCycle(cycle['start']);
    final endDate = _parseDateFromCycle(cycle['end']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cycle Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (startDate != null)
              Text('Start: ${DateFormat.yMMMd().format(startDate)}'),
            if (endDate != null)
              Text('End: ${DateFormat.yMMMd().format(endDate)}'),
            if (startDate != null && endDate != null)
              Text(
                'Duration: ${endDate.difference(startDate).inDays + 1} days',
              ),
            if (cycle['flow'] != null) Text('Flow: ${cycle['flow']}'),
            if (cycle['symptoms'] != null &&
                (cycle['symptoms'] as List).isNotEmpty)
              Text('Symptoms: ${(cycle['symptoms'] as List).join(', ')}'),
            if (cycle['notes'] != null && cycle['notes'].isNotEmpty)
              Text('Notes: ${cycle['notes']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return DimensionalTheme.getDimensionalCard(
          context: context,
          elevation: 4,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            themeService
                                .getPrimaryColor(context)
                                .withValues(alpha: 0.1),
                            themeService
                                .getPrimaryColor(context)
                                .withValues(alpha: 0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: themeService
                              .getPrimaryColor(context)
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(
                        Icons.info_outline,
                        color: themeService.getPrimaryColor(context),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Cycle Legend',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themeService.getTextColor(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    _buildLegendItem(
                      Colors.red.shade600,
                      'Cycle Start',
                      Icons.play_arrow,
                    ),
                    _buildLegendItem(
                      Colors.pink.shade300,
                      'Active Period',
                      Icons.circle,
                    ),
                    _buildLegendItem(
                      Colors.pink.shade400,
                      'Cycle End',
                      Icons.stop,
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

  Widget _buildLegendItem(Color color, String label, IconData icon) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.8)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 12),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: themeService
                      .getTextColor(context)
                      .withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📅 Calendar View'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadCycles),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load cycles',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text('Please try again'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadCycles,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                _buildCalendar(),
                _buildLegend(),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: ValueListenableBuilder<List<CycleEvent>>(
                      valueListenable: _selectedEvents,
                      builder: (context, value, _) {
                        return Column(
                          children: [
                            if (value.isNotEmpty)
                              ...value.map((event) => _buildEventCard(event)),
                            _buildCycleList(),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class CycleEvent {
  final String id;
  final DateTime date;
  final String type;
  final Color color;
  final Map<String, dynamic> cycleData;

  CycleEvent({
    required this.id,
    required this.date,
    required this.type,
    required this.color,
    required this.cycleData,
  });

  @override
  String toString() => type;
}
