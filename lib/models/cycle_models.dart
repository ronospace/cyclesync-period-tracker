import 'package:flutter/material.dart';

/// Core cycle data model with comprehensive symptom tracking
class CycleData {
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final FlowIntensity flowIntensity;
  final WellbeingData wellbeing;
  final List<Symptom> symptoms;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  CycleData({
    required this.id,
    required this.startDate,
    this.endDate,
    this.flowIntensity = FlowIntensity.medium,
    required this.wellbeing,
    this.symptoms = const [],
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculate cycle length in days
  int get lengthInDays {
    if (endDate == null) return 0;
    return endDate!.difference(startDate).inDays + 1;
  }

  /// Check if cycle is completed
  bool get isCompleted => endDate != null;

  /// Get formatted date range
  String get dateRange {
    if (endDate == null) {
      return 'Started ${_formatDate(startDate)}';
    }
    return '${_formatDate(startDate)} - ${_formatDate(endDate!)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'start': startDate,
      'end': endDate,
      'flow_intensity': flowIntensity.name,
      'mood': wellbeing.mood,
      'energy': wellbeing.energy,
      'pain': wellbeing.pain,
      'symptoms': symptoms.map((s) => s.name).toList(),
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Create from Firestore document
  factory CycleData.fromFirestore(Map<String, dynamic> data) {
    return CycleData(
      id: data['id'] ?? '',
      startDate: _parseDate(data['start']) ?? DateTime.now(),
      endDate: _parseDate(data['end']),
      flowIntensity: FlowIntensity.values.firstWhere(
        (e) => e.name == data['flow_intensity'],
        orElse: () => FlowIntensity.medium,
      ),
      wellbeing: WellbeingData(
        mood: (data['mood'] ?? 3).toDouble(),
        energy: (data['energy'] ?? 3).toDouble(),
        pain: (data['pain'] ?? 1).toDouble(),
      ),
      symptoms: _parseSymptoms(data['symptoms']),
      notes: data['notes']?.toString() ?? '',
      createdAt: _parseDate(data['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(data['updated_at']) ?? DateTime.now(),
    );
  }

  static DateTime? _parseDate(dynamic date) {
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

  static List<Symptom> _parseSymptoms(dynamic symptoms) {
    if (symptoms == null) return [];
    if (symptoms is! List) return [];
    
    return symptoms
        .map((name) => Symptom.fromName(name.toString()))
        .where((symptom) => symptom != null)
        .cast<Symptom>()
        .toList();
  }

  /// Create a copy with updated values
  CycleData copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    FlowIntensity? flowIntensity,
    WellbeingData? wellbeing,
    List<Symptom>? symptoms,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CycleData(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      flowIntensity: flowIntensity ?? this.flowIntensity,
      wellbeing: wellbeing ?? this.wellbeing,
      symptoms: symptoms ?? this.symptoms,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Flow intensity levels
enum FlowIntensity {
  light('Light', Colors.pink, Icons.opacity),
  medium('Medium', Colors.pinkAccent, Icons.water_drop),
  heavy('Heavy', Colors.red, Icons.bloodtype);

  const FlowIntensity(this.displayName, this.color, this.icon);
  
  final String displayName;
  final Color color;
  final IconData icon;
}

/// Wellbeing data structure
class WellbeingData {
  final double mood; // 1-5 scale
  final double energy; // 1-5 scale  
  final double pain; // 1-5 scale

  const WellbeingData({
    required this.mood,
    required this.energy,
    required this.pain,
  });

  /// Get mood description
  String get moodDescription {
    if (mood >= 4.5) return 'Excellent';
    if (mood >= 3.5) return 'Good';
    if (mood >= 2.5) return 'Okay';
    if (mood >= 1.5) return 'Poor';
    return 'Very Poor';
  }

  /// Get energy description
  String get energyDescription {
    if (energy >= 4.5) return 'Very High';
    if (energy >= 3.5) return 'High';
    if (energy >= 2.5) return 'Moderate';
    if (energy >= 1.5) return 'Low';
    return 'Very Low';
  }

  /// Get pain description
  String get painDescription {
    if (pain >= 4.5) return 'Severe';
    if (pain >= 3.5) return 'Moderate';
    if (pain >= 2.5) return 'Mild';
    if (pain >= 1.5) return 'Slight';
    return 'None';
  }

  WellbeingData copyWith({
    double? mood,
    double? energy,
    double? pain,
  }) {
    return WellbeingData(
      mood: mood ?? this.mood,
      energy: energy ?? this.energy,
      pain: pain ?? this.pain,
    );
  }
}

/// Symptom definitions
class Symptom {
  final String name;
  final String displayName;
  final IconData icon;
  final Color color;
  final String category;

  const Symptom({
    required this.name,
    required this.displayName,
    required this.icon,
    required this.color,
    required this.category,
  });

  static const List<Symptom> allSymptoms = [
    // Physical symptoms
    Symptom(
      name: 'cramps',
      displayName: 'Cramps',
      icon: Icons.healing,
      color: Colors.red,
      category: 'Physical',
    ),
    Symptom(
      name: 'headache',
      displayName: 'Headache',
      icon: Icons.psychology_alt,
      color: Colors.orange,
      category: 'Physical',
    ),
    Symptom(
      name: 'bloating',
      displayName: 'Bloating',
      icon: Icons.circle_outlined,
      color: Colors.blue,
      category: 'Physical',
    ),
    Symptom(
      name: 'breast_tenderness',
      displayName: 'Breast Tenderness',
      icon: Icons.favorite_border,
      color: Colors.pink,
      category: 'Physical',
    ),
    Symptom(
      name: 'fatigue',
      displayName: 'Fatigue',
      icon: Icons.battery_2_bar,
      color: Colors.grey,
      category: 'Physical',
    ),
    Symptom(
      name: 'nausea',
      displayName: 'Nausea',
      icon: Icons.sick,
      color: Colors.green,
      category: 'Physical',
    ),
    
    // Emotional symptoms
    Symptom(
      name: 'mood_swings',
      displayName: 'Mood Swings',
      icon: Icons.emoji_emotions,
      color: Colors.purple,
      category: 'Emotional',
    ),
    Symptom(
      name: 'irritability',
      displayName: 'Irritability',
      icon: Icons.sentiment_dissatisfied,
      color: Colors.red,
      category: 'Emotional',
    ),
    Symptom(
      name: 'anxiety',
      displayName: 'Anxiety',
      icon: Icons.psychology,
      color: Colors.orange,
      category: 'Emotional',
    ),
    Symptom(
      name: 'depression',
      displayName: 'Depression',
      icon: Icons.cloud,
      color: Colors.indigo,
      category: 'Emotional',
    ),
    
    // Other symptoms
    Symptom(
      name: 'acne',
      displayName: 'Acne',
      icon: Icons.face,
      color: Colors.brown,
      category: 'Skin',
    ),
    Symptom(
      name: 'food_cravings',
      displayName: 'Food Cravings',
      icon: Icons.restaurant,
      color: Colors.deepOrange,
      category: 'Other',
    ),
  ];

  /// Get symptom by name
  static Symptom? fromName(String name) {
    try {
      return allSymptoms.firstWhere((s) => s.name == name);
    } catch (e) {
      return null;
    }
  }

  /// Get symptoms by category
  static List<Symptom> byCategory(String category) {
    return allSymptoms.where((s) => s.category == category).toList();
  }

  /// Get all categories
  static List<String> get allCategories {
    return allSymptoms.map((s) => s.category).toSet().toList();
  }
}

/// Cycle statistics and analytics data
class CycleAnalytics {
  final List<CycleData> cycles;
  final double averageCycleLength;
  final double regularityScore;
  final Map<String, double> symptomFrequency;
  final Map<String, double> wellbeingAverages;
  final CyclePrediction? nextCyclePrediction;

  CycleAnalytics({
    required this.cycles,
    required this.averageCycleLength,
    required this.regularityScore,
    required this.symptomFrequency,
    required this.wellbeingAverages,
    this.nextCyclePrediction,
  });

  /// Calculate analytics from cycle data
  factory CycleAnalytics.fromCycles(List<CycleData> cycles) {
    final completedCycles = cycles.where((c) => c.isCompleted).toList();
    
    if (completedCycles.isEmpty) {
      return CycleAnalytics(
        cycles: cycles,
        averageCycleLength: 0,
        regularityScore: 0,
        symptomFrequency: {},
        wellbeingAverages: {},
      );
    }

    // Calculate average cycle length
    final totalLength = completedCycles.fold(0, (sum, cycle) => sum + cycle.lengthInDays);
    final averageLength = totalLength / completedCycles.length;

    // Calculate regularity score (based on standard deviation)
    final lengths = completedCycles.map((c) => c.lengthInDays.toDouble()).toList();
    final variance = lengths.fold(0.0, (sum, length) => sum + (length - averageLength) * (length - averageLength)) / lengths.length;
    final standardDeviation = variance > 0 ? variance.sqrtSafe() : 0.0;
    final regularity = (100 - (standardDeviation * 10)).clamp(0.0, 100.0);

    // Calculate symptom frequency
    final symptomFreq = <String, double>{};
    for (final symptom in Symptom.allSymptoms) {
      final count = cycles.where((c) => c.symptoms.any((s) => s.name == symptom.name)).length;
      symptomFreq[symptom.name] = cycles.isEmpty ? 0 : count / cycles.length;
    }

    // Calculate wellbeing averages
    final wellbeingAvg = <String, double>{};
    if (cycles.isNotEmpty) {
      wellbeingAvg['mood'] = cycles.fold(0.0, (sum, c) => sum + c.wellbeing.mood) / cycles.length;
      wellbeingAvg['energy'] = cycles.fold(0.0, (sum, c) => sum + c.wellbeing.energy) / cycles.length;
      wellbeingAvg['pain'] = cycles.fold(0.0, (sum, c) => sum + c.wellbeing.pain) / cycles.length;
    }

    return CycleAnalytics(
      cycles: cycles,
      averageCycleLength: averageLength,
      regularityScore: regularity,
      symptomFrequency: symptomFreq,
      wellbeingAverages: wellbeingAvg,
      nextCyclePrediction: _predictNextCycle(completedCycles),
    );
  }

  static CyclePrediction? _predictNextCycle(List<CycleData> completedCycles) {
    if (completedCycles.length < 2) return null;

    // Sort by start date (most recent first)
    completedCycles.sort((a, b) => b.startDate.compareTo(a.startDate));
    
    // Take last 3 cycles for prediction
    final recentCycles = completedCycles.take(3).toList();
    final avgLength = recentCycles.fold(0, (sum, c) => sum + c.lengthInDays) / recentCycles.length;
    
    final lastCycleEnd = recentCycles.first.endDate!;
    final predictedStart = lastCycleEnd.add(Duration(days: avgLength.round()));
    final predictedEnd = predictedStart.add(Duration(days: avgLength.round() - 1));
    
    // Calculate confidence based on regularity
    final lengths = recentCycles.map((c) => c.lengthInDays).toList();
    final variance = lengths.fold(0.0, (sum, length) => sum + (length - avgLength) * (length - avgLength)) / lengths.length;
    final confidence = (100 - variance * 10).clamp(50.0, 95.0);

    return CyclePrediction(
      predictedStartDate: predictedStart,
      predictedEndDate: predictedEnd,
      confidence: confidence,
      basedOnCycles: recentCycles.length,
    );
  }
}

/// Cycle prediction model
class CyclePrediction {
  final DateTime predictedStartDate;
  final DateTime predictedEndDate;
  final double confidence; // 0-100
  final int basedOnCycles;

  CyclePrediction({
    required this.predictedStartDate,
    required this.predictedEndDate,
    required this.confidence,
    required this.basedOnCycles,
  });

  int get daysUntilPredicted => predictedStartDate.difference(DateTime.now()).inDays;
  int get predictedLength => predictedEndDate.difference(predictedStartDate).inDays + 1;
}

/// Helper extension for double sqrt
extension DoubleExtension on double {
  double sqrtSafe() {
    if (this <= 0) return 0;
    var x = this / 2;
    while ((x * x - this).abs() > 0.0001) {
      x = (x + this / x) / 2;
    }
    return x;
  }
}

/// Filter options for cycle history
class CycleFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<FlowIntensity>? flowIntensities;
  final List<Symptom>? symptoms;
  final double? minMood;
  final double? maxMood;
  final double? minEnergy;
  final double? maxEnergy;
  final double? minPain;
  final double? maxPain;

  CycleFilter({
    this.startDate,
    this.endDate,
    this.flowIntensities,
    this.symptoms,
    this.minMood,
    this.maxMood,
    this.minEnergy,
    this.maxEnergy,
    this.minPain,
    this.maxPain,
  });

  /// Apply filter to cycle list
  List<CycleData> apply(List<CycleData> cycles) {
    return cycles.where((cycle) {
      // Date range filter
      if (startDate != null && cycle.startDate.isBefore(startDate!)) return false;
      if (endDate != null && cycle.startDate.isAfter(endDate!)) return false;
      
      // Flow intensity filter
      if (flowIntensities != null && !flowIntensities!.contains(cycle.flowIntensity)) return false;
      
      // Symptom filter
      if (symptoms != null && symptoms!.isNotEmpty) {
        final hasSymptom = symptoms!.any((symptom) => 
          cycle.symptoms.any((cycleSymptom) => cycleSymptom.name == symptom.name));
        if (!hasSymptom) return false;
      }
      
      // Wellbeing filters
      if (minMood != null && cycle.wellbeing.mood < minMood!) return false;
      if (maxMood != null && cycle.wellbeing.mood > maxMood!) return false;
      if (minEnergy != null && cycle.wellbeing.energy < minEnergy!) return false;
      if (maxEnergy != null && cycle.wellbeing.energy > maxEnergy!) return false;
      if (minPain != null && cycle.wellbeing.pain < minPain!) return false;
      if (maxPain != null && cycle.wellbeing.pain > maxPain!) return false;
      
      return true;
    }).toList();
  }
}
