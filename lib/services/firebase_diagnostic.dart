import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseDiagnostic {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Comprehensive Firebase connection and configuration test
  static Future<Map<String, dynamic>> runDiagnostics() async {
    final results = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'tests': <String, dynamic>{},
    };

    debugPrint('🔍 Nova: Starting Firebase diagnostics...\n');

    // Test 1: Auth Status
    await _testAuthStatus(results);

    // Test 2: Basic Connectivity
    await _testConnectivity(results);

    // Test 3: Read Permissions
    await _testReadPermissions(results);

    // Test 4: Write Permissions
    await _testWritePermissions(results);

    // Test 5: Network Configuration
    await _testNetworkConfiguration(results);

    _printSummary(results);
    return results;
  }

  static Future<void> _testAuthStatus(Map<String, dynamic> results) async {
    debugPrint('🔐 Testing Authentication Status...');

    try {
      final user = _auth.currentUser;
      results['tests']['auth'] = {
        'status': user != null ? 'authenticated' : 'not_authenticated',
        'uid': user?.uid,
        'email': user?.email,
        'displayName': user?.displayName,
        'emailVerified': user?.emailVerified,
        'isAnonymous': user?.isAnonymous,
        'success': true,
      };

      if (user != null) {
        debugPrint('   ✅ User authenticated: ${user.email} (${user.uid})');
      } else {
        debugPrint('   ❌ No authenticated user found');
      }
    } catch (e) {
      results['tests']['auth'] = {
        'status': 'error',
        'error': e.toString(),
        'success': false,
      };
      debugPrint('   ❌ Auth test failed: $e');
    }
    debugPrint('');
  }

  static Future<void> _testConnectivity(Map<String, dynamic> results) async {
    debugPrint('🌐 Testing Basic Connectivity...');

    try {
      // Try to access Firestore settings (doesn't require auth)
      _firestore.settings;

      results['tests']['connectivity'] = {
        'status': 'connected',
        'success': true,
      };
      debugPrint('   ✅ Firestore connection established');
    } catch (e) {
      results['tests']['connectivity'] = {
        'status': 'failed',
        'error': e.toString(),
        'success': false,
      };
      debugPrint('   ❌ Connectivity test failed: $e');
    }
    debugPrint('');
  }

  static Future<void> _testReadPermissions(Map<String, dynamic> results) async {
    debugPrint('📖 Testing Read Permissions...');

    try {
      final user = _auth.currentUser;
      if (user == null) {
        results['tests']['read_permissions'] = {
          'status': 'skipped',
          'reason': 'no_authenticated_user',
          'success': false,
        };
        debugPrint('   ⚠️  Skipped - no authenticated user');
        debugPrint('');
        return;
      }

      // Try to read user document (should always be allowed for authenticated users)
      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 10));

      results['tests']['read_permissions'] = {
        'status': 'success',
        'document_exists': userDoc.exists,
        'data': userDoc.data(),
        'success': true,
      };

      if (userDoc.exists) {
        debugPrint('   ✅ User document read successfully');
        debugPrint('   📄 Document data: ${userDoc.data()}');
      } else {
        debugPrint(
          '   ✅ Read permission granted (document does not exist yet)',
        );
      }
    } catch (e) {
      results['tests']['read_permissions'] = {
        'status': 'failed',
        'error': e.toString(),
        'error_type': e.runtimeType.toString(),
        'success': false,
      };
      debugPrint('   ❌ Read test failed: $e');
      debugPrint('   🔍 Error type: ${e.runtimeType}');
    }
    debugPrint('');
  }

  static Future<void> _testWritePermissions(
    Map<String, dynamic> results,
  ) async {
    debugPrint('✍️  Testing Write Permissions...');

    try {
      final user = _auth.currentUser;
      if (user == null) {
        results['tests']['write_permissions'] = {
          'status': 'skipped',
          'reason': 'no_authenticated_user',
          'success': false,
        };
        debugPrint('   ⚠️  Skipped - no authenticated user');
        debugPrint('');
        return;
      }

      // Try to write a test document
      final testDoc = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('diagnostic_test')
          .doc('connection_test');

      await testDoc
          .set({
            'test': true,
            'timestamp': FieldValue.serverTimestamp(),
            'created_at': DateTime.now().toIso8601String(),
          })
          .timeout(const Duration(seconds: 10));

      // Clean up test document
      await testDoc.delete();

      results['tests']['write_permissions'] = {
        'status': 'success',
        'success': true,
      };

      debugPrint(
        '   ✅ Write permission granted - test document created and deleted',
      );
    } catch (e) {
      results['tests']['write_permissions'] = {
        'status': 'failed',
        'error': e.toString(),
        'error_type': e.runtimeType.toString(),
        'success': false,
      };
      debugPrint('   ❌ Write test failed: $e');
      debugPrint('   🔍 Error type: ${e.runtimeType}');
    }
    debugPrint('');
  }

  static Future<void> _testNetworkConfiguration(
    Map<String, dynamic> results,
  ) async {
    debugPrint('⚙️  Testing Network Configuration...');

    try {
      final user = _auth.currentUser;
      if (user == null) {
        results['tests']['network_config'] = {
          'status': 'skipped',
          'reason': 'no_authenticated_user',
          'success': false,
        };
        debugPrint('   ⚠️  Skipped - no authenticated user');
        debugPrint('');
        return;
      }

      // Test network configuration by reading user's own document
      final stopwatch = Stopwatch()..start();

      await _firestore
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 5));

      stopwatch.stop();

      results['tests']['network_config'] = {
        'status': 'success',
        'response_time_ms': stopwatch.elapsedMilliseconds,
        'success': true,
      };

      debugPrint('   ✅ Network test successful');
      debugPrint('   ⏱️  Response time: ${stopwatch.elapsedMilliseconds}ms');
    } catch (e) {
      results['tests']['network_config'] = {
        'status': 'failed',
        'error': e.toString(),
        'error_type': e.runtimeType.toString(),
        'success': false,
      };
      debugPrint('   ❌ Network test failed: $e');
      debugPrint('   🔍 Error type: ${e.runtimeType}');
    }
    debugPrint('');
  }

  static void _printSummary(Map<String, dynamic> results) {
    debugPrint('📊 DIAGNOSTIC SUMMARY');
    debugPrint('=' * 50);

    final tests = results['tests'] as Map<String, dynamic>;
    int passed = 0;
    int total = tests.length;

    tests.forEach((testName, testResult) {
      final success = testResult['success'] as bool;
      final status = testResult['status'];

      debugPrint('${success ? '✅' : '❌'} $testName: $status');
      if (success) passed++;

      if (!success && testResult['error'] != null) {
        debugPrint('   └── Error: ${testResult['error']}');
      }
    });

    debugPrint('');
    debugPrint('🎯 Results: $passed/$total tests passed');

    if (passed == total) {
      debugPrint('🎉 All tests passed! Firebase should be working correctly.');
    } else {
      debugPrint('⚠️  Issues detected. Check the failed tests above.');
      _printTroubleshootingTips(tests);
    }
    debugPrint('');
  }

  static void _printTroubleshootingTips(Map<String, dynamic> tests) {
    debugPrint('🔧 TROUBLESHOOTING TIPS:');
    debugPrint('-' * 30);

    if (tests['auth']?['success'] == false) {
      debugPrint('• Authentication issue: Make sure user is logged in');
    }

    if (tests['connectivity']?['success'] == false) {
      debugPrint(
        '• Connectivity issue: Check internet connection and Firebase config',
      );
    }

    if (tests['read_permissions']?['success'] == false) {
      debugPrint('• Read permission denied: Check Firestore security rules');
      debugPrint('  Suggested rule: allow read: if request.auth != null');
    }

    if (tests['write_permissions']?['success'] == false) {
      debugPrint('• Write permission denied: Check Firestore security rules');
      debugPrint(
        '  Suggested rule: allow write: if request.auth != null && request.auth.uid == resource.data.uid',
      );
    }

    if (tests['network_config']?['success'] == false) {
      debugPrint(
        '• Network timeout: Consider increasing timeout or check Firebase region',
      );
    }
  }
}
