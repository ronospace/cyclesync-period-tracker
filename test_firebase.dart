import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';
import 'lib/services/firebase_diagnostic.dart';

void main() async {
  print('🔍 Nova: Starting Firebase diagnostics from console...\n');
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully\n');
    
    // Run diagnostics
    final results = await FirebaseDiagnostic.runDiagnostics();
    
    print('\n${'='*60}');
    print('🎯 FINAL DIAGNOSTIC REPORT');
    print('='*60);
    
    final tests = results['tests'] as Map<String, dynamic>;
    final passed = tests.values.where((test) => test['success'] == true).length;
    final total = tests.length;
    
    if (passed == total) {
      print('🎉 SUCCESS: All $total tests passed!');
      print('🚀 Your Firebase configuration is working perfectly.');
    } else {
      print('⚠️  ISSUES DETECTED: $passed/$total tests passed');
      print('🔧 Check the detailed logs above for troubleshooting steps.');
      
      // Print failed tests summary
      print('\n📋 Failed Tests:');
      tests.forEach((testName, testResult) {
        if (testResult['success'] != true) {
          print('   ❌ $testName: ${testResult['status']}');
          if (testResult['error'] != null) {
            print('      └── ${testResult['error']}');
          }
        }
      });
    }
    
  } catch (e) {
    print('❌ Failed to initialize Firebase or run diagnostics: $e');
  }
}
