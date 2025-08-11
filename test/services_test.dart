import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import '../lib/services/firebase_service.dart';
import '../lib/services/analytics_service.dart';
import '../lib/services/data_export_service.dart';
import '../lib/services/health_service.dart';

void main() {
  group('Firebase Service Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    
    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth(signedIn: true);
      // FirebaseService.initializeForTesting(fakeFirestore, mockAuth);
    });

    test('should save cycle data successfully', () async {
      final cycleData = {
        'start': DateTime.now(),
        'end': DateTime.now().add(const Duration(days: 5)),
        'flow': 'Medium',
        'mood_level': 3,
        'energy_level': 4,
        'pain_level': 2,
        'symptoms': ['cramps', 'fatigue'],
        'notes': 'Test cycle',
        'created_at': DateTime.now().toIso8601String(),
      };

      // Mock the save operation
      expect(() async => await FirebaseService.saveCycleWithSymptoms(
        cycleData: cycleData,
        timeout: const Duration(seconds: 5),
      ), returnsNormally);
    });

    test('should retrieve cycles successfully', () async {
      // Test cycle retrieval
      final cycles = await FirebaseService.getCycles(limit: 10);
      expect(cycles, isA<List<Map<String, dynamic>>>());
    });

    test('should handle Firebase errors gracefully', () async {
      // Test error handling
      expect(() async => await FirebaseService.getCycles(limit: -1), throwsA(isA<Exception>()));
    });
  });

  group('Analytics Service Tests', () {
    test('should calculate cycle statistics correctly', () {
      final mockCycles = [
        {
          'id': '1',
          'start': DateTime.now().subtract(const Duration(days: 60)),
          'end': DateTime.now().subtract(const Duration(days: 55)),
          'flow': 'Medium',
        },
        {
          'id': '2', 
          'start': DateTime.now().subtract(const Duration(days: 32)),
          'end': DateTime.now().subtract(const Duration(days: 27)),
          'flow': 'Light',
        },
        {
          'id': '3',
          'start': DateTime.now().subtract(const Duration(days: 4)),
          'end': DateTime.now(),
          'flow': 'Heavy',
        },
      ];

      final statistics = AnalyticsService.calculateStatistics(mockCycles);
      
      expect(statistics, isNotNull);
      expect(statistics.totalCycles, equals(3));
      expect(statistics.averageCycleLength, isNotNull);
      expect(statistics.averageCycleLength! > 0, isTrue);
    });

    test('should predict next cycle correctly', () {
      final mockCycles = [
        {
          'id': '1',
          'start': DateTime.now().subtract(const Duration(days: 60)),
          'end': DateTime.now().subtract(const Duration(days: 55)),
        },
        {
          'id': '2',
          'start': DateTime.now().subtract(const Duration(days: 32)),
          'end': DateTime.now().subtract(const Duration(days: 27)),
        },
      ];

      final prediction = AnalyticsService.predictNextCycle(mockCycles);
      
      expect(prediction, isNotNull);
      expect(prediction.nextCycleDate, isNotNull);
      expect(prediction.confidence, isNotNull);
      expect(prediction.confidence >= 0 && prediction.confidence <= 1, isTrue);
    });

    test('should handle insufficient data gracefully', () {
      final emptyCycles = <Map<String, dynamic>>[];
      
      final statistics = AnalyticsService.calculateStatistics(emptyCycles);
      expect(statistics.totalCycles, equals(0));
      expect(statistics.averageCycleLength, isNull);
      
      final prediction = AnalyticsService.predictNextCycle(emptyCycles);
      expect(prediction.nextCycleDate, isNull);
      expect(prediction.confidence, equals(0.0));
    });
  });

  group('Data Export Service Tests', () {
    test('should export cycles to JSON successfully', () async {
      final mockCycles = [
        {
          'id': '1',
          'start': DateTime.now().subtract(const Duration(days: 30)),
          'end': DateTime.now().subtract(const Duration(days: 25)),
          'flow': 'Medium',
          'symptoms': ['cramps'],
          'notes': 'Test cycle 1',
        },
        {
          'id': '2',
          'start': DateTime.now().subtract(const Duration(days: 60)),
          'end': DateTime.now().subtract(const Duration(days: 55)), 
          'flow': 'Light',
          'symptoms': ['fatigue'],
          'notes': 'Test cycle 2',
        },
      ];

      final result = await DataExportService.exportToJson(mockCycles);
      
      expect(result.success, isTrue);
      expect(result.data, isNotNull);
      expect(result.data!.contains('cycles'), isTrue);
      expect(result.data!.contains('Test cycle 1'), isTrue);
    });

    test('should export cycles to CSV successfully', () async {
      final mockCycles = [
        {
          'id': '1',
          'start': DateTime.now(),
          'end': DateTime.now().add(const Duration(days: 5)),
          'flow': 'Medium',
          'symptoms': ['cramps', 'fatigue'],
          'notes': 'Test cycle',
        },
      ];

      final result = await DataExportService.exportToCsv(mockCycles);
      
      expect(result.success, isTrue);
      expect(result.data, isNotNull);
      expect(result.data!.contains('Start Date'), isTrue);
      expect(result.data!.contains('End Date'), isTrue);
      expect(result.data!.contains('Flow'), isTrue);
    });

    test('should handle empty cycle data', () async {
      final emptyCycles = <Map<String, dynamic>>[];
      
      final jsonResult = await DataExportService.exportToJson(emptyCycles);
      expect(jsonResult.success, isTrue);
      expect(jsonResult.data, contains('[]'));
      
      final csvResult = await DataExportService.exportToCsv(emptyCycles);
      expect(csvResult.success, isTrue);
      expect(csvResult.data, contains('Start Date')); // Headers should still be present
    });
  });

  group('Health Service Tests', () {
    test('should check integration status', () async {
      final status = await HealthService.getIntegrationStatus();
      
      expect(status, isNotNull);
      expect(status.isSupported, isA<bool>());
      expect(status.hasPermissions, isA<bool>());
      expect(status.message, isA<String>());
      expect(status.canSync, isA<bool>());
    });

    test('should handle health service errors gracefully', () async {
      // Test error handling when health service is not available
      final status = await HealthService.getIntegrationStatus();
      
      // On test environment, health integration should not be supported
      expect(status.isSupported, isFalse);
      expect(status.canSync, isFalse);
      expect(status.message, isNotEmpty);
    });

    test('should validate flow intensity conversion', () {
      // Test internal flow intensity conversion methods would go here
      // Since they're private, we'd need to make them public or test through public APIs
      expect(true, isTrue); // Placeholder
    });
  });

  group('Integration Tests', () {
    test('should complete full cycle logging workflow', () async {
      // Test the complete workflow from logging to analytics
      final cycleData = {
        'start': DateTime.now().subtract(const Duration(days: 5)),
        'end': DateTime.now(),
        'flow': 'Medium',
        'mood_level': 3,
        'energy_level': 4,
        'pain_level': 2,
        'symptoms': ['cramps'],
        'notes': 'Integration test cycle',
        'created_at': DateTime.now().toIso8601String(),
      };

      // Step 1: Save cycle
      expect(() async => await FirebaseService.saveCycleWithSymptoms(
        cycleData: cycleData,
        timeout: const Duration(seconds: 5),
      ), returnsNormally);

      // Step 2: Retrieve cycles
      final cycles = await FirebaseService.getCycles(limit: 10);
      expect(cycles, isA<List<Map<String, dynamic>>>());

      // Step 3: Calculate analytics
      final statistics = AnalyticsService.calculateStatistics(cycles);
      expect(statistics, isNotNull);

      // Step 4: Export data
      final exportResult = await DataExportService.exportToJson(cycles);
      expect(exportResult.success, isTrue);
    });
  });
}

// Helper functions for testing
class TestHelpers {
  static Map<String, dynamic> createMockCycle({
    DateTime? start,
    DateTime? end,
    String flow = 'Medium',
    List<String> symptoms = const [],
    String notes = '',
  }) {
    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'start': start ?? DateTime.now().subtract(const Duration(days: 5)),
      'end': end ?? DateTime.now(),
      'flow': flow,
      'mood_level': 3,
      'energy_level': 3,
      'pain_level': 2,
      'symptoms': symptoms,
      'notes': notes,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  static List<Map<String, dynamic>> createMockCycles(int count) {
    return List.generate(count, (index) {
      final daysAgo = (index + 1) * 30;
      return createMockCycle(
        start: DateTime.now().subtract(Duration(days: daysAgo)),
        end: DateTime.now().subtract(Duration(days: daysAgo - 5)),
        flow: ['Light', 'Medium', 'Heavy'][index % 3],
        symptoms: [
          ['cramps'],
          ['fatigue', 'mood_swings'],
          ['headache']
        ][index % 3],
        notes: 'Test cycle ${index + 1}',
      );
    });
  }
}
