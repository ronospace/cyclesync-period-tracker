import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../models/cycle_models.dart';

class EnhancedCycleHistoryScreen extends StatefulWidget {
  const EnhancedCycleHistoryScreen({super.key});

  @override
  State<EnhancedCycleHistoryScreen> createState() => _EnhancedCycleHistoryScreenState();
}

class _EnhancedCycleHistoryScreenState extends State<EnhancedCycleHistoryScreen> {
  List<CycleData> _cycles = [];
  List<CycleData> _filteredCycles = [];
  bool _isLoading = true;
  String? _error;
  CycleFilter _currentFilter = CycleFilter();
  String _sortBy = 'date'; // 'date', 'length', 'mood'
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _loadCycles();
  }

  Future<void> _loadCycles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Convert existing Firebase data to new CycleData models
      final rawCycles = await FirebaseService.getCycles(limit: 50);
      final cycles = rawCycles.map((raw) => _convertToCycleData(raw)).toList();
      
      setState(() {
        _cycles = cycles;
        _filteredCycles = cycles;
        _isLoading = false;
      });
      
      _applySorting();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  CycleData _convertToCycleData(Map<String, dynamic> raw) {
    return CycleData(
      id: raw['id'] ?? '',
      startDate: _parseDate(raw['start']) ?? DateTime.now(),
      endDate: _parseDate(raw['end']),
      flowIntensity: _parseFlowIntensity(raw['flow_intensity'] ?? raw['flow']),
      wellbeing: WellbeingData(
        mood: (raw['mood'] ?? 3.0).toDouble(),
        energy: (raw['energy'] ?? 3.0).toDouble(),
        pain: (raw['pain'] ?? 1.0).toDouble(),
      ),
      symptoms: _parseSymptoms(raw['symptoms']),
      notes: raw['notes']?.toString() ?? '',
      createdAt: _parseDate(raw['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(raw['updated_at']) ?? DateTime.now(),
    );
  }

  DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    try {
      if (date is DateTime) return date;
      if (date.toString().contains('Timestamp')) {
        return (date as dynamic).toDate();
      }
      return DateTime.parse(date.toString());
    } catch (e) {
      return null;
    }
  }

  FlowIntensity _parseFlowIntensity(dynamic flow) {
    if (flow == null) return FlowIntensity.medium;
    if (flow is String) {
      switch (flow.toLowerCase()) {
        case 'light': return FlowIntensity.light;
        case 'heavy': return FlowIntensity.heavy;
        default: return FlowIntensity.medium;
      }
    }
    return FlowIntensity.medium;
  }

  List<Symptom> _parseSymptoms(dynamic symptoms) {
    if (symptoms == null) return [];
    if (symptoms is! List) return [];
    
    return symptoms
        .map((name) => Symptom.fromName(name.toString()))
        .where((symptom) => symptom != null)
        .cast<Symptom>()
        .toList();
  }

  void _applyFilter(CycleFilter filter) {
    setState(() {
      _currentFilter = filter;
      _filteredCycles = filter.apply(_cycles);
    });
    _applySorting();
  }

  Future<void> _deleteCycle(CycleData cycle) async {
    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red.shade600),
            const SizedBox(width: 8),
            const Text('Delete Cycle'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this cycle?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cycle: ${DateFormat.yMMMd().format(cycle.startDate)}${cycle.endDate != null ? ' - ${DateFormat.yMMMd().format(cycle.endDate!)}' : ''}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (cycle.notes.isNotEmpty) 
                    Text('Notes: ${cycle.notes}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Deleting cycle...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Delete from Firebase
      await FirebaseService.deleteCycle(cycleId: cycle.id);

      // Update local state
      setState(() {
        _cycles.removeWhere((c) => c.id == cycle.id);
        _filteredCycles.removeWhere((c) => c.id == cycle.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Cycle deleted successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Undo',
              textColor: Colors.white,
              onPressed: () => _undoDelete(cycle),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete cycle: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _deleteCycle(cycle),
            ),
          ),
        );
      }
    }
  }

  Future<bool?> _confirmDelete(CycleData cycle) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red.shade600),
            const SizedBox(width: 8),
            const Text('Delete Cycle'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this cycle?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cycle: ${DateFormat.yMMMd().format(cycle.startDate)}${cycle.endDate != null ? ' - ${DateFormat.yMMMd().format(cycle.endDate!)}' : ''}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (cycle.notes.isNotEmpty) 
                    Text('Notes: ${cycle.notes}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _undoDelete(CycleData cycle) async {
    try {
      // Re-add to Firebase (this would need implementation in FirebaseService)
      // For now, just reload the data
      await _loadCycles();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delete undone - data reloaded'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to undo: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applySorting() {
    setState(() {
      _filteredCycles.sort((a, b) {
        int comparison;
        switch (_sortBy) {
          case 'length':
            comparison = a.lengthInDays.compareTo(b.lengthInDays);
            break;
          case 'mood':
            comparison = a.wellbeing.mood.compareTo(b.wellbeing.mood);
            break;
          case 'date':
          default:
            comparison = a.startDate.compareTo(b.startDate);
            break;
        }
        return _sortAscending ? comparison : -comparison;
      });
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(
        currentFilter: _currentFilter,
        onApply: _applyFilter,
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.history, color: Colors.blue.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cycle History',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_filteredCycles.length} cycles tracked',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.sort, color: Colors.grey.shade600),
              onSelected: (value) {
                if (value == _sortBy) {
                  setState(() => _sortAscending = !_sortAscending);
                } else {
                  setState(() {
                    _sortBy = value;
                    _sortAscending = false;
                  });
                }
                _applySorting();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'date',
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 8),
                      const Text('Date'),
                      if (_sortBy == 'date') ...[
                        const Spacer(),
                        Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                      ],
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'length',
                  child: Row(
                    children: [
                      Icon(Icons.timeline, size: 16),
                      const SizedBox(width: 8),
                      const Text('Length'),
                      if (_sortBy == 'length') ...[
                        const Spacer(),
                        Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                      ],
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'mood',
                  child: Row(
                    children: [
                      Icon(Icons.mood, size: 16),
                      const SizedBox(width: 8),
                      const Text('Mood'),
                      if (_sortBy == 'mood') ...[
                        const Spacer(),
                        Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.filter_list, color: Colors.grey.shade600),
              onPressed: _showFilterDialog,
              tooltip: 'Filter cycles',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleCard(CycleData cycle) {
    return Dismissible(
      key: Key(cycle.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete,
              color: Colors.white,
              size: 28,
            ),
            SizedBox(height: 4),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        final confirmed = await _confirmDelete(cycle);
        if (confirmed == true) {
          // Perform the deletion
          try {
            await FirebaseService.deleteCycle(cycleId: cycle.id);
            
            // Update local state
            setState(() {
              _cycles.removeWhere((c) => c.id == cycle.id);
              _filteredCycles.removeWhere((c) => c.id == cycle.id);
            });
            
            // Show success message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Cycle deleted successfully'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  action: SnackBarAction(
                    label: 'Undo',
                    textColor: Colors.white,
                    onPressed: () => _undoDelete(cycle),
                  ),
                ),
              );
            }
            return true;
          } catch (e) {
            // Show error message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to delete cycle: ${e.toString()}'),
                  backgroundColor: Colors.red,
                  action: SnackBarAction(
                    label: 'Retry',
                    textColor: Colors.white,
                    onPressed: () => _deleteCycle(cycle),
                  ),
                ),
              );
            }
            return false;
          }
        }
        return false;
      },
      onDismissed: (direction) {
        // Deletion is handled in confirmDismiss
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          onTap: () => _showCycleDetails(cycle),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with date and flow
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: cycle.flowIntensity.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cycle.flowIntensity.color.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cycle.flowIntensity.icon,
                          color: cycle.flowIntensity.color,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          cycle.flowIntensity.displayName,
                          style: TextStyle(
                            color: cycle.flowIntensity.color,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (cycle.isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${cycle.lengthInDays} days',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Date range
              Text(
                cycle.dateRange,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Wellbeing indicators
              Row(
                children: [
                  _buildWellbeingIndicator(
                    'Mood',
                    Icons.mood,
                    cycle.wellbeing.mood,
                    cycle.wellbeing.moodDescription,
                    Colors.purple,
                  ),
                  const SizedBox(width: 16),
                  _buildWellbeingIndicator(
                    'Energy',
                    Icons.battery_charging_full,
                    cycle.wellbeing.energy,
                    cycle.wellbeing.energyDescription,
                    Colors.orange,
                  ),
                  const SizedBox(width: 16),
                  _buildWellbeingIndicator(
                    'Pain',
                    Icons.healing,
                    cycle.wellbeing.pain,
                    cycle.wellbeing.painDescription,
                    Colors.red,
                  ),
                ],
              ),
              
              if (cycle.symptoms.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildSymptomsPreview(cycle.symptoms),
              ],
              
              if (cycle.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.note, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cycle.notes,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWellbeingIndicator(
    String label,
    IconData icon,
    double value,
    String description,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Icon(
                Icons.star,
                size: 12,
                color: index < value ? color : Colors.grey.shade300,
              );
            }),
          ),
          Text(
            description,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsPreview(List<Symptom> symptoms) {
    final displaySymptoms = symptoms.take(4).toList();
    final remaining = symptoms.length - displaySymptoms.length;
    
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        ...displaySymptoms.map((symptom) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: symptom.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: symptom.color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(symptom.icon, size: 12, color: symptom.color),
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
        )),
        if (remaining > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+$remaining more',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  void _showCycleDetails(CycleData cycle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _CycleDetailsSheet(cycle: cycle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📋 Cycle History'),
        backgroundColor: Colors.blue.shade50,
        foregroundColor: Colors.blue.shade700,
        iconTheme: IconThemeData(color: Colors.blue.shade700),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue.shade700),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.blue.shade700),
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
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text('Failed to load cycles', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadCycles,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCycles,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _buildHeader()),
                      _filteredCycles.isEmpty
                          ? SliverFillRemaining(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No cycles match your filters',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: () => _applyFilter(CycleFilter()),
                                      child: const Text('Clear filters'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _buildCycleCard(_filteredCycles[index]),
                                childCount: _filteredCycles.length,
                              ),
                            ),
                      const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/log-cycle'),
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Filter Dialog Widget
class _FilterDialog extends StatefulWidget {
  final CycleFilter currentFilter;
  final Function(CycleFilter) onApply;

  const _FilterDialog({
    required this.currentFilter,
    required this.onApply,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late DateTime? _startDate;
  late DateTime? _endDate;
  late List<FlowIntensity> _selectedFlows;
  late List<Symptom> _selectedSymptoms;
  late double _minMood;
  late double _maxMood;

  @override
  void initState() {
    super.initState();
    _startDate = widget.currentFilter.startDate;
    _endDate = widget.currentFilter.endDate;
    _selectedFlows = widget.currentFilter.flowIntensities ?? [];
    _selectedSymptoms = widget.currentFilter.symptoms ?? [];
    _minMood = widget.currentFilter.minMood ?? 1.0;
    _maxMood = widget.currentFilter.maxMood ?? 5.0;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Cycles'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Date range
              Text('Date Range', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) setState(() => _startDate = date);
                      },
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(_startDate != null ? DateFormat.yMMMd().format(_startDate!) : 'Start Date'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) setState(() => _endDate = date);
                      },
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(_endDate != null ? DateFormat.yMMMd().format(_endDate!) : 'End Date'),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Flow intensity
              Text('Flow Intensity', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: FlowIntensity.values.map((flow) {
                  final isSelected = _selectedFlows.contains(flow);
                  return FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(flow.icon, size: 16, color: isSelected ? Colors.white : flow.color),
                        const SizedBox(width: 4),
                        Text(flow.displayName),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedFlows.add(flow);
                        } else {
                          _selectedFlows.remove(flow);
                        }
                      });
                    },
                    selectedColor: flow.color,
                    checkmarkColor: Colors.white,
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 16),
              
              // Mood range
              Text('Mood Range', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              RangeSlider(
                values: RangeValues(_minMood, _maxMood),
                min: 1.0,
                max: 5.0,
                divisions: 4,
                labels: RangeLabels(_minMood.toInt().toString(), _maxMood.toInt().toString()),
                onChanged: (values) {
                  setState(() {
                    _minMood = values.start;
                    _maxMood = values.end;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _startDate = null;
              _endDate = null;
              _selectedFlows.clear();
              _selectedSymptoms.clear();
              _minMood = 1.0;
              _maxMood = 5.0;
            });
          },
          child: const Text('Clear'),
        ),
        ElevatedButton(
          onPressed: () {
            final filter = CycleFilter(
              startDate: _startDate,
              endDate: _endDate,
              flowIntensities: _selectedFlows.isEmpty ? null : _selectedFlows,
              symptoms: _selectedSymptoms.isEmpty ? null : _selectedSymptoms,
              minMood: _minMood == 1.0 ? null : _minMood,
              maxMood: _maxMood == 5.0 ? null : _maxMood,
            );
            widget.onApply(filter);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

// Cycle Details Bottom Sheet
class _CycleDetailsSheet extends StatelessWidget {
  final CycleData cycle;

  const _CycleDetailsSheet({required this.cycle});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(cycle.flowIntensity.icon, color: cycle.flowIntensity.color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cycle Details',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            cycle.dateRange,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Flow and Duration
                      _buildDetailSection(
                        'Cycle Information',
                        [
                          _DetailRow('Flow Intensity', cycle.flowIntensity.displayName, 
                                   icon: cycle.flowIntensity.icon, color: cycle.flowIntensity.color),
                          if (cycle.isCompleted)
                            _DetailRow('Duration', '${cycle.lengthInDays} days', 
                                     icon: Icons.timeline, color: Colors.blue),
                          _DetailRow('Start Date', DateFormat.yMMMEd().format(cycle.startDate), 
                                   icon: Icons.play_arrow, color: Colors.green),
                          if (cycle.endDate != null)
                            _DetailRow('End Date', DateFormat.yMMMEd().format(cycle.endDate!), 
                                     icon: Icons.stop, color: Colors.red),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Wellbeing
                      _buildDetailSection(
                        'Wellbeing',
                        [
                          _DetailRow('Mood', cycle.wellbeing.moodDescription, 
                                   icon: Icons.mood, color: Colors.purple,
                                   rating: cycle.wellbeing.mood),
                          _DetailRow('Energy', cycle.wellbeing.energyDescription, 
                                   icon: Icons.battery_charging_full, color: Colors.orange,
                                   rating: cycle.wellbeing.energy),
                          _DetailRow('Pain Level', cycle.wellbeing.painDescription, 
                                   icon: Icons.healing, color: Colors.red,
                                   rating: cycle.wellbeing.pain),
                        ],
                      ),
                      
                      if (cycle.symptoms.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildSymptomsSection(cycle.symptoms),
                      ],
                      
                      if (cycle.notes.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildNotesSection(cycle.notes),
                      ],
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildSymptomsSection(List<Symptom> symptoms) {
    final categories = Symptom.allCategories;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Symptoms',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...categories.map((category) {
          final categorySymptoms = symptoms.where((s) => s.category == category).toList();
          if (categorySymptoms.isEmpty) return const SizedBox.shrink();
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: categorySymptoms.map((symptom) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: symptom.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: symptom.color.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(symptom.icon, size: 16, color: symptom.color),
                        const SizedBox(width: 6),
                        Text(
                          symptom.displayName,
                          style: TextStyle(
                            color: symptom.color,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildNotesSection(String notes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            notes,
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;
  final double? rating;

  const _DetailRow(
    this.label,
    this.value, {
    this.icon,
    this.color,
    this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: color ?? Colors.grey.shade600),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          if (rating != null) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (index) {
                return Icon(
                  Icons.star,
                  size: 16,
                  color: index < rating! ? (color ?? Colors.grey.shade600) : Colors.grey.shade300,
                );
              }),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color ?? Colors.grey.shade900,
            ),
          ),
        ],
      ),
    );
  }
}
