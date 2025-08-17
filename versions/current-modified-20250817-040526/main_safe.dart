import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'router.dart';
import 'services/auth_state_notifier.dart';
import 'services/theme_service.dart';
import 'services/error_service.dart';
import 'services/localization_service.dart';
import 'services/app_branding_service.dart';
import 'l10n/generated/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize error handling first
  await ErrorService.initialize();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    
    // Initialize only essential services
    final themeService = ThemeService();
    await themeService.init();
    
    final localizationService = LocalizationService();
    await localizationService.initialize();
    
    final appBrandingService = AppBrandingService();
    await appBrandingService.initialize();
    
    runApp(SafeMyApp(
      themeService: themeService,
      localizationService: localizationService,
      appBrandingService: appBrandingService,
    ));
  } catch (error, stackTrace) {
    // Log startup error
    ErrorService.logError(
      error,
      stackTrace: stackTrace,
      context: 'App Startup',
      severity: ErrorSeverity.fatal,
    );
    
    // Run minimal error app
    runApp(const MinimalErrorApp());
  }
}

class SafeMyApp extends StatelessWidget {
  final ThemeService themeService;
  final LocalizationService localizationService;
  final AppBrandingService appBrandingService;
  
  const SafeMyApp({
    super.key,
    required this.themeService,
    required this.localizationService,
    required this.appBrandingService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthStateNotifier()),
        ChangeNotifierProvider.value(value: themeService),
        ChangeNotifierProvider.value(value: localizationService),
        ChangeNotifierProvider.value(value: appBrandingService),
      ],
      child: Builder(
        builder: (context) {
          final router = AppRouter.router(context);
          final themeService = Provider.of<ThemeService>(context);

          return MaterialApp.router(
            title: 'CycleSync',
            theme: ThemeService.lightTheme,
            darkTheme: ThemeService.darkTheme,
            themeMode: themeService.themeMode,
            locale: const Locale('en', 'US'),
            
            supportedLocales: const [
              Locale('en'), // English only for safety
            ],
            
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            
            routerConfig: router,
            
            localeResolutionCallback: (locale, supportedLocales) {
              return const Locale('en', 'US');
            },
          );
        },
      ),
    );
  }
}

class MinimalErrorApp extends StatelessWidget {
  const MinimalErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CycleSync - Safe Mode',
      theme: ThemeData.light(),
      home: Scaffold(
        backgroundColor: Colors.orange.shade50,
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning,
                  size: 80,
                  color: Colors.orange,
                ),
                SizedBox(height: 24),
                Text(
                  'Safe Mode',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'CycleSync is running in safe mode with minimal features.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
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
