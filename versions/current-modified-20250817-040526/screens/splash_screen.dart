import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_state_notifier.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' as foundation;
import '../widgets/ai_splash_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Minimum splash screen time for smooth UX
      await Future.wait([
        Future.delayed(const Duration(milliseconds: 2500)),
        _performInitialization(),
      ]);
      
      if (!mounted) return;
      
      setState(() {
        _isInitialized = true;
      });
      
      // Navigate to appropriate screen
      await _navigateToNextScreen();
      
    } catch (error) {
      foundation.debugPrint('Splash screen initialization error: $error');
      // Still navigate even if there's an error
      if (mounted) {
        await _navigateToNextScreen();
      }
    }
  }

  Future<void> _performInitialization() async {
    // Add any actual app initialization logic here
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (!mounted) return;
      
      // Simple navigation - either login or home
      if (mounted) {
        context.go(user == null ? '/login' : '/home');
      }
    } catch (e) {
      foundation.debugPrint('Navigation error: $e');
      if (mounted) {
        context.go('/login');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AISplashWidget(
        duration: const Duration(seconds: 3),
        onComplete: () {
          // Only navigate if widget is still mounted and initialization is complete
          if (mounted && _isInitialized) {
            _navigateToNextScreen();
          }
        },
      ),
    );
  }
}
