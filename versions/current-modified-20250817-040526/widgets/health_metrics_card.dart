import 'package:flutter/material.dart';
import '../models/cycle_models.dart';

class HealthMetricsCard extends StatelessWidget {
  final CycleAnalytics analytics;
  final VoidCallback? onViewDetails;

  const HealthMetricsCard({
    super.key,
    required this.analytics,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onViewDetails,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildMetricsGrid(context),
              const SizedBox(height: 12),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.health_and_safety,
            color: Colors.green.shade600,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Health Metrics',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Today\'s wellness indicators',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                ),
              ),
            ],
          ),
        ),
        _buildHealthScore(context),
      ],
    );
  }

  Widget _buildHealthScore(BuildContext context) {
    final score = _calculateHealthScore();
    final color = _getScoreColor(score);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '$score',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context) {
    final metricItems = <Widget>[];

    // Cycle length metric
    metricItems.add(_buildMetricItem(
      context,
      icon: Icons.timeline,
      iconColor: Colors.blue.shade400,
      title: 'Avg Cycle Length',
      value: '${analytics.averageCycleLength.toStringAsFixed(1)} days',
      trend: MetricTrend.stable,
    ));

    // Regularity score
    metricItems.add(_buildMetricItem(
      context,
      icon: Icons.track_changes,
      iconColor: Colors.green.shade400,
      title: 'Regularity',
      value: '${analytics.regularityScore.toStringAsFixed(0)}%',
      trend: _getRegularityTrend(),
    ));

    // Mood average from wellbeing
    final avgMood = analytics.wellbeingAverages['mood'];
    if (avgMood != null) {
      metricItems.add(_buildMetricItem(
        context,
        icon: Icons.mood,
        iconColor: Colors.purple.shade400,
        title: 'Avg Mood',
        value: _getMoodText(avgMood),
        trend: null,
      ));
    }

    // Energy average from wellbeing
    final avgEnergy = analytics.wellbeingAverages['energy'];
    if (avgEnergy != null) {
      metricItems.add(_buildMetricItem(
        context,
        icon: Icons.battery_charging_full,
        iconColor: Colors.orange.shade400,
        title: 'Avg Energy',
        value: _getEnergyLevelText(avgEnergy),
        trend: null,
      ));
    }

    if (metricItems.isEmpty) {
      return _buildNoMetricsMessage(context);
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: metricItems.take(4).toList(), // Show max 4 items in grid
    );
  }

  Widget _buildMetricItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    MetricTrend? trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(60),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trend != null) _buildTrendIcon(context, trend),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendIcon(BuildContext context, MetricTrend trend) {
    IconData icon;
    Color color;

    switch (trend) {
      case MetricTrend.up:
        icon = Icons.trending_up;
        color = Colors.green;
        break;
      case MetricTrend.down:
        icon = Icons.trending_down;
        color = Colors.red;
        break;
      case MetricTrend.stable:
        icon = Icons.trending_flat;
        color = Colors.grey;
        break;
    }

    return Icon(
      icon,
      color: color,
      size: 16,
    );
  }

  Widget _buildNoMetricsMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(60),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            Icons.health_and_safety_outlined,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'No Health Data',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Start logging symptoms to track your wellness',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.update,
          size: 14,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(120),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Based on ${analytics.cycles.length} cycles',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(120),
              fontSize: 11,
            ),
          ),
        ),
        if (onViewDetails != null)
          TextButton(
            onPressed: onViewDetails,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size.zero,
            ),
            child: Text(
              'View All',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  // Helper methods
  int _calculateHealthScore() {
    int score = 0;
    int factors = 0;

    // Calculate based on regularity score
    final regularity = analytics.regularityScore;
    if (regularity > 0) {
      score += (regularity / 5).round(); // Convert 0-100 to 0-20 scale
      factors++;
    }

    // Calculate based on average mood
    final avgMood = analytics.wellbeingAverages['mood'];
    if (avgMood != null) {
      score += (avgMood * 4).round(); // Convert 1-5 to 4-20 scale
      factors++;
    }

    // Calculate based on average energy
    final avgEnergy = analytics.wellbeingAverages['energy'];
    if (avgEnergy != null) {
      score += (avgEnergy * 4).round(); // Convert 1-5 to 4-20 scale
      factors++;
    }

    return factors > 0 ? (score / factors).round() : 0;
  }

  Color _getScoreColor(int score) {
    if (score >= 16) return Colors.green;
    if (score >= 12) return Colors.orange;
    return Colors.red;
  }

  MetricTrend? _getTemperatureTrend() {
    // This would normally compare with historical data
    // For now, return a mock trend
    return MetricTrend.stable;
  }

  MetricTrend? _getHeartRateTrend() {
    // This would normally compare with historical data
    // For now, return a mock trend
    return MetricTrend.down;
  }

  MetricTrend? _getWeightTrend() {
    // This would normally compare with historical data
    // For now, return a mock trend
    return MetricTrend.stable;
  }
  
  MetricTrend? _getRegularityTrend() {
    // Calculate regularity trend based on score
    final regularity = analytics.regularityScore;
    if (regularity >= 80) {
      return MetricTrend.up;
    } else if (regularity <= 60) {
      return MetricTrend.down;
    }
    return MetricTrend.stable;
  }

  String _getSleepQualityText(double quality) {
    if (quality >= 4.0) return 'Excellent';
    if (quality >= 3.0) return 'Good';
    if (quality >= 2.0) return 'Fair';
    return 'Poor';
  }

  String _getEnergyLevelText(double energy) {
    if (energy >= 4.0) return 'High';
    if (energy >= 3.0) return 'Good';
    if (energy >= 2.0) return 'Moderate';
    return 'Low';
  }

  String _getMoodText(double mood) {
    if (mood >= 4.0) return 'Great';
    if (mood >= 3.0) return 'Good';
    if (mood >= 2.0) return 'Okay';
    return 'Low';
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

enum MetricTrend { up, down, stable }
