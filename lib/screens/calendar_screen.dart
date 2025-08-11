import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../services/theme_service.dart';
import '../theme/app_theme.dart';

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
          
          events.add(CycleEvent(
            id: cycle['id'],
            date: day,
            type: eventType,
            color: color,
            cycleData: cycle,
          ));
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
    return TableCalendar<CycleEvent>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      eventLoader: _getEventsForDay,
      rangeSelectionMode: _rangeSelectionMode,
      startingDayOfWeek: StartingDayOfWeek.monday,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
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
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendTextStyle: TextStyle(color: Colors.red.shade700),
        holidayTextStyle: TextStyle(color: Colors.red.shade700),
        markerDecoration: BoxDecoration(
          color: Colors.pink.shade400,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.pink.shade600,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Colors.blue.shade400,
          shape: BoxShape.circle,
        ),
        rangeHighlightColor: Colors.pink.shade100,
        rangeStartDecoration: BoxDecoration(
          color: Colors.pink.shade600,
          shape: BoxShape.circle,
        ),
        rangeEndDecoration: BoxDecoration(
          color: Colors.pink.shade600,
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
        formatButtonShowsNext: false,
        formatButtonDecoration: BoxDecoration(
          color: Colors.pink.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        formatButtonTextStyle: TextStyle(
          color: Colors.pink.shade700,
          fontWeight: FontWeight.bold,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          if (events.isEmpty) return null;
          
          return Positioned(
            bottom: 1,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: events.first.color,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventList() {
    return ValueListenableBuilder<List<CycleEvent>>(
      valueListenable: _selectedEvents,
      builder: (context, value, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _selectedDay != null
                    ? 'Events for ${DateFormat.yMMMd().format(_selectedDay!)}'
                    : _rangeStart != null && _rangeEnd != null
                        ? 'Events from ${DateFormat.MMMd().format(_rangeStart!)} to ${DateFormat.MMMd().format(_rangeEnd!)}'
                        : 'Select a date to view events',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (value.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No cycle events for this date',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...value.map((event) => _buildEventCard(event)),
          ],
        );
      },
    );
  }

  Widget _buildEventCard(CycleEvent event) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: event.color.withOpacity(0.2),
          child: Icon(
            _getEventIcon(event.type),
            color: event.color,
            size: 20,
          ),
        ),
        title: Text('Cycle ${event.type}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${DateFormat.yMMMd().format(event.date)}'),
            if (event.cycleData['flow'] != null)
              Text('Flow: ${event.cycleData['flow']}'),
            if (event.cycleData['symptoms'] != null && 
                (event.cycleData['symptoms'] as List).isNotEmpty)
              Text('Symptoms: ${(event.cycleData['symptoms'] as List).join(', ')}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showCycleDetails(event.cycleData),
        ),
      ),
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
              Text('Duration: ${endDate.difference(startDate).inDays + 1} days'),
            if (cycle['flow'] != null)
              Text('Flow: ${cycle['flow']}'),
            if (cycle['symptoms'] != null && (cycle['symptoms'] as List).isNotEmpty)
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
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Legend',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildLegendItem(Colors.red.shade600, 'Cycle Start'),
                const SizedBox(width: 16),
                _buildLegendItem(Colors.pink.shade300, 'Active Period'),
                const SizedBox(width: 16),
                _buildLegendItem(Colors.pink.shade400, 'Cycle End'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCycles,
          ),
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
                        child: _buildEventList(),
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
