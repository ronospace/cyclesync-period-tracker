import 'package:flutter/material.dart';

/// Represents a daily log entry for quick tracking
class DailyLogEntry {
  final String id;
  final DateTime date;
  final double? mood; // 1-5 scale
  final double? energy; // 1-5 scale
  final double? pain; // 1-5 scale
  final List<String> symptoms;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Additional wellness fields
  final double? wellbeing; // 1-5 scale overall wellbeing
  final double? sleepHours; // Hours of sleep
  final int? stepsCount; // Daily step count
  final double? waterIntake; // Liters of water

  const DailyLogEntry({
    required this.id,
    required this.date,
    this.mood,
    this.energy,
    this.pain,
    this.symptoms = const [],
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
    this.wellbeing,
    this.sleepHours,
    this.stepsCount,
    this.waterIntake,
  });

  DailyLogEntry copyWith({
    String? id,
    DateTime? date,
    double? mood,
    double? energy,
    double? pain,
    List<String>? symptoms,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyLogEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      energy: energy ?? this.energy,
      pain: pain ?? this.pain,
      symptoms: symptoms ?? this.symptoms,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mood': mood,
      'energy': energy,
      'pain': pain,
      'symptoms': symptoms,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static DailyLogEntry fromJson(Map<String, dynamic> json) {
    return DailyLogEntry(
      id: json['id'] ?? '',
      date: DateTime.parse(json['date']),
      mood: json['mood']?.toDouble(),
      energy: json['energy']?.toDouble(),
      pain: json['pain']?.toDouble(),
      symptoms: List<String>.from(json['symptoms'] ?? []),
      notes: json['notes'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Firestore methods
  Map<String, dynamic> toFirestore() {
    return {
      'date': date.millisecondsSinceEpoch,
      'mood': mood,
      'energy': energy,
      'pain': pain,
      'symptoms': symptoms,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  static DailyLogEntry fromFirestore(Map<String, dynamic> data, String id) {
    return DailyLogEntry(
      id: id,
      date: DateTime.fromMillisecondsSinceEpoch(data['date'] ?? 0),
      mood: data['mood']?.toDouble(),
      energy: data['energy']?.toDouble(),
      pain: data['pain']?.toDouble(),
      symptoms: List<String>.from(data['symptoms'] ?? []),
      notes: data['notes'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] ?? 0),
    );
  }

  bool get hasData => 
      mood != null || energy != null || pain != null || 
      symptoms.isNotEmpty || notes.isNotEmpty;

  String get moodDescription {
    if (mood == null) return 'Not logged';
    if (mood! <= 1.5) return 'Very Low';
    if (mood! <= 2.5) return 'Low';
    if (mood! <= 3.5) return 'Okay';
    if (mood! <= 4.5) return 'Good';
    return 'Great';
  }

  String get energyDescription {
    if (energy == null) return 'Not logged';
    if (energy! <= 1.5) return 'Exhausted';
    if (energy! <= 2.5) return 'Low';
    if (energy! <= 3.5) return 'Okay';
    if (energy! <= 4.5) return 'Good';
    return 'High';
  }

  String get painDescription {
    if (pain == null) return 'Not logged';
    if (pain! <= 1.5) return 'None';
    if (pain! <= 2.5) return 'Mild';
    if (pain! <= 3.5) return 'Moderate';
    if (pain! <= 4.5) return 'Severe';
    return 'Extreme';
  }

  Color get moodColor {
    if (mood == null) return Colors.grey;
    if (mood! <= 1.5) return Colors.red.shade700;
    if (mood! <= 2.5) return Colors.orange.shade700;
    if (mood! <= 3.5) return Colors.yellow.shade700;
    if (mood! <= 4.5) return Colors.lightGreen.shade700;
    return Colors.green.shade700;
  }

  Color get energyColor {
    if (energy == null) return Colors.grey;
    if (energy! <= 1.5) return Colors.red.shade700;
    if (energy! <= 2.5) return Colors.orange.shade700;
    if (energy! <= 3.5) return Colors.yellow.shade700;
    if (energy! <= 4.5) return Colors.lightGreen.shade700;
    return Colors.green.shade700;
  }

  Color get painColor {
    if (pain == null) return Colors.grey;
    if (pain! <= 1.5) return Colors.green.shade700;
    if (pain! <= 2.5) return Colors.lightGreen.shade700;
    if (pain! <= 3.5) return Colors.yellow.shade700;
    if (pain! <= 4.5) return Colors.orange.shade700;
    return Colors.red.shade700;
  }

  /// Calculate overall wellness score (0-100)
  double calculateWellnessScore() {
    double score = 0.0;
    int factors = 0;

    // Mood factor (0-20 points)
    if (mood != null) {
      score += (mood! / 5.0) * 20;
      factors++;
    }

    // Energy factor (0-20 points)
    if (energy != null) {
      score += (energy! / 5.0) * 20;
      factors++;
    }

    // Pain factor (0-20 points, inverted)
    if (pain != null) {
      score += (1.0 - (pain! - 1) / 4.0) * 20;
      factors++;
    }

    // Wellbeing factor (0-20 points)
    if (wellbeing != null) {
      score += (wellbeing! / 5.0) * 20;
      factors++;
    }

    // Sleep factor (0-20 points)
    if (sleepHours != null) {
      // Optimal sleep is 7-9 hours
      double sleepScore = sleepHours! >= 7 && sleepHours! <= 9 ? 1.0 : 
                         sleepHours! < 7 ? sleepHours! / 7.0 :
                         sleepHours! > 9 ? (16 - sleepHours!) / 7.0 : 0.5;
      score += sleepScore * 20;
      factors++;
    }

    return factors > 0 ? score / factors * (factors / 5.0) : 50.0;
  }
}

/// Quick logging template for common scenarios
class QuickLogTemplate {
  final String name;
  final IconData icon;
  final Color color;
  final double? mood;
  final double? energy;
  final double? pain;
  final List<String> symptoms;
  final String notes;

  const QuickLogTemplate({
    required this.name,
    required this.icon,
    required this.color,
    this.mood,
    this.energy,
    this.pain,
    this.symptoms = const [],
    this.notes = '',
  });

  static List<QuickLogTemplate> getDefaultTemplates() {
    return [
      const QuickLogTemplate(
        name: 'Great Day',
        icon: Icons.sentiment_very_satisfied,
        color: Colors.green,
        mood: 5.0,
        energy: 4.5,
        pain: 1.0,
      ),
      const QuickLogTemplate(
        name: 'Good Day',
        icon: Icons.sentiment_satisfied,
        color: Colors.lightGreen,
        mood: 4.0,
        energy: 4.0,
        pain: 1.5,
      ),
      const QuickLogTemplate(
        name: 'Okay Day',
        icon: Icons.sentiment_neutral,
        color: Colors.orange,
        mood: 3.0,
        energy: 3.0,
        pain: 2.0,
      ),
      const QuickLogTemplate(
        name: 'Tough Day',
        icon: Icons.sentiment_dissatisfied,
        color: Colors.deepOrange,
        mood: 2.0,
        energy: 2.0,
        pain: 3.0,
        symptoms: ['Fatigue', 'Mood Swings'],
      ),
      const QuickLogTemplate(
        name: 'Period Day',
        icon: Icons.water_drop,
        color: Colors.red,
        mood: 2.5,
        energy: 2.0,
        pain: 3.5,
        symptoms: ['Cramps', 'Bloating', 'Fatigue'],
      ),
      const QuickLogTemplate(
        name: 'PMS',
        icon: Icons.psychology,
        color: Colors.purple,
        mood: 2.0,
        energy: 2.5,
        pain: 2.5,
        symptoms: ['Mood Swings', 'Irritability', 'Bloating'],
      ),
    ];
  }
}

/// Represents a mood rating with visual elements
class MoodRating {
  final double value;
  final String label;
  final IconData icon;
  final Color color;

  const MoodRating({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  static List<MoodRating> get all => [
    const MoodRating(
      value: 1.0,
      label: 'Very Low',
      icon: Icons.sentiment_very_dissatisfied,
      color: Colors.red,
    ),
    const MoodRating(
      value: 2.0,
      label: 'Low',
      icon: Icons.sentiment_dissatisfied,
      color: Colors.orange,
    ),
    const MoodRating(
      value: 3.0,
      label: 'Okay',
      icon: Icons.sentiment_neutral,
      color: Colors.amber,
    ),
    const MoodRating(
      value: 4.0,
      label: 'Good',
      icon: Icons.sentiment_satisfied,
      color: Colors.lightGreen,
    ),
    const MoodRating(
      value: 5.0,
      label: 'Great',
      icon: Icons.sentiment_very_satisfied,
      color: Colors.green,
    ),
  ];

  static MoodRating fromValue(double value) {
    return all.reduce((curr, next) {
      return (value - curr.value).abs() < (value - next.value).abs() ? curr : next;
    });
  }
}
