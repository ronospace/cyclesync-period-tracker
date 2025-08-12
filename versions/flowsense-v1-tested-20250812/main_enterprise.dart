import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Enterprise Data Layer
import 'data/repositories/health_data_repository.dart';
import 'data/cache/data_cache_manager.dart';
import 'data/sync/data_sync_manager.dart';
import 'data/providers/data_change_notifier.dart';
import 'services/encryption_service.dart';
import 'services/analytics_engine.dart';
import 'services/advanced_health_kit_service.dart';

// UI Layer
import 'providers/enterprise_data_provider.dart';
import 'providers/cycle_provider.dart';
import 'services/theme_service.dart';
import 'lib/theme/app_theme.dart';
import 'screens/home_screen.dart';

/// Enterprise version of main.dart with full data architecture initialization
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    print('🚀 Starting CycleSync Enterprise initialization...');
    
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized');

    // Initialize Enterprise Data Architecture
    await _initializeEnterpriseDataLayer();
    
    // Run the app
    runApp(const CycleSyncEnterpriseApp());
    
  } catch (e, stackTrace) {
    print('❌ Fatal error during initialization: $e');
    print('Stack trace: $stackTrace');
    
    // Run app with error state
    runApp(MaterialApp(
      title: 'CycleSync - Error',
      home: Scaffold(
        appBar: AppBar(title: const Text('Initialization Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Failed to initialize CycleSync',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

/// Initialize the enterprise data layer components
Future<void> _initializeEnterpriseDataLayer() async {
  print('🏗️ Initializing Enterprise Data Layer...');
  
  // Initialize core services in dependency order
  try {
    // 1. Encryption Service (foundational)
    print('🔐 Initializing encryption service...');
    await EncryptionService.instance.initialize();
    
    // 2. Cache Manager (depends on encryption)
    print('🗂️ Initializing cache manager...');
    await DataCacheManager.instance.initialize();
    
    // 3. Health Kit Service (independent)
    print('🏥 Initializing HealthKit service...');
    await AdvancedHealthKitService.instance.initialize();
    
    // 4. Data Sync Manager (depends on cache and health kit)
    print('🔄 Initializing sync manager...');
    await DataSyncManager.instance.initialize();
    
    // 5. Health Data Repository (depends on all previous)
    print('🏛️ Initializing health data repository...');
    await HealthDataRepository.instance.initialize();
    
    // 6. Analytics Engine (independent but can use cache)
    print('📊 Initializing analytics engine...');
    // Analytics engine is initialized on-demand
    
    print('✅ Enterprise Data Layer initialized successfully');
    
  } catch (e) {
    print('❌ Failed to initialize Enterprise Data Layer: $e');
    rethrow;
  }
}

/// Main app widget with enterprise providers
class CycleSyncEnterpriseApp extends StatelessWidget {
  const CycleSyncEnterpriseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme Provider
        ChangeNotifierProvider(create: (_) => ThemeService.instance),
        
        // Enterprise Data Provider (main data interface)
        ChangeNotifierProvider(create: (_) => EnterpriseDataProvider.instance),
        
        // Legacy provider for backward compatibility
        ChangeNotifierProvider(create: (_) => CycleProvider()),
        
        // Data Change Notifier (for real-time updates)
        Provider<DataChangeNotifier>.value(
          value: DataChangeNotifier.instance,
        ),
        
        // Repository access (for advanced usage)
        Provider<HealthDataRepository>.value(
          value: HealthDataRepository.instance,
        ),
        
        // Analytics Engine access
        Provider<AnalyticsEngine>.value(
          value: AnalyticsEngine.instance,
        ),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'CycleSync Enterprise',
            debugShowCheckedModeBanner: false,
            
            // Dynamic theming
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.themeMode,
            
            // App initialization wrapper
            home: const AppInitializationWrapper(),
            
            // Routes for navigation
            routes: {
              '/home': (context) => const HomeScreen(),
              // Add other routes as needed
            },
          );
        },
      ),
    );
  }
}

/// Wrapper to handle app initialization and loading states
class AppInitializationWrapper extends StatefulWidget {
  const AppInitializationWrapper({super.key});

  @override
  State<AppInitializationWrapper> createState() => _AppInitializationWrapperState();
}

class _AppInitializationWrapperState extends State<AppInitializationWrapper> {
  bool _isInitialized = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Wait for enterprise data provider to initialize
      final dataProvider = context.read<EnterpriseDataProvider>();
      
      // The provider initializes automatically, so we just wait for it
      await Future.delayed(const Duration(seconds: 1));
      
      // Check if there were any initialization errors
      if (dataProvider.error != null) {
        setState(() {
          _initError = dataProvider.error;
        });
        return;
      }
      
      setState(() {
        _isInitialized = true;
      });
      
    } catch (e) {
      setState(() {
        _initError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initError != null) {
      return _buildErrorScreen(_initError!);
    }
    
    if (!_isInitialized) {
      return _buildLoadingScreen();
    }
    
    return const HomeScreen();
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Theme.of(context).primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo or icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Loading indicator
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Loading text
              Text(
                'Initializing CycleSync...',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                'Setting up your personalized health tracking',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 60),
              
              // Feature highlights during loading
              Container(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Column(
                  children: [
                    _buildFeatureItem(
                      context,
                      Icons.security,
                      'Encrypting your data',
                    ),
                    _buildFeatureItem(
                      context,
                      Icons.sync,
                      'Setting up synchronization',
                    ),
                    _buildFeatureItem(
                      context,
                      Icons.analytics,
                      'Preparing analytics engine',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).primaryColor.withOpacity(0.7),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red[400],
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Initialization Error',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'CycleSync encountered an error during startup.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  error,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 32),
              
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isInitialized = false;
                    _initError = null;
                  });
                  _initializeApp();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Debug information widget for development
class DebugInfoWidget extends StatelessWidget {
  const DebugInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EnterpriseDataProvider>(
      builder: (context, dataProvider, child) {
        if (!kDebugMode) return const SizedBox.shrink();
        
        final stats = dataProvider.getRepositoryStats();
        
        return Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enterprise Data Layer Status',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
              Text('Cycles: ${stats.totalCycles}', style: _debugTextStyle),
              Text('Daily Logs: ${stats.totalDailyLogs}', style: _debugTextStyle),
              Text('Cache: ${(stats.cacheSize / 1024).toStringAsFixed(1)}KB', style: _debugTextStyle),
              Text('Online: ${stats.isOnline ? "✅" : "❌"}', style: _debugTextStyle),
              Text('Last Sync: ${stats.lastSyncTime?.toString().split('.')[0] ?? "Never"}', style: _debugTextStyle),
            ],
          ),
        );
      },
    );
  }

  TextStyle get _debugTextStyle => const TextStyle(
    color: Colors.white,
    fontSize: 9,
    fontFamily: 'monospace',
  );
}
