import 'package:flutter/material.dart';
import '../../models/partner_models.dart';
import '../../services/partner_sharing_service.dart';

class PartnerMonitorScreen extends StatelessWidget {
  final PartnerRelationship relationship;
  const PartnerMonitorScreen({super.key, required this.relationship});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Monitor ${relationship.displayName}')),
      body: StreamBuilder<List<SharedDataEntry>>(
        stream: PartnerSharingService.instance.getSharedData(relationship.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final entries = snapshot.data ?? [];
          if (entries.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSummaryCards(context, entries),
              const SizedBox(height: 12),
              _buildPermissionNotice(context),
              const SizedBox(height: 12),
              ...entries.map((e) => _SharedEntryTile(entry: e)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.health_and_safety,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          const Text('No shared health updates yet'),
          const SizedBox(height: 8),
          const Text(
            'You\'ll see your partner\'s shared cycle and health updates here.',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    List<SharedDataEntry> entries,
  ) {
    // Simple aggregations
    final totalEntries = entries.length;
    final symptoms = entries
        .where((e) => e.dataType == SharedDataType.symptoms)
        .length;
    final moods = entries
        .where(
          (e) =>
              e.dataType == SharedDataType.mood ||
              e.dataType == SharedDataType.moods,
        )
        .length;
    final predictions = entries
        .where((e) => e.dataType == SharedDataType.predictions)
        .length;

    return Row(
      children: [
        _SummaryCard(
          label: 'Updates',
          value: '$totalEntries',
          icon: Icons.update,
        ),
        const SizedBox(width: 8),
        _SummaryCard(
          label: 'Symptoms',
          value: '$symptoms',
          icon: Icons.healing,
        ),
        const SizedBox(width: 8),
        _SummaryCard(label: 'Mood', value: '$moods', icon: Icons.mood),
        const SizedBox(width: 8),
        _SummaryCard(
          label: 'Predictions',
          value: '$predictions',
          icon: Icons.insights,
        ),
      ],
    );
  }

  Widget _buildPermissionNotice(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Permissions: ${relationship.sharingPermissions.keys.map((e) => e.name).join(', ')}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

class _SharedEntryTile extends StatelessWidget {
  final SharedDataEntry entry;
  const _SharedEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(child: Icon(_iconFor(entry.dataType))),
        title: Text(_titleFor(entry)),
        subtitle: Text(_subtitleFor(entry)),
        trailing: Text(_timeAgo(entry.timestamp)),
      ),
    );
  }

  String _titleFor(SharedDataEntry e) {
    switch (e.dataType) {
      case SharedDataType.cycleStart:
        return 'Cycle started';
      case SharedDataType.symptoms:
        return 'Symptoms update';
      case SharedDataType.mood:
      case SharedDataType.moods:
        return 'Mood update';
      case SharedDataType.predictions:
        return 'Prediction update';
      default:
        return e.dataType.name;
    }
  }

  String _subtitleFor(SharedDataEntry e) {
    final map = e.data;
    if (map.containsKey('summary')) return map['summary'].toString();
    if (map.containsKey('value')) return map['value'].toString();
    return 'Tap to view details';
  }

  IconData _iconFor(SharedDataType t) {
    switch (t) {
      case SharedDataType.cycleStart:
        return Icons.calendar_month;
      case SharedDataType.symptoms:
        return Icons.healing;
      case SharedDataType.mood:
      case SharedDataType.moods:
        return Icons.mood;
      case SharedDataType.predictions:
        return Icons.insights;
      default:
        return Icons.health_and_safety;
    }
  }

  String _timeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inDays > 0) return '${d.inDays}d ago';
    if (d.inHours > 0) return '${d.inHours}h ago';
    if (d.inMinutes > 0) return '${d.inMinutes}m ago';
    return 'now';
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
