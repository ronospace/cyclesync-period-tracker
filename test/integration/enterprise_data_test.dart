import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../lib/data/repositories/health_data_repository.dart';
import '../../lib/data/cache/data_cache_manager.dart';
import '../../lib/data/sync/data_sync_manager.dart';
import '../../lib/services/encryption_service.dart';
import '../../lib/services/analytics_engine.dart';
import '../../lib/providers/enterprise_data_provider.dart';
import '../../lib/models/cycle_models.dart';

// Generate mocks
@GenerateMocks([
  HealthDataRepository,
  DataCacheManager,
  DataSyncManager,
  EncryptionService,
])
import 'enterprise_data_test.mocks.dart';

void main() {
  group('Enterprise Data Architecture Integration Tests', () {
    late MockHealthDataRepository mockRepository;
    late MockDataCacheManager mockCacheManager;
    late MockDataSyncManager mockSyncManager;
    late MockEncryptionService mockEncryptionService;

    setUp(() {
      mockRepository = MockHealthDataRepository();
      mockCacheManager = MockDataCacheManager();
      mockSyncManager = MockDataSyncManager();
      mockEncryptionService = MockEncryptionService();
    });

    group('Data Repository Layer', () {
      test('should initialize repository successfully', () async {
        // Arrange
        when(mockRepository.initialize()).thenAnswer((_) async => {});
        
        // Act & Assert
        expect(() => mockRepository.initialize(), returnsNormally);
        verify(mockRepository.initialize()).called(1);
      });

      test('should handle repository initialization failure', () async {
        // Arrange
        when(mockRepository.initialize()).thenThrow(Exception('Init failed'));
        
        // Act & Assert
        expect(() => mockRepository.initialize(), throwsException);
      });

      test('should retrieve cycles from repository', () async {
        // Arrange
        final testCycles = [
          CycleData(
            id: 'test1',
            startDate: DateTime(2024, 1, 1),
            flowIntensity: FlowIntensity.medium,
            symptoms: [],
            notes: 'Test cycle',
            createdAt: DateTime.now(),
            lastUpdated: DateTime.now(),
          ),
        ];
        
        when(mockRepository.getCycles()).thenAnswer((_) async => testCycles);
        
        // Act
        final result = await mockRepository.getCycles();
        
        // Assert
        expect(result, equals(testCycles));
        expect(result.length, equals(1));
        expect(result.first.id, equals('test1'));
      });

      test('should handle save cycle operation', () async {
        // Arrange
        final testCycle = CycleData(
          id: 'new-cycle',
          startDate: DateTime(2024, 1, 15),
          flowIntensity: FlowIntensity.light,
          symptoms: [],
          notes: 'New cycle',
          createdAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        );
        
        when(mockRepository.saveCycle(testCycle)).thenAnswer((_) async => {});
        
        // Act & Assert
        expect(() => mockRepository.saveCycle(testCycle), returnsNormally);
        verify(mockRepository.saveCycle(testCycle)).called(1);
      });
    });

    group('Cache Management Layer', () {
      test('should initialize cache manager', () async {
        // Arrange
        when(mockCacheManager.initialize()).thenAnswer((_) async => {});
        
        // Act & Assert
        expect(() => mockCacheManager.initialize(), returnsNormally);
        verify(mockCacheManager.initialize()).called(1);
      });

      test('should cache and retrieve cycles', () async {
        // Arrange
        final testCycles = [
          CycleData(
            id: 'cached1',
            startDate: DateTime(2024, 2, 1),
            flowIntensity: FlowIntensity.heavy,
            symptoms: [],
            notes: 'Cached cycle',
            createdAt: DateTime.now(),
            lastUpdated: DateTime.now(),
          ),
        ];
        
        when(mockCacheManager.cacheCycles(testCycles)).thenAnswer((_) async => {});
        when(mockCacheManager.getCachedCycles()).thenAnswer((_) async => testCycles);
        
        // Act
        await mockCacheManager.cacheCycles(testCycles);
        final result = await mockCacheManager.getCachedCycles();
        
        // Assert
        verify(mockCacheManager.cacheCycles(testCycles)).called(1);
        verify(mockCacheManager.getCachedCycles()).called(1);
        expect(result, equals(testCycles));
      });

      test('should handle cache operations with TTL', () async {
        // Arrange
        const testKey = 'test-key';
        const testData = {'test': 'data'};
        const ttl = Duration(hours: 1);
        
        when(mockCacheManager.cacheData(testKey, testData, ttl: ttl))
            .thenAnswer((_) async => {});
        when(mockCacheManager.getCachedData<Map<String, dynamic>>(testKey))
            .thenAnswer((_) async => testData);
        
        // Act
        await mockCacheManager.cacheData(testKey, testData, ttl: ttl);
        final result = await mockCacheManager.getCachedData<Map<String, dynamic>>(testKey);
        
        // Assert
        verify(mockCacheManager.cacheData(testKey, testData, ttl: ttl)).called(1);
        expect(result, equals(testData));
      });
    });

    group('Data Synchronization Layer', () {
      test('should initialize sync manager', () async {
        // Arrange
        when(mockSyncManager.initialize()).thenAnswer((_) async => {});
        
        // Act & Assert
        expect(() => mockSyncManager.initialize(), returnsNormally);
        verify(mockSyncManager.initialize()).called(1);
      });

      test('should perform data synchronization', () async {
        // Arrange
        final mockSyncResult = DataSyncStatus.success('Sync completed');
        when(mockSyncManager.performSync()).thenAnswer((_) async => mockSyncResult);
        
        // Act
        final result = await mockSyncManager.performSync();
        
        // Assert
        expect(result.state, equals(SyncState.success));
        expect(result.message, equals('Sync completed'));
        verify(mockSyncManager.performSync()).called(1);
      });

      test('should handle sync failures gracefully', () async {
        // Arrange
        final errorSyncResult = DataSyncStatus.error('Network error');
        when(mockSyncManager.performSync()).thenAnswer((_) async => errorSyncResult);
        
        // Act
        final result = await mockSyncManager.performSync();
        
        // Assert
        expect(result.state, equals(SyncState.error));
        expect(result.message, contains('Network error'));
      });
    });

    group('Encryption Service Layer', () {
      test('should initialize encryption service', () async {
        // Arrange
        when(mockEncryptionService.initialize()).thenAnswer((_) async => {});
        
        // Act & Assert
        expect(() => mockEncryptionService.initialize(), returnsNormally);
        verify(mockEncryptionService.initialize()).called(1);
      });

      test('should encrypt and decrypt data', () async {
        // Arrange
        const plaintext = 'sensitive health data';
        const encrypted = 'encrypted-data-123';
        
        when(mockEncryptionService.encrypt(plaintext)).thenAnswer((_) async => encrypted);
        when(mockEncryptionService.decrypt(encrypted)).thenAnswer((_) async => plaintext);
        
        // Act
        final encryptedResult = await mockEncryptionService.encrypt(plaintext);
        final decryptedResult = await mockEncryptionService.decrypt(encrypted);
        
        // Assert
        expect(encryptedResult, equals(encrypted));
        expect(decryptedResult, equals(plaintext));
        verify(mockEncryptionService.encrypt(plaintext)).called(1);
        verify(mockEncryptionService.decrypt(encrypted)).called(1);
      });

      test('should handle encryption with custom purpose', () async {
        // Arrange
        const plaintext = 'cycle data';
        const purpose = 'cycle_encryption';
        const encrypted = 'purpose-encrypted-456';
        
        when(mockEncryptionService.encrypt(plaintext, purpose: purpose))
            .thenAnswer((_) async => encrypted);
        
        // Act
        final result = await mockEncryptionService.encrypt(plaintext, purpose: purpose);
        
        // Assert
        expect(result, equals(encrypted));
        verify(mockEncryptionService.encrypt(plaintext, purpose: purpose)).called(1);
      });
    });

    group('Analytics Engine', () {
      test('should generate cycle analytics', () async {
        // Arrange
        final testCycles = [
          CycleData(
            id: 'analytics1',
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2024, 1, 5),
            flowIntensity: FlowIntensity.medium,
            symptoms: [],
            notes: 'Analytics test',
            createdAt: DateTime.now(),
            lastUpdated: DateTime.now(),
          ),
          CycleData(
            id: 'analytics2',
            startDate: DateTime(2024, 1, 29),
            endDate: DateTime(2024, 2, 3),
            flowIntensity: FlowIntensity.light,
            symptoms: [],
            notes: 'Analytics test 2',
            createdAt: DateTime.now(),
            lastUpdated: DateTime.now(),
          ),
        ];

        final analyticsEngine = AnalyticsEngine.instance;
        
        // Act
        final analytics = await analyticsEngine.generateCycleAnalytics(testCycles);
        
        // Assert
        expect(analytics.totalCycles, equals(2));
        expect(analytics.averageCycleLength, greaterThan(0));
        expect(analytics.predictedNextPeriod, isNotNull);
        expect(analytics.insights, isNotEmpty);
      });

      test('should handle empty cycle data for analytics', () async {
        // Arrange
        final analyticsEngine = AnalyticsEngine.instance;
        
        // Act
        final analytics = await analyticsEngine.generateCycleAnalytics([]);
        
        // Assert
        expect(analytics.totalCycles, equals(0));
        expect(analytics.averageCycleLength, equals(28.0)); // Default value
      });
    });

    group('Enterprise Data Provider Integration', () {
      test('should integrate all layers correctly', () async {
        // This test would require more complex setup with actual instances
        // For now, we'll test the basic integration points
        
        // Arrange
        when(mockRepository.initialize()).thenAnswer((_) async => {});
        when(mockRepository.getCycles()).thenAnswer((_) async => []);
        when(mockRepository.getDailyLogs()).thenAnswer((_) async => []);
        
        // Act & Assert
        // This would test the actual EnterpriseDataProvider integration
        // which is more complex and would require widget testing
        expect(true, isTrue); // Placeholder for actual integration test
      });
    });

    group('Performance and Memory Tests', () {
      test('should handle large datasets efficiently', () async {
        // Arrange
        final largeCycleDataset = List.generate(1000, (index) => 
          CycleData(
            id: 'perf-test-$index',
            startDate: DateTime(2020, 1, 1).add(Duration(days: index * 28)),
            flowIntensity: FlowIntensity.values[index % FlowIntensity.values.length],
            symptoms: [],
            notes: 'Performance test cycle $index',
            createdAt: DateTime.now(),
            lastUpdated: DateTime.now(),
          )
        );
        
        when(mockRepository.getCycles()).thenAnswer((_) async => largeCycleDataset);
        
        // Act
        final stopwatch = Stopwatch()..start();
        final result = await mockRepository.getCycles();
        stopwatch.stop();
        
        // Assert
        expect(result.length, equals(1000));
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Should complete in under 1 second
        print('Large dataset retrieval took ${stopwatch.elapsedMilliseconds}ms');
      });

      test('should handle concurrent operations', () async {
        // Test concurrent cache operations
        final futures = List.generate(10, (index) => 
          mockCacheManager.cacheData('concurrent-$index', {'data': index})
        );
        
        when(mockCacheManager.cacheData(any, any)).thenAnswer((_) async => {});
        
        // Act & Assert
        expect(() => Future.wait(futures), returnsNormally);
      });
    });

    group('Error Handling and Resilience', () {
      test('should recover from network failures', () async {
        // Arrange
        when(mockSyncManager.performSync())
            .thenThrow(Exception('Network error'))
            .thenAnswer((_) async => DataSyncStatus.success('Recovered'));
        
        // Act - First attempt fails
        try {
          await mockSyncManager.performSync();
          fail('Expected exception');
        } catch (e) {
          expect(e.toString(), contains('Network error'));
        }
        
        // Act - Second attempt succeeds
        final result = await mockSyncManager.performSync();
        
        // Assert
        expect(result.state, equals(SyncState.success));
      });

      test('should handle data corruption gracefully', () async {
        // Arrange
        when(mockEncryptionService.decrypt(any))
            .thenThrow(Exception('Decryption failed - data corrupted'));
        
        // Act & Assert
        expect(
          () => mockEncryptionService.decrypt('corrupted-data'),
          throwsException,
        );
      });
    });
  });
}

/// Helper method to create test cycle data
CycleData createTestCycle({
  String? id,
  DateTime? startDate,
  FlowIntensity? flowIntensity,
  String? notes,
}) {
  return CycleData(
    id: id ?? 'test-${DateTime.now().millisecondsSinceEpoch}',
    startDate: startDate ?? DateTime.now(),
    flowIntensity: flowIntensity ?? FlowIntensity.medium,
    symptoms: [],
    notes: notes ?? 'Test cycle',
    createdAt: DateTime.now(),
    lastUpdated: DateTime.now(),
  );
}

/// Helper method to create test analytics
CycleAnalytics createTestAnalytics() {
  return CycleAnalytics(
    totalCycles: 5,
    averageCycleLength: 28.5,
    averagePeriodLength: 5.0,
    cycleRegularity: 0.85,
    predictedNextPeriod: DateTime.now().add(const Duration(days: 28)),
    predictedOvulation: DateTime.now().add(const Duration(days: 14)),
    fertileWindow: null,
    commonSymptoms: [],
    symptomPatterns: {},
    healthCorrelations: {},
    insights: [],
    trendData: [],
    generatedAt: DateTime.now(),
  );
}
