import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static const Duration _defaultTimeout = Duration(seconds: 30);
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user with validation
  static User? get currentUser => _auth.currentUser;

  /// Ensure user is authenticated, throw if not
  static User _requireAuth() {
    final user = currentUser;
    if (user == null) {
      throw FirebaseException(
        plugin: 'auth',
        code: 'unauthenticated',
        message: 'User not authenticated',
      );
    }
    return user;
  }

  /// Save a cycle with enhanced symptom data
  static Future<void> saveCycleWithSymptoms({
    required Map<String, dynamic> cycleData,
    Duration timeout = _defaultTimeout,
  }) async {
    try {
      final user = _requireAuth();
      
      debugPrint('🔥 FirebaseService: Starting enhanced save for user ${user.uid}');
      debugPrint('🔥 FirebaseService: Data keys: ${cycleData.keys.join(", ")}');

      // Create the document reference first
      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cycles');
      
      // Add metadata to the cycle data
      final enhancedData = {
        ...cycleData,
        'user_id': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      };
      
      // Add with explicit timeout and proper error handling
      await docRef
          .add(enhancedData)
          .timeout(
            timeout,
            onTimeout: () {
              throw FirebaseException(
                plugin: 'cloud_firestore',
                code: 'timeout',
                message: 'Operation timed out after ${timeout.inSeconds} seconds. Please check your internet connection.',
              );
            },
          );

      debugPrint('🔥 FirebaseService: Enhanced save completed successfully');
    } catch (e) {
      debugPrint('🔥 FirebaseService: Error in enhanced save: $e');
      debugPrint('🔥 FirebaseService: Error type: ${e.runtimeType}');
      
      // Re-throw with more context
      if (e is FirebaseException) {
        throw FirebaseException(
          plugin: e.plugin,
          code: e.code,
          message: 'Failed to save cycle with symptoms: ${e.message}',
        );
      } else {
        throw Exception('Failed to save cycle with symptoms: $e');
      }
    }
  }

  /// Save a cycle entry with robust error handling
  static Future<void> saveCycle({
    required DateTime startDate,
    required DateTime endDate,
    Duration timeout = _defaultTimeout,
  }) async {
    try {
      final user = _requireAuth();
      
      debugPrint('🔥 FirebaseService: Starting save for user ${user.uid}');
      debugPrint('🔥 FirebaseService: Start: $startDate, End: $endDate');

      // Create the document reference first
      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cycles');
      
      // Add with explicit timeout and proper error handling
      await docRef
          .add({
            'start': startDate,
            'end': endDate,
            'timestamp': FieldValue.serverTimestamp(),
            'created_at': DateTime.now().toIso8601String(), // Fallback timestamp
          })
          .timeout(
            timeout,
            onTimeout: () {
              throw FirebaseException(
                plugin: 'cloud_firestore',
                code: 'timeout',
                message: 'Operation timed out after ${timeout.inSeconds} seconds. Please check your internet connection.',
              );
            },
          );

      debugPrint('🔥 FirebaseService: Save completed successfully');
    } catch (e) {
      debugPrint('🔥 FirebaseService: Error occurred: $e');
      debugPrint('🔥 FirebaseService: Error type: ${e.runtimeType}');
      
      // Re-throw with more context
      if (e is FirebaseException) {
        throw FirebaseException(
          plugin: e.plugin,
          code: e.code,
          message: 'Failed to save cycle: ${e.message}',
        );
      } else {
        throw Exception('Failed to save cycle: $e');
      }
    }
  }

  /// Save daily log entry
  static Future<void> saveDailyLog(
    Map<String, dynamic> dailyLogData, {
    Duration timeout = _defaultTimeout,
  }) async {
    try {
      final user = _requireAuth();
      
      debugPrint('🔥 FirebaseService: Starting daily log save for user ${user.uid}');
      debugPrint('🔥 FirebaseService: Daily log data keys: ${dailyLogData.keys.join(", ")}');

      // Create the document reference
      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_logs');
      
      // Add metadata to the daily log data
      final enhancedData = {
        ...dailyLogData,
        'user_id': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      };
      
      // Use date as document ID to ensure one log per day
      final dateKey = (dailyLogData['date'] as DateTime).toIso8601String().split('T')[0];
      
      // Set (upsert) with explicit timeout and proper error handling
      await docRef
          .doc(dateKey)
          .set(enhancedData, SetOptions(merge: true))
          .timeout(
            timeout,
            onTimeout: () {
              throw FirebaseException(
                plugin: 'cloud_firestore',
                code: 'timeout',
                message: 'Daily log save timed out after ${timeout.inSeconds} seconds. Please check your internet connection.',
              );
            },
          );

      debugPrint('🔥 FirebaseService: Daily log save completed successfully');
    } catch (e) {
      debugPrint('🔥 FirebaseService: Error in daily log save: $e');
      debugPrint('🔥 FirebaseService: Error type: ${e.runtimeType}');
      
      // Re-throw with more context
      if (e is FirebaseException) {
        throw FirebaseException(
          plugin: e.plugin,
          code: e.code,
          message: 'Failed to save daily log: ${e.message}',
        );
      } else {
        throw Exception('Failed to save daily log: $e');
      }
    }
  }

  /// Get daily log entry for a specific date
  static Future<Map<String, dynamic>?> getDailyLog({
    required DateTime date,
    Duration timeout = _defaultTimeout,
  }) async {
    try {
      final user = _requireAuth();
      
      final dateKey = date.toIso8601String().split('T')[0];
      
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_logs')
          .doc(dateKey)
          .get()
          .timeout(timeout);
      
      if (doc.exists) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }
      return null;
    } catch (e) {
      debugPrint('🔥 FirebaseService: Error getting daily log: $e');
      return null;
    }
  }

  /// Get user's cycles with pagination
  static Future<List<Map<String, dynamic>>> getCycles({
    int limit = 50,
    DocumentSnapshot? startAfter,
    Duration timeout = _defaultTimeout,
  }) async {
    try {
      final user = _requireAuth();
      
      Query query = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cycles')
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final QuerySnapshot snapshot = await query.get().timeout(timeout);
      
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e) {
      debugPrint('🔥 FirebaseService: Error getting cycles: $e');
      throw Exception('Failed to fetch cycles: $e');
    }
  }

  /// Check Firebase connection
  static Future<bool> checkConnection({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final user = _requireAuth();
      
      // Try a simple read operation
      await _firestore
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(timeout);
      
      debugPrint('🔥 FirebaseService: Connection check successful');
      return true;
    } catch (e) {
      debugPrint('🔥 FirebaseService: Connection check failed: $e');
      return false;
    }
  }

  /// Delete a cycle entry with robust error handling
  static Future<void> deleteCycle({
    required String cycleId,
    Duration timeout = _defaultTimeout,
  }) async {
    try {
      final user = _requireAuth();
      
      debugPrint('🔥 FirebaseService: Starting delete for cycle $cycleId');
      debugPrint('🔥 FirebaseService: User: ${user.uid}');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cycles')
          .doc(cycleId)
          .delete()
          .timeout(timeout);

      debugPrint('🔥 FirebaseService: Delete completed successfully');
    } catch (e) {
      debugPrint('🔥 FirebaseService: Error deleting cycle: $e');
      debugPrint('🔥 FirebaseService: Error type: ${e.runtimeType}');
      
      // Re-throw with more context
      if (e is FirebaseException) {
        throw FirebaseException(
          plugin: e.plugin,
          code: e.code,
          message: 'Failed to delete cycle: ${e.message}',
        );
      } else {
        throw Exception('Failed to delete cycle: $e');
      }
    }
  }

  /// Update an existing cycle entry with robust error handling
  static Future<void> updateCycle({
    required String cycleId,
    required DateTime startDate,
    required DateTime endDate,
    Duration timeout = _defaultTimeout,
  }) async {
    try {
      final user = _requireAuth();
      
      debugPrint('🔥 FirebaseService: Starting update for cycle $cycleId');
      debugPrint('🔥 FirebaseService: User: ${user.uid}');
      debugPrint('🔥 FirebaseService: New Start: $startDate, New End: $endDate');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cycles')
          .doc(cycleId)
          .update({
            'start': startDate,
            'end': endDate,
            'updated_at': FieldValue.serverTimestamp(),
          })
          .timeout(timeout);

      debugPrint('🔥 FirebaseService: Update completed successfully');
    } catch (e) {
      debugPrint('🔥 FirebaseService: Error updating cycle: $e');
      debugPrint('🔥 FirebaseService: Error type: ${e.runtimeType}');
      
      // Re-throw with more context
      if (e is FirebaseException) {
        throw FirebaseException(
          plugin: e.plugin,
          code: e.code,
          message: 'Failed to update cycle: ${e.message}',
        );
      } else {
        throw Exception('Failed to update cycle: $e');
      }
    }
  }

  /// Initialize user document if it doesn't exist
  static Future<void> initializeUser() async {
    try {
      final user = _requireAuth();
      
      final userDoc = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();
      
      if (!docSnapshot.exists) {
        await userDoc.set({
          'created_at': FieldValue.serverTimestamp(),
          'email': user.email,
          'uid': user.uid,
        });
        debugPrint('🔥 FirebaseService: User document created');
      }
    } catch (e) {
      debugPrint('🔥 FirebaseService: Error initializing user: $e');
      // Don't throw here - this is optional initialization
    }
  }

  // DAILY LOGGING METHODS


  /// Get daily log entries for a date range
  static Future<List<Map<String, dynamic>>> getDailyLogs({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 30,
    Duration timeout = _defaultTimeout,
  }) async {
    try {
      final user = _requireAuth();
      
      Query query = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_logs')
          .orderBy('date', descending: true)
          .limit(limit);

      if (startDate != null) {
        final startDateString = startDate.toIso8601String().split('T')[0];
        query = query.where('date', isGreaterThanOrEqualTo: startDateString);
      }

      if (endDate != null) {
        final endDateString = endDate.toIso8601String().split('T')[0];
        query = query.where('date', isLessThanOrEqualTo: endDateString);
      }

      final QuerySnapshot snapshot = await query.get().timeout(timeout);
      
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e) {
      debugPrint('🔥 FirebaseService: Error getting daily logs: $e');
      throw Exception('Failed to fetch daily logs: $e');
    }
  }

  /// Get daily log entry for a specific date
  static Future<Map<String, dynamic>?> getDailyLogForDate({
    required DateTime date,
    Duration timeout = _defaultTimeout,
  }) async {
    try {
      final user = _requireAuth();
      
      final dateString = date.toIso8601String().split('T')[0];
      
      final DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_logs')
          .doc(dateString)
          .get()
          .timeout(timeout);

      if (doc.exists) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }
      
      return null;
    } catch (e) {
      debugPrint('🔥 FirebaseService: Error getting daily log for date: $e');
      throw Exception('Failed to fetch daily log: $e');
    }
  }

  /// Delete a daily log entry
  static Future<void> deleteDailyLog({
    required DateTime date,
    Duration timeout = _defaultTimeout,
  }) async {
    try {
      final user = _requireAuth();
      
      final dateString = date.toIso8601String().split('T')[0];
      
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_logs')
          .doc(dateString)
          .delete()
          .timeout(timeout);

      debugPrint('🔥 FirebaseService: Daily log deleted successfully');
    } catch (e) {
      debugPrint('🔥 FirebaseService: Error deleting daily log: $e');
      
      if (e is FirebaseException) {
        throw FirebaseException(
          plugin: e.plugin,
          code: e.code,
          message: 'Failed to delete daily log: ${e.message}',
        );
      } else {
        throw Exception('Failed to delete daily log: $e');
      }
    }
  }
}
