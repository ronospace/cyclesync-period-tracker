import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/cycle_logging_screen.dart'; // ✅ NEW
import 'services/auth_state_notifier.dart';

class AppRouter {
  static GoRouter router(BuildContext context) {
    final authState = Provider.of<AuthStateNotifier>(context, listen: false);

    return GoRouter(
      initialLocation: '/login',
      refreshListenable: authState,
      redirect: (context, state) {
        final isLoggedIn = authState.isLoggedIn;
        final location = state.uri.toString();

        final loggingIn = location == '/login' || location == '/signup';

        if (!isLoggedIn) {
          return loggingIn ? null : '/login';
        }

        if (isLoggedIn && loggingIn) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/log-cycle', // ✅ NEW ROUTE
          builder: (context, state) => const CycleLoggingScreen(),
        ),
      ],
    );
  }
}
