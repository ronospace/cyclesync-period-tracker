import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/enhanced_cycle_logging_screen.dart';
import 'screens/enhanced_cycle_history_screen.dart';
import 'screens/diagnostic_screen.dart';
import 'screens/advanced_analytics_screen.dart'; // 📊 ANALYTICS
import 'screens/settings_screen.dart'; // ⚙️ NEW
import 'screens/data_management_screen.dart';
import 'screens/notification_settings_screen.dart';
import 'screens/smart_notification_settings_screen.dart';
import 'screens/calendar_screen.dart'; // 📅 NEW
import 'screens/symptom_trends_screen.dart'; // 📈 NEW
import 'screens/health_integration_screen.dart'; // 🏥 NEW
import 'screens/social/simple_social_sharing_screen.dart'; // 🤝 NEW
import 'screens/ai_insights_screen.dart'; // 🔮 AI
import 'screens/daily_log_screen.dart'; // 📝 NEW
import 'screens/health_insights_screen.dart'; // 🏥 ENHANCED
import 'screens/export_screen.dart'; // 📤 EXPORT & BACKUP
import 'screens/help_support_screen.dart'; // ❓ HELP & SUPPORT
import 'screens/ai_analytics_dashboard.dart'; // 🧠 AI ANALYTICS
// import 'screens/ai_health_coach_screen.dart'; // 🤖 DISABLED FOR TESTING
import 'screens/settings/language_selector_screen.dart'; // 🌍 LANGUAGE SELECTOR
import 'screens/smart_daily_log_screen.dart'; // 🌸 SMART DAILY LOG
import 'screens/social/social_feed_screen.dart'; // 📱 SOCIAL FEED
import 'screens/social/gamification_screen.dart'; // 🎮 GAMIFICATION
import 'screens/splash_screen.dart'; // 🌟 SPLASH SCREEN
import 'services/auth_state_notifier.dart';

class AppRouter {
  static GoRouter router(BuildContext context) {
    final authState = Provider.of<AuthStateNotifier>(context, listen: false);

    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: authState,
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Page Not Found', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 8),
              Text('Path: ${state.uri.path}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
      redirect: (context, state) {
        final isLoggedIn = authState.isLoggedIn;
        final location = state.uri.toString();

        // Allow splash screen to show without redirect
        if (location == '/splash') {
          return null;
        }

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
          path: '/',
          redirect: (context, state) => '/splash',
        ),
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
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
          path: '/smart-notifications',
          builder: (context, state) => const SmartNotificationSettingsScreen(),
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarScreen(),
        ),
        GoRoute(
          path: '/symptom-trends',
          builder: (context, state) => const SymptomTrendsScreen(),
        ),
        GoRoute(
          path: '/health-integration',
          builder: (context, state) => const HealthIntegrationScreen(),
        ),
        GoRoute(
          path: '/social-sharing',
          builder: (context, state) => const SimpleSocialSharingScreen(),
        ),
        GoRoute(
          path: '/ai-insights',
          builder: (context, state) => const AIInsightsScreen(),
        ),
        GoRoute(
          path: '/daily-log',
          builder: (context, state) => const DailyLogScreen(),
        ),
        GoRoute(
          path: '/health-insights',
          builder: (context, state) => const HealthInsightsScreen(),
        ),
        GoRoute(
          path: '/ai-health-coach',
          builder: (context, state) => Scaffold(
            appBar: AppBar(
              title: const Text('🤖 AI Health Coach'),
              backgroundColor: Colors.indigo.shade50,
              foregroundColor: Colors.indigo.shade700,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.indigo.shade700),
                onPressed: () => context.go('/home'),
              ),
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.smart_toy, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('AI Health Coach', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Coming Soon!', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  SizedBox(height: 16),
                  Text('Your personal AI wellness advisor will be available soon',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/export',
          builder: (context, state) => const ExportScreen(),
        ),
        GoRoute(
          path: '/help-support',
          builder: (context, state) => const HelpSupportScreen(),
        ),
        GoRoute(
          path: '/ai-analytics-dashboard',
          builder: (context, state) => const AIAnalyticsDashboard(),
        ),
        GoRoute(
          path: '/language-selector',
          builder: (context, state) => const LanguageSelectorScreen(),
        ),
        GoRoute(
          path: '/smart-daily-log',
          builder: (context, state) => const SmartDailyLogScreen(),
        ),
        GoRoute(
          path: '/social-feed',
          builder: (context, state) => const SocialFeedScreen(),
        ),
        GoRoute(
          path: '/gamification',
          builder: (context, state) => const GamificationScreen(),
        ),
      ],
    );
  }
}
