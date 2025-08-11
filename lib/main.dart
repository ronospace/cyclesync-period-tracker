import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'router.dart';
import 'services/auth_state_notifier.dart';
import 'services/theme_service.dart';
import 'services/notification_service.dart';
import 'services/smart_notification_service.dart';
import 'services/performance_service.dart';
import 'services/error_service.dart';
import 'services/health_kit_service.dart';
import 'services/localization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize error handling first
  await ErrorService.initialize();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    
    // Initialize performance optimizations
    await PerformanceService.initialize();
    
    // Initialize services
    final themeService = ThemeService();
    await themeService.init();
    
    final localizationService = LocalizationService();
    await localizationService.initialize();
    
    // Initialize HealthKit service (don't await - let it initialize in background)
    final healthKitService = HealthKitService();
    healthKitService.initialize();
    
    // Preload critical data for faster startup
    await PerformanceService.preloadCriticalData();
    
    // Optimize performance for device
    PerformanceService.optimizeForDevice();
    
    // Initialize notifications (don't await - let it initialize in background)
    NotificationService.initialize();
    SmartNotificationService.initialize();
    
    // Start performance monitoring in debug mode
    PerformanceService.startPerformanceMonitoring();
    
    runApp(MyApp(
      themeService: themeService,
      localizationService: localizationService,
      healthKitService: healthKitService,
    ));
  } catch (error, stackTrace) {
    // Log startup error
    ErrorService.logError(
      error,
      stackTrace: stackTrace,
      context: 'App Startup',
      severity: ErrorSeverity.fatal,
    );
    
    // Still try to run the app with minimal functionality
    runApp(const ErrorApp());
  }
}

class MyApp extends StatelessWidget {
  final ThemeService themeService;
  final LocalizationService localizationService;
  final HealthKitService healthKitService;
  
  const MyApp({
    super.key,
    required this.themeService,
    required this.localizationService,
    required this.healthKitService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthStateNotifier()),
        ChangeNotifierProvider.value(value: themeService),
        ChangeNotifierProvider.value(value: localizationService),
        // HealthKitService is a singleton, so we provide the instance
        Provider.value(value: healthKitService),
      ],
      child: Builder(
        builder: (context) {
          final router = AppRouter.router(context);
          final themeService = Provider.of<ThemeService>(context);
          final localizationService = Provider.of<LocalizationService>(context);

          return MaterialApp.router(
            title: 'CycleSync',
            theme: ThemeService.lightTheme,
            darkTheme: ThemeService.darkTheme,
            themeMode: themeService.themeMode,
            locale: localizationService.currentLocale,
            supportedLocales: LocalizationService.supportedLocales,
            routerConfig: router,
            // Add locale resolution delegate
            localeResolutionCallback: (locale, supportedLocales) {
              // Try to find exact match
              for (final supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode &&
                    supportedLocale.countryCode == locale?.countryCode) {
                  return supportedLocale;
                }
              }
              
              // Try to find language match
              for (final supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }
              
              // Return default (English)
              return const Locale('en', 'US');
            },
          );
        },
      ),
    );
  }
}

/// Fallback app shown when startup fails
class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CycleSync - Error',
      theme: ThemeData.light(),
      home: Scaffold(
        backgroundColor: Colors.red.shade50,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red.shade400,
                ),
                const SizedBox(height: 24),
                Text(
                  'Startup Error',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'CycleSync encountered an error during startup. Please restart the app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red.shade600,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    // In a real app, you might restart or show recovery options
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Restart App'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
