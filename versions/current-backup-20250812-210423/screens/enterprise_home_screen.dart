/// Enterprise Home Screen with Real-time Data Integration
/// 
/// This is the main dashboard that showcases the Enterprise Data Architecture
/// with real-time updates, advanced analytics, and healthcare-compliant features.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// Enterprise Data Layer
import '../providers/enterprise_data_provider.dart';
import '../models/cycle_models.dart';
import '../services/analytics_engine.dart';
import '../config/analytics_config.dart';

// UI Components
import '../widgets/cycle_status_card.dart';
import '../widgets/prediction_card.dart';
import '../widgets/health_metrics_card.dart';
import '../widgets/loading_shimmer.dart';

class EnterpriseHomeScreen extends StatefulWidget {
  const EnterpriseHomeScreen({super.key});

  @override
  State<EnterpriseHomeScreen> createState() => _EnterpriseHomeScreenState();
}

class _EnterpriseHomeScreenState extends State<EnterpriseHomeScreen> 
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _logScreenView();
    
    // Initialize enterprise data if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dataProvider = context.read<EnterpriseDataProvider>();
      if (!dataProvider.isInitialized) {
        dataProvider.initialize();
      }
    });
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  void _logScreenView() {
    AnalyticsConfig.logEngagementEvent(
      screen: 'enterprise_home',
      timeSpent: Duration.zero,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Consumer<EnterpriseDataProvider>(
        builder: (context, dataProvider, child) {
          return RefreshIndicator(
            onRefresh: () => dataProvider.refreshData(),
            color: Theme.of(context).primaryColor,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildContent(context, dataProvider),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, EnterpriseDataProvider dataProvider) {
    if (dataProvider.isLoading && !dataProvider.hasData) {
      return _buildLoadingState();
    }

    if (dataProvider.hasError && !dataProvider.hasData) {
      return _buildErrorState(dataProvider);
    }

    return CustomScrollView(
      slivers: [
        _buildAppBar(context, dataProvider),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildWelcomeSection(context, dataProvider),
                const SizedBox(height: 24),
                _buildCycleStatusCard(context, dataProvider),
                const SizedBox(height: 16),
                _buildQuickActions(context),
                const SizedBox(height: 16),
                _buildPredictionsSection(context, dataProvider),
                const SizedBox(height: 16),
                _buildHealthInsightsSection(context, dataProvider),
                const SizedBox(height: 16),
                _buildRecentActivitySection(context, dataProvider),
                const SizedBox(height: 100), // Bottom padding for FAB
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, EnterpriseDataProvider dataProvider) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor.withAlpha(240),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Row(
          children: [
            Icon(
              Icons.favorite,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'CycleSync',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withAlpha(200),
              ],
            ),
          ),
        ),
      ),
      actions: [
        // Sync Status Indicator
        IconButton(
          icon: _buildSyncStatusIcon(dataProvider),
          onPressed: () => dataProvider.forceSync(),
          tooltip: 'Sync Status: ${dataProvider.syncStatus}',
        ),
        // Settings
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () => context.push('/settings'),
        ),
      ],
    );
  }

  Widget _buildSyncStatusIcon(EnterpriseDataProvider dataProvider) {
    switch (dataProvider.syncStatus) {
      case SyncStatus.syncing:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      case SyncStatus.synced:
        return const Icon(Icons.cloud_done, color: Colors.white);
      case SyncStatus.error:
        return const Icon(Icons.cloud_off, color: Colors.red);
      default:
        return const Icon(Icons.cloud, color: Colors.white);
    }
  }

  Widget _buildWelcomeSection(BuildContext context, EnterpriseDataProvider dataProvider) {
    final now = DateTime.now();
    final greeting = _getTimeBasedGreeting();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('EEEE, MMMM d, y').format(now),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
              ),
            ),
            if (dataProvider.totalCycles > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${dataProvider.totalCycles} cycles tracked',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning! 🌅';
    if (hour < 17) return 'Good afternoon! ☀️';
    return 'Good evening! 🌙';
  }

  Widget _buildCycleStatusCard(BuildContext context, EnterpriseDataProvider dataProvider) {
    final currentCycle = dataProvider.currentCycle;
    
    return CycleStatusCard(
      cycle: currentCycle,
      predictions: dataProvider.predictions,
      onTap: () => context.push('/cycle-analytics'),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _ActionItem(
        icon: Icons.add_circle,
        label: 'Log Period',
        color: Colors.red.shade400,
        onTap: () => context.push('/cycle-logging'),
      ),
      _ActionItem(
        icon: Icons.calendar_today,
        label: 'Calendar',
        color: Colors.blue.shade400,
        onTap: () => context.push('/calendar'),
      ),
      _ActionItem(
        icon: Icons.analytics,
        label: 'Analytics',
        color: Colors.green.shade400,
        onTap: () => context.push('/analytics'),
      ),
      _ActionItem(
        icon: Icons.health_and_safety,
        label: 'Health',
        color: Colors.purple.shade400,
        onTap: () => context.push('/health-insights'),
      ),
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: actions.map((action) => Expanded(
                child: _buildActionButton(context, action),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, _ActionItem action) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: action.color.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                action.icon,
                color: action.color,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                action.label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: action.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPredictionsSection(BuildContext context, EnterpriseDataProvider dataProvider) {
    final predictions = dataProvider.predictions;
    
    if (predictions == null) {
      return const SizedBox.shrink();
    }

    return PredictionCard(
      predictions: predictions,
      onViewDetails: () => context.push('/predictions'),
    );
  }

  Widget _buildHealthInsightsSection(BuildContext context, EnterpriseDataProvider dataProvider) {
    final analytics = dataProvider.analytics;
    
    if (analytics == null) return const SizedBox.shrink();

    return HealthMetricsCard(
      analytics: analytics,
      onViewDetails: () => context.push('/health-insights'),
    );
  }

  Widget _buildRecentActivitySection(BuildContext context, EnterpriseDataProvider dataProvider) {
    final recentCycles = dataProvider.recentCycles.take(3).toList();
    
    if (recentCycles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/cycle-history'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recentCycles.map((cycle) => _buildActivityItem(context, cycle)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, CycleData cycle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.water_drop,
              color: Theme.of(context).primaryColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cycle ${cycle.cycleNumber}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  DateFormat('MMM d, y').format(cycle.startDate),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${cycle.lengthInDays} days',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const LoadingShimmer(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _ShimmerCard(height: 100),
            SizedBox(height: 16),
            _ShimmerCard(height: 150),
            SizedBox(height: 16),
            _ShimmerCard(height: 200),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(EnterpriseDataProvider dataProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              dataProvider.errorMessage ?? 'Unknown error occurred',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => dataProvider.refreshData(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper classes
class _ActionItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _ShimmerCard extends StatelessWidget {
  final double height;
  
  const _ShimmerCard({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
