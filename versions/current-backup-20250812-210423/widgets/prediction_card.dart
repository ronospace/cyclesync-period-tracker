import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ai_models.dart';

class PredictionCard extends StatelessWidget {
  final CyclePrediction predictions;
  final VoidCallback? onViewDetails;

  const PredictionCard({
    super.key,
    required this.predictions,
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
              _buildPredictionsList(context),
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
            color: Colors.purple.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.psychology,
            color: Colors.purple.shade400,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Predictions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Based on your cycle patterns',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                ),
              ),
            ],
          ),
        ),
        _buildConfidenceBadge(context),
      ],
    );
  }

  Widget _buildConfidenceBadge(BuildContext context) {
    final confidence = (predictions.confidence * 100).toInt();
    final color = _getConfidenceColor(confidence);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(
        '$confidence%',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPredictionsList(BuildContext context) {
    final items = <Widget>[];

    // Next period prediction
    if (predictions.nextPeriodDate != null) {
      items.add(_buildPredictionItem(
        context,
        icon: Icons.water_drop,
        iconColor: Colors.red.shade400,
        title: 'Next Period',
        subtitle: _formatNextPeriod(predictions.nextPeriodDate!),
        detail: _getPeriodDetail(predictions.nextPeriodDate!),
      ));
    }

    // Fertility window prediction
    if (predictions.fertilityWindowStart != null && 
        predictions.fertilityWindowEnd != null) {
      items.add(_buildPredictionItem(
        context,
        icon: Icons.favorite,
        iconColor: Colors.pink.shade400,
        title: 'Fertile Window',
        subtitle: _formatFertilityWindow(
          predictions.fertilityWindowStart!,
          predictions.fertilityWindowEnd!,
        ),
        detail: _getFertilityDetail(),
      ));
    }

    // Ovulation prediction
    if (predictions.ovulationDate != null) {
      items.add(_buildPredictionItem(
        context,
        icon: Icons.circle,
        iconColor: Colors.purple.shade400,
        title: 'Ovulation',
        subtitle: DateFormat('EEEE, MMM d').format(predictions.ovulationDate!),
        detail: _getOvulationDetail(predictions.ovulationDate!),
      ));
    }

    if (items.isEmpty) {
      return _buildNoPredictionsMessage(context);
    }

    return Column(
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: item,
      )).toList(),
    );
  }

  Widget _buildPredictionItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? detail,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(60),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(20),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (detail != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPredictionsMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withAlpha(60),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            Icons.timeline,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Building Predictions',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Log more cycles to get AI-powered predictions',
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
          Icons.info_outline,
          size: 14,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(120),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Predictions improve with more cycle data',
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

  Color _getConfidenceColor(int confidence) {
    if (confidence >= 80) return Colors.green;
    if (confidence >= 60) return Colors.orange;
    return Colors.red;
  }

  String _formatNextPeriod(DateTime date) {
    final now = DateTime.now();
    final daysUntil = date.difference(now).inDays;
    
    if (daysUntil <= 0) {
      return 'Expected now';
    } else if (daysUntil == 1) {
      return 'Tomorrow';
    } else if (daysUntil <= 7) {
      return 'In $daysUntil days';
    } else {
      return DateFormat('EEEE, MMM d').format(date);
    }
  }

  String _getPeriodDetail(DateTime date) {
    final now = DateTime.now();
    final daysUntil = date.difference(now).inDays;
    
    if (daysUntil <= 3) {
      return 'Prepare with period supplies';
    } else if (daysUntil <= 7) {
      return 'Plan ahead for your cycle';
    } else {
      return 'Based on your cycle patterns';
    }
  }

  String _formatFertilityWindow(DateTime start, DateTime end) {
    final now = DateTime.now();
    
    if (now.isAfter(start) && now.isBefore(end)) {
      return 'Active now';
    } else if (start.isAfter(now)) {
      final daysUntil = start.difference(now).inDays;
      if (daysUntil == 1) {
        return 'Starts tomorrow';
      } else {
        return 'Starts in $daysUntil days';
      }
    } else {
      return 'Recently ended';
    }
  }

  String _getFertilityDetail() {
    return 'Best time for conception';
  }

  String _getOvulationDetail(DateTime date) {
    final now = DateTime.now();
    final daysUntil = date.difference(now).inDays;
    
    if (daysUntil == 0) {
      return 'Peak fertility today';
    } else if (daysUntil == 1) {
      return 'Peak fertility tomorrow';
    } else if (daysUntil > 0) {
      return 'In $daysUntil days';
    } else {
      return 'Recently occurred';
    }
  }
}
