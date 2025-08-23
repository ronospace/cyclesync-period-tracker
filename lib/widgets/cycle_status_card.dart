import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/cycle_models.dart';

class CycleStatusCard extends StatelessWidget {
  final CycleData? cycle;
  final CyclePrediction? predictions;
  final VoidCallback? onTap;

  const CycleStatusCard({super.key, this.cycle, this.predictions, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (cycle == null) {
      return _buildNoCycleCard(context);
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: _getCyclePhaseGradient(context),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildPhaseInfo(context),
              const SizedBox(height: 16),
              _buildProgressBar(context),
              if (predictions != null) ...[
                const SizedBox(height: 16),
                _buildPredictionInfo(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoCycleCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor.withAlpha(30),
                Theme.of(context).primaryColor.withAlpha(10),
              ],
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Start Tracking',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Log your first cycle to begin tracking',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final phase = _getCurrentPhase();
    final phaseIcon = _getPhaseIcon(phase);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(80),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(phaseIcon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                phase,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Cycle #${_getCycleNumber()}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withAlpha(200),
                ),
              ),
            ],
          ),
        ),
        _buildDayCounter(context),
      ],
    );
  }

  Widget _buildDayCounter(BuildContext context) {
    final currentDay = _getCurrentCycleDay();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(80),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'Day',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withAlpha(200),
              fontSize: 10,
            ),
          ),
          Text(
            '$currentDay',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseInfo(BuildContext context) {
    final description = _getPhaseDescription();
    final nextEvent = _getNextEvent();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(80),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (nextEvent != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.event, size: 16, color: Colors.white.withAlpha(180)),
                const SizedBox(width: 4),
                Text(
                  nextEvent,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withAlpha(180),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final progress = _getCycleProgress();
    final estimatedLength = cycle!.lengthInDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cycle Progress',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withAlpha(200),
              ),
            ),
            Text(
              '${(progress * 100).toInt()}% • ~$estimatedLength days',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withAlpha(200),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white.withAlpha(60),
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildPredictionInfo(BuildContext context) {
    if (predictions == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(60),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(80)),
      ),
      child: Row(
        children: [
          Icon(Icons.psychology, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Prediction',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withAlpha(180),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _getPredictionText(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(80),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${(predictions!.confidence * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getCyclePhaseGradient(BuildContext context) {
    final phase = _getCurrentPhase();

    switch (phase.toLowerCase()) {
      case 'menstrual':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE53E3E), Color(0xFFFC8181)],
        );
      case 'follicular':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF38B2AC), Color(0xFF4FD1C7)],
        );
      case 'ovulation':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD53F8C), Color(0xFFED64A6)],
        );
      case 'luteal':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF805AD5), Color(0xFF9F7AEA)],
        );
      default:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withAlpha(200),
          ],
        );
    }
  }

  IconData _getPhaseIcon(String phase) {
    switch (phase.toLowerCase()) {
      case 'menstrual':
        return Icons.water_drop;
      case 'follicular':
        return Icons.eco;
      case 'ovulation':
        return Icons.favorite;
      case 'luteal':
        return Icons.nightlight_round;
      default:
        return Icons.circle;
    }
  }

  String _getCurrentPhase() {
    if (cycle == null) return 'Unknown';

    final dayInCycle = _getCurrentCycleDay();
    final cycleLength = cycle!.lengthInDays;

    if (cycle!.endDate == null || DateTime.now().isBefore(cycle!.endDate!)) {
      return 'Menstrual';
    }

    // Post-period phases based on typical 28-day cycle ratios
    final follicularEnd = (cycleLength * 0.45).round(); // ~Day 13
    final ovulationEnd = (cycleLength * 0.55).round(); // ~Day 15

    if (dayInCycle <= follicularEnd) {
      return 'Follicular';
    } else if (dayInCycle <= ovulationEnd) {
      return 'Ovulation';
    } else {
      return 'Luteal';
    }
  }

  String _getPhaseDescription() {
    final phase = _getCurrentPhase();

    switch (phase.toLowerCase()) {
      case 'menstrual':
        return 'Your period is active. Stay hydrated and rest well.';
      case 'follicular':
        return 'Post-period recovery. Energy levels are building.';
      case 'ovulation':
        return 'Peak fertility window. Perfect time for conception.';
      case 'luteal':
        return 'Pre-period phase. You might experience PMS symptoms.';
      default:
        return 'Tracking your cycle for insights.';
    }
  }

  String? _getNextEvent() {
    if (cycle == null || predictions == null) return null;

    final phase = _getCurrentPhase();

    switch (phase.toLowerCase()) {
      case 'menstrual':
        if (cycle!.endDate != null) {
          final daysLeft = cycle!.endDate!.difference(DateTime.now()).inDays;
          return daysLeft > 0 ? 'Period ends in ~$daysLeft days' : null;
        }
        return null;
      case 'follicular':
        return 'Ovulation expected in ~${_daysUntilOvulation()} days';
      case 'ovulation':
        return 'Fertile window active';
      case 'luteal':
        final nextPeriod = predictions!.predictedStartDate;
        final daysUntil = nextPeriod.difference(DateTime.now()).inDays;
        return 'Next period in ~$daysUntil days';
      default:
        return null;
    }
  }

  int _getCurrentCycleDay() {
    if (cycle == null) return 0;
    return DateTime.now().difference(cycle!.startDate).inDays + 1;
  }

  double _getCycleProgress() {
    if (cycle == null) return 0.0;

    final dayInCycle = _getCurrentCycleDay();
    final estimatedLength = cycle!.lengthInDays;

    return (dayInCycle / estimatedLength).clamp(0.0, 1.0);
  }

  int _daysUntilOvulation() {
    if (cycle == null) return 0;

    final cycleLength = cycle!.lengthInDays;
    final ovulationDay = (cycleLength * 0.5).round(); // Mid-cycle
    final currentDay = _getCurrentCycleDay();

    return (ovulationDay - currentDay).clamp(0, cycleLength);
  }

  String _getPredictionText() {
    if (predictions == null) return 'No predictions available';

    // Use predictedStartDate instead of nextPeriodDate since CyclePrediction doesn't have nextPeriodDate
    final nextPeriod = predictions!.predictedStartDate;
    final daysUntil = nextPeriod.difference(DateTime.now()).inDays;
    if (daysUntil <= 0) {
      return 'Period expected now';
    } else if (daysUntil <= 3) {
      return 'Period expected in $daysUntil days';
    } else {
      return 'Next period: ${DateFormat('MMM d').format(nextPeriod)}';
    }
  }

  int _getCycleNumber() {
    // Generate a simple cycle number based on the cycle start date
    // This is a placeholder - in a real app you might store this in the database
    if (cycle == null) return 1;
    final daysSinceEpoch = cycle!.startDate
        .difference(DateTime(2024, 1, 1))
        .inDays;
    return (daysSinceEpoch / 28).floor() + 1; // Assume 28-day cycles
  }
}
