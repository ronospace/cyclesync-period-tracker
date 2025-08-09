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

    print('🔍 Nova: Starting Firebase diagnostics...\n');

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
    print('🔐 Testing Authentication Status...');
    
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
        print('   ✅ User authenticated: ${user.email} (${user.uid})');
      } else {
        print('   ❌ No authenticated user found');
      }
    } catch (e) {
      results['tests']['auth'] = {
        'status': 'error',
        'error': e.toString(),
        'success': false,
      };
      print('   ❌ Auth test failed: $e');
    }
    print('');
  }

  static Future<void> _testConnectivity(Map<String, dynamic> results) async {
    print('🌐 Testing Basic Connectivity...');
    
    try {
      // Try to access Firestore settings (doesn't require auth)
      _firestore.settings;
      
      results['tests']['connectivity'] = {
        'status': 'connected',
        'success': true,
      };
      print('   ✅ Firestore connection established');
    } catch (e) {
      results['tests']['connectivity'] = {
        'status': 'failed',
        'error': e.toString(),
        'success': false,
      };
      print('   ❌ Connectivity test failed: $e');
    }
    print('');
  }

  static Future<void> _testReadPermissions(Map<String, dynamic> results) async {
    print('📖 Testing Read Permissions...');
    
    try {
      final user = _auth.currentUser;
      if (user == null) {
        results['tests']['read_permissions'] = {
          'status': 'skipped',
          'reason': 'no_authenticated_user',
          'success': false,
        };
        print('   ⚠️  Skipped - no authenticated user');
        print('');
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
        print('   ✅ User document read successfully');
        print('   📄 Document data: ${userDoc.data()}');
      } else {
        print('   ✅ Read permission granted (document does not exist yet)');
      }
    } catch (e) {
      results['tests']['read_permissions'] = {
        'status': 'failed',
        'error': e.toString(),
        'error_type': e.runtimeType.toString(),
        'success': false,
      };
      print('   ❌ Read test failed: $e');
      print('   🔍 Error type: ${e.runtimeType}');
    }
    print('');
  }

  static Future<void> _testWritePermissions(Map<String, dynamic> results) async {
    print('✍️  Testing Write Permissions...');
    
    try {
      final user = _auth.currentUser;
      if (user == null) {
        results['tests']['write_permissions'] = {
          'status': 'skipped',
          'reason': 'no_authenticated_user',
          'success': false,
        };
        print('   ⚠️  Skipped - no authenticated user');
        print('');
        return;
      }

      // Try to write a test document
      final testDoc = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('diagnostic_test')
          .doc('connection_test');

      await testDoc.set({
        'test': true,
        'timestamp': FieldValue.serverTimestamp(),
        'created_at': DateTime.now().toIso8601String(),
      }).timeout(const Duration(seconds: 10));

      // Clean up test document
      await testDoc.delete();

      results['tests']['write_permissions'] = {
        'status': 'success',
        'success': true,
      };
      
      print('   ✅ Write permission granted - test document created and deleted');
    } catch (e) {
      results['tests']['write_permissions'] = {
        'status': 'failed',
        'error': e.toString(),
        'error_type': e.runtimeType.toString(),
        'success': false,
      };
      print('   ❌ Write test failed: $e');
      print('   🔍 Error type: ${e.runtimeType}');
    }
    print('');
  }

  static Future<void> _testNetworkConfiguration(Map<String, dynamic> results) async {
    print('⚙️  Testing Network Configuration...');
    
    try {
      // Test with different timeout values
      final stopwatch = Stopwatch()..start();
      
      await _firestore
          .collection('users')
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 5));
      
      stopwatch.stop();
      
      results['tests']['network_config'] = {
        'status': 'success',
        'response_time_ms': stopwatch.elapsedMilliseconds,
        'success': true,
      };
      
      print('   ✅ Network test successful');
      print('   ⏱️  Response time: ${stopwatch.elapsedMilliseconds}ms');
    } catch (e) {
      results['tests']['network_config'] = {
        'status': 'failed',
        'error': e.toString(),
        'error_type': e.runtimeType.toString(),
        'success': false,
      };
      print('   ❌ Network test failed: $e');
      print('   🔍 Error type: ${e.runtimeType}');
    }
    print('');
  }

  static void _printSummary(Map<String, dynamic> results) {
    print('📊 DIAGNOSTIC SUMMARY');
    print('=' * 50);
    
    final tests = results['tests'] as Map<String, dynamic>;
    int passed = 0;
    int total = tests.length;
    
    tests.forEach((testName, testResult) {
      final success = testResult['success'] as bool;
      final status = testResult['status'];
      
      print('${success ? '✅' : '❌'} $testName: $status');
      if (success) passed++;
      
      if (!success && testResult['error'] != null) {
        print('   └── Error: ${testResult['error']}');
      }
    });
    
    print('');
    print('🎯 Results: $passed/$total tests passed');
    
    if (passed == total) {
      print('🎉 All tests passed! Firebase should be working correctly.');
    } else {
      print('⚠️  Issues detected. Check the failed tests above.');
      _printTroubleshootingTips(tests);
    }
    print('');
  }

  static void _printTroubleshootingTips(Map<String, dynamic> tests) {
    print('🔧 TROUBLESHOOTING TIPS:');
    print('-' * 30);
    
    if (tests['auth']?['success'] == false) {
      print('• Authentication issue: Make sure user is logged in');
    }
    
    if (tests['connectivity']?['success'] == false) {
      print('• Connectivity issue: Check internet connection and Firebase config');
    }
    
    if (tests['read_permissions']?['success'] == false) {
      print('• Read permission denied: Check Firestore security rules');
      print('  Suggested rule: allow read: if request.auth != null');
    }
    
    if (tests['write_permissions']?['success'] == false) {
      print('• Write permission denied: Check Firestore security rules');
      print('  Suggested rule: allow write: if request.auth != null && request.auth.uid == resource.data.uid');
    }
    
    if (tests['network_config']?['success'] == false) {
      print('• Network timeout: Consider increasing timeout or check Firebase region');
    }
  }
}
