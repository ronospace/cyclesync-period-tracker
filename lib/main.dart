import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'router.dart'; // ✅ use AppRouter
import 'services/auth_state_notifier.dart';
import 'services/theme_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Initialize services
  final themeService = ThemeService();
  await themeService.init();
  
  // Initialize notifications (don't await - let it initialize in background)
  NotificationService.initialize();
  
  runApp(MyApp(themeService: themeService));
}

class MyApp extends StatelessWidget {
  final ThemeService themeService;
  
  const MyApp({super.key, required this.themeService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthStateNotifier()),
        ChangeNotifierProvider.value(value: themeService),
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
            routerConfig: router,
          );
        },
      ),
    );
  }
}
