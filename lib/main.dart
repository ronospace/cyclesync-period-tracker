import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'router.dart'; // ✅ use AppRouter
import 'services/auth_state_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthStateNotifier(),
      child: Builder(
        builder: (context) {
          final router = AppRouter.router(context);

          return MaterialApp.router(
            title: 'CycleSync',
            theme: ThemeData(primarySwatch: Colors.pink),
            routerConfig: router,
          );
        },
      ),
    );
  }
}
