import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../models/cycle_models.dart';

class SymptomTrendsScreen extends StatefulWidget {
  const SymptomTrendsScreen({super.key});

  @override
  State<SymptomTrendsScreen> createState() => _SymptomTrendsScreenState();
}

class _SymptomTrendsScreenState extends State<SymptomTrendsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<CycleData> _cycles = [];
  bool _isLoading = true;
  String? _error;
  
  // Chart configurations
  String _selectedTimeRange = '6 months';
  final List<String> _timeRangeOptions = ['3 months', '6 months', '1 year', 'All time'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCycleData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCycleData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final rawCycles = await FirebaseService.getCycles(limit: 100);
      final cycles = rawCycles.map((raw) => _convertToCycleData(raw)).toList();
      
      setState(() {
        _cycles = cycles;
        _isLoading = false;
      });
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
        mood: (raw['mood'] ?? raw['mood_level'] ?? 3.0).toDouble(),
        energy: (raw['energy'] ?? raw['energy_level'] ?? 3.0).toDouble(),
        pain: (raw['pain'] ?? raw['pain_level'] ?? 1.0).toDouble(),
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

  List<CycleData> _getFilteredCycles() {
    final now = DateTime.now();
    final DateTime cutoffDate;
    
    switch (_selectedTimeRange) {
      case '3 months':
        cutoffDate = now.subtract(const Duration(days: 90));
        break;
      case '6 months':
        cutoffDate = now.subtract(const Duration(days: 180));
        break;
      case '1 year':
        cutoffDate = now.subtract(const Duration(days: 365));
        break;
      default:
        return _cycles;
    }
    
    return _cycles.where((cycle) => cycle.startDate.isAfter(cutoffDate)).toList();
  }

  Widget _buildHeader() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.purple.shade600, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Symptom Trends',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  initialValue: _selectedTimeRange,
                  icon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedTimeRange,
                        style: TextStyle(
                          color: Colors.purple.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.expand_more, color: Colors.purple.shade600, size: 20),
                    ],
                  ),
                  onSelected: (value) {
                    setState(() {
                      _selectedTimeRange = value;
                    });
                  },
                  itemBuilder: (context) => _timeRangeOptions
                      .map((option) => PopupMenuItem(
                            value: option,
                            child: Text(option),
                          ))
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Track patterns in your symptoms and wellbeing over time',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomFrequencyTab() {
    final filteredCycles = _getFilteredCycles();
    
    if (filteredCycles.isEmpty) {
      return _buildEmptyState('No data available for the selected time range');
    }

    // Calculate symptom frequency
    final Map<String, int> symptomCounts = {};
    final Map<String, Symptom> symptomDetails = {};
    
    for (final cycle in filteredCycles) {
      for (final symptom in cycle.symptoms) {
        symptomCounts[symptom.name] = (symptomCounts[symptom.name] ?? 0) + 1;
        symptomDetails[symptom.name] = symptom;
      }
    }
    
    if (symptomCounts.isEmpty) {
      return _buildEmptyState('No symptoms tracked in this time period');
    }

    // Sort by frequency
    final sortedSymptoms = symptomCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Frequency chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Symptom Frequency',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: sortedSymptoms.first.value.toDouble() * 1.2,
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: 1.0,
                              getTitlesWidget: (value, meta) {
                                // Only show whole numbers and avoid duplicates
                                if (value % 1 != 0) return const Text('');
                                final intValue = value.toInt();
                                if (intValue < 0) return const Text('');
                                return Text(
                                  intValue.toString(),
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 60,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= sortedSymptoms.length) return const Text('');
                                final symptomName = sortedSymptoms[value.toInt()].key;
                                final symptom = symptomDetails[symptomName];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        symptom?.icon ?? Icons.circle,
                                        size: 16,
                                        color: symptom?.color ?? Colors.grey,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        symptom?.displayName.split(' ').first ?? '',
                                        style: const TextStyle(fontSize: 10),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: sortedSymptoms.asMap().entries.map((entry) {
                          final index = entry.key;
                          final symptomEntry = entry.value;
                          final symptom = symptomDetails[symptomEntry.key];
                          
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: symptomEntry.value.toDouble(),
                                color: symptom?.color ?? Colors.purple,
                                width: 20,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Detailed list
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Symptom Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...sortedSymptoms.map((entry) {
                    final symptom = symptomDetails[entry.key];
                    final percentage = (entry.value / filteredCycles.length * 100);
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(
                            symptom?.icon ?? Icons.circle,
                            color: symptom?.color ?? Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  symptom?.displayName ?? entry.key,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '${entry.value} cycles (${percentage.toStringAsFixed(1)}%)',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: symptom?.color.withOpacity(0.1) ?? Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              entry.value.toString(),
                              style: TextStyle(
                                color: symptom?.color ?? Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWellbeingTrendsTab() {
    final filteredCycles = _getFilteredCycles();
    
    if (filteredCycles.isEmpty) {
      return _buildEmptyState('No wellbeing data available for the selected time range');
    }

    // Sort cycles by date
    filteredCycles.sort((a, b) => a.startDate.compareTo(b.startDate));

    // Create data points
    final moodSpots = <FlSpot>[];
    final energySpots = <FlSpot>[];
    final painSpots = <FlSpot>[];

    for (int i = 0; i < filteredCycles.length; i++) {
      final cycle = filteredCycles[i];
      final x = i.toDouble();
      
      moodSpots.add(FlSpot(x, cycle.wellbeing.mood));
      energySpots.add(FlSpot(x, cycle.wellbeing.energy));
      painSpots.add(FlSpot(x, cycle.wellbeing.pain));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wellbeing Trends Over Time',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawHorizontalLine: true,
                          horizontalInterval: 1,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.shade200,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                const labels = ['', 'Poor', 'Low', 'Okay', 'Good', 'Great'];
                                if (value.toInt() >= labels.length) return const Text('');
                                return Text(
                                  labels[value.toInt()],
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: (filteredCycles.length / 6).ceilToDouble(),
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= filteredCycles.length) return const Text('');
                                final cycle = filteredCycles[value.toInt()];
                                return Text(
                                  DateFormat.MMMd().format(cycle.startDate),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: true),
                        minX: 0,
                        maxX: (filteredCycles.length - 1).toDouble(),
                        minY: 0.5,
                        maxY: 5.5,
                        lineBarsData: [
                          LineChartBarData(
                            spots: moodSpots,
                            isCurved: true,
                            color: Colors.purple,
                            barWidth: 3,
                            dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 3,
                                color: Colors.purple,
                                strokeWidth: 1,
                                strokeColor: Colors.white,
                              );
                            }),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.purple.withOpacity(0.1),
                            ),
                          ),
                          LineChartBarData(
                            spots: energySpots,
                            isCurved: true,
                            color: Colors.orange,
                            barWidth: 3,
                            dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 3,
                                color: Colors.orange,
                                strokeWidth: 1,
                                strokeColor: Colors.white,
                              );
                            }),
                          ),
                          LineChartBarData(
                            spots: painSpots,
                            isCurved: true,
                            color: Colors.red,
                            barWidth: 3,
                            dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 3,
                                color: Colors.red,
                                strokeWidth: 1,
                                strokeColor: Colors.white,
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLegendItem('Mood', Colors.purple),
                      _buildLegendItem('Energy', Colors.orange),
                      _buildLegendItem('Pain', Colors.red),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Averages card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Average Wellbeing Scores',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildAverageRow(
                    'Mood',
                    filteredCycles.fold(0.0, (sum, c) => sum + c.wellbeing.mood) / filteredCycles.length,
                    Colors.purple,
                  ),
                  const SizedBox(height: 8),
                  _buildAverageRow(
                    'Energy',
                    filteredCycles.fold(0.0, (sum, c) => sum + c.wellbeing.energy) / filteredCycles.length,
                    Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  _buildAverageRow(
                    'Pain',
                    filteredCycles.fold(0.0, (sum, c) => sum + c.wellbeing.pain) / filteredCycles.length,
                    Colors.red,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
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
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildAverageRow(String label, double average, Color color) {
    return Row(
      children: [
        Icon(
          _getIconForWellbeingType(label),
          color: color,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star,
                    size: 16,
                    color: index < average ? color : Colors.grey.shade300,
                  );
                }),
              ),
            ],
          ),
        ),
        Text(
          average.toStringAsFixed(1),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  IconData _getIconForWellbeingType(String type) {
    switch (type) {
      case 'Mood':
        return Icons.sentiment_satisfied_alt;
      case 'Energy':
        return Icons.battery_charging_full;
      case 'Pain':
        return Icons.healing;
      default:
        return Icons.circle;
    }
  }

  Widget _buildCorrelationsTab() {
    final filteredCycles = _getFilteredCycles();
    
    if (filteredCycles.length < 5) {
      return _buildEmptyState('Need at least 5 cycles to show correlations');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Symptom & Wellbeing Patterns',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Discover connections between your symptoms and wellbeing scores',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  
                  // Most common symptom combinations
                  _buildSymptomCombinations(filteredCycles),
                  
                  const SizedBox(height: 20),
                  
                  // Wellbeing impact
                  _buildWellbeingImpact(filteredCycles),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomCombinations(List<CycleData> cycles) {
    // Find common symptom pairs
    final Map<String, int> combinations = {};
    
    for (final cycle in cycles) {
      final symptoms = cycle.symptoms;
      for (int i = 0; i < symptoms.length; i++) {
        for (int j = i + 1; j < symptoms.length; j++) {
          final pair = [symptoms[i].displayName, symptoms[j].displayName]
            ..sort();
          final key = pair.join(' + ');
          combinations[key] = (combinations[key] ?? 0) + 1;
        }
      }
    }

    final sortedCombinations = combinations.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    if (sortedCombinations.isEmpty) {
      return const Text('No symptom combinations found');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Most Common Symptom Combinations',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...sortedCombinations.take(5).map((entry) {
          final percentage = (entry.value / cycles.length * 100);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    entry.value.toString(),
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}% of cycles',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWellbeingImpact(List<CycleData> cycles) {
    // Calculate average wellbeing scores when specific symptoms are present
    final Map<String, List<double>> symptomMoodMap = {};
    final Map<String, List<double>> symptomEnergyMap = {};
    
    for (final cycle in cycles) {
      for (final symptom in cycle.symptoms) {
        symptomMoodMap[symptom.displayName] ??= [];
        symptomMoodMap[symptom.displayName]!.add(cycle.wellbeing.mood);
        
        symptomEnergyMap[symptom.displayName] ??= [];
        symptomEnergyMap[symptom.displayName]!.add(cycle.wellbeing.energy);
      }
    }

    final overallMoodAvg = cycles.fold(0.0, (sum, c) => sum + c.wellbeing.mood) / cycles.length;
    final overallEnergyAvg = cycles.fold(0.0, (sum, c) => sum + c.wellbeing.energy) / cycles.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Symptom Impact on Wellbeing',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...symptomMoodMap.entries.take(5).map((entry) {
          final symptomName = entry.key;
          final moodScores = entry.value;
          final energyScores = symptomEnergyMap[symptomName] ?? [];
          
          if (moodScores.length < 2) return const SizedBox.shrink();
          
          final avgMood = moodScores.reduce((a, b) => a + b) / moodScores.length;
          final avgEnergy = energyScores.isNotEmpty 
              ? energyScores.reduce((a, b) => a + b) / energyScores.length 
              : 0.0;
          
          final moodDiff = avgMood - overallMoodAvg;
          final energyDiff = avgEnergy - overallEnergyAvg;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    symptomName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.mood, size: 16, color: Colors.purple),
                      const SizedBox(width: 4),
                      Text(
                        'Mood: ${moodDiff.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: moodDiff < 0 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.battery_charging_full, size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        'Energy: ${energyDiff.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: energyDiff < 0 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildInsightsTab() {
    final filteredCycles = _getFilteredCycles();
    
    if (filteredCycles.isEmpty) {
      return _buildEmptyState('No data available for insights');
    }

    final insights = _generateInsights(filteredCycles);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.amber.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Personal Insights',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI-powered insights based on your tracking data',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  
                  ...insights.map((insight) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: insight.color.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: insight.color.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                insight.icon,
                                color: insight.color,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                insight.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: insight.color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            insight.description,
                            style: const TextStyle(fontSize: 14),
                          ),
                          if (insight.recommendation != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.tips_and_updates,
                                    size: 16,
                                    color: Colors.blue.shade600,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      insight.recommendation!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TrendInsight> _generateInsights(List<CycleData> cycles) {
    final insights = <TrendInsight>[];
    
    // Most frequent symptom
    final Map<String, int> symptomCounts = {};
    for (final cycle in cycles) {
      for (final symptom in cycle.symptoms) {
        symptomCounts[symptom.displayName] = (symptomCounts[symptom.displayName] ?? 0) + 1;
      }
    }
    
    if (symptomCounts.isNotEmpty) {
      final mostFrequent = symptomCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
      final percentage = (mostFrequent.value / cycles.length * 100);
      
      insights.add(TrendInsight(
        title: 'Most Common Symptom',
        description: '${mostFrequent.key} appears in ${percentage.toStringAsFixed(1)}% of your cycles (${mostFrequent.value} out of ${cycles.length}).',
        icon: Icons.trending_up,
        color: Colors.blue,
        recommendation: 'Consider tracking what might trigger this symptom - diet, stress, sleep patterns, or cycle phase.',
      ));
    }
    
    // Mood patterns
    final avgMood = cycles.fold(0.0, (sum, c) => sum + c.wellbeing.mood) / cycles.length;
    if (avgMood >= 4.0) {
      insights.add(TrendInsight(
        title: 'Great Mood Stability',
        description: 'Your average mood score is ${avgMood.toStringAsFixed(1)}/5, showing excellent emotional wellbeing during cycles.',
        icon: Icons.sentiment_very_satisfied,
        color: Colors.green,
      ));
    } else if (avgMood < 2.5) {
      insights.add(TrendInsight(
        title: 'Mood Support Needed',
        description: 'Your average mood score is ${avgMood.toStringAsFixed(1)}/5. Consider strategies to support emotional wellbeing.',
        icon: Icons.sentiment_dissatisfied,
        color: Colors.orange,
        recommendation: 'Try mindfulness, regular exercise, adequate sleep, or consider speaking with a healthcare provider.',
      ));
    }
    
    // Energy patterns
    final avgEnergy = cycles.fold(0.0, (sum, c) => sum + c.wellbeing.energy) / cycles.length;
    if (avgEnergy < 2.5) {
      insights.add(TrendInsight(
        title: 'Energy Management',
        description: 'Your average energy level is ${avgEnergy.toStringAsFixed(1)}/5 during cycles.',
        icon: Icons.battery_2_bar,
        color: Colors.red,
        recommendation: 'Focus on iron-rich foods, adequate sleep, and gentle exercise. Low energy during cycles is common but manageable.',
      ));
    }
    
    // Cycle length insights
    final completedCycles = cycles.where((c) => c.isCompleted).toList();
    if (completedCycles.isNotEmpty) {
      final avgLength = completedCycles.fold(0, (sum, c) => sum + c.lengthInDays) / completedCycles.length;
      if (avgLength < 21 || avgLength > 35) {
        insights.add(TrendInsight(
          title: 'Cycle Length Pattern',
          description: 'Your average cycle length is ${avgLength.toStringAsFixed(1)} days, which is ${avgLength < 21 ? "shorter" : "longer"} than typical.',
          icon: Icons.schedule,
          color: Colors.purple,
          recommendation: 'This could be normal for you, but consider discussing with a healthcare provider if you have concerns.',
        ));
      }
    }
    
    return insights;
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insights,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Track more cycles with symptoms to see trends',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/log-cycle'),
            child: const Text('Log a Cycle'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📈 Symptom Trends'),
        backgroundColor: Colors.purple.shade50,
        foregroundColor: Colors.purple.shade700,
        iconTheme: IconThemeData(color: Colors.purple.shade700),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.purple.shade700),
          onPressed: () => context.go('/home'),
        ),
        bottom: _isLoading || _error != null || _cycles.isEmpty
            ? null
            : TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Frequency', icon: Icon(Icons.bar_chart, size: 16)),
                  Tab(text: 'Wellbeing', icon: Icon(Icons.favorite, size: 16)),
                  Tab(text: 'Patterns', icon: Icon(Icons.scatter_plot, size: 16)),
                  Tab(text: 'Insights', icon: Icon(Icons.lightbulb, size: 16)),
                ],
              ),
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
                      Text('Failed to load data', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadCycleData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _cycles.isEmpty
                  ? _buildEmptyState('No cycle data available')
                  : Column(
                      children: [
                        _buildHeader(),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildSymptomFrequencyTab(),
                              _buildWellbeingTrendsTab(),
                              _buildCorrelationsTab(),
                              _buildInsightsTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }
}

class TrendInsight {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String? recommendation;

  TrendInsight({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.recommendation,
  });
}
