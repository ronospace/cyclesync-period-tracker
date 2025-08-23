import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/health_service.dart';
import '../models/cycle_models.dart';

class HealthIntegrationTile extends StatefulWidget {
  final bool showDetails;
  final EdgeInsetsGeometry? margin;

  const HealthIntegrationTile({
    super.key,
    this.showDetails = false,
    this.margin,
  });

  @override
  State<HealthIntegrationTile> createState() => _HealthIntegrationTileState();
}

class _HealthIntegrationTileState extends State<HealthIntegrationTile> {
  HealthIntegrationStatus? _status;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkHealthStatus();
  }

  Future<void> _checkHealthStatus() async {
    if (!mounted) return;

    try {
      final status = await HealthService.getIntegrationStatus();
      if (mounted) {
        setState(() {
          _status = status;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = HealthIntegrationStatus(
            isSupported: false,
            hasPermissions: false,
            message: 'Error: ${e.toString()}',
            canSync: false,
          );
          _isLoading = false;
        });
      }
    }
  }

  Color _getStatusColor() {
    if (_status == null) return Colors.grey;

    if (_status!.canSync) return Colors.green;
    if (_status!.isSupported) return Colors.orange;
    return Colors.red;
  }

  IconData _getStatusIcon() {
    if (_status == null) return Icons.health_and_safety_outlined;

    if (_status!.canSync) return Icons.health_and_safety;
    if (_status!.isSupported) return Icons.health_and_safety_outlined;
    return Icons.error_outline;
  }

  String _getStatusTitle() {
    if (_status == null) return 'Health Integration';

    if (_status!.canSync) return 'Health Integration Active';
    if (_status!.isSupported) return 'Health Setup Required';
    return 'Health Not Available';
  }

  String _getStatusSubtitle() {
    if (_status == null) return 'Checking status...';

    if (_status!.canSync) return 'Syncing with health platforms';
    if (_status!.isSupported) return 'Tap to set up health sync';
    return _status!.message;
  }

  Widget _buildStatusBadge() {
    if (_isLoading) {
      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      );
    }

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: _getStatusColor(),
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = Card(
      margin: widget.margin,
      elevation: 1,
      child: ListTile(
        leading: Stack(
          children: [
            Icon(_getStatusIcon(), color: _getStatusColor(), size: 28),
            Positioned(right: 0, top: 0, child: _buildStatusBadge()),
          ],
        ),
        title: Text(
          _getStatusTitle(),
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getStatusSubtitle()),
            if (widget.showDetails && _status != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    _status!.isSupported ? Icons.check_circle : Icons.cancel,
                    size: 14,
                    color: _status!.isSupported ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _status!.isSupported ? 'Supported' : 'Not Supported',
                    style: TextStyle(
                      fontSize: 12,
                      color: _status!.isSupported ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    _status!.hasPermissions ? Icons.check_circle : Icons.cancel,
                    size: 14,
                    color: _status!.hasPermissions
                        ? Colors.green
                        : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _status!.hasPermissions ? 'Authorized' : 'No Permission',
                    style: TextStyle(
                      fontSize: 12,
                      color: _status!.hasPermissions
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_status?.canSync == true)
              Icon(Icons.sync, color: Colors.green, size: 16)
            else if (_status?.isSupported == true)
              Icon(Icons.warning, color: Colors.orange, size: 16),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
        onTap: () {
          context.push('/health-integration');
        },
      ),
    );

    if (_isLoading) {
      return Stack(
        children: [
          card,
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return card;
  }
}

class HealthQuickSyncWidget extends StatefulWidget {
  const HealthQuickSyncWidget({super.key});

  @override
  State<HealthQuickSyncWidget> createState() => _HealthQuickSyncWidgetState();
}

class _HealthQuickSyncWidgetState extends State<HealthQuickSyncWidget> {
  bool _isSyncing = false;

  Future<void> _quickSync() async {
    if (_isSyncing) return;

    setState(() => _isSyncing = true);

    try {
      final status = await HealthService.getIntegrationStatus();

      if (!status.canSync) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '⚠️ Health integration not set up. ${status.message}',
            ),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Setup',
              onPressed: () => context.push('/health-integration'),
            ),
          ),
        );
        return;
      }

      // Perform a quick sync of the latest cycle
      final result = await HealthService.bulkSyncToHealth();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.success ? '✅ ${result.summary}' : '❌ ${result.summary}',
          ),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Sync failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.health_and_safety, color: Colors.purple, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Health Sync',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _isSyncing ? null : _quickSync,
                  icon: _isSyncing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync, size: 16),
                  label: Text(_isSyncing ? 'Syncing...' : 'Sync Now'),
                  style: TextButton.styleFrom(foregroundColor: Colors.purple),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Keep your health data in sync across all your apps',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
