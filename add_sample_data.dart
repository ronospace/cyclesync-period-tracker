import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lib/firebase_options.dart';

void main() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  const userId = '4GEkV6hItgUgrZNPLMl3ES4mXOm2'; // The user ID from logs

  // Adding sample cycle data for user: $userId

  // Sample cycle data for the last 6 months
  final sampleCycles = [
    {
      'id': 'cycle_1',
      'start_date': DateTime(2025, 2, 1),
      'end_date': DateTime(2025, 2, 28),
      'flow': 'medium',
      'mood_level': 4,
      'energy_level': 3,
      'pain_level': 2,
      'symptoms': ['cramps', 'headache'],
      'notes': 'First cycle tracked',
      'created_at': DateTime(2025, 2, 1),
    },
    {
      'id': 'cycle_2',
      'start_date': DateTime(2025, 3, 2),
      'end_date': DateTime(2025, 3, 30),
      'flow': 'heavy',
      'mood_level': 3,
      'energy_level': 2,
      'pain_level': 4,
      'symptoms': ['cramps', 'fatigue', 'mood_swings'],
      'notes': 'Heavy flow cycle',
      'created_at': DateTime(2025, 3, 2),
    },
    {
      'id': 'cycle_3',
      'start_date': DateTime(2025, 4, 1),
      'end_date': DateTime(2025, 4, 27),
      'flow': 'light',
      'mood_level': 5,
      'energy_level': 4,
      'pain_level': 1,
      'symptoms': ['bloating'],
      'notes': 'Light and easy cycle',
      'created_at': DateTime(2025, 4, 1),
    },
    {
      'id': 'cycle_4',
      'start_date': DateTime(2025, 5, 3),
      'end_date': DateTime(2025, 5, 31),
      'flow': 'medium',
      'mood_level': 4,
      'energy_level': 4,
      'pain_level': 2,
      'symptoms': ['cramps', 'headache', 'breast_tenderness'],
      'notes': 'Regular cycle',
      'created_at': DateTime(2025, 5, 3),
    },
    {
      'id': 'cycle_5',
      'start_date': DateTime(2025, 6, 2),
      'end_date': DateTime(2025, 6, 29),
      'flow': 'medium',
      'mood_level': 3,
      'energy_level': 3,
      'pain_level': 3,
      'symptoms': ['cramps', 'fatigue', 'irritability'],
      'notes': 'Average cycle',
      'created_at': DateTime(2025, 6, 2),
    },
    {
      'id': 'cycle_6',
      'start_date': DateTime(2025, 7, 1),
      'end_date': DateTime(2025, 7, 28),
      'flow': 'light',
      'mood_level': 4,
      'energy_level': 5,
      'pain_level': 1,
      'symptoms': ['mood_swings'],
      'notes': 'Great energy this cycle',
      'created_at': DateTime(2025, 7, 1),
    },
  ];

  try {
    // Add each cycle to Firestore
    for (int i = 0; i < sampleCycles.length; i++) {
      final cycleData = sampleCycles[i];
      
      await firestore
          .collection('users')
          .doc(userId)
          .collection('cycles')
          .doc(cycleData['id'] as String)
          .set({
        'start': Timestamp.fromDate(cycleData['start_date'] as DateTime),
        'end': Timestamp.fromDate(cycleData['end_date'] as DateTime),
        'flow': cycleData['flow'],
        'mood_level': cycleData['mood_level'],
        'energy_level': cycleData['energy_level'],
        'pain_level': cycleData['pain_level'],
        'symptoms': cycleData['symptoms'],
        'notes': cycleData['notes'],
        'created_at': Timestamp.fromDate(cycleData['created_at'] as DateTime),
      });
      
      // Added cycle ${i + 1}/6: ${cycleData['id']}
    }

    // Add some daily logs too
    final sampleDailyLogs = [
      {
        'date': DateTime(2025, 8, 5),
        'mood': 4.0,
        'energy': 3.5,
        'pain': 1.0,
        'symptoms': ['headache'],
        'notes': 'Slight headache today',
      },
      {
        'date': DateTime(2025, 8, 7),
        'mood': 5.0,
        'energy': 4.0,
        'pain': 0.0,
        'symptoms': [],
        'notes': 'Great day!',
      },
      {
        'date': DateTime(2025, 8, 9),
        'mood': 3.0,
        'energy': 2.5,
        'pain': 2.0,
        'symptoms': ['fatigue', 'cramps'],
        'notes': 'Feeling tired',
      },
    ];

    for (int i = 0; i < sampleDailyLogs.length; i++) {
      final logData = sampleDailyLogs[i];
      final dateStr = (logData['date'] as DateTime).toIso8601String().split('T')[0];
      
      await firestore
          .collection('users')
          .doc(userId)
          .collection('daily_logs')
          .doc(dateStr)
          .set({
        'date': Timestamp.fromDate(logData['date'] as DateTime),
        'mood': logData['mood'],
        'energy': logData['energy'],
        'pain': logData['pain'],
        'symptoms': logData['symptoms'],
        'notes': logData['notes'],
        'created_at': Timestamp.now(),
      });
      
      // Added daily log ${i + 1}/3: $dateStr
    }

    // Successfully added sample data!
    // Analytics should now show:
    // • 6 completed cycles
    // • Cycle length trends
    // • Symptom patterns
    // • Predictions with confidence
    // • Wellbeing trends
    // Restart the app to see the analytics!

  } catch (e) {
    // Error adding sample data: $e
  }

  exit(0);
}
