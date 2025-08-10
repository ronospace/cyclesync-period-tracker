import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/enhanced_cycle_logging_screen.dart';
import 'screens/enhanced_cycle_history_screen.dart';
import 'screens/diagnostic_screen.dart';
import 'screens/advanced_analytics_screen.dart'; // 📊 NEW
import 'screens/settings_screen.dart'; // ⚙️ NEW
import 'screens/edit_cycle_screen.dart'; // ✏️ NEW
import 'screens/data_management_screen.dart';
import 'screens/notification_settings_screen.dart';
import 'screens/calendar_screen.dart'; // 📅 NEW
import 'screens/symptom_trends_screen.dart'; // 📈 NEW
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
          path: '/log-cycle',
          builder: (context, state) => const EnhancedCycleLoggingScreen(),
        ),
        GoRoute(
          path: '/cycle-history',
          builder: (context, state) => const EnhancedCycleHistoryScreen(),
        ),
        GoRoute(
          path: '/diagnostics',
          builder: (context, state) => const DiagnosticScreen(),
        ),
        GoRoute(
          path: '/analytics',
          builder: (context, state) => const AdvancedAnalyticsScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/data-management',
          builder: (context, state) => const DataManagementScreen(),
        ),
        GoRoute(
          path: '/notification-settings',
          builder: (context, state) => const NotificationSettingsScreen(),
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarScreen(),
        ),
        GoRoute(
          path: '/symptom-trends',
          builder: (context, state) => const SymptomTrendsScreen(),
        ),
      ],
    );
  }
}
